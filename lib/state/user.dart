import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class User extends GetxController {
  SharedPreferences? prefs;

  RxString nickname = ''.obs;
  RxInt points = 0.obs;

  @override
  void onInit() async {
    prefs = await SharedPreferences.getInstance();

    points.value = prefs!.getInt('points')!;
    nickname.value = prefs!.getString('nickname')!;
    super.onInit();
  }

  void updateNickname(String nickname) async {
    await prefs!.setString('nickname', nickname);
  }
}