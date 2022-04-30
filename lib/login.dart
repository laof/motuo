import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/env.data.dart';
import 'package:motuo/js.cache.dart';
import 'package:motuo/setting.data.dart';
import 'package:motuo/url.dart';
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
  SettingMap obj;
  LoginState(this.obj);

  injectJS() async {
    var runfunc = "run()";

    List<dynamic> plist = obj.parameter;

    if (plist.length > 0) {
      EnvSetup es = EnvSetup();
      await es.loadMap();

      Map map = es.map;
      List parameter = [];

      obj.parameter.forEach((key) {
        if (map.containsKey(key)) {
          parameter.add("'" + map[key] + "'");
        } else {
          parameter.add(Null);
        }
      });
      runfunc = "run(${parameter.join(",")})";
    }

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
      print(
          "HeadlessInAppWebView is not running. Click on \"Run HeadlessInAppWebView\"!");
    }
  }

  @override
  void initState() {
    super.initState();
    checkNetwork();
  }

  checkNetwork() async {
    final PermissionHandlerPlatform _permissionHandler =
        PermissionHandlerPlatform.instance;
    final status11 =
        await _permissionHandler.checkPermissionStatus(Permission.location);

    if (status11 == PermissionStatus.denied) {
      setState(() {
        this.log = 'no network permission \n\n';
      });
      return;
    }

    final NetworkInfo _networkInfo = NetworkInfo();
    try {
      var wifiName = await _networkInfo.getWifiName();
      String targetWifi = obj.variable[0].toString();

      if (wifiName == null) {
        setState(() {
          log = '没有连接WIFI';
        });
        return;
      } else {
        var wl = wifiName.toString().toLowerCase();
        var wifi = targetWifi.toLowerCase();
        if (!wl.contains(wifi)) {
          setState(() {
            log = wifiName + '不是目标WIFI，请连接到' + targetWifi;
          });
          return;
        }
      }

      final response = await http.get(Uri.parse(oktxt));

      if (response.statusCode == 200 && response.body.contains(okstr)) {
        setState(() {
          log = '网络可用，已经登录';
        });
        return;
      }
    } on PlatformException catch (e) {
      setState(() {
        log = '检查网络环境失败';
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
                    print(route.settings.name);
                    await Navigator.of(context)
                        .pushNamed(route.settings.name.toString());
                  }
                },
                child: Icon(Icons.refresh)),
          ]),
        ));
  }
}
