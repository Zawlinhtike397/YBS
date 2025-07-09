import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ybs/models/bus.dart';
import 'package:ybs/models/bus_stop.dart';
import 'package:ybs/models/message.dart';

class AppData {
  static final GeolocatorPlatform geolocatorPlatform =
      GeolocatorPlatform.instance;
  static StreamSubscription<Position>? positionStreamSubscription;

  static int currentBusIndex = -1;
  static bool isTracking = false;

  static FlutterTts flutterTts = FlutterTts();
  static List<BusStop> busStopList = [];
  static List<List<BusStop>> routeList = [];
  static List<Bus> busList = [];

  static final List<BusStop> testStop = [
    BusStop(
      id: 1,
      name: "လက်ပံကုန်း",
      latitude: 21.82533,
      longitude: 96.355862,
    ),
    BusStop(
      id: 2,
      name: "ရွာမလမ်းဆုံ",
      latitude: 21.837542,
      longitude: 96.355197,
    ),
    BusStop(id: 3, name: "မိသားစု", latitude: 21.846795, longitude: 96.349075),
    BusStop(
      id: 4,
      name: "အောက်စခန်း",
      latitude: 21.857323,
      longitude: 96.34807,
    ),
    BusStop(
      id: 5,
      name: "၆ ထပ်ကွေ့",
      latitude: 21.856444,
      longitude: 96.335372,
    ),
    BusStop(id: 6, name: "ပေပင်", latitude: 21.859933, longitude: 96.317823),
    BusStop(
      id: 7,
      name: "လွန်ကောင်း",
      latitude: 21.803346,
      longitude: 96.331013,
    ),
    BusStop(
      id: 8,
      name: "အိမ်ဂျယ်ကမ့်",
      latitude: 21.817823,
      longitude: 96.335905,
    ),
    BusStop(
      id: 9,
      name: "နောင်ဝယ်",
      latitude: 21.8261549,
      longitude: 96.3371543,
    ),
    BusStop(id: 10, name: "နတ်စင်", latitude: 21.835825, longitude: 96.34297),

    BusStop(id: 11, name: "ပြင်စာ", latitude: 21.867082, longitude: 96.356845),
    BusStop(
      id: 12,
      name: "ရတနာပုံတယ်လီ‌ပေါ့",
      latitude: 21.877886,
      longitude: 96.351827,
    ),

    BusStop(
      id: 13,
      name: "သုံးတောင်",
      latitude: 21.892834990749435,
      longitude: 96.3585538634988,
    ),
    BusStop(
      id: 14,
      name: "ကျောက်ဖျာဒိုး",
      latitude: 21.903940971474682,
      longitude: 96.36229567615949,
    ),
    BusStop(
      id: 15,
      name: "ဖားအောက်တောရ",
      latitude: 21.914771356816388,
      longitude: 96.36558450578559,
    ),
    BusStop(
      id: 16,
      name: "ဂျင်ဂနိုင်အောက်",
      latitude: 21.921606403595202,
      longitude: 96.37240837185864,
    ),
    BusStop(
      id: 17,
      name: "ဂျင်ဂနိုင်ထက်",
      latitude: 21.926915933853614,
      longitude: 96.37756266743946,
    ),
    BusStop(
      id: 18,
      name: "ညောင်ပင်",
      latitude: 21.93193779406747,
      longitude: 96.3832742962214,
    ),
    BusStop(
      id: 19,
      name: "အောင်ချမ်းသာ",
      latitude: 21.937749531346977,
      longitude: 96.38723058952361,
    ),
  ];

  static final List<Bus> testbus = [busOne, busTwo, bus3];

  static final Bus busOne = Bus(
    id: 1,
    name: "Bus One",
    routeName: "ရွာမ ⇆ ပြင်စာ",
    colorCode: "#DF504E",
    routeOne: [1, 2, 3, 4, 5, 6],
    routeTwo: [6, 5, 4, 3, 2, 1],
  );

  static final Bus busTwo = Bus(
    id: 2,
    name: "Bus Two",
    routeName: "လွန်ကောင်း ⇆ ရတနာပုံတယ်လီပေါ့",
    colorCode: "#405CAA",
    routeOne: [7, 8, 9, 10, 3, 4, 11, 12],
    routeTwo: [12, 11, 4, 3, 10, 9, 8, 7],
  );

  static final Bus bus3 = Bus(
    id: 3,
    name: "Bus Three",
    colorCode: "#DAF7A6",
    routeName: "သုံးတောင် ⇆ အောင်ချမ်းသာ",
    routeOne: [13, 14, 15, 16, 17, 18, 19],
    routeTwo: [19, 18, 17, 16, 15, 14, 13],
  );

  static List<Message> testMessages = [
    Message(
      id: 1,
      dateTime: DateTime.now(),
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna.",
      text:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna. Suspendisse ac semper ipsum. Etiam vel ullamcorper nulla. Cras condimentum lacus eget sodales pulvinar. Donec sit amet ipsum nec velit viverra feugiat. Nam a efficitur est. Phasellus justo justo, rhoncus ac scelerisque ut, consectetur sit amet urna. Sed lobortis lacus est, in elementum est efficitur eget. Curabitur non nunc non ipsum ornare hendrerit. Nunc lectus velit, viverra sit amet sapien sed, luctus tristique enim. Sed molestie, quam at rutrum pulvinar, nisi mi fermentum enim, sit amet rutrum eros sapien vel neque. Nam eleifend sem at eros gravida bibendum. Vivamus ex magna, pharetra dictum convallis sed, ultricies sit amet ipsum. Vestibulum eros sapien, congue et urna nec, viverra cursus eros. Praesent quis convallis eros. Morbi malesuada metus eget quam tincidunt ultricies. Integer ornare neque at orci vehicula, sed tristique est vulputate. Aliquam ultrices facilisis auctor. Fusce id arcu ante. Fusce pulvinar et massa id suscipit. Praesent nec mi quis leo cursus viverra ac id justo.",
      category: "Trip/Journy",
    ),
    Message(
      id: 2,
      dateTime: DateTime.now(),
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna.",
      text:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna. Suspendisse ac semper ipsum. Etiam vel ullamcorper nulla. Cras condimentum lacus eget sodales pulvinar. Donec sit amet ipsum nec velit viverra feugiat. Nam a efficitur est. Phasellus justo justo, rhoncus ac scelerisque ut, consectetur sit amet urna. Sed lobortis lacus est, in elementum est efficitur eget. Curabitur non nunc non ipsum ornare hendrerit. Nunc lectus velit, viverra sit amet sapien sed, luctus tristique enim. Sed molestie, quam at rutrum pulvinar, nisi mi fermentum enim, sit amet rutrum eros sapien vel neque. Nam eleifend sem at eros gravida bibendum. Vivamus ex magna, pharetra dictum convallis sed, ultricies sit amet ipsum. Vestibulum eros sapien, congue et urna nec, viverra cursus eros. Praesent quis convallis eros. Morbi malesuada metus eget quam tincidunt ultricies. Integer ornare neque at orci vehicula, sed tristique est vulputate. Aliquam ultrices facilisis auctor. Fusce id arcu ante. Fusce pulvinar et massa id suscipit. Praesent nec mi quis leo cursus viverra ac id justo.",

      category: "Trip/Journy",
    ),
    Message(
      id: 3,
      dateTime: DateTime.now(),
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna.",
      text:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna. Suspendisse ac semper ipsum. Etiam vel ullamcorper nulla. Cras condimentum lacus eget sodales pulvinar. Donec sit amet ipsum nec velit viverra feugiat. Nam a efficitur est. Phasellus justo justo, rhoncus ac scelerisque ut, consectetur sit amet urna. Sed lobortis lacus est, in elementum est efficitur eget. Curabitur non nunc non ipsum ornare hendrerit. Nunc lectus velit, viverra sit amet sapien sed, luctus tristique enim. Sed molestie, quam at rutrum pulvinar, nisi mi fermentum enim, sit amet rutrum eros sapien vel neque. Nam eleifend sem at eros gravida bibendum. Vivamus ex magna, pharetra dictum convallis sed, ultricies sit amet ipsum. Vestibulum eros sapien, congue et urna nec, viverra cursus eros. Praesent quis convallis eros. Morbi malesuada metus eget quam tincidunt ultricies. Integer ornare neque at orci vehicula, sed tristique est vulputate. Aliquam ultrices facilisis auctor. Fusce id arcu ante. Fusce pulvinar et massa id suscipit. Praesent nec mi quis leo cursus viverra ac id justo.",

      category: "System",
    ),
    Message(
      id: 4,
      dateTime: DateTime.now(),
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna.",
      text:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna. Suspendisse ac semper ipsum. Etiam vel ullamcorper nulla. Cras condimentum lacus eget sodales pulvinar. Donec sit amet ipsum nec velit viverra feugiat. Nam a efficitur est. Phasellus justo justo, rhoncus ac scelerisque ut, consectetur sit amet urna. Sed lobortis lacus est, in elementum est efficitur eget. Curabitur non nunc non ipsum ornare hendrerit. Nunc lectus velit, viverra sit amet sapien sed, luctus tristique enim. Sed molestie, quam at rutrum pulvinar, nisi mi fermentum enim, sit amet rutrum eros sapien vel neque. Nam eleifend sem at eros gravida bibendum. Vivamus ex magna, pharetra dictum convallis sed, ultricies sit amet ipsum. Vestibulum eros sapien, congue et urna nec, viverra cursus eros. Praesent quis convallis eros. Morbi malesuada metus eget quam tincidunt ultricies. Integer ornare neque at orci vehicula, sed tristique est vulputate. Aliquam ultrices facilisis auctor. Fusce id arcu ante. Fusce pulvinar et massa id suscipit. Praesent nec mi quis leo cursus viverra ac id justo.",

      category: "Service",
    ),
    Message(
      id: 5,
      dateTime: DateTime.now(),
      title:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna.",
      text:
          "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent non finibus urna. Suspendisse ac semper ipsum. Etiam vel ullamcorper nulla. Cras condimentum lacus eget sodales pulvinar. Donec sit amet ipsum nec velit viverra feugiat. Nam a efficitur est. Phasellus justo justo, rhoncus ac scelerisque ut, consectetur sit amet urna. Sed lobortis lacus est, in elementum est efficitur eget. Curabitur non nunc non ipsum ornare hendrerit. Nunc lectus velit, viverra sit amet sapien sed, luctus tristique enim. Sed molestie, quam at rutrum pulvinar, nisi mi fermentum enim, sit amet rutrum eros sapien vel neque. Nam eleifend sem at eros gravida bibendum. Vivamus ex magna, pharetra dictum convallis sed, ultricies sit amet ipsum. Vestibulum eros sapien, congue et urna nec, viverra cursus eros. Praesent quis convallis eros. Morbi malesuada metus eget quam tincidunt ultricies. Integer ornare neque at orci vehicula, sed tristique est vulputate. Aliquam ultrices facilisis auctor. Fusce id arcu ante. Fusce pulvinar et massa id suscipit. Praesent nec mi quis leo cursus viverra ac id justo.",

      category: "Trip/Journy",
    ),
  ];
}
