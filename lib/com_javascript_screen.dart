import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/env.data.dart';
import 'package:motuo/my_dialog.dart';
import 'package:motuo/cache_js.dart';
import 'package:motuo/sys.data.dart';
import 'package:motuo/conf.dart';
import 'main.dart';

class ConmonJavascriptScreen extends StatefulWidget {
  SettingMap obj;
  ConmonJavascriptScreen(this.obj);
  @override
  _ComState createState() => new _ComState(this.obj);
}

class _ComState extends State<ConmonJavascriptScreen> {
  HeadlessInAppWebView? headlessWebView;
  String result = "";
  String log = "";
  SettingMap obj;

  _ComState(this.obj);

  inject() async {
    var runFunc = "run()";

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
      runFunc = "run(${parameter.join(",")})";
    }

    try {
      Javascript javascript = Javascript(obj.javascript);
      var js = await javascript.loadFile();

      var r = await headlessWebView?.webViewController
          .evaluateJavascript(source: """
(function(){
  $js
  if (typeof run === 'function') {
     return $runFunc
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
//        print('HeadlessInAppWebView created!');
        setState(() {
          log = log + "workspace created successfully\n\n";
        });
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
          log = log + "loading, please wait...\n\n";
        });
      },
      onLoadStop: (controller, url) async {
        setState(() {
          log = log + "resource loaded successfully, executing...\n\n";
        });
        await inject();
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
                    this.log = 'retry, please wait...\n\n';
                  });
                },
                child: Text("Restart")),
            ElevatedButton(
              child: Icon(Icons.settings_accessibility_sharp),
              onPressed: () {
                try {
                  var t = """
${obj.name} ${obj.version}

HOME:${obj.page}
JAVASCRIPT:${obj.javascript.replaceAll(server, "server")}
PARAMETER:${obj.parameter}
""";
                  MyDialog.info(context, t);
                } catch (e) {}
              },
            ),
            ElevatedButton(
                onPressed: () {
                  var r = result.toString();
                  var mes = "copied successfully";
                  if (r != "" && r != "null") {
                    Clipboard.setData(ClipboardData(text: r));
                  } else {
                    mes = "no data, copy failed";
                  }

                  setState(() {
                    log = log + mes + '\n\n';
                  });
                },
                child: Text("Copy")),
          ],
        ),
      ])),
    );
  }
}
