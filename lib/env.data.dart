import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EnvSetup {
  Map map = {};

  String _varkey = 'fdf9_8362af_fds9r845_fds37485_env';

  save() {}

  // file0() async {
  //   final dir = await getApplicationSupportDirectory();
  //   return File('${dir.path}/fdf9_8362af_fds9r845_fds37485_env.json');
  // }

  Future<SharedPreferences> getInstance() async {
    // Obtain shared preferences.
    return await SharedPreferences.getInstance();
  }

  // loadMap0() async {
  //   File f = await file();
  //   var str = await f.readAsString();
  //   map = json.decode(str.toString());
  // }

  Future<String?> getValue() async {
    final prefs = await getInstance();
    return prefs.getString(_varkey);
  }

  loadMap() async {
    String? value = await getValue();
    if (value != null) {
      map = json.decode(value);
    }
  }

  // writeAsString0(String str) async {
  //   final f = await file();
  //   await f.writeAsString(str);
  // }

  writeAsString(String str) async {
    final prefs = await getInstance();
    await prefs.setString(_varkey, str);
  }

  // init0() async {
  //   File f = await file();
  //   var b = await f.exists();
  //   if (!b) {
  //     await f.writeAsString("{}");
  //   }
  // }

  init() async {
    String? value = await getValue();
    if (value == null) {
      writeAsString("{}");
    }
  }
}
