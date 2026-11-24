import 'package:flutter/material.dart';
import 'package:scrumboard/src/api/scrumboard_api.dart';
import 'package:scrumboard/src/l10n/messages.dart';
import 'package:scrumboard/src/theme/scrum_theme.dart';

/// The text to show for a failed load: msg:scbServerUnreachable (SCB-13.h) when
/// the server did not answer, otherwise msg:scbLoadFailed (SCB-01.f).
String loadErrorText(Messages msg, Object error) {
  if (error is ScrumBoardUnreachableException) {
    return msg('scbServerUnreachable', {'reason': error.reason});
  }
  if (error is ScrumBoardApiException) {
    return msg('scbLoadFailed', {'reason': error.reason});
  }
  return msg('scbLoadFailed', {'reason': '$error'});
}

/// The message a pane shows in its own area when its data cannot be read.
class LoadErrorMessage extends StatelessWidget {
  const LoadErrorMessage({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(scrumErrorPadding),
        child: Text(
          loadErrorText(context.msg, error),
          style: TextStyle(color: Theme.of(context).colorScheme.error),
        ),
      );
}

