class BusStop {
  int id;
  String name;
  double latitude;
  double longitude;

  BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) => BusStop(
    id: json["id"],
    name: json["name"],
    latitude: json["latitude"],
    longitude: json["longitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "latitude": latitude,
    "longitude": longitude,
  };
}
