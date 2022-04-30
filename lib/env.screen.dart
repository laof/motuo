import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:motuo/env.data.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class SettingApp extends InAppBrowser {
  SettingApp(
      {int? windowId, UnmodifiableListView<UserScript>? initialUserScripts})
      : super(windowId: windowId, initialUserScripts: initialUserScripts);

  @override
  Future onBrowserCreated() async {
    print("\n\nBrowser Created!\n\n");
  }

  @override
  Future onLoadStart(url) async {
    print("\n\nStarted $url\n\n");
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    print("\n\nStopped $url\n\n");
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    print("Can't load $url.. Error: $message");
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    print("Progress: $progress");
  }

  @override
  void onExit() {
    print("\n\nBrowser closed!\n\n");
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(
      navigationAction) async {
    print("\n\nOverride ${navigationAction.request.url}\n\n");
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(response) {
    print("Started at: " +
        response.startTime.toString() +
        "ms ---> duration: " +
        response.duration.toString() +
        "ms " +
        (response.url ?? '').toString());
  }

  @override
  void onConsoleMessage(consoleMessage) {
    print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
  }
}

class SettingScreen extends StatefulWidget {
  final SettingApp browser = new SettingApp();

  @override
  _InAppBrowserExampleScreenState createState() =>
      new _InAppBrowserExampleScreenState();
}

class _InAppBrowserExampleScreenState extends State<SettingScreen> {
  late PullToRefreshController pullToRefreshController;

  @override
  void initState() {
    super.initState();

    pullToRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          widget.browser.webViewController.reload();
        } else if (Platform.isIOS) {
          widget.browser.webViewController.loadUrl(
              urlRequest: URLRequest(
                  url: await widget.browser.webViewController.getUrl()));
        }
      },
    );
    widget.browser.pullToRefreshController = pullToRefreshController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "Env variable",
        )),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
                child: Stack(children: [
                  InAppWebView(
                    onConsoleMessage: (controller, consoleMessage) async {
                      EnvSetup es = EnvSetup();
                      await es.writeAsString(consoleMessage.message);
                    },
                    initialFile: "assets/index.html",
                  )
                ]),
              ),
              Text(
                "Version: 1.0.0",
                strutStyle: StrutStyle(
                  height: 2,
                  leading: 2.0,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.normal,
                  forceStrutHeight: true,
                ),
              ),
            ])));
  }
}
