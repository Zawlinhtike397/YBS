import 'package:free_map/free_map.dart';
import 'package:geodesy/geodesy.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/bus_stop_distance.dart';
import 'package:ybs/models/route_data.dart';

class SearchRouteController {
  List<BusStopDistance> busStopDistanceList = [];

  List<Bus> startPointArrivalBusList = [];
  List<Bus> endPointArrivalBusList = [];

  BusStop? start;
  BusStop? end;

  List<RouteData> avaliableRoute = [];

  List<RouteData> getSameBusRoute(Bus bus, BusStop start, BusStop end) {
    List<RouteData> route = [];
    bool startStopFound = false;
    bool endStopFound = false;
    bool isRouteOne = false;
    for (var id in bus.routeOne) {
      startStopFound = id == start.id;
      endStopFound = id == end.id;
      if (startStopFound) {
        isRouteOne = true;
        break;
      } else if (endStopFound) {
        isRouteOne = false;
        break;
      }
    }

    if (isRouteOne) {
      final startIndex = bus.routeOne.indexOf(start.id);
      final endIndex = bus.routeOne.indexOf(end.id);
      for (int i = startIndex; i <= endIndex; i++) {
        route.add(
          RouteData(
            bus: bus,
            busStop: AppData.testStop.firstWhere(
              (stop) => stop.id == bus.routeOne[i],
            ),
          ),
        );
      }
      return route;
    } else {
      final startIndex = bus.routeTwo.indexOf(start.id);
      final endIndex = bus.routeTwo.indexOf(end.id);
      for (int i = startIndex; i <= endIndex; i++) {
        route.add(
          RouteData(
            bus: bus,
            busStop: AppData.testStop.firstWhere(
              (stop) => stop.id == bus.routeTwo[i],
            ),
          ),
        );
      }
      return route;
    }
  }

  List<RouteData> getRoute(BusStop startStop, BusStop endStop) {
    Bus startBus = AppData.testbus.firstWhere(
      (bus) => bus.routeOne.contains(startStop.id),
    );
    Bus endBus = AppData.testbus.firstWhere(
      (bus) => bus.routeOne.contains(endStop.id),
    );

    // TODO: update for more than 2 bus route or no overlap bus stop
    // Current code is only work for the overlap bus stop trip
    // The following cade are chekcing the ways that have overlap bus stop withing two bus lines.
    List<int> sameStopIds = [];
    for (var id1 in startBus.routeOne) {
      for (var id2 in endBus.routeOne) {
        if (id1 == id2) {
          sameStopIds.add(id1);
        }
      }
    }
    if (sameStopIds.isNotEmpty) {
      List<RouteData> finalRoute = [];
      int lenght = 0;
      for (var i in sameStopIds) {
        List<RouteData> route = [];
        route = getSameBusRoute(
          startBus,
          startStop,
          AppData.testStop.firstWhere((stop) => stop.id == i),
        );

        if (lenght == 0 || lenght > route.length) {
          lenght = route.length;
          final route2 = getSameBusRoute(
            endBus,
            AppData.testStop.firstWhere((stop) => stop.id == i),
            endStop,
          );
          route.addAll(route2);
          finalRoute.clear();
          finalRoute = route;
        }
      }
      return finalRoute;
    }

    // find the distance between bus1 bus stopes and bus2 bus stopes.
    // the nearest distance will be the transit bus stop.
    // This saniro will only work for two bus transit.
    // if the route have more that one transit point, we have to think another way.

    for (var id1 in startBus.routeOne) {
      final busStop1 = AppData.testStop.firstWhere((e) => e.id == id1);
      LatLng stopOne = LatLng(busStop1.latitude, busStop1.longitude);
      for (var id2 in endBus.routeOne) {
        final busStop2 = AppData.testStop.firstWhere((e) => e.id == id2);
        LatLng stopTwo = LatLng(busStop2.latitude, busStop2.longitude);
        busStopDistanceList.add(
          BusStopDistance(
            distance: Geodesy()
                .distanceBetweenTwoGeoPoints(stopOne, stopTwo)
                .toDouble(),
            busStopOne: busStop1,
            busStopTwo: busStop2,
          ),
        );
      }
    }

    busStopDistanceList.sort((a, b) => a.distance.compareTo(b.distance));

    List<RouteData> finalRoute = [];
    final route1 = getSameBusRoute(
      startBus,
      startStop,
      busStopDistanceList.first.busStopOne,
    );
    final route2 = getSameBusRoute(
      endBus,
      busStopDistanceList.first.busStopTwo,
      endStop,
    );
    route1.addAll(route2);
    finalRoute.clear();
    finalRoute = route1;
    busStopDistanceList.clear();

    return finalRoute;
  }

  List<RouteData> searchRoute(BusStop startStop, BusStop endStop) {
    avaliableRoute.clear();
    startPointArrivalBusList.clear();
    endPointArrivalBusList.clear();

    for (var bus in AppData.testbus) {
      if (bus.routeOne.contains(startStop.id) &&
          bus.routeOne.contains(endStop.id)) {
        return getSameBusRoute(bus, startStop, endStop);
      }
    }

    return getRoute(startStop, endStop);
  }
}
