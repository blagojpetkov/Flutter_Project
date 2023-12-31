class BusStop {
  final int id;
  final int areaId;
  final String number;
  final String name;
  final Map<String, String> translations;
  final double lat;
  final double lon;
  final String note;

  BusStop({
    required this.id,
    required this.areaId,
    required this.number,
    required this.name,
    required this.translations,
    required this.lat,
    required this.lon,
    required this.note,
  });

  // Empty constructor
  BusStop.empty()
      : id = 0,
        areaId = 0,
        number = '',
        name = '',
        translations = {},
        lat = 0.0,
        lon = 0.0,
        note = '';

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      areaId: json['areaId'],
      number: json['number'],
      name: json['name'],
      translations: Map<String, String>.from(json['translations']),
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'areaId': areaId,
        'number': number,
        'name': name,
        'translations': translations,
        'lat': lat,
        'lon': lon,
        'note': note,
      };

  @override
  String toString() {
    return 'Stop(id: $id, areaId: $areaId, number: $number, name: $name, translations: $translations, lat: $lat, lon: $lon, note: $note)';
  }
}
