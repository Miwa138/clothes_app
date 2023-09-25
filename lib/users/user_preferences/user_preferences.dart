import 'dart:convert';

import 'package:clothes_app/users/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RememberUserPrefs {
  //Запомнить пользоватея
  static Future<void> storeUserInfo(User userInfo) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String userJsonData =
        jsonEncode(userInfo.toJson()); //Кодируем в формат Json
    await preferences.setString("currentUser", userJsonData);
  }

  static Future<User?> readUserUser() async {
    User? currentUserInfo;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String? userInfo = preferences.getString("currentUser"); // Получаем данные о пользователе из локального хранилища
    if (userInfo != null) {
      Map<String, dynamic> userDataMap = jsonDecode(userInfo);
      currentUserInfo =
          User.fromJson(userDataMap); //Кодируем в обычный формат из Json
    }
    return currentUserInfo;
  }

  static Future<void> removeUserInfo() async
  {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.remove("currentUser");
  }

}
