import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motuo/conf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingMap {
  String name = "";
  String page = "";
  String javascript = "";
  String version = "";
  List<dynamic> parameter = [];
  List<dynamic> variable = [];

  SettingMap(Map map) {
    this.name = map["name"];
    this.page = map["page"];
    this.version = map["version"];
    this.javascript = map["javascript"];
    this.parameter = map["parameter"].toList();
    this.variable = map["variable"].toList();
  }
}

class SettingList {
  List<SettingMap> list = [];

  String _varkey = 'bG9uZ2h1YW5paGFvemhlc2Vz';

  file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/jobv2.json');
  }

  // loadList0() async {
  //   File f = await file();
  //   final str = await f.readAsString();
  //   var arr = json.decode(str);

  //   arr.forEach((element) {
  //     this.list.add(SettingMap(element));
  //   });
  // }

  loadList() async {
    String? str = await getValue();

    if (str == null) {
      return null;
    }

    var arr = json.decode(str);

    arr.forEach((element) {
      this.list.add(SettingMap(element));
    });
  }

  // readAsString() async {
  //   File f = await file();
  //   return await f.readAsString();
  // }

  // update() async {
  //   final url = Uri.parse(config);
  //   File f = await file();
  //   var response = await http.get(url);
  //   await f.writeAsString(response.body);
  //   await loadList();
  // }
  update() async {
    final url = Uri.parse(config);
    var response = await http.get(url);
    var inst = await getInstance();
    await inst.setString(_varkey, response.body);
    await loadList();
  }

  Future<SharedPreferences> getInstance() async {
    // Obtain shared preferences.
    return await SharedPreferences.getInstance();
  }

  Future<String?> getValue() async {
    // Obtain shared preferences.
    var instn = await SharedPreferences.getInstance();
    return instn.getString(_varkey);
  }

  Future<bool> init() async {
    String? value = await getValue();
    if (value == null) {
      await update();
    } else {
      await loadList();
    }
    return value != null;
  }

  // init() async {
  //   File f = await file();
  //   var b = await f.exists();
  //   if (b) {
  //     await loadList();
  //   } else {
  //     await update();
  //   }
  //   return b;
  // }
}
