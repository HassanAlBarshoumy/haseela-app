<!-- lang:ar -->
## ميزات جديدة

- نافذة «سجل التغييرات» الكاملة داخل التطبيق: تعرض التاريخ من أول إصدار منشور حتى الأحدث، وتُحدَّث حيّاً من GitHub مع نسخة مضمَّنة تعمل بلا اتصال.
- عرض ملاحظات الإصدارات بلغة الجهاز (عربي/إنجليزي) مع زرّ لتبديل لغة العرض.
- مدخل «سجل التغييرات» في قائمة «مساعدة» وزرّ داخل نافذة «حول».

## إصلاحات

- إصلاح انهيار متكرّر في واجهة الإعدادات (صفحة النطق): كان مفتاح المسافة مع تحديد قديم يرمي تأكيد wxCheckListBox ويُسقط النافذة برسالة SystemError. الآن يُحرَس الفهرس قبل أي قراءة، وتُصفَّر القوائم بأمان بعد إعادة التعبئة.

المقارنة مع الإصدار السابق: https://github.com/HassanAlBarshoumy/haseela-app/compare/v1.4.1...v1.4.2

<!-- lang:en -->
## New features

- Full in-app "Changelog" window: shows the complete history from the first published release to the newest, refreshed live from GitHub with a bundled offline snapshot.
- Release notes rendered in the device language (Arabic/English) with a toggle button.
- A "Changelog" entry in the Help menu and a button inside the About window.

## Fixes

- Fixed a recurring crash in the Settings speech-filter page: pressing Space with a stale selection raised a wxCheckListBox assertion and took the window down with a SystemError. The index is now guarded before any read and the lists are reset safely after repopulation.

Compare with the previous release: https://github.com/HassanAlBarshoumy/haseela-app/compare/v1.4.1...v1.4.2
