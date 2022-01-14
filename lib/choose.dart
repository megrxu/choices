import 'package:flutter/material.dart';
import 'package:choices/choice.dart';

class ChoosePage extends StatefulWidget {
  const ChoosePage({Key? key}) : super(key: key);

  @override
  _ChoosePageState createState() => _ChoosePageState();
}

class _ChoosePageState extends State<ChoosePage> {
  final profilePaths = ["zju-yq", "dice", "yes-or-no"]
      .map((e) => "profiles/" + e + ".yaml")
      .toList();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4.0),
      children: profilePaths
          .map((e) => ChoiceCard(profile: Profile.fromYaml(e)))
          .toList(),
    );
  }
}

class ChoiceCard extends StatefulWidget {
  const ChoiceCard({
    Key? key,
    required this.profile,
  }) : super(key: key);

  final Future<Profile> profile;

  @override
  _ChoiceCardState createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<ChoiceCard> {
  Choice? _choice;
  // TODO
  ChoiceConstraint? _choice_constraint;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: () => {},
      child: Container(
          constraints: const BoxConstraints(minHeight: 240),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                FutureBuilder(
                    future: widget.profile,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return _renderProfile(snapshot.data as Profile);
                      } else if (snapshot.hasError) {
                        return Text("${snapshot.error}");
                      }
                      return const Text("加载中...");
                    }),
                _renderChoice(_choice),
              ],
            ),
          )),
    ));
  }

  Widget _renderProfile(Profile profile) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading:
              Text(profile.icon, style: Theme.of(context).textTheme.titleLarge),
          title:
              Text(profile.name, style: Theme.of(context).textTheme.titleLarge),
        ),
      ],
    );
  }

  Widget _renderChoice(Choice? choice) {
    return Column(children: <Widget>[
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 48.0),
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
                      _choice = null;
                    });
                  },
                ),
          TextButton(
            child: Text(choice == null ? '帮我选！' : '再选一次！'),
            onPressed: () {
              widget.profile.then((value) => setState(
                  () => _choice = value.getRandomChoice(_choice_constraint)));
            },
          )
        ],
      ),
    ]);
  }
}
