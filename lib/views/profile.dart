import 'package:flutter/material.dart';
import 'package:choices/models/choice.dart';
import 'package:choices/views/utils.dart';

typedef ChoiceWidgetCallBack = Widget Function(ChoiceConstraint? constraint);

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    Key? key,
    required this.profile,
    required this.choiceWidgetCallBack,
  }) : super(key: key);

  final Future<Profile> profile;
  final ChoiceWidgetCallBack choiceWidgetCallBack;

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
                      return ProfileWidget(
                          profile: snapshot.data as Profile,
                          choiceWidgetCallBack: choiceWidgetCallBack);
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
  final ChoiceWidgetCallBack choiceWidgetCallBack;

  const ProfileWidget(
      {Key? key, required this.profile, required this.choiceWidgetCallBack})
      : super(key: key);

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
          [
            CategoryWidget(
                choiceConstraint: _choiceConstraint,
                choiceWidgetCallBack: widget.choiceWidgetCallBack)
          ],
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
                  noChoiceDialog(context);
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
  final ChoiceWidgetCallBack choiceWidgetCallBack;

  const CategoryWidget(
      {Key? key,
      required this.choiceConstraint,
      required this.choiceWidgetCallBack})
      : super(key: key);

  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: _renderCategoryConstraints() +
          [widget.choiceWidgetCallBack(widget.choiceConstraint)],
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
}
