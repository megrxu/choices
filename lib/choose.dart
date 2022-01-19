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
          .map((e) => ProfileCard(profile: Profile.fromYaml(e)))
          .toList(),
    );
  }
}

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
    required this.profile,
  }) : super(key: key);

  final Future<Profile> profile;

  @override
  Widget build(BuildContext context) {
    var style = Theme.of(context).textTheme.titleLarge;
    return Card(
      child: Container(
          constraints: const BoxConstraints(minHeight: 240),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              FutureBuilder(
                  future: profile,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ProfileWidget(profile: snapshot.data as Profile);
                    } else if (snapshot.hasError) {
                      return _renderNotReady(style, "发生了错误");
                    }
                    return _renderNotReady(style, "加载中...");
                  }),
            ],
          )),
    );
  }

  Widget _renderNotReady(style, String text) {
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
}

class ProfileWidget extends StatefulWidget {
  final Profile profile;

  const ProfileWidget({Key? key, required this.profile}) : super(key: key);

  @override
  _ProfileWidgetState createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  ChoiceConstraint? _choiceConstraint;

  @override
  Widget build(context) {
    var style = Theme.of(context).textTheme.titleLarge;
    _choiceConstraint ??= widget.profile.initChoiceConstraint();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
            ListTile(
                leading: Text(widget.profile.icon, style: style),
                title: Text(widget.profile.name, style: style),
                trailing: _renderDropdown(widget.profile)),
          ] +
          [CategoryWidget(choiceConstraint: _choiceConstraint)],
    );
  }

  Widget _renderDropdown(Profile profile) {
    if (profile.categories.length > 1) {
      return SizedBox(
          width: 150,
          child: DropdownButtonFormField(
              value: profile.categories.first.name,
              items: profile.categories
                  .map((category) => DropdownMenuItem(
                      value: category.name, child: Text(category.name ?? "默认")))
                  .toList(),
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              alignment: Alignment.centerRight,
              onChanged: (String? value) {
                var cat = profile.getCategoryByString(value);
                if (cat == null) {
                  _noChoiceDialog(context);
                } else {
                  setState(() {
                    _choiceConstraint?.belongsTo = {cat};
                    _choiceConstraint?.includeTags = {};
                  });
                }
              }));
    } else {
      return const SizedBox(width: 0.0);
    }
  }
}

class CategoryWidget extends StatefulWidget {
  final ChoiceConstraint? choiceConstraint;

  const CategoryWidget({Key? key, required this.choiceConstraint})
      : super(key: key);

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  Choice? _choice;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _renderCategoryConstraints() + [_renderChoice(_choice)],
    );
  }

  List<Widget> _renderCategoryConstraints() {
    var tags = Profile.getAllTags(widget.choiceConstraint?.belongsTo);
    if (tags.isEmpty) {
      return [];
    } else {
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
            children: tags
                .map(
                  (e) => FilterChip(
                    label: Text(e),
                    onSelected: (bool value) {
                      setState(() {
                        if (widget.choiceConstraint?.includeTags.contains(e) ??
                            false) {
                          widget.choiceConstraint?.includeTags.remove(e);
                        } else {
                          widget.choiceConstraint?.includeTags.add(e);
                        }
                      });
                    },
                    selected:
                        widget.choiceConstraint?.includeTags.contains(e) ??
                            false,
                  ),
                )
                .toList(),
          ),
        ),
      ];
    }
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
                  setState(() {
                    _choice = widget.choiceConstraint?.belongsTo.first
                        .getRandomChoice(widget.choiceConstraint);
                    if (_choice == null) {
                      _noChoiceDialog(context);
                    }
                  });
                },
              )
            ],
          ),
        ]));
  }
}

Future<void> _noChoiceDialog(context) async {
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
