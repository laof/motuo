import 'dart:io';

void main(List<String> args) {
  var pf = args[0];
  print("build planform:" + pf);

  File apk = File('build/app/outputs/flutter-apk/app-release.apk');

  var f = File("motuo-apk.apk");
  if (f.existsSync()) {
    f.deleteSync();
  }

  apk.copySync("motuo-apk.apk");
}
