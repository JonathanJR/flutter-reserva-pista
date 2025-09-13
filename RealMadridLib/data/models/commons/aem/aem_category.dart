import 'package:rm_app_flutter_core/core/core.dart';
import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';
import 'package:rm_app_flutter_core/state_management.dart';
import 'package:rm_app_flutter_fan/data/models/commons/aem/aem_img.dart';

class AemCategory extends Equatable {
  final String? label;
  final AemImg? icon;
  final List<String> tags;

  const AemCategory({
    this.label,
    this.icon,
    this.tags = const [],
  });

  factory AemCategory.fromJson(Map<String, dynamic> json) => AemCategory(
        label: json.getOrNull('label'),
        icon: json.getMappedOrNull('icon', AemImg.fromJson),
        tags: json.getListOrNull('tags') ?? [],
      );

  factory AemCategory.sport() => AemCategory(
        label: 'walletFootballLabel'.rtr,
        icon: AemImg(
          publishUrl:
              'https://publish-p47754-e237307.adobeaemcloud.com/content/dam/portals/areavip/es-es/content/common-web-content/categories/icons/ball_Football.svg',
        ),
        tags: const ['area-vip:event/sports'],
      );

  factory AemCategory.bookABox() => AemCategory(
        label: 'VIP', //'walletBookABoxLabel'.rtr,
        icon: AemImg(
          publishUrl:
              'https://publish-p47754-e237307.adobeaemcloud.com/content/dam/portals/areavip/es-es/content/common-web-content/categories/icons/ball_Football.svg',
        ),
        tags: const ['area-vip:event/bookABox'],
      );

  @override
  List<Object?> get props => [label];
}
