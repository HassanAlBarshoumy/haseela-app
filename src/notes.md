<!-- lang:ar -->
## Ù…ÙŠØ²Ø§Øª Ø¬Ø¯ÙŠØ¯Ø©

- Ù†Ø§ÙØ°Ø© Â«Ø³Ø¬Ù„ Ø§Ù„ØªØºÙŠÙŠØ±Ø§ØªÂ» Ø§Ù„ÙƒØ§Ù…Ù„Ø© Ø¯Ø§Ø®Ù„ Ø§Ù„ØªØ·Ø¨ÙŠÙ‚: ØªØ¹Ø±Ø¶ Ø§Ù„ØªØ§Ø±ÙŠØ® Ù…Ù† Ø£ÙˆÙ„ Ø¥ØµØ¯Ø§Ø± Ù…Ù†Ø´ÙˆØ± Ø­ØªÙ‰ Ø§Ù„Ø£Ø­Ø¯Ø«ØŒ ÙˆØªÙØ­Ø¯ÙŽÙ‘Ø« Ø­ÙŠÙ‘Ø§Ù‹ Ù…Ù† GitHub Ù…Ø¹ Ù†Ø³Ø®Ø© Ù…Ø¶Ù…ÙŽÙ‘Ù†Ø© ØªØ¹Ù…Ù„ Ø¨Ù„Ø§ Ø§ØªØµØ§Ù„.
- Ø¹Ø±Ø¶ Ù…Ù„Ø§Ø­Ø¸Ø§Øª Ø§Ù„Ø¥ØµØ¯Ø§Ø±Ø§Øª Ø¨Ù„ØºØ© Ø§Ù„Ø¬Ù‡Ø§Ø² (Ø¹Ø±Ø¨ÙŠ/Ø¥Ù†Ø¬Ù„ÙŠØ²ÙŠ) Ù…Ø¹ Ø²Ø±Ù‘ Ù„ØªØ¨Ø¯ÙŠÙ„ Ù„ØºØ© Ø§Ù„Ø¹Ø±Ø¶.
- Ù…Ø¯Ø®Ù„ Â«Ø³Ø¬Ù„ Ø§Ù„ØªØºÙŠÙŠØ±Ø§ØªÂ» ÙÙŠ Ù‚Ø§Ø¦Ù…Ø© Â«Ù…Ø³Ø§Ø¹Ø¯Ø©Â» ÙˆØ²Ø±Ù‘ Ø¯Ø§Ø®Ù„ Ù†Ø§ÙØ°Ø© Â«Ø­ÙˆÙ„Â».

## Ø¥ØµÙ„Ø§Ø­Ø§Øª

- Ø¥ØµÙ„Ø§Ø­ Ø§Ù†Ù‡ÙŠØ§Ø± Ù…ØªÙƒØ±Ù‘Ø± ÙÙŠ ÙˆØ§Ø¬Ù‡Ø© Ø§Ù„Ø¥Ø¹Ø¯Ø§Ø¯Ø§Øª (ØµÙØ­Ø© Ø§Ù„Ù†Ø·Ù‚): ÙƒØ§Ù† Ù…ÙØªØ§Ø­ Ø§Ù„Ù…Ø³Ø§ÙØ© Ù…Ø¹ ØªØ­Ø¯ÙŠØ¯ Ù‚Ø¯ÙŠÙ… ÙŠØ±Ù…ÙŠ ØªØ£ÙƒÙŠØ¯ wxCheckListBox ÙˆÙŠÙØ³Ù‚Ø· Ø§Ù„Ù†Ø§ÙØ°Ø© Ø¨Ø±Ø³Ø§Ù„Ø© SystemError. Ø§Ù„Ø¢Ù† ÙŠÙØ­Ø±ÙŽØ³ Ø§Ù„ÙÙ‡Ø±Ø³ Ù‚Ø¨Ù„ Ø£ÙŠ Ù‚Ø±Ø§Ø¡Ø©ØŒ ÙˆØªÙØµÙÙŽÙ‘Ø± Ø§Ù„Ù‚ÙˆØ§Ø¦Ù… Ø¨Ø£Ù…Ø§Ù† Ø¨Ø¹Ø¯ Ø¥Ø¹Ø§Ø¯Ø© Ø§Ù„ØªØ¹Ø¨Ø¦Ø©.

Ø§Ù„Ù…Ù‚Ø§Ø±Ù†Ø© Ù…Ø¹ Ø§Ù„Ø¥ØµØ¯Ø§Ø± Ø§Ù„Ø³Ø§Ø¨Ù‚: https://github.com/HassanAlBarshoumy/haseela-app/compare/v1.4.1...v1.4.2

<!-- lang:en -->
## New features

- Full in-app "Changelog" window: shows the complete history from the first published release to the newest, refreshed live from GitHub with a bundled offline snapshot.
- Release notes rendered in the device language (Arabic/English) with a toggle button.
- A "Changelog" entry in the Help menu and a button inside the About window.

## Fixes

- Fixed a recurring crash in the Settings speech-filter page: pressing Space with a stale selection raised a wxCheckListBox assertion and took the window down with a SystemError. The index is now guarded before any read and the lists are reset safely after repopulation.

Compare with the previous release: https://github.com/HassanAlBarshoumy/haseela-app/compare/v1.4.1...v1.4.2
