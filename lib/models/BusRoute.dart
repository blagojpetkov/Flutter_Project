class BusRoute {
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

  BusRoute({
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

  BusRoute.empty()
      : id = -1, // Indicates an invalid ID
        lineId = -1,
        direction = '',
        directionTranslations = {},
        name = '',
        nameTranslations = {},
        begin = 0,
        end = 0,
        length = 0,
        stopIds = [],
        stopOffsets = [];

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'],
      lineId: json['lineId'],
      direction: json['direction'],
      directionTranslations:
          Map<String, String>.from(json['directionTranslations']),
      name: json['name'],
      nameTranslations: Map<String, String>.from(json['nameTranslations']),
      begin: json['begin'],
      end: json['end'],
      length: json['length'] ?? 0,
      stopIds: List<int>.from(json['stopIds']),
      stopOffsets: List<int>.from(json['stopOffsets']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lineId': lineId,
        'direction': direction,
        'directionTranslations': directionTranslations,
        'name': name,
        'nameTranslations': nameTranslations,
        'begin': begin,
        'end': end,
        'length': length,
        'stopIds': stopIds,
        'stopOffsets': stopOffsets,
      };

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
