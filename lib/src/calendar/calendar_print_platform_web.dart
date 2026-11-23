import 'dart:js_interop';

const calendarPrintingAvailable = true;

@JS('document')
external _Document get _document;

extension type _Document(JSObject _) implements JSObject {
  external _PrintFrame createElement(String tag);
  external _Body get body;
}

extension type _Body(JSObject _) implements JSObject {
  external void appendChild(_PrintFrame frame);
}

extension type _PrintFrame(JSObject _) implements JSObject {
  external void setAttribute(String name, String value);
  external set srcdoc(String html);
  external _PrintWindow? get contentWindow;
  external void addEventListener(String type, JSFunction callback);
  external void remove();
}

extension type _PrintWindow(JSObject _) implements JSObject {
  external void addEventListener(String type, JSFunction callback);
  external void focus();
  external void print();
}

_PrintFrame? _activeFrame;

void printCalendarHtml(String html) {
  _activeFrame?.remove();
  final frame = _document.createElement('iframe');
  _activeFrame = frame;
  frame.setAttribute('title', 'Calendar print');
  frame.setAttribute('aria-hidden', 'true');
  frame.setAttribute('tabindex', '-1');
  frame.setAttribute(
    'style',
    'position:fixed;left:-10000px;width:1px;height:1px;border:0',
  );
  frame.addEventListener(
    'load',
    (() {
      if (_activeFrame != frame) return;
      final window = frame.contentWindow;
      if (window == null) return;
      window.addEventListener(
        'afterprint',
        (() {
          if (_activeFrame == frame) _activeFrame = null;
          frame.remove();
        }).toJS,
      );
      window.focus();
      window.print();
    }).toJS,
  );
  frame.srcdoc = html;
  _document.body.appendChild(frame);
}
