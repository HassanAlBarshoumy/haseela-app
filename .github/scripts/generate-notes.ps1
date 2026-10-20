<#
.SYNOPSIS
  يولّد ملاحظات الإصدار ثنائية اللغة (عربي أولاً) ونسخة سجل التغييرات
  المضمّنة (resources/changelog.json) لمشروع حصيلة.

.DESCRIPTION
  يعمل قبل بناء Nuitka في workflow العام:

  1. يحدّد الإصدار السابق من قائمة Releases في المستودع العام (مع استبعاد
     الـ Tag الجاري بناؤه).
  2. يحوّل رقم الإصدار السابق إلى التزام رفع APP_VERSION في المصدر عبر
     `git log -S "<ver>" -- gui_constants.py` (الخاص لا يحمل Tags).
  3. يصنّف التزامات النطاق إلى أقسام ثنائية اللغة مع علامات
     `<!-- lang:ar -->` و `<!-- lang:en -->`، ويستبعد chore/test/style/ci/build
     و«bump version». إن وُجد ملف تجاوز docs/releases/<tag>.md استُخدم حرفياً.
  4. يكتب notes.md ثم resources/changelog.json (السجل الكامل + الإصدار الجاري).

  بلا Tag (workflow_dispatch) يولّد `changelog.json` فقط ويترك notes.md.

.EXAMPLE
  ./generate-notes.ps1 -RepoFullName HassanAlBarshoumy/haseela-app `
      -SourcePath src -CurrentTag v1.4.1 -OutFile notes.md
#>
#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$RepoFullName = "HassanAlBarshoumy/haseela-app",
    [string]$SourcePath = "src",
    [string]$CurrentTag = "",
    [string]$OutFile = "notes.md",
    [string]$ChangelogOut = "src/resources/changelog.json"
)

$ErrorActionPreference = "Stop"

$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Write-NotesFile {
    param([string]$Path, [string]$Text)
    $dir = Split-Path -Parent $Path
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -ItemType Directory -Force $dir | Out-Null
    }
    [System.IO.File]::WriteAllText($Path, $Text, $Utf8NoBom)
}

function Write-ErrorAndExit {
    param([string]$Message)
    Write-Host "::error::$Message"
    exit 1
}

function Get-CurrentTag {
    param([string]$Explicit)
    if ($Explicit) { return $Explicit }
    if ($env:GITHUB_REF_NAME) { return $env:GITHUB_REF_NAME }
    return ""
}

function Get-PreviousStableRelease {
    param([string]$Repo, [string]$CurrentTag)
    $raw = gh release list --repo $Repo --limit 50 --json tagName,publishedAt,isDraft 2>$null
    if (-not $raw) { return $null }
    $all = $raw | ConvertFrom-Json
    foreach ($rel in $all) {
        if ($rel.isDraft) { continue }
        if ($rel.tagName -eq $CurrentTag) { continue }
        if ($rel.tagName -match '^v[0-9]+\.[0-9]+\.[0-9]+$') { return $rel }
    }
    return $null
}

function Get-CommitSection {
    param([string]$Subject)
    $s = $Subject.Trim()
    # الالتزامات التي لا تعني المستخدم النهائي تُستبعد كلياً.
    if ($s -match '(?i)^(?<type>[a-z]+)(\((?<scope>[^)]+)\))?!?:') {
        $type = $Matches['type'].ToLower()
        $scope = ""
        if ($Matches['scope']) { $scope = $Matches['scope'].ToLower() }
        if ($type -in @('chore', 'test', 'style', 'ci', 'build')) { return 'skip' }
        # التزام رفع الإصدار لا يضيف معلومة للقارئ.
        if ($s -match '(?i)bump(ing)?\s+version|version\s+bump') { return 'skip' }
        if ($type -eq 'security' -or ($scope -match 'security')) { return 'security' }
        switch ($type) {
            'feat' { return 'features' }
            'fix' { return 'fixes' }
            'perf' { return 'performance' }
            'docs' { return 'docs' }
            default { return 'other' }
        }
    }
    if ($s -match '(?i)bump(ing)?\s+version|version\s+bump') { return 'skip' }
    return 'other'
}

function New-BilingualBody {
    param(
        [hashtable]$Groups,
        [string]$RangeLabelAr,
        [string]$RangeLabelEn,
        [string]$CompareUrl
    )
    # ترتيب الأقسام المعروض بعد النصّين.
    $order = @(
        @{ key = 'features';    ar = '## ميزات جديدة';        en = '## New features' },
        @{ key = 'fixes';       ar = '## إصلاحات';            en = '## Fixes' },
        @{ key = 'security';    ar = '## الأمان والخصوصية';   en = '## Security & privacy' },
        @{ key = 'performance'; ar = '## تحسينات الأداء';     en = '## Performance' },
        @{ key = 'docs';        ar = '## توثيق';              en = '## Documentation' },
        @{ key = 'other';       ar = '## أخرى';               en = '## Other' }
    )

    $arLines = @("<!-- lang:ar -->", "> $RangeLabelAr")
    foreach ($section in $order) {
        $items = $Groups[$section.key]
        if ($items -and $items.Count) {
            $arLines += ""
            $arLines += $section.ar
            $arLines += $items
        }
    }
    $arLines += ""
    $arLines += "المقارنة مع الإصدار السابق: $CompareUrl"

    $enLines = @("<!-- lang:en -->", "> $RangeLabelEn")
    foreach ($section in $order) {
        $items = $Groups[$section.key]
        if ($items -and $items.Count) {
            $enLines += ""
            $enLines += $section.en
            $enLines += $items
        }
    }
    $enLines += ""
    $enLines += "Compare with the previous release: $CompareUrl"

    return (($arLines + "" + $enLines) -join "`n")
}

function Write-ChangelogSnapshot {
    param(
        [string]$Repo,
        [string]$CurrentTag,
        [string]$NotesBody,
        [string]$Path
    )
    $raw = gh api "repos/$Repo/releases?per_page=100" 2>$null
    if (-not $raw) { $raw = "[]" }
    $raw = $raw.Trim()

    if ($CurrentTag -and $NotesBody) {
        # الإصدار الجاري لم يُنشر بعد وقت البناء: نضيفه فيصبح السجل المضمَّن
        # محدّثاً بالكامل حتى آخر إصدار. إن كان منشوراً بالفعل (إعادة بناء
        # إصدار قائم) نستبعده من الاستجابة الخام أولاً كي لا يتكرر.
        $parsed = $raw | ConvertFrom-Json
        $kept = @($parsed | Where-Object { $_.tag_name -ne $CurrentTag })
        if ($kept.Count -eq 1) {
            $raw = "[" + ($kept[0] | ConvertTo-Json -Depth 6) + "]"
        }
        elseif ($kept.Count -eq 0) {
            $raw = "[]"
        }
        else {
            $raw = ($kept | ConvertTo-Json -Depth 6)
        }

        $published = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        $current = [pscustomobject]@{
            tag_name     = $CurrentTag
            name         = "Haseela $CurrentTag"
            body         = $NotesBody
            published_at = $published
            html_url     = "https://github.com/$Repo/releases/tag/$CurrentTag"
            draft        = $false
            prerelease   = $false
        }
        $currentJson = ($current | ConvertTo-Json -Depth 4 -Compress)
        $rest = $raw -replace '^\s*\[', '' -replace '\]\s*$', ''
        if ([string]::IsNullOrWhiteSpace($rest)) {
            $combined = "[$currentJson]"
        }
        else {
            $combined = "[$currentJson,$rest]"
        }
    }
    else {
        $combined = $raw
    }

    # التحقق من صحة JSON قبل الكتابة كي لا يُحزم ملف تالف.
    try {
        $null = $combined | ConvertFrom-Json
    }
    catch {
        Write-ErrorAndExit "Generated changelog is not valid JSON: $($_.Exception.Message)"
    }

    Write-NotesFile -Path $Path -Text $combined
    Write-Host "Wrote changelog snapshot to $Path"
}

# --------------------------------------------------------------------------- #
# التنفيذ
# --------------------------------------------------------------------------- #

$tag = Get-CurrentTag -Explicit $CurrentTag
$isRelease = $tag -match '^v[0-9]+\.[0-9]+\.[0-9]+$'

$notesBody = ""
if ($isRelease) {
    # ملف تجاوز يدوي إن وُجد يُستخدم حرفياً.
    $overridePath = Join-Path $SourcePath "docs/releases/$tag.md"
    if (Test-Path $overridePath) {
        $notesBody = [System.IO.File]::ReadAllText((Resolve-Path $overridePath))
        if ([string]::IsNullOrWhiteSpace($notesBody)) {
            Write-ErrorAndExit "Override file $overridePath is empty; refusing to publish blank notes."
        }
        Write-Host "Using manual override notes: $overridePath"
    }
    else {
        $prevRel = Get-PreviousStableRelease -Repo $RepoFullName -CurrentTag $tag
        if ($null -eq $prevRel) {
            Write-ErrorAndExit "Could not determine the previous stable release for $tag."
        }
        $prevVer = $prevRel.tagName -replace '^v', ''

        $prevShaLine = git -C $SourcePath log --reverse -S $prevVer --oneline -- gui_constants.py 2>$null | Select-Object -First 1
        if (-not $prevShaLine) {
            Write-ErrorAndExit "No source commit bumps APP_VERSION to $prevVer in gui_constants.py; aborting to avoid a wrong commit range."
        }
        $prevSha = ($prevShaLine -split ' ')[0]
        $range = "$prevSha..HEAD"

        $log = @(git -C $SourcePath log --no-merges --format='%s' $range 2>$null)
        if ($log.Count -eq 0) {
            Write-ErrorAndExit "No commits found in range '$range' for $tag."
        }

        $groups = @{
            features = @(); fixes = @(); security = @()
            performance = @(); docs = @(); other = @()
        }
        foreach ($subj in $log) {
            $section = Get-CommitSection -Subject $subj
            if ($section -eq 'skip') { continue }
            $groups[$section] += $subj
        }

        $compareUrl = "https://github.com/$RepoFullName/compare/$($prevRel.tagName)...$tag"
        $rangeLabelAr = "التغييرات منذ الإصدار $($prevRel.tagName) (التزام المصدر $prevSha)"
        $rangeLabelEn = "Changes since release $($prevRel.tagName) (source commit $prevSha)"

        $notesBody = New-BilingualBody -Groups $groups `
            -RangeLabelAr $rangeLabelAr -RangeLabelEn $rangeLabelEn -CompareUrl $compareUrl

        Write-NotesFile -Path $OutFile -Text $notesBody
        Write-Host "Wrote release notes to $OutFile"
    }
}
else {
    Write-Host "No release tag supplied (got '$tag'); skipping notes and writing the changelog snapshot only."
}

Write-ChangelogSnapshot -Repo $RepoFullName -CurrentTag $tag -NotesBody $notesBody -Path $ChangelogOut
