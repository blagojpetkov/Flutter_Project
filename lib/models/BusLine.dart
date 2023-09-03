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

  @override
  String toString() {
    return 'BusLine(id: $id, kind: $kind, number: $number, name: $name, nightly: $nightly, routeIds: $routeIds, type: $type, carrier: $carrier)';
  }
}