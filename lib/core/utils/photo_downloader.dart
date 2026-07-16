import 'dart:io';
import 'dart:typed_data';

import 'package:gal/gal.dart';

Future<void> downloadPhotoToGallery(String url) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(Uri.parse(url));
    final response = await request.close();
    final builder = BytesBuilder();
    await for (final chunk in response) {
      builder.add(chunk);
    }
    final Uint8List bytes = builder.takeBytes();
    await Gal.putImageBytes(
      bytes,
      name: 'ai_hairstyle_${DateTime.now().millisecondsSinceEpoch}',
    );
  } finally {
    client.close();
  }
}
