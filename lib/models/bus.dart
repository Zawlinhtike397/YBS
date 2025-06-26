import 'package:ybs/models/bus_stop.dart';

class Bus {
  int id;
  String name;
  String routeName;
  List<BusStop> routeOne;
  List<BusStop> routeTwo;

  Bus({
    required this.id,
    required this.name,
    required this.routeName,
    required this.routeOne,
    required this.routeTwo,
  });
}
