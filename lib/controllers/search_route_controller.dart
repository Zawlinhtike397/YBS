import 'package:geolocator/geolocator.dart';
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

    if (startBus == endBus) return [];

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
      if (finalRoute.last.busStop ==
          finalRoute[finalRoute.length - 2].busStop) {
        finalRoute.clear();
      }
      return finalRoute;
    }

    // find the distance between bus1 bus stopes and bus2 bus stopes.
    // the nearest distance will be the transit bus stop.
    // This saniro will only work for two bus transit.
    // if the route have more that one transit point, we have to think another way.

    for (var id1 in startBus.routeOne) {
      final busStop1 = AppData.testStop.firstWhere((e) => e.id == id1);
      for (var id2 in endBus.routeOne) {
        final busStop2 = AppData.testStop.firstWhere((e) => e.id == id2);
        busStopDistanceList.add(
          BusStopDistance(
            distance: Geolocator.distanceBetween(
              busStop1.latitude,
              busStop1.longitude,
              busStop2.latitude,
              busStop2.longitude,
            ),
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

  bool checkSame(List<RouteData> r1, List<RouteData> r2) {
    if (r1.length != r2.length) return false;
    int length = r1.length;
    for (int i = 0; i < length; i++) {
      if (r1[i].bus != r2[i].bus || r1[i].busStop != r2[i].busStop) {
        return false;
      }
    }
    return true;
  }

  List<List<RouteData>> searchRoute(BusStop startStop, BusStop endStop) {
    List<List<RouteData>> allRoutes = [];
    avaliableRoute.clear();
    startPointArrivalBusList.clear();
    endPointArrivalBusList.clear();
    allRoutes.clear();

    for (var bus in AppData.testbus) {
      if (bus.routeOne.contains(startStop.id) &&
          bus.routeOne.contains(endStop.id)) {
        List<RouteData> route = getSameBusRoute(bus, startStop, endStop);
        allRoutes.add(route);
      } else {
        List<RouteData> route = getRoute(startStop, endStop);
        if (route.isNotEmpty) {
          if (allRoutes.isEmpty) {
            allRoutes.add(route);
          } else {
            bool hasSame = false;
            for (var r in allRoutes) {
              hasSame = checkSame(r, route);
              if (hasSame) break;
            }
            if (!hasSame) {
              allRoutes.add(route);
            }
          }
        }
      }
    }
    return allRoutes;
  }
}
