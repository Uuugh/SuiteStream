import 'package:flutter/material.dart';

import '../l10n/messages.dart';
import 'cancel_save_pair.dart';
import 'suite_dialog.dart';

/// UIC-06: an action that hides or deletes something asks first with a No | Yes
/// pair; cancelling changes nothing. Returns true only for Yes.
Future<bool> confirmYesNo(BuildContext context, String question) async {
  final m = context.msg;
  final yes = await showSuiteDialog<bool>(
    context: context,
    builder: (ctx) => MessagesScope(
      messages: m,
      child: SuiteAlertDialog(
        content: Text(question),
        actions: [
          // UIC-27.d: a question's answers are the same pair, No | Yes.
          CancelSavePair(
            cancelKey: const ValueKey('confirm-no'),
            saveKey: const ValueKey('confirm-yes'),
            cancelLabel: m('no'),
            saveLabel: m('yes'),
            onCancel: () => Navigator.of(ctx).pop(false),
            onSave: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    ),
  );
  return yes ?? false;
}
