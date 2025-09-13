import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';

class AemText {
  final String plainText;
  final String? htmlText;

  AemText({
    required this.plainText,
    this.htmlText,
  });

  factory AemText.fromJson(Map<String, dynamic> json) => AemText(
        plainText: json.getOrNull('plaintext') ?? '',
        htmlText: json.getOrNull('html'),
      );
}
