import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart' show rootBundle;

/// The languages offered (SHL-02), by the code of their message file.
const List<String> supportedLocales = ['en', 'es', 'fr', 'de', 'pt', 'nl'];

/// The wording of everything the app shows: keys from `requirements/messages/`.
/// A key a language has no translation for falls back to English.
class Messages {
  Messages._(this.locale, this._text, this._fallback);

  /// Builds messages from already-parsed ARB maps (used by tests).
  factory Messages.fromMaps(String locale, Map<String, dynamic> text, Map<String, dynamic> english) =>
      Messages._(locale, _strings(text), _strings(english));

  /// Loads the ARB files from the app's assets.
  static Future<Messages> load(String locale, {AssetBundle? bundle}) async {
    final b = bundle ?? rootBundle;
    Future<Map<String, dynamic>> read(String code) async =>
        jsonDecode(await b.loadString('requirements/messages/app_$code.arb')) as Map<String, dynamic>;
    final english = await read('en');
    final code = supportedLocales.contains(locale) ? locale : 'en';
    final text = code == 'en' ? english : await read(code);
    return Messages.fromMaps(code, text, english);
  }

  final String locale;
  final Map<String, String> _text;
  final Map<String, String> _fallback;

  static Map<String, String> _strings(Map<String, dynamic> m) => {
        for (final e in m.entries)
          if (!e.key.startsWith('@') && e.value is String) e.key: e.value as String,
      };

  bool has(String key) => _text.containsKey(key) || _fallback.containsKey(key);

  /// The message for [key] with each `{name}` replaced from [args].
  /// Values are inserted as plain text, never read as markup. An unknown key
  /// shows as the key itself, so a gap is visible.
  String call(String key, [Map<String, Object?> args = const {}]) {
    var s = _text[key] ?? _fallback[key] ?? key;
    args.forEach((name, value) => s = s.replaceAll('{$name}', '$value'));
    return s;
  }
}

/// Gives the current [Messages] to every widget below it.
class MessagesScope extends InheritedWidget {
  const MessagesScope({super.key, required this.messages, required super.child});

  final Messages messages;

  static Messages of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<MessagesScope>();
    assert(scope != null, 'No MessagesScope above this widget');
    return scope!.messages;
  }

  @override
  bool updateShouldNotify(MessagesScope old) => old.messages != messages;
}

extension MessagesContext on BuildContext {
  Messages get msg => MessagesScope.of(this);
}
