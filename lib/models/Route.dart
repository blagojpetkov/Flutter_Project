class Route {
  final int id;
  final int lineId;
  final String direction;
  final Map<String, String> directionTranslations;
  final String name;
  final Map<String, String> nameTranslations;
  final int begin;
  final int end;
  final int length;
  final List<int> stopIds;
  final List<int> stopOffsets;

  Route({
    required this.id,
    required this.lineId,
    required this.direction,
    required this.directionTranslations,
    required this.name,
    required this.nameTranslations,
    required this.begin,
    required this.end,
    required this.length,
    required this.stopIds,
    required this.stopOffsets,
  });

  factory Route.fromJson(Map<String, dynamic> json) {
    return Route(
      id: json['id'],
      lineId: json['lineId'],
      direction: json['direction'],
      directionTranslations:
          Map<String, String>.from(json['directionTranslations']),
      name: json['name'],
      nameTranslations: Map<String, String>.from(json['nameTranslations']),
      begin: json['begin'],
      end: json['end'],
      length: json['length'],
      stopIds: List<int>.from(json['stopIds']),
      stopOffsets: List<int>.from(json['stopOffsets']),
    );
  }

  @override
  String toString() {
    return 'Route(\n'
        '  id: $id,\n'
        '  lineId: $lineId,\n'
        '  direction: $direction,\n'
        '  directionTranslations: $directionTranslations,\n'
        '  name: $name,\n'
        '  nameTranslations: $nameTranslations,\n'
        '  begin: $begin,\n'
        '  end: $end,\n'
        '  length: $length,\n'
        '  stopIds: $stopIds,\n'
        '  stopOffsets: $stopOffsets,\n'
        ')';
  }
}
