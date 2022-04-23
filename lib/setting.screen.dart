import 'dart:io';

import 'package:flutter_inappwebview_example/js.cache.dart';
import 'package:flutter_inappwebview_example/my-dialog.dart';
import 'package:flutter_inappwebview_example/setting.data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';

class MyChromeSafariBrowser extends ChromeSafariBrowser {
  @override
  void onOpened() {
    print("ChromeSafari browser opened");
  }

  @override
  void onCompletedInitialLoad() {
    print("ChromeSafari browser initial load completed");
  }

  @override
  void onClosed() {
    print("ChromeSafari browser closed");
  }
}

class ChromeSafariBrowserExampleScreen extends StatefulWidget {
  final ChromeSafariBrowser browser = MyChromeSafariBrowser();

  @override
  _ChromeSafariBrowserExampleScreenState createState() =>
      _ChromeSafariBrowserExampleScreenState();
}

class _ChromeSafariBrowserExampleScreenState
    extends State<ChromeSafariBrowserExampleScreen> {
  String log = "";

  _loadfile() async {
    SettingList sl = SettingList();
    String str = await sl.readAsString();
    setState(() {
      log = str;
    });
  }

  @override
  void initState() {
    widget.browser.addMenuItem(ChromeSafariBrowserMenuItem(
        id: 1,
        label: 'Custom item menu 1',
        action: (url, title) {
          print('Custom item menu 1 clicked!');
        }));
    widget.browser.addMenuItem(ChromeSafariBrowserMenuItem(
        id: 2,
        label: 'Custom item menu 2',
        action: (url, title) {
          print('Custom item menu 2 clicked!');
        }));
    super.initState();
    _loadfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "Setting",
        )),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
                child: Stack(children: [
                  ListView(
                    children: [Text(log)],
                  )
                ]),
              ),
              ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      log = "loading...";
                    });

                    var size = 0;

                    SettingList sl = SettingList();
                    await sl.update();

                    List<SettingMap> list = sl.list;

                    await Future.forEach(list, (dynamic element) async {
                      Javascript js = Javascript(element.javascript);
                      await js.update();
                      size++;
                    });

                    if (size > 0) {
                      MyDialog.info(context, "updated:${size.toString()}");
                    }

                    _loadfile();
                  },
                  child: Icon(Icons.refresh)),
            ])));
  }
}
