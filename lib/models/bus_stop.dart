class BusStop {
  int id;
  String name;
  double latitude;
  double longitude;
  String township;
  String nearPlaces;

  BusStop({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.township = "Unknow",
    this.nearPlaces = "Unknow",
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
