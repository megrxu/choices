import 'dart:math';

import "package:flutter/services.dart" as s;
import "package:yaml/yaml.dart";
import 'package:http/http.dart' as http;

class Choice {
  String name = "";
  List<String> tags = [];

  static Choice fromMap(Map map) {
    var c = Choice();
    c.name = map["name"];
    // c.tags = map["tags"];
    return c;
  }
}

class Category {
  String? name;
  List<Category> subCatagories = <Category>[];
  List<Choice> choices = <Choice>[];

  static Category fromMap(Map map) {
    var c = Category();
    c.name = map["name"];
    // TODO
    // c.subCatagories = map["catagories"]
    //     .map<Category>((subCatagories) => Category.fromMap(subCatagories))
    //     .toList();
    c.choices =
        map["choices"].map<Choice>((choice) => Choice.fromMap(choice)).toList();
    return c;
  }
}

class ChoiceConstraint {
  // TODO
  List<Category> belongsTo = [];
  List<Category> noBelongsTo = [];
  List<String> includeTags = [];
  List<String> excludeTags = [];
}

class Profile {
  String name = "";
  String icon = "🎲";
  List<Category> categories = <Category>[];

  final _random = Random();

  List<Choice> getChoices(ChoiceConstraint? constraint) {
    return categories.fold([], (res, element) => res + element.choices);
  }

  Choice getRandomChoice(ChoiceConstraint? constraint) {
    var currentChoices = getChoices(constraint);
    return currentChoices[_random.nextInt(currentChoices.length)];
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
