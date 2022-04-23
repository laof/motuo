import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/env-setting.screen.dart';
import 'package:flutter_inappwebview_example/env.data.dart';

import 'package:flutter_inappwebview_example/headless_in_app_webview.screen.dart'
    show HeadlessInAppWebViewExampleScreen;
import 'package:flutter_inappwebview_example/in_app_webiew_example.screen.dart';
import 'package:flutter_inappwebview_example/in_app_browser_example.screen.dart'
    show InAppBrowserExampleScreen;

import 'package:flutter_inappwebview_example/in_app_javascript_screen.dart';
import 'package:flutter_inappwebview_example/js.cache.dart';
import 'package:flutter_inappwebview_example/setting.screen.dart';
import 'package:flutter_inappwebview_example/setting.data.dart';

List<SettingMap> sm = [];

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      await serviceWorkerController
          .setServiceWorkerClient(AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          return null;
        },
      ));
    }
  }

  SettingList sl = SettingList();

  EnvSetup es = EnvSetup();
  await es.init();

  var isFirst = await sl.init();
  sm = sl.list;

  if (isFirst) {
    await Future.forEach(sm, (dynamic element) async {
      Javascript js = Javascript(element.javascript);
      await js.init();
    });
  }

  runApp(MyApp());
}

Drawer myDrawer({required BuildContext context}) {
  List<ListTile> list = [];

  sm.forEach((element) => {
        list.add(ListTile(
          title: Text(element.name),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/my_' + element.id);
          },
        ))
      });

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text(
            'My Browser',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ...list,
        ListTile(
          title: Text('Browser'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/browser');
          },
        ),
        ListTile(
          title: Text('WebView'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/webview');
          },
        ),
        ListTile(
          title: Text('Headless'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/headless');
          },
        ),
        ListTile(
          title: Text('Env variable'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/env');
          },
        ),
        ListTile(
          title: Text('Setting'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/setting');
          },
        ),
      ],
    ),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, WidgetBuilder> map = {
      '/browser': (context) => InAppBrowserExampleScreen(),
      '/webview': (context) => InAppWebViewExampleScreen(),
      '/env': (context) => EnvListScreen(),
      '/headless': (context) => HeadlessInAppWebViewExampleScreen(),
      '/setting': (context) => ChromeSafariBrowserExampleScreen(),
    };

    String first = "";
    sm.forEach((obj) {
      var key = '/my_' + obj.id;

      if (first == "") {
        first = key;
      }
      map[key] = (context) => JavascriptScreen(obj);
    });
    return MaterialApp(initialRoute: first, routes: map);
  }
}
