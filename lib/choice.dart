import 'dart:math';

import "package:yaml/yaml.dart";
import 'package:http/http.dart' as http;

class Choice {
  String name = "";
  List<String> tags = [];

  static Choice fromMap(Map map) {
    var c = Choice();
    c.name = map["name"];
    if (map.containsKey("tags")) {
      map["tags"].forEach((e) => c.tags.add(e));
    }
    return c;
  }
}

class Category {
  String? name;
  // List<Category> subCatagories = <Category>[];
  List<Choice> choices = <Choice>[];

  static Category fromMap(Map map) {
    var c = Category();
    c.name = map["name"];
    // TODO: subCatagories
    // c.subCatagories = map.containsKey("catagories")
    //     ? map["catagories"]
    //         .map<Category>((subCatagories) => Category.fromMap(subCatagories))
    //         .toList()
    //     : <Category>[];
    c.choices =
        map["choices"].map<Choice>((choice) => Choice.fromMap(choice)).toList();
    return c;
  }
}

class ChoiceConstraint {
  // TODO
  Set<Category> belongsTo = {};
  Set<String> includeTags = {};
}

class Profile {
  String name = "";
  String icon = "🎲";
  List<Category> categories = <Category>[];

  final _random = Random();

  Set<String> getAllTags() {
    return categories.fold(
        {},
        (res, cat) => res.union(cat.choices
            .fold({}, (res, choice) => res.union(choice.tags.toSet()))));
  }

  ChoiceConstraint initChoiceConstraint() {
    var cc = ChoiceConstraint();
    cc.includeTags = getAllTags();
    cc.belongsTo = categories.toSet();
    return cc;
  }

  List<Choice> getChoices(ChoiceConstraint? constraint) {
    if (constraint == null) {
      return categories.fold([], (res, element) => res + element.choices);
    } else {
      var excludeTags = getAllTags();
      excludeTags.removeAll(constraint.includeTags);
      return categories.fold(
          [],
          (res, element) =>
              res +
              element.choices
                  .where((c) => c.tags
                      .toSet()
                      .any((element) => !(excludeTags.contains(element))))
                  .toList());
    }
  }

  Choice? getRandomChoice(ChoiceConstraint? constraint) {
    var currentChoices = getChoices(constraint);
    if (currentChoices.isEmpty) {
      return null;
    } else {
      return currentChoices[_random.nextInt(currentChoices.length)];
    }
  }

  static Future<Profile> fromYaml(String url) async {
    var httpResp = await http.get(Uri.parse(url));
    if (httpResp.statusCode == 200) {
      var data = loadYaml(httpResp.body);
      var profile = Profile();
      profile.name = data["name"];
      profile.icon = data["icon"];
      profile.categories =
          (data["categories"] as List).map((c) => Category.fromMap(c)).toList();
      return profile;
    } else {
      throw Exception('无法取得配置文件');
    }
  }
}
