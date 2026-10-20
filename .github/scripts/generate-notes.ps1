<#
.SYNOPSIS
  يولّد ملاحظات �
�لإصدار ثنائية اللغة (عرب
ي أولاً) ونسخة سجل التغيي
رات
  المضمّنة (resources/changelo
g.json) لمشروع حصيلة.

.DESCRIPTIO
N
  يعمل قبل بناء Nuitka في work
flow العام:

  1. يحدّد الإصد�
�ر السابق من قائمة Releases ف�
� المستودع العام (مع استب�
�اد
     الـ Tag الجاري بناؤه
).
  2. يحوّل رقم الإصدار ال
سابق إلى التزام رفع APP_VERSI
ON في المصدر عبر
     `git log -S 
"<ver>" -- gui_constants.py` (الخاص لا
 يحمل Tags).
  3. يصنّف التزام
ات النطاق إلى أقسام ثنائ�
�ة اللغة مع علامات
     `<!-- l
ang:ar -->` و `<!-- lang:en -->`، ويست�
�عد chore/test/style/ci/build
     و«bump
 version». إن وُجد ملف تجاوز d
ocs/releases/<tag>.md استُخدم حرفي
اً.
  4. يكتب notes.md ثم resources/c
hangelog.json (السجل الكامل + ال
إصدار الجاري).

  بلا Tag (work
flow_dispatch) يولّد `changelog.json` ف
قط ويترك notes.md.

.EXAMPLE
  ./gener
ate-notes.ps1 -RepoFullName HassanAlBarshoumy
/haseela-app `
      -SourcePath src -Current
Tag v1.4.1 -OutFile notes.md
#>
#Requires -Ve
rsion 5.1
[CmdletBinding()]
param(
    [strin
g]$RepoFullName = "HassanAlBarshoumy/haseela-
app",
    [string]$SourcePath = "src",
    [s
tring]$CurrentTag = "",
    [string]$OutFile 
= "notes.md",
    [string]$ChangelogOut = "sr
c/resources/changelog.json"
)

$ErrorActionPr
eference = "Stop"

$Utf8NoBom = New-Object Sy
stem.Text.UTF8Encoding($false)

function Writ
e-NotesFile {
    param([string]$Path, [strin
g]$Text)
    $dir = Split-Path -Parent $Path

    if ($dir -and -not (Test-Path $dir)) {
  
      New-Item -ItemType Directory -Force $di
r | Out-Null
    }
    [System.IO.File]::Writ
eAllText($Path, $Text, $Utf8NoBom)
}

functio
n Write-ErrorAndExit {
    param([string]$Mes
sage)
    Write-Host "::error::$Message"
    
exit 1
}

function Get-CurrentTag {
    param
([string]$Explicit)
    if ($Explicit) { retu
rn $Explicit }
    if ($env:GITHUB_REF_NAME) 
{ return $env:GITHUB_REF_NAME }
    return ""

}

function Get-PreviousStableRelease {
    
param([string]$Repo, [string]$CurrentTag)
   
 $raw = gh release list --repo $Repo --limit 
50 --json tagName,publishedAt,isDraft 2>$null

    if (-not $raw) { return $null }
    $all
 = $raw | ConvertFrom-Json
    foreach ($rel 
in $all) {
        if ($rel.isDraft) { contin
ue }
        if ($rel.tagName -eq $CurrentTag
) { continue }
        if ($rel.tagName -matc
h '^v[0-9]+\.[0-9]+\.[0-9]+$') { return $rel 
}
    }
    return $null
}

function Get-Comm
itSection {
    param([string]$Subject)
    $
s = $Subject.Trim()
    # الالتزاما�
� التي لا تعني المستخدم ا�
�نهائي تُستبعد كلياً.
    if
 ($s -match '(?i)^(?<type>[a-z]+)(\((?<scope>
[^)]+)\))?!?:') {
        $type = $Matches['t
ype'].ToLower()
        $scope = ""
        i
f ($Matches['scope']) { $scope = $Matches['sc
ope'].ToLower() }
        if ($type -in @('ch
ore', 'test', 'style', 'ci', 'build')) { retu
rn 'skip' }
        # التزام رفع ا�
�إصدار لا يضيف معلومة للق
ارئ.
        if ($s -match '(?i)bump(ing)?
\s+version|version\s+bump') { return 'skip' }

        if ($type -eq 'security' -or ($scope
 -match 'security')) { return 'security' }
  
      switch ($type) {
            'feat' { r
eturn 'features' }
            'fix' { return
 'fixes' }
            'perf' { return 'perfo
rmance' }
            'docs' { return 'docs' 
}
            default { return 'other' }
    
    }
    }
    if ($s -match '(?i)bump(ing)?
\s+version|version\s+bump') { return 'skip' }

    return 'other'
}

function New-Bilingual
Body {
    param(
        [hashtable]$Groups,

        [string]$RangeLabelAr,
        [stri
ng]$RangeLabelEn,
        [string]$CompareUrl

    )
    # ترتيب الأقسام الم
عروض بعد النصّين.
    $order = 
@(
        @{ key = 'features';    ar = '## �
�يزات جديدة';        en = '## New fe
atures' },
        @{ key = 'fixes';       ar
 = '## إصلاحات';            en = '## F
ixes' },
        @{ key = 'security';    ar =
 '## الأمان والخصوصية';   en =
 '## Security & privacy' },
        @{ key = 
'performance'; ar = '## تحسينات الأ
داء';     en = '## Performance' },
       
 @{ key = 'docs';        ar = '## توثيق'
;              en = '## Documentation' },
   
     @{ key = 'other';       ar = '## أخر�
�';               en = '## Other' }
    )

  
  $arLines = @("<!-- lang:ar -->", "> $RangeL
abelAr")
    foreach ($section in $order) {
 
       $items = $Groups[$section.key]
       
 if ($items -and $items.Count) {
            
$arLines += ""
            $arLines += $secti
on.ar
            $arLines += $items
        
}
    }
    $arLines += ""
    $arLines += "�
�لمقارنة مع الإصدار السا�
�ق: $CompareUrl"

    $enLines = @("<!-- lan
g:en -->", "> $RangeLabelEn")
    foreach ($s
ection in $order) {
        $items = $Groups[
$section.key]
        if ($items -and $items.
Count) {
            $enLines += ""
         
   $enLines += $section.en
            $enLin
es += $items
        }
    }
    $enLines += 
""
    $enLines += "Compare with the previous
 release: $CompareUrl"

    return (($arLines
 + "" + $enLines) -join "`n")
}

function Wri
te-ChangelogSnapshot {
    param(
        [st
ring]$Repo,
        [string]$CurrentTag,
    
    [string]$NotesBody,
        [string]$Path

    )
    $raw = gh api "repos/$Repo/release
s?per_page=100" 2>$null
    if (-not $raw) { 
$raw = "[]" }
    $raw = $raw.Trim()

    if 
($CurrentTag -and $NotesBody) {
        # ا�
�إصدار الجاري لم يُنشر بع
د وقت البناء: نضيفه فيصبح
 السجل المضمَّن
        # محد
ّثاً بالكامل حتى آخر إصد�
�ر. إن كان منشوراً بالفعل 
(إعادة بناء
        # إصدار ق�
�ئم) نستبعده من الاستجابة
 الخام أولاً كي لا يتكرر.

        $parsed = $raw | ConvertFrom-Json
   
     $kept = @($parsed | Where-Object { $_.ta
g_name -ne $CurrentTag })
        if ($kept.C
ount -eq 1) {
            $raw = "[" + ($kept
[0] | ConvertTo-Json -Depth 6) + "]"
        
}
        elseif ($kept.Count -eq 0) {
      
      $raw = "[]"
        }
        else {
  
          $raw = ($kept | ConvertTo-Json -Dep
th 6)
        }

        $published = (Get-Da
te).ToUniversalTime().ToString("yyyy-MM-ddTHH
:mm:ssZ")
        $current = [pscustomobject]
@{
            tag_name     = $CurrentTag
   
         name         = "Haseela $CurrentTag"

            body         = $NotesBody
      
      published_at = $published
            h
tml_url     = "https://github.com/$Repo/relea
ses/tag/$CurrentTag"
            draft       
 = $false
            prerelease   = $false
 
       }
        $currentJson = ($current | C
onvertTo-Json -Depth 4 -Compress)
        $re
st = $raw -replace '^\s*\[', '' -replace '\]\
s*$', ''
        if ([string]::IsNullOrWhiteS
pace($rest)) {
            $combined = "[$cur
rentJson]"
        }
        else {
         
   $combined = "[$currentJson,$rest]"
       
 }
        $repoRootNotes = Join-Path (Get-Location) "notes.md"
        [System.IO.File]::WriteAllText($repoRootNotes, $notesBody, [System.Text.UTF8Encoding]($false))
        Write-Host "Wrote release notes to $repoRootNotes"
        $changelogOut = [System.IO.Path]::GetFullPath($ChangelogOut)
        $chlogDir = Split-Path -Parent $changelogOut
        if (-not (Test-Path $chlogDir)) { New-Item -ItemType Directory -Force -Path $chlogDir | Out-Null }
        Write-ChangelogSnapshot -SourcePath $SourcePath -CurrentTag $tag -OutFile $changelogOut
        exit 0
    }
    else {
        $combined = $raw

    }

    # التحقق من صحة JSON ق
بل الكتابة كي لا يُحزم مل
ف تالف.
    try {
        $null = $combi
ned | ConvertFrom-Json
    }
    catch {
    
    Write-ErrorAndExit "Generated changelog i
s not valid JSON: $($_.Exception.Message)"
  
  }

    Write-NotesFile -Path $Path -Text $c
ombined
    Write-Host "Wrote changelog snaps
hot to $Path"
}

# --------------------------
---------------------------------------------
---- #
# التنفيذ
# -------------------
---------------------------------------------
----------- #

$tag = Get-CurrentTag -Explici
t $CurrentTag
$isRelease = $tag -match '^v[0-
9]+\.[0-9]+\.[0-9]+$'

$notesBody = ""
if ($i
sRelease) {
    # ملف تجاوز يدوي 
إن وُجد يُستخدم حرفياً.
  
  $overridePath = Join-Path $SourcePath "docs
/releases/$tag.md"
    if (Test-Path $overrid
ePath) {
        $notesBody = [System.IO.File
]::ReadAllText((Resolve-Path $overridePath))

        if ([string]::IsNullOrWhiteSpace($not
esBody)) {
            Write-ErrorAndExit "Ov
erride file $overridePath is empty; refusing 
to publish blank notes."
        }
        Wr
ite-Host "Using manual override notes: $overr
idePath"
        $repoRootNotes = Join-Path (Get-Location) "notes.md"
        [System.IO.File]::WriteAllText($repoRootNotes, $notesBody, [System.Text.UTF8Encoding]($false))
        Write-Host "Wrote release notes to $repoRootNotes"
        $changelogOut = [System.IO.Path]::GetFullPath($ChangelogOut)
        $chlogDir = Split-Path -Parent $changelogOut
        if (-not (Test-Path $chlogDir)) { New-Item -ItemType Directory -Force -Path $chlogDir | Out-Null }
        Write-ChangelogSnapshot -SourcePath $SourcePath -CurrentTag $tag -OutFile $changelogOut
        exit 0
    }
    else {
        $prevRel = 
Get-PreviousStableRelease -Repo $RepoFullName
 -CurrentTag $tag
        if ($null -eq $prev
Rel) {
            Write-ErrorAndExit "Could 
not determine the previous stable release for
 $tag."
        }
        $prevVer = $prevRel
.tagName -replace '^v', ''

        $prevShaL
ine = git -C $SourcePath log --reverse -S $pr
evVer --oneline -- gui_constants.py 2>$null |
 Select-Object -First 1
        if (-not $pre
vShaLine) {
            Write-ErrorAndExit "N
o source commit bumps APP_VERSION to $prevVer
 in gui_constants.py; aborting to avoid a wro
ng commit range."
        }
        $prevSha 
= ($prevShaLine -split ' ')[0]
        $range
 = "$prevSha..HEAD"

        $log = @(git -C 
$SourcePath log --no-merges --format='%s' $ra
nge 2>$null)
        if ($log.Count -eq 0) {

            Write-ErrorAndExit "No commits fo
und in range '$range' for $tag."
        }

 
       $groups = @{
            features = @(
); fixes = @(); security = @()
            pe
rformance = @(); docs = @(); other = @()
    
    }
        foreach ($subj in $log) {
     
       $section = Get-CommitSection -Subject 
$subj
            if ($section -eq 'skip') { 
continue }
            $groups[$section] += $
subj
        }

        $compareUrl = "https:
//github.com/$RepoFullName/compare/$($prevRel
.tagName)...$tag"
        $rangeLabelAr = "ا
لتغييرات منذ الإصدار $($pre
vRel.tagName) (التزام المصدر $pre
vSha)"
        $rangeLabelEn = "Changes since
 release $($prevRel.tagName) (source commit $
prevSha)"

        $notesBody = New-Bilingual
Body -Groups $groups `
            -RangeLabe
lAr $rangeLabelAr -RangeLabelEn $rangeLabelEn
 -CompareUrl $compareUrl

        Write-Notes
File -Path $OutFile -Text $notesBody
        
Write-Host "Wrote release notes to $OutFile"

    }
}
else {
    Write-Host "No release tag
 supplied (got '$tag'); skipping notes and wr
iting the changelog snapshot only."
}

Write-
ChangelogSnapshot -Repo $RepoFullName -Curren
tTag $tag -NotesBody $notesBody -Path $Change
logOut


