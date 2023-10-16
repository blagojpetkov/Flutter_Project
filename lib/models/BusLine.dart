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
      id: json['id'],
      kind: json['kind'],
      number: json['number'],
      name: json['name'],
      nightly: json['nightly'],
      routeIds: List<int>.from(json['routeIds']),
      type: json['type'],
      carrier: json['carrier'],
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
