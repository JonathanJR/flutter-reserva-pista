import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_fan/data/models/commons/aem/aem_text.dart';

class AemTitleDescription {
  final String? title;
  final AemText? description;

  AemTitleDescription({
    this.title,
    this.description,
  });

  factory AemTitleDescription.fromJson(Map<String, dynamic> json) =>
      AemTitleDescription(
        title: json.getOrNull('title'),
        description: json.getMappedOrNull(
          'description',
          AemText.fromJson,
        ),
      );
}
