import 'package:shared_preferences/shared_preferences.dart';

setData(String dataKey, String data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setString(dataKey, data);
}

getData(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getString(key);
}

removeData(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  preferences.remove(key);
}

setIntData(String dataKey, int data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setInt(dataKey, data);
}

getIntData(String key) async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.getInt(key);
}

setBool(String key, bool data) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  pref.setBool(key, data);
}

getBool(String key) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getBool(key);
}

clearData() async {
  SharedPreferences preferences = await SharedPreferences.getInstance();
  return preferences.clear();
}