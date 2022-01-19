import 'package:flutter/material.dart';

Future<void> noChoiceDialog(context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('没有选择！'),
        content: SingleChildScrollView(
          child: ListBody(
            children: const <Widget>[
              Text('现在没有可供选择的内容！'),
              Text('你需要把条件设置得更宽松一点。'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('重新设置'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
