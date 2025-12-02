import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  SharedPreferences? prefs;

  setString(String key, String val) async {
    prefs = await SharedPreferences.getInstance();
    await prefs!.setString(key, val);
  }

  Future<String?> getString(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getString(key);
  }

  setBool(String key, bool val) async {
    prefs = await SharedPreferences.getInstance();
    await prefs!.setBool(key, val);
  }

  Future<bool?> getBool(String key) async {
    prefs = await SharedPreferences.getInstance();
    return prefs!.getBool(key);
  }

  remove(String key) async {
    prefs = await SharedPreferences.getInstance();
    return await prefs!.remove(key);
  }

  clearPref() async {
    prefs = await SharedPreferences.getInstance();
    return await prefs!.clear();
  }
}
