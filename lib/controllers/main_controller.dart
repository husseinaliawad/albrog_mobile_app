import 'package:get/get.dart';

class MainController extends GetxController {
  var currentIndex = 0.obs;
  
  void changeTab(int index) {
    currentIndex.value = index;
  }
  
  void goToHome() {
    currentIndex.value = 0;
  }
  
  void goToProperties() {
    currentIndex.value = 1;
  }
  
  void goToProfile() {
    currentIndex.value = 2;
  }
} 