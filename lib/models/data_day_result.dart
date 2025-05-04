import 'next_days.dart';

class DayliResult {
  List<ListDataDaily>? list;

  static var dt;

  DayliResult({this.list});

  DayliResult.fromJson(Map<String, dynamic> json) {
    if (json['list'] != null) {
      list = <ListDataDaily>[];
      json['list'].forEach((v) {
        list!.add(ListDataDaily.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};

    if (list != null) {
      data['list'] = list!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ListDataDaily {
  int? dt;
  Main? main;
  List<Weather>? weather;

  ListDataDaily({this.dt, this.main, this.weather});

  ListDataDaily.fromJson(Map<String, dynamic> json) {
    dt = json['dt'];
    main = json['main'] != null ? Main.fromJson(json['main']) : null;
    if (json['weather'] != null) {
      weather = <Weather>[];
      json['weather'].forEach((v) {
        weather!.add(Weather.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var data = <String, dynamic>{};

    if (main != null) {
      data['main'] = main!.toJson();
    }
    if (weather != null) {
      data['weather'] = weather!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
