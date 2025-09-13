import 'package:rm_app_flutter_core/core/extensions/map_extractor.dart';

class AemDate {
  final DateTime? dateTime;
  final String? dateText;
  final DateTime? dateTimeStartRequestTickets;
  final DateTime? dateTimeStartExpressRequest;
  final DateTime? dateTimeEndExpressRequest;

  AemDate({
    this.dateTime,
    this.dateText,
    this.dateTimeStartRequestTickets,
    this.dateTimeStartExpressRequest,
    this.dateTimeEndExpressRequest,
  });

  factory AemDate.fromJson(Map<String, dynamic> json) => AemDate(
        dateTime: json['dateTime'] != null
            ? DateTime.parse(json.getOrThrow('dateTime'))
            : null,
        dateText: json.getOrNull('dateText'),
        dateTimeStartRequestTickets: json['dateTimeStartRequestTickets'] != null
            ? DateTime.parse(
                json.getOrThrow('dateTimeStartRequestTickets'),
              )
            : null,
        dateTimeStartExpressRequest: json['dateTimeStartExpressRequest'] != null
            ? DateTime.parse(
                json.getOrThrow('dateTimeStartExpressRequest'),
              )
            : null,
        dateTimeEndExpressRequest: json['dateTimeEndExpressRequest'] != null
            ? DateTime.parse(
                json.getOrThrow('dateTimeEndExpressRequest'),
              )
            : null,
      );
}
