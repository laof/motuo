import 'package:motuo/conf.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Javascript {
  String _url = "";
  // String _filename = '';

  Javascript(String str) {
    this._url = str;
    // print(str);
    // _filename = str.replaceAll(server, "server");
    // _filename = _filename.replaceAll("/", ".");
    // print(_filename);
  }

  // file() async {
  //   final dir = await getTemporaryDirectory();
  //   return File('${dir.path}/$_filename');
  // }

  // update0() async {
  //   final url = Uri.parse(_url);
  //   var response = await http.get(url);
  //   final f = await file();
  //   await f.writeAsString(response.body);
  // }

  update() async {
    // Obtain shared preferences.
    final prefs = await SharedPreferences.getInstance();
    final url = Uri.parse(_url);
    var response = await http.get(url);
    await prefs.setString(_url, response.body);
  }

  // loadFile0() async {
  //   final f = await file();
  //   return await f.readAsString();
  // }

  Future<String?> loadFile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_url);
  }

  // init0() async {
  //   File f = await file();
  //   if (await f.exists() == false) {
  //     await update();
  //   }
  // }

  init() async {
    String? f = await loadFile();
    if (f == null) {
      await update();
    }
  }
}
