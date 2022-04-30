import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:motuo/conf.dart';
import 'package:path_provider/path_provider.dart';

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

  file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/jobv2.json');
  }

  loadList() async {
    File f = await file();
    final str = await f.readAsString();
    var arr = json.decode(str);

    arr.forEach((element) {
      this.list.add(SettingMap(element));
    });
  }

  readAsString() async {
    File f = await file();
    return await f.readAsString();
  }

  update() async {
    final url = Uri.parse(config);
    File f = await file();
    var response = await http.get(url);
    await f.writeAsString(response.body);
    await loadList();
  }

  init() async {
    File f = await file();
    var b = await f.exists();
    if (b) {
      await loadList();
    } else {
      await update();
    }
    return b;
  }
}
