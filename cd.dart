import 'dart:io';

void main(List<String> args) {
  var pf = args[0];
  print("build planform:" + pf);
  if (pf == "apk") {
    File apk = File('build/app/outputs/flutter-apk/app-release.apk');

    var f = File("motuo-apk.apk");
    if (f.existsSync()) {
      f.deleteSync();
    }

    apk.copySync("motuo-apk.apk");
  } else {
    // File app = File('build/ios/iphoneos/Runner.app.');
    // app.copySync("motuo-app.app");
  }
}
