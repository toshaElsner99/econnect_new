import 'package:shared_preferences/shared_preferences.dart';

setData(String dataKey, String data) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString(dataKey, data);
  } catch (e) {
    print("Error setting data for key '$dataKey': $e");
    // Optionally show user feedback or handle gracefully
  }
}

getData(String key) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getString(key);
  } catch (e) {
    print("Error getting data for key '$key': $e");
    return null;
  }
}

removeData(String key) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove(key);
  } catch (e) {
    print("Error removing data for key '$key': $e");
  }
}

setIntData(String dataKey, int data) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setInt(dataKey, data);
  } catch (e) {
    print("Error setting int data for key '$dataKey': $e");
  }
}

getIntData(String key) async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key);
  } catch (e) {
    print("Error getting int data for key '$key': $e");
    return null;
  }
}

setBool(String key, bool data) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setBool(key, data);
  } catch (e) {
    print("Error setting bool data for key '$key': $e");
  }
}

getBool(String key) async {
  try {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool(key);
  } catch (e) {
    print("Error getting bool data for key '$key': $e");
    return null;
  }
}

clearData() async {
  try {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.clear();
  } catch (e) {
    print("Error clearing SharedPreferences data: $e");
    return false;
  }
}