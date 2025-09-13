import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_fan/data/models/commons/aem/aem_img.dart';

class AemDownload {
  final String? downloadTitle;
  final AemImg? bannerImage;
  final AemImg? file;
  final AemImg? downloadIcon;

  AemDownload({
    this.downloadTitle,
    this.bannerImage,
    this.file,
    this.downloadIcon,
  });

  factory AemDownload.fromJson(Map<String, dynamic> json) => AemDownload(
        downloadTitle: json.getOrNull('downloadTitle'),
        bannerImage: json.getMappedOrNull('bannerImage', AemImg.fromJson),
        file: json.getMappedOrNull('file', AemImg.fromJson),
        downloadIcon: json.getMappedOrNull('downloadIcon', AemImg.fromJson),
      );
}
