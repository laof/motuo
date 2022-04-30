import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class EnvSetup {
  Map map = {};

  save() {}

  file() async {
    final dir = await getApplicationSupportDirectory();
    return File('${dir.path}/fdf9_8362af_fds9r845_fds37485_env.json');
  }

  loadMap() async {
    File f = await file();
    var str = await f.readAsString();
    map = json.decode(str.toString());
  }

  writeAsString(String str) async {
    final f = await file();
    await f.writeAsString(str);
  }

  init() async {
    File f = await file();
    var b = await f.exists();
    if (!b) {
      await f.writeAsString("{}");
    }
  }
}
