import 'package:flutter/material.dart';

class MyDialog {
  static info(BuildContext context, String txt) {
    showDialog<Null>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Info',
            strutStyle: StrutStyle(fontSize: 14),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(txt),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
