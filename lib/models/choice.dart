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

  final _random = Random();

  Set<String> getAllTags() {
    return choices.fold({}, (res, choice) => res.union(choice.tags.toSet()));
  }

  List<Choice> getChoices(ChoiceConstraint? constraint) {
    if (constraint == null || constraint.includeTags.isEmpty) {
      return choices;
    } else {
      return choices
          .where((c) => c.tags.toSet().containsAll(constraint.includeTags))
          .toList();
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

  Choice? getRandomChoiceDetermained(ChoiceConstraint? constraint, int seed) {
    var _random = Random(seed);
    var currentChoices = getChoices(constraint);
    if (currentChoices.isEmpty) {
      return null;
    } else {
      return currentChoices[_random.nextInt(currentChoices.length)];
    }
  }
}

class ChoiceConstraint {
  Set<Category> belongsTo = {};
  Set<String> includeTags = {};
}

class Profile {
  String name = "自定义";
  String icon = "🎲";
  List<Category> categories = <Category>[];

  static Set<String> getAllTags(Set<Category>? categories) {
    return categories?.fold(
            {},
            (res, cat) => res!.union(cat.choices
                .fold({}, (res, choice) => res.union(choice.tags.toSet())))) ??
        {};
  }

  Category? getCategoryByString(String? name) {
    return categories.firstWhere((cat) => cat.name == name);
  }

  ChoiceConstraint initChoiceConstraint() {
    var cc = ChoiceConstraint();
    cc.includeTags = {};
    cc.belongsTo = {categories.first};
    return cc;
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
