import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

Future<Uint8List?> pickImageBytesForWeb() {
  final completer = Completer<Uint8List?>();
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.style.display = 'none';
  html.document.body?.append(input);
  input.click();

  input.onChange.first.then((_) {
    final file = input.files?.first;
    if (file == null) {
      input.remove();
      completer.complete(null);
      return;
    }

    final reader = html.FileReader();
    reader.readAsDataUrl(file);
    reader.onLoadEnd.first.then((_) {
      final result = reader.result;
      input.remove();
      if (result is String && result.contains(',')) {
        final base64 = result.split(',').last;
        completer.complete(base64Decode(base64));
      } else {
        completer.complete(null);
      }
    });
  });

  return completer.future;
}
