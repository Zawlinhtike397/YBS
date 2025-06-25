import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ybs/data/app_data.dart';
import 'package:ybs/models/bus_stop.dart';

class BusStopController {
  static loadBusStopList() async {
    Directory appDir = await getApplicationSupportDirectory();
    String filePath = join(appDir.path, "save_route.txt");
    File routeFile = await File(filePath).create();
    String data = routeFile.readAsStringSync();
    if (data != "") {
      var records = jsonDecode(data);
      for (var i in records) {
        AppData.busStopList.add(BusStop.fromJson(i));
      }
    }
  }
}
