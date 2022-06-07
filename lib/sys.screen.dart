import 'package:motuo/cache_js.dart';
import 'package:motuo/my_dialog.dart';
import 'package:motuo/sys.data.dart';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/conf.dart';
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
    String? str = await sl.getValue();

    if (str == null) {
      return null;
    }

    setState(() {
      log = str.replaceAll(server, "server");
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
          "Sys config",
        )),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
                child: Stack(children: [
                  ListView(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8), child: Text(log))
                    ],
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
