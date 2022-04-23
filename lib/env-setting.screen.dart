import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_inappwebview_example/env.data.dart';
import 'package:flutter_inappwebview_example/my-dialog.dart';
import 'package:flutter_inappwebview_example/setting.data.dart';
import 'main.dart';

class Env extends ChromeSafariBrowser {
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

class EnvListScreen extends StatefulWidget {
  final ChromeSafariBrowser browser = Env();

  @override
  PageState createState() => PageState();
}

class PageState extends State<EnvListScreen> {
  String log = "";

  List<Padding> list = [];
  Map<dynamic, dynamic> map = {};

  _loadfile() async {
    SettingList sl = SettingList();
    await sl.loadList();

    EnvSetup es = EnvSetup();

    await es.loadMap();

    map = es.map;

    List<Padding> arr = [];
    sl.list.forEach((menus) {
      menus.parameter.forEach((element) {
        var app = menus.name.toLowerCase();

        app = app.replaceAll(" ", "_");

        arr.add(Padding(
          padding: const EdgeInsets.all(8),
          child: TextFormField(
            initialValue: map.containsKey(element) ? map[element] : "",
            decoration: InputDecoration(labelText: element + " " + app),
            keyboardType: TextInputType.text,
            validator: (value) {
              if (value == "") {
                return "Please enter value";
              }
              return null;
            },
            onChanged: (newValue) {
              map[element] = newValue;
            },
          ),
        ));
      });
    });
    setState(() {
      list = arr;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(
          "Env variable setting",
        )),
        drawer: myDrawer(context: context),
        body: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
              Expanded(
                child: Stack(children: [
                  ListView(
                    children: list,
                  )
                ]),
              ),
              ElevatedButton(
                  onPressed: () async {
                    var data = json.encode(map); //将map数据转换为json字符串
                    EnvSetup es = EnvSetup();
                    await es.writeAsString(data);
                    MyDialog.info(context, 'Setup success');
                  },
                  child: Icon(Icons.done_outlined)),
            ])));
  }
}
