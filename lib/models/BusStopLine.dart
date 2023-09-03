class BusStopLine {
  final int stopId;
  final int lineId;
  final int routeId;
  final List<int> remainingTime;

  BusStopLine({
    required this.stopId,
    required this.lineId,
    required this.routeId,
    required this.remainingTime,
  });

  factory BusStopLine.fromJson(Map<String, dynamic> json) {
    return BusStopLine(
      stopId: json['stopId'],
      lineId: json['lineId'],
      routeId: json['routeId'],
      remainingTime: List<int>.from(json['remainingTime']),
    );
  }

  @override
  String toString() {
    return 'BusStopLine(stopId: $stopId, lineId: $lineId, routeId: $routeId, remainingTime: $remainingTime)';
  }
}