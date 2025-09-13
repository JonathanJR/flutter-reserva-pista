class GetMatchUseCaseParams {
  const GetMatchUseCaseParams({
    required this.langCode,
    required this.fromDate,
    required this.toDate,
  });

  final String langCode;
  final DateTime fromDate;
  final DateTime toDate;
}
