import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class Javascript {
  String _url = "";
  String _filename = '';

  Javascript(String str) {
    this._url = str;
    this._filename = Uri.encodeComponent(str);
  }

  file() async {
    final dir = await getTemporaryDirectory();
    return File('${dir.path}/$_filename');
  }

  update() async {
    final url = Uri.parse(_url);
    var response = await http.get(url);
    final f = await file();
    await f.writeAsString(response.body);
  }

  loadFile() async {
    final f = await file();
    return await f.readAsString();
  }

  init() async {
    File f = await file();
    if (!(await f.exists())) {
      await update();
    }
  }
}
