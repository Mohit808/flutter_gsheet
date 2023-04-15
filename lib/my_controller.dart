import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MyController extends GetxController{
  RxString countDownTime=''.obs;
  RxString clockBtnText="Start clock in".obs;
  RxBool shouldGoForward=false.obs;
  Timer? timer;
  RxBool loadingClockBtn=true.obs;
  // RxString? animatedWidth="".obs;
  final animatedWidth = Rxn<double>();
  RxBool loginLoading=false.obs;
  RxBool applyLeaveLoading=false.obs;
  RxBool cancelLeaveLoading=false.obs;
  RxBool isLoginPage=false.obs;
  RxString isAdmin=''.obs;
  RxString isLoggedIn="notLoggedIn".obs;
  TextEditingController textEditingControllerEmail=TextEditingController();

}