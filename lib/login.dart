import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/env.data.dart';
import 'package:motuo/cache_js.dart';
import 'package:motuo/sys.data.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:http/http.dart' as http;
import 'main.dart';

class Login extends StatefulWidget {
  SettingMap obj;
  Login(this.obj);
  @override
  LoginState createState() => new LoginState(this.obj);
}

class LoginState extends State<Login> {
  HeadlessInAppWebView? headlessWebView;
  String log = "";
  String runfunc = "run()";
  SettingMap obj;
  LoginState(this.obj);

  @override
  void initState() {
    super.initState();
    checkNetwork();
  }

  checkParameter() async {
    List<dynamic> plist = obj.parameter;

    if (plist.length > 0) {
      EnvSetup es = EnvSetup();
      await es.loadMap();

      Map map = es.map;
      List input = [];

      obj.parameter.forEach((key) {
        final value = map[key].toString().trim();
        if (map[key] != null && value != "") {
          input.add("'" + map[key] + "'");
        }
      });

      if (input.length == plist.length) {
        runfunc = "run(${input.join(",")})";
        return true;
      }
    }
    return false;
  }

  checkNetwork() async {
    if (!await checkParameter()) {
      setState(() {
        this.log = 'parameter error';
      });
      return;
    }

    final PermissionHandlerPlatform _permissionHandler =
        PermissionHandlerPlatform.instance;
    final startus =
        await _permissionHandler.checkPermissionStatus(Permission.location);

    if (startus == PermissionStatus.denied) {
      setState(() {
        this.log = 'network permission denied';
      });
      return;
    }

    final NetworkInfo _networkInfo = NetworkInfo();
    try {
      var wifiName = await _networkInfo.getWifiName();
      String targetWifi = obj.variable[0].toString();

      if (wifiName == null) {
        setState(() {
          log = 'no wifi';
        });
        return;
      } else {
        var wl = wifiName.toString().toLowerCase();
        var wifi = targetWifi.toLowerCase();
        if (!wl.contains(wifi)) {
          setState(() {
            log = wifiName + ' is unknown, please connect to ' + targetWifi;
          });
          return;
        }
      }

      // final response = await http.get(Uri.parse(oktxt));

      http.Response res = await http.get(Uri.parse(obj.page)).timeout(
          Duration(seconds: 3),
          onTimeout: () => http.Response('error', 408));

      if (res.statusCode != 200) {
        setState(() {
          log = 'welcome to ' + targetWifi;
        });
        return;
      }
    } on PlatformException catch (_) {
      setState(() {
        log = 'network status check failed';
      });
      return;
    }

    headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(obj.page)),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(),
      ),
      onWebViewCreated: (controller) {
//        print('HeadlessInAppWebView created!');
      },
      onConsoleMessage: (controller, consoleMessage) {
        setState(() {
          this.log = this.log + consoleMessage.message + '\n\n';
        });
//        print("CONSOLE MESSAGE: " + consoleMessage.message);
      },
      onLoadStart: (controller, url) async {
//        print("onLoadStart $url");
        setState(() {
          this.log = this.log + '... \n\n';
        });
      },
      onLoadStop: (controller, url) async {
//        print("onLoadStop $url");
        injectJS();
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
//        print("onUpdateVisitedHistory $url");
      },
    );

    headlessWebView?.run();
  }

  injectJS() async {
    try {
      Javascript javascript = Javascript(obj.javascript);
      var js = await javascript.loadFile();
      await headlessWebView?.webViewController.evaluateJavascript(source: """
(function(){
  $js
  if (typeof run === 'function') {
    $runfunc
  } else {
    console.log('not found run function')
  }
})()
    """);
    } on MissingPluginException {
      setState(() {
        this.log = this.log + "js is not running\n\n";
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    headlessWebView?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          obj.name,
        )),
        drawer: myDrawer(context: context),
        body: SafeArea(
          child: Column(children: <Widget>[
            Expanded(
                child: Stack(children: [
              ListView(children: [
                Padding(padding: const EdgeInsets.all(8), child: Text(log))
              ])
            ])),
            ElevatedButton(
                onPressed: () async {
                  var route = ModalRoute.of(context);
                  if (route != null) {
                    await Navigator.pushReplacementNamed(
                        context, route.settings.name.toString());
                  }
                },
                child: Icon(Icons.refresh)),
          ]),
        ));
  }
}
