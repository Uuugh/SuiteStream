import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/messages.dart';
import '../theme/suite_theme.dart';
import '../theme/tokens.dart';
import '../time/length_input.dart';
import '../ui/cancel_save_pair.dart';
import '../ui/popup_size_lock.dart';
import '../ui/stepper_arrows.dart';
import 'calendar_controller.dart';
import 'event_drag.dart';

/// Opens the user's settings (view settings, kept on the device).
Future<void> openSettingsDialog(BuildContext context, CalendarController c) {
  final msgs = context.msg;
  return showDialog<void>(
    context: context,
    builder: (_) => MessagesScope(
      messages: msgs,
      child: Dialog(
        backgroundColor: context.tokens.card,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: PopupSizeLock(child: SettingsDialog(controller: c))),
      ),
    ),
  );
}

/// SET-08, SET-09: the user's own settings: the default length of an event and the
/// press-and-hold delay before an event can be dragged.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, required this.controller});

  final CalendarController controller;

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late final TextEditingController _length = TextEditingController(text: formatLength(widget.controller.defaultLength));
  late final TextEditingController _press = TextEditingController(text: formatPressDelay(widget.controller.longPress));
  late final String _initialLength = _length.text;
  late final String _initialPress = _press.text;
  String? _lengthError;
  String? _pressError;

  @override
  void dispose() {
    _length.dispose();
    _press.dispose();
    super.dispose();
  }

  bool get _changed => _length.text.trim() != _initialLength || _press.text.trim() != _initialPress;

  void _save() {
    final m = context.msg;
    final length = parseLengthInput(_length.text);
    final press = parsePressDelayInput(_press.text);
    if (length == null || press == null) {
      setState(() {
        _lengthError = length == null ? m('lengthInvalid') : null;
        _pressError = press == null ? m('pressDelayInvalid') : null;
      });
      return;
    }
    widget.controller.defaultLength = length;
    widget.controller.longPress = press;
    Navigator.of(context).pop();
  }

  /// The arrows step the default length by 15 minutes.
  void _stepLength(int dir) {
    final d = parseLengthInput(_length.text) ?? widget.controller.defaultLength;
    _length.text = formatLength(clampEventLength(d + Duration(minutes: 15 * dir)));
    setState(() => _lengthError = null);
  }

  /// The arrows step the press-and-hold delay by 0.1 seconds.
  void _stepPress(int dir) {
    final d = parsePressDelayInput(_press.text) ?? widget.controller.longPress;
    _press.text = formatPressDelay(clampLongPress(d + Duration(milliseconds: 100 * dir)));
    setState(() => _pressError = null);
  }

  Widget _field(String label, String key, TextEditingController ctl, String? error, VoidCallback onChanged, void Function(int) step) {
    final t = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Text(label, style: TextStyle(color: t.muted, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        ArrowKeyStepper(
          onUp: () => step(1),
          onDown: () => step(-1),
          child: TextField(
          key: ValueKey(key),
          controller: ctl,
          inputFormatters: [LengthLimitingTextInputFormatter(8)],
          decoration: InputDecoration(
            suffixIcon: StepperArrows(upKey: ValueKey('$key-up'), downKey: ValueKey('$key-down'), onUp: () => step(1), onDown: () => step(-1)),
            isDense: true,
            errorText: error,
            errorMaxLines: 2,
            filled: true,
            fillColor: t.bg,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: t.line)),
          ),
          onChanged: (_) => setState(onChanged),
        ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final m = context.msg;
    return Padding(
      key: const ValueKey('settings-dialog'),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(m('settings'), style: SuiteText.moduleKind(t, windowWidth: MediaQuery.sizeOf(context).width)),
          const SizedBox(height: 12),
          _field(m('defaultEventLength'), 'setting-default-length', _length, _lengthError, () => _lengthError = null, _stepLength),
          const SizedBox(height: 12),
          _field(m('pressDelay'), 'setting-press-delay', _press, _pressError, () => _pressError = null, _stepPress),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            // UIC-27: Save is available once something has changed.
            child: CancelSavePair(
              cancelKey: const ValueKey('settings-cancel'),
              saveKey: const ValueKey('settings-save'),
              cancelLabel: m('cancel'),
              saveLabel: m('save'),
              useThemedSaveStates: true,
              onCancel: () => Navigator.of(context).pop(),
              saveEnabled: _changed,
              onSave: _save,
            ),
          ),
        ],
      ),
    );
  }
}
