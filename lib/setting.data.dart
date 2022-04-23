import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class SettingMap {
  String id = "";
  String name = "";
  String title = "";
  String page = "";
  String javascript = "";
  List<dynamic> parameter = [];

  SettingMap(Map map) {
    this.id = map["id"];
    this.name = map["name"];
    this.title = map["title"];
    this.page = map["page"];
    this.javascript = map["javascript"];
    this.parameter = map["parameter"].toList();
  }
}

class SettingList {
  List<SettingMap> list = [];

  file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/job.json');
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
    final url = Uri.parse("https://laof.github.io/assets/data/f.json");
    File f = await file();
    var response = await http.get(url);
    await f.writeAsString(response.body);
    await loadList();
  }

  init() async {
    File f = await file();
    var b = await f.exists();
    if (!b) {
      await update();
    }
    await loadList();
    return !b;
  }
}
