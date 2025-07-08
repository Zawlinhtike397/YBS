import 'package:ybs/data/app_data.dart';

String getBusStopName(int id) {
  return AppData.testStop.firstWhere((e) => e.id == id).name;
}
