import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';

class AppData {
  static List<BusStop> busStopList = [];
  static List<List<BusStop>> routeList = [];
  static List<Bus> busList = [];

  static final List<BusStop> testStop = [
    BusStop(id: 1, name: "a", latitude: 21.82533, longitude: 96.355862),
    BusStop(id: 2, name: "b", latitude: 21.837542, longitude: 96.355197),
    BusStop(id: 3, name: "c", latitude: 21.846795, longitude: 96.349075),
    BusStop(id: 4, name: "d", latitude: 21.857323, longitude: 96.34807),
    BusStop(id: 5, name: "e", latitude: 21.856444, longitude: 96.335372),
    BusStop(id: 6, name: "f", latitude: 21.859933, longitude: 96.317823),
    BusStop(id: 7, name: "1", latitude: 21.803346, longitude: 96.331013),
    BusStop(id: 8, name: "2", latitude: 21.817823, longitude: 96.335905),
    BusStop(id: 9, name: "3", latitude: 21.8261549, longitude: 96.3371543),
    BusStop(id: 10, name: "4", latitude: 21.835825, longitude: 96.34297),
    BusStop(id: 11, name: "5", latitude: 21.849969, longitude: 96.349208),
    BusStop(id: 12, name: "6", latitude: 21.857808, longitude: 96.350018),
    BusStop(id: 13, name: "7", latitude: 21.867082, longitude: 96.356845),
    BusStop(id: 14, name: "8", latitude: 21.877886, longitude: 96.351827),
  ];

  static final List<Bus> testbus = [busOne, busTwo];

  static final Bus busOne = Bus(
    id: 1,
    name: "Bus One",
    routeName: "ရွာမ - ပြင်စာ",
    routeOne: [1, 2, 3, 4, 5, 6],
    routeTwo: [6, 5, 4, 3, 2, 1],
  );

  static final Bus busTwo = Bus(
    id: 2,
    name: "Bus Two",
    routeName: "လွန်ကောင်း - ရတနာပုံတယ်လီပေါ့",
    routeOne: [7, 8, 9, 10, 11, 12, 13, 14],
    routeTwo: [14, 13, 12, 11, 10, 9, 8, 7],
  );
}
