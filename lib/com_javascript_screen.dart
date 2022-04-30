import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/env.data.dart';
import 'package:motuo/my_dialog.dart';
import 'package:motuo/js.cache.dart';
import 'package:motuo/setting.data.dart';
import 'package:motuo/url.dart';
import 'main.dart';

var firstview = 'Loading, please wait...\n\n';

class ConmonJavascriptScreen extends StatefulWidget {
  SettingMap obj;
  ConmonJavascriptScreen(this.obj);
  @override
  _ComState createState() => new _ComState(this.obj);
}

class _ComState extends State<ConmonJavascriptScreen> {
  HeadlessInAppWebView? headlessWebView;
  String result = "";
  String log = firstview ;
  SettingMap obj;

  _ComState(this.obj);

  inject() async {
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

      var r = await headlessWebView?.webViewController
          .evaluateJavascript(source: """
(function(){
  $js
  if (typeof run === 'function') {
     return $runfunc
  } else {
    console.log('not found run function')
    return ""
  }
})()
    """);

      if (r.toString() != "") {
        result = r.toString();
      }
    } on MissingPluginException {
      print(
          "HeadlessInAppWebView is not running. Click on \"Run HeadlessInAppWebView\"!");
    }
  }

  @override
  void initState() {
    super.initState();
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
//        print("CONSOLE MESSAGE: " + consoleMessage.message);
      },
      onLoadStart: (controller, url) async {
        print("onLoadStart $url");
      },
      onLoadStop: (controller, url) async {
        print("onLoadStop $url");
        inject();
      },
      onUpdateVisitedHistory: (controller, url, androidIsReload) {
        print("onUpdateVisitedHistory $url");
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
                    this.log = firstview;
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
                  if (result.toString() != "") {
                    Clipboard.setData(ClipboardData(text: result.toString()));
                    setState(() {
                      log = log + "copied successful" + '\n\n';
                    });
                  } else {
                    setState(() {
                      log = log + "no data, copy failed" + '\n\n';
                    });
                  }
                },
                child: Text("Copy")),
          ],
        ),
      ])),
    );
  }
}
