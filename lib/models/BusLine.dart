class BusLine {
  final int id;
  final String kind;
  final String number;
  final String name;
  final bool nightly;
  final List<int> routeIds;
  final String type;
  final String carrier;

  BusLine({
    required this.id,
    required this.kind,
    required this.number,
    required this.name,
    required this.nightly,
    required this.routeIds,
    required this.type,
    required this.carrier,
  });

  // Empty constructor
  BusLine.empty()
      : id = 0,
        kind = '',
        number = '',
        name = '',
        nightly = false,
        routeIds = [],
        type = '',
        carrier = '';

  factory BusLine.fromJson(Map<String, dynamic> json) {
  return BusLine(
    id: json['id'] as int? ?? -1,
    kind: json['kind'] as String? ?? 'default_kind',
    number: json['number'] as String? ?? 'default_number',
    name: json['name'] as String? ?? 'default_name',
    nightly: json['nightly'] ?? false,
    routeIds: (json['routeIds'] as List<dynamic>?)
        ?.map((e) => e as int)
        .toList() ?? [],
    type: json['type'] as String? ?? 'default_type',
    carrier: json['carrier'] as String? ?? 'default_carrier',
  );
}

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'number': number,
        'name': name,
        'nightly': nightly,
        'routeIds': routeIds,
        'type': type,
        'carrier': carrier,
      };

  @override
  String toString() {
    return 'BusLine(id: $id, kind: $kind, number: $number, name: $name, nightly: $nightly, routeIds: $routeIds, type: $type, carrier: $carrier)';
  }
}
