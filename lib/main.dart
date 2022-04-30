import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/env-setting.screen.dart';
import 'package:motuo/env.data.dart';


import 'package:motuo/login.dart';
import 'package:motuo/js.cache.dart';
import 'package:motuo/setting.screen.dart';
import 'package:motuo/setting.data.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';
import 'package:motuo/in_app_javascript_screen.dart';

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


  EnvSetup es = EnvSetup();
  await es.init();

  SettingList sl = SettingList();
  var isFirst = await sl.init();
  sm = sl.list;


  if (isFirst) {
    await Future.forEach(sm, (dynamic element) async {
      Javascript js = Javascript(element.javascript);
      await js.init();
    });
  }

  final PermissionHandlerPlatform _permissionHandler =
      PermissionHandlerPlatform.instance;

  await _permissionHandler.requestPermissions([Permission.location]);

  runApp(MyApp());
}

Drawer myDrawer({required BuildContext context}) {
  List<ListTile> list = [];

  sm.forEach((element) => {
        list.add(ListTile(
          title: Text(element.name),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/my_' + element.name);
          },
        ))
      });

  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text(
            'Motuo',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ...list,
        ListTile(
          title: Text('Env variable'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/env');
          },
        ),
        ListTile(
          title: Text('Sys config'),
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
//      '/browser': (context) => InAppBrowserExampleScreen(),
//      '/webview': (context) => InAppWebViewExampleScreen(),
//      '/headless': (context) => HeadlessInAppWebViewExampleScreen(),
      '/env': (context) => EnvListScreen(),
      '/setting': (context) => ChromeSafariBrowserExampleScreen(),
    };

    String first = "";
    sm.forEach((obj) {
      var key = '/my_' + obj.name;

      if (first == "") {
        first = key;
        map[key] = (context) => Login(obj);
      } else {
        map[key] = (context) => JavascriptScreen(obj);
      }
    });
    return MaterialApp(initialRoute: first, routes: map);
  }
}
