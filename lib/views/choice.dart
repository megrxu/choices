import 'dart:async';
import 'package:choices/models/settings.dart';
import 'package:flutter/material.dart';
import 'package:choices/views/utils.dart';
import 'package:choices/models/choice.dart';

class ChoiceWidget extends StatefulWidget {
  final ChoiceConstraint? choiceConstraint;

  const ChoiceWidget({Key? key, required this.choiceConstraint})
      : super(key: key);

  @override
  _ChoiceWidgetState createState() => _ChoiceWidgetState();
}

class _ChoiceWidgetState extends State<ChoiceWidget> {
  Choice? choice;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 48.0),
            child: SizedBox(
                height: 120,
                width: 360,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(choice?.name ?? "等待决定...",
                      style: TextStyle(
                          color: choice == null ? Colors.grey : Colors.black,
                          fontSize: 60)),
                )),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              choice == null
                  ? const SizedBox(width: 0)
                  : TextButton(
                      child: const Text('重置'),
                      onPressed: () {
                        setState(() {
                          choice = null;
                        });
                      },
                    ),
              TextButton(
                child: Text(choice == null ? '帮我选！' : '再选一次！'),
                onPressed: () {
                  setState(() {
                    choice = widget.choiceConstraint?.belongsTo.first
                        .getRandomChoice(widget.choiceConstraint);
                    if (choice == null) {
                      noChoiceDialog(context);
                    }
                  });
                },
              )
            ],
          ),
        ]));
  }
}

class ChoiceDeterminedWidget extends StatefulWidget {
  final ChoiceConstraint? choiceConstraint;

  const ChoiceDeterminedWidget({Key? key, required this.choiceConstraint})
      : super(key: key);

  @override
  _ChoiceDeterminedWidgetState createState() => _ChoiceDeterminedWidgetState();
}

class _ChoiceDeterminedWidgetState extends State<ChoiceDeterminedWidget> {
  late Future<Choice?> choice;
  int interval = 3600;

  void updateChoice() {
    choice = getDeviceId().then((value) {
      return widget.choiceConstraint?.belongsTo.first
          .getRandomChoiceDetermained(widget.choiceConstraint,
              value ^ (DateTime.now().second ~/ interval));
    });
  }

  @override
  Widget build(BuildContext context) {
    updateChoice();
    Timer.periodic(Duration(seconds: interval), (timer) {
      if (mounted) {
        setState(() {
          updateChoice();
        });
      }
    });
    return Padding(
        padding: const EdgeInsets.only(
            left: 8.0, right: 8.0, top: 8.0, bottom: 32.0),
        child: Column(children: <Widget>[
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 48.0),
            child: SizedBox(
              height: 120,
              width: 360,
              child: FittedBox(
                fit: BoxFit.contain,
                child: FutureBuilder(
                    future: choice,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var _choice = snapshot.data as Choice?;
                        return Text(_choice?.name ?? "条件过于严格...",
                            style: TextStyle(
                                color: _choice == null
                                    ? Colors.grey
                                    : Colors.black,
                                fontSize: 60));
                      } else {
                        return const Text("生成中...",
                            style: TextStyle(color: Colors.grey, fontSize: 60));
                      }
                    }),
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextFormField(
              initialValue: "$interval",
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                labelText: '更新间隔（秒）',
              ),
              onChanged: (value) {
                setState(() {
                  interval = int.tryParse(value) ?? 3600;
                  updateChoice();
                });
              },
            ),
          )
        ]));
  }
}
