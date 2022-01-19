import 'package:choices/views/profile.dart';
import 'package:flutter/material.dart';
import 'package:choices/models/choice.dart';
import 'package:choices/views/choice.dart';

class DeterminePage extends StatelessWidget {
  DeterminePage({Key? key}) : super(key: key);

  final profileURLs = ["zju-yq", "dice", "yes-or-no"]
      .map((e) => "https://static.xugr.me/choices/profiles/" + e + ".yaml")
      .toList();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4.0),
      children: profileURLs
          .map((e) => ProfileCard(
              profile: Profile.fromYaml(e),
              choiceWidgetCallBack: (value) =>
                  ChoiceDeterminedWidget(choiceConstraint: value)))
          .toList(),
    );
  }
}
