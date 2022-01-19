import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

Future<int> getDeviceId() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var deviceId = prefs.getInt('device_id');
  if (prefs.getInt('device_id') == null) {
    deviceId = Random().nextInt(1 << 31);
    prefs.setInt('device_id', deviceId);
  }
  return deviceId!;
}
