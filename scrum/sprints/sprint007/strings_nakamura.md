# Strings from Nakamura (PBI-035, PBI-041)

For Yamamoto to merge into the six arb files. Until merged the code shows the English text below through `Messages.orElse` (grep `TODO(arb)` in `lib/src/theme/theme_mode_controller.dart` and `lib/src/calendar/calendar_page.dart`); once a key exists in the arb files the arb text wins. Test calendar names Work, Family, Travel and event titles are sample data, not interface text.

| Key | en | es | fr | de | pt | nl |
|---|---|---|---|---|---|---|
| themeName | Theme | Tema | Thème | Design | Tema | Thema |
| themeTooltip | Theme: {name} | Tema: {name} | Thème : {name} | Design: {name} | Tema: {name} | Thema: {name} |
| themeLight | Light | Claro | Clair | Hell | Claro | Licht |
| themeDark | Dark | Oscuro | Sombre | Dunkel | Escuro | Donker |
| themeSystem | Match system | Igual que el sistema | Comme le système | Wie das System | Igual ao sistema | Zoals systeem |
| adminTestDataHelp | Test calendars Work, Family and Travel with sample events across November 2026, for trying the app. | Calendarios de prueba Work, Family y Travel con eventos de ejemplo en noviembre de 2026, para probar la aplicación. | Calendriers de test Work, Family et Travel avec des événements d'exemple en novembre 2026, pour essayer l'application. | Testkalender Work, Family und Travel mit Beispielterminen im November 2026, zum Ausprobieren der App. | Calendários de teste Work, Family e Travel com eventos de exemplo em novembro de 2026, para experimentar a aplicação. | Testagenda's Work, Family en Travel met voorbeeldafspraken in november 2026, om de app uit te proberen. |
| adminAddTestCalendars | Add test calendars | Añadir calendarios de prueba | Ajouter des calendriers de test | Testkalender hinzufügen | Adicionar calendários de teste | Testagenda's toevoegen |
| adminRemoveTestData | Remove test data | Quitar datos de prueba | Supprimer les données de test | Testdaten entfernen | Remover dados de teste | Testgegevens verwijderen |
| adminRemoveConfirm | Remove the test calendars and their events? Your own calendars and events are not changed. | ¿Quitar los calendarios de prueba y sus eventos? Tus calendarios y eventos no cambian. | Supprimer les calendriers de test et leurs événements ? Vos calendriers et événements ne changent pas. | Testkalender und ihre Termine entfernen? Ihre eigenen Kalender und Termine bleiben unverändert. | Remover os calendários de teste e os seus eventos? Os seus calendários e eventos não são alterados. | De testagenda's en hun afspraken verwijderen? Uw eigen agenda's en afspraken blijven ongewijzigd. |
| adminAdded | Test calendars added. | Calendarios de prueba añadidos. | Calendriers de test ajoutés. | Testkalender hinzugefügt. | Calendários de teste adicionados. | Testagenda's toegevoegd. |
| adminRemoved | Test data removed. | Datos de prueba quitados. | Données de test supprimées. | Testdaten entfernt. | Dados de teste removidos. | Testgegevens verwijderd. |
| adminFailed | Could not save. Try again. | No se pudo guardar. Inténtalo de nuevo. | Enregistrement impossible. Réessayez. | Speichern nicht möglich. Bitte erneut versuchen. | Não foi possível guardar. Tente novamente. | Opslaan mislukt. Probeer het opnieuw. |

Not needed from Yamamoto: the heading "Admin" for the pane and its settings entry (his `settings_dialog.dart`); suggested key `settingsAdmin` = Admin.
