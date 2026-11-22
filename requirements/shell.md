# Requirements: shell and shared UI

The frame (top bar, modules, navigation), theme and branding, shared widgets.

| ID | status | statement | test |
|---|---|---|---|
| SHL-01 | backlog | The page identifies SuiteStream in its title bar, footer and favicon. | — |
| SHL-01.a | backlog | The footer shows the running version, linked to its release (including the full beta identifier), the copyright, and a link to README License & Attribution (DOC-01). | — |
| SHL-01.b | backlog | The favicon is the light SuiteStream icon with its white background cropped to a circle and the rest transparent. | — |
| SHL-01.c | backlog | The SuiteStream logo files have no compression or visual artifacts. | — |
| SHL-01.d | backlog | The title bar shows the logo's mark (no words; the Light mark on light pages, the Dark mark on dark ones) left of the title, and the title in the logo colors (THM-02.m). One transparent favicon serves light and dark. | — |
| SHL-01.e | backlog | A browser tab is titled SuiteStream on the main page and "<page name> · SuiteStream" on the sign-in page (msg:signInAction) and the initial-setup page (msg:welcome). | — |
| SHL-01.f | backlog | The sign-in and initial-setup pages show the running version as vX.Y.Z beside the name SuiteStream; the main page shows it in the footer only (SHL-01.a). | — |
| SHL-01.g | backlog | The default icons are a favicon, an app icon and an Apple touch icon at the sizes in DEF-01, each with the version in its address; a custom favicon (SET-06.f) replaces all three. | — |
| SHL-02 | backlog | The page is available in several languages, chosen automatically or by the user. | — |
| SHL-02.a | backlog | The initial page language is English; Automatic follows supported browser language preferences, including French, German and Belgian Dutch, while an unknown browser language falls back to English. Choosing Automatic clears the explicit language override. | — |
| SHL-02.b | backlog | The selected language applies to every screen, setup guide, error message (including validation guidance), month name and day name; user-supplied text follows SHL-02. Languages offered include Spanish, French, German, Portuguese and Dutch (SHL-02 adds Brazilian Portuguese). | — |
| SHL-02.c | backlog | Brazilian Portuguese is offered as a page language. | — |
| SHL-02.d | backlog | The selected page language is a view setting kept on the device for later visits (SET-01). | — |
| SHL-02.e | backlog | Translation supports composed and nested messages, including sync-change summaries and download-failure explanations, without translating user event titles. Unknown messages retain their original English wording. | — |
| SHL-02.f | done | Values inserted into translated messages are escaped rather than interpreted as markup. | test/l10n/messages_test.dart |
| SHL-02.g | backlog | The subscription page and Google setup-error guide follow the visitor’s supported browser language. | — |
| SHL-02.h | backlog | A browser form error presents a localized error page with a way to return to the preceding page; API error responses follow SHL-05. | — |
| SHL-03 | backlog | The page uses a light, dark or system theme, and starts in the saved one. | — |
| SHL-03.a | backlog | With no saved theme override, the page uses Match system; choosing Dark applies it and indicates it as the selected choice. The page starts in the saved theme without first showing another (SHL-03 owns the choice control). | — |
| SHL-03.b | backlog | The Light / Dark / Match system choice is one icon when closed, a button plus menu like the view picker, replacing a three-way cycling button. | — |
| SHL-03.c | backlog | The sign-in and initial-setup pages follow the saved theme. | — |
| SHL-05 | backlog | The page loads everything from the installation and keeps its errors machine-readable for programs. | — |
| SHL-05.a | backlog | Rendering a SuiteStream page loads its resources, including its fonts (the Mono font with its license), from the SuiteStream installation, without contacting external resource providers such as Google Fonts. | — |
| SHL-05.b | backlog | Versioned stylesheet, language-script and font assets can be cached as immutable, fonts for one year; an obsolete script version or an unsupported script language is not served, and the unversioned font is not advertised as immutable. | — |
| SHL-05.d | backlog | API-style requests retain structured JSON errors rather than receiving translated HTML pages. | — |

