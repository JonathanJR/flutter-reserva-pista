import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_fan/data/models/commons/aem/aem_img.dart';

class AemWebLink {
  final String? linkTitle;
  final String? url;
  final AemImg? linkIcon;
  final bool? internalLink;
  final bool? openNewWindow;
  final bool? sso;

  AemWebLink({
    this.linkTitle,
    this.url,
    this.linkIcon,
    this.internalLink,
    this.openNewWindow,
    this.sso,
  });

  factory AemWebLink.fromJson(Map<String, dynamic> json) => AemWebLink(
        linkTitle: json.getOrNull('linkTitle'),
        url: json.getOrNull('url'),
        linkIcon: json.getMappedOrNull(
          'linkIcon',
          AemImg.fromJson,
        ),
        internalLink: json.getOrNull('internalLink'),
        openNewWindow: json.getOrNull('openNewWindow'),
        sso: json.getOrNull('sso'),
      );
}
