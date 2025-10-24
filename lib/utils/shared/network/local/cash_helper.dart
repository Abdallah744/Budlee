// ignore_for_file: unnecessary_type_check, body_might_complete_normally_nullable

import 'package:shared_preferences/shared_preferences.dart';

class CashHelper {
  static SharedPreferences? sharedPreferences;
  static init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  static Future<bool> putBoolean({
    required String key,
    required bool value,
  }) async {
    return await sharedPreferences!.setBool(key, value);
  }

  static dynamic get({required String key}) {
    return sharedPreferences!.get(key);
  }

  static Future<bool?> savedData({
    required String key,
    required dynamic value,
  }) async {
    if (value is String) return await sharedPreferences?.setString(key, value);
    if (value is int) return await sharedPreferences?.setInt(key, value);
    if (value is bool) {
      return await sharedPreferences?.setBool(key, value);
    }
    return await sharedPreferences?.setDouble(key, value);
  }
}
