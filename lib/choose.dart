import 'package:flutter/material.dart';
import 'package:choices/choice.dart';

class ChoosePage extends StatefulWidget {
  const ChoosePage({Key? key}) : super(key: key);

  @override
  _ChoosePageState createState() => _ChoosePageState();
}

class _ChoosePageState extends State<ChoosePage> {
  final profileURLs = ["zju-yq", "dice", "yes-or-no"]
      .map((e) => "https://static.xugr.me/choices/profiles/" + e + ".yaml")
      .toList();
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(4.0),
      children: profileURLs
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
  ChoiceConstraint? _choiceConstraint;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: InkWell(
      onTap: () => {},
      child: Container(
          constraints: const BoxConstraints(minHeight: 240),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FutureBuilder(
                  future: widget.profile,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var profile = snapshot.data as Profile;
                      _choiceConstraint ??= profile.getAllTags().isEmpty
                          ? null
                          : profile.initChoiceConstraint();
                      return _renderProfile(profile);
                    } else if (snapshot.hasError) {
                      return _renderNotReady("$snapshot.error");
                    }
                    return _renderNotReady("加载中...");
                  }),
              const Divider(),
              _renderChoice(_choice),
            ],
          )),
    ));
  }

  Widget _renderNotReady(String text) {
    var style = Theme.of(context).textTheme.titleLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.circle_outlined),
          title: Text(text, style: style),
        ),
      ],
    );
  }

  Widget _renderProfile(Profile profile) {
    var style = Theme.of(context).textTheme.titleLarge;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            ListTile(
              leading: Text(profile.icon, style: style),
              title: Text(profile.name, style: style),
            )
          ] +
          _renderProfileConstraints(profile),
    );
  }

  List<Widget> _renderProfileConstraints(Profile profile) {
    var tags = profile.getAllTags();
    if (tags.isEmpty) {
      return [];
    } else {}
    return [
      const Divider(),
      Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          alignment: Alignment.centerLeft,
          child: Text("标签", style: Theme.of(context).textTheme.caption)),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 4.0,
          runSpacing: 4.0,
          children: profile
              .getAllTags()
              .map(
                (e) => FilterChip(
                  label: Text(e),
                  onSelected: (bool value) {
                    setState(() {
                      if (_choiceConstraint?.includeTags.contains(e) ?? false) {
                        _choiceConstraint?.includeTags.remove(e);
                      } else {
                        _choiceConstraint?.includeTags.add(e);
                      }
                    });
                  },
                  selected: _choiceConstraint?.includeTags.contains(e) ?? false,
                ),
              )
              .toList(),
        ),
      ),
    ];
  }

  Widget _renderChoice(Choice? choice) {
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
                          _choice = null;
                        });
                      },
                    ),
              TextButton(
                child: Text(choice == null ? '帮我选！' : '再选一次！'),
                onPressed: () {
                  widget.profile.then((value) {
                    setState(() =>
                        _choice = value.getRandomChoice(_choiceConstraint));
                    if (_choice == null) {
                      _noChoiceDialog();
                    }
                  });
                },
              )
            ],
          ),
        ]));
  }

  Future<void> _noChoiceDialog() async {
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
}
