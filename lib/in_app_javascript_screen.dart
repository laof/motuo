import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/env.data.dart';
import 'package:motuo/my-dialog.dart';
import 'package:motuo/js.cache.dart';
import 'package:motuo/setting.data.dart';
import 'package:motuo/url.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

import 'main.dart';

class JavascriptScreen extends StatefulWidget {
  SettingMap obj;
  JavascriptScreen(this.obj);

  @override
  _ScreenState createState() => new _ScreenState(this.obj);
}

class _ScreenState extends State<JavascriptScreen> {
  HeadlessInAppWebView? headlessWebView;
  String url = "";
  String log = "";

  SettingMap obj;

  _ScreenState(this.obj);

  _zhuru() async {
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

      String metaTagList = (await headlessWebView?.webViewController
          .evaluateJavascript(source: """
(function(){
  $js
  if (typeof run === 'function') {
    $runfunc
  } else {
    console.log('not found run function')
  }
})()
    """));

      setState(() {
        this.log = this.log + metaTagList + '\n\n';
      });
    } on MissingPluginException {
      print(
          "HeadlessInAppWebView is not running. Click on \"Run HeadlessInAppWebView\"!");
    }
  }

  _run() async {
    try {
      await headlessWebView?.run();
    } on MissingPluginException {}
  }

  final PermissionHandlerPlatform _permissionHandler =
      PermissionHandlerPlatform.instance;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  Future<void> requestPermission() async {
//    setState(() {
//      print(status);
//      _permissionStatus = status[Permission] ?? PermissionStatus.denied;
//      print(_permissionStatus);
//    });
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
    createHeadlessWebView();
  }

  createHeadlessWebView() async {
    headlessWebView = new HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: Uri.parse(obj.page)),
      initialOptions: InAppWebViewGroupOptions(
        crossPlatform: InAppWebViewOptions(),
      ),
      onWebViewCreated: (controller) {
        print('HeadlessInAppWebView created!');
      },
      onConsoleMessage: (controller, consoleMessage) {
        setState(() {
          this.log = this.log + consoleMessage.message + '\n\n';
        });

        print("CONSOLE MESSAGE: " + consoleMessage.message);
      },
      onLoadStart: (controller, url) async {
        print("onLoadStart $url");
        setState(() {
          this.url = url.toString();
        });
      },
      onLoadStop: (controller, url) async {
        print("onLoadStop $url");
        setState(() {
          _zhuru();
          this.url = url.toString();
        });
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        print("onUpdateVisitedHistory $url");
        setState(() {
          this.url = url.toString();
        });
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
//          minimum: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: Column(children: <Widget>[
        Expanded(
            child: Stack(children: [
//          Container(
//            child: Text("CURRENT URL:${url}"),
//          ),

          ListView(children: [
            Padding(padding: const EdgeInsets.all(8), child: Text(log))
          ])
        ])),
        ButtonBar(
          alignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: () async {
                  await headlessWebView?.dispose();
                  await headlessWebView?.run();
                  setState(() {
                    this.log = "";
                  });
                },
                child: Text("Restart")),
            ElevatedButton(
              child: Icon(Icons.settings_accessibility_sharp),
              onPressed: () {
                try {
                  var t = """
${obj.name} ${obj.version}

HOME：${obj.page}
JAVASCRIPT：${obj.javascript.replaceAll(server, "server")}
PARAMETER：${obj.parameter}
""";
                  MyDialog.info(context, t);
                } catch (e) {}
              },
            ),
            ElevatedButton(
                onPressed: () {
                  headlessWebView?.dispose();
                },
                child: Text("Dispose")),
          ],
        ),
      ])),
    );
  }
}
