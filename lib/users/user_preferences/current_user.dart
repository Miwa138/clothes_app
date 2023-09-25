import 'package:clothes_app/users/model/user.dart';
import 'package:clothes_app/users/user_preferences/user_preferences.dart';
import 'package:get/get.dart';

class CurrentUser extends GetxController
{
  Rx<User> _currentUser = User(user_id: 0, user_name: '', user_email: '', user_password: '').obs;
  User get user => _currentUser.value;

  getUserInfo()async
  {
    User? getUserInfoFromLocalStorage = await RememberUserPrefs.readUserUser();
    _currentUser.value = getUserInfoFromLocalStorage!;
  }

}