import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_gsheet/hello_page.dart';
import 'package:flutter_gsheet/my_controller.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import 'main.dart';
class KredilyClock{
  static String topicScaleupString="scaleup";
  static String taskTitleString="Task List";
  static String taskBodyString="Please add your tasklist in slack group- Team cloud tech";

  static String hourTitleString="Hours log";
  static String hourBodyString="Please update your daily hours log";


  var client = http.Client();
  MyController myController=Get.put(MyController());
  getKredily() async {
    String url="https://scaleupallyio.kredily.com";
    var response=await client.get(Uri.parse(url));
    print(response.statusCode);
    if(response.statusCode==200){
      // print(response.headers);
      String rawCookie = response.headers['set-cookie']!;
      var splt=rawCookie.split(";");
      for(var x in splt){
        if(x.contains("csrftoken")){
          var csrfToken=x.split("=")[1];
          loginKredily(csrfToken);
          break;
        }
      }

    }else{
      Fluttertoast.showToast(msg: "Error! please try again");
    }

  }
  loginKredily(String token) async {
    var header={
      "X-CSRFToken":token,
      'Content-Type': 'application/json'
    };
    var data=jsonEncode({
      "email":sharedPreference.get("email").toString().toLowerCase(),
      "password":sharedPreference.get("pass")
    });
    print(data);
    var response=await client.post(Uri.parse('https://scaleupallyio.kredily.com/login/'),headers: header,body: data);
    print(response.statusCode);
    print(response.body);
    if(response.statusCode==200) {
      try{
        var json=jsonDecode(response.body);
        if(json['message']['status']=="error"){
          Fluttertoast.showToast(msg: json['message']['validation']);
          myController.loginLoading.value=false;
          return;
        }

        sharedPreference.setString("verified", "true");

        String rawCookie = response.headers['set-cookie']!;
        var splt = rawCookie.split(";");
        var csrfToken;
        var sessionId;
        for (var x in splt) {
          if (x.contains("sessionid")) {
            sessionId = x.split("=")[1];
          }
          if (x.contains("csrftoken")) {
            csrfToken = x.split("=")[1];
          }
        }
        sharedPreference.setString("csrftoken", "$csrfToken");
        sharedPreference.setString("sessionid", "$sessionId");
        getEmpDetails(csrfToken, sessionId);
      }catch(e){
        Fluttertoast.showToast(msg: "Error: ${response.body}");
        myController.loginLoading.value=false;
      }

    }
  }
  getEmpDetails(csrfToken,sessionId) async {
    var header={
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };

    var response=await http.get(Uri.parse("https://scaleupallyio.kredily.com/attendanceLog/clockingWidgetApi/"),headers: header);
    myController.loadingClockBtn.value=false;
    if(response.statusCode==200){
      print("SSSSSSSSS ${response.statusCode}");
      print("SSSSSSSSS ${response.body}");
      try{
        var json=jsonDecode(response.body);
        if(myController.isLoginPage==true){
          myController.loginLoading.value=false;
          FirebaseMessaging.instance.subscribeToTopic(KredilyClock.topicScaleupString);
          FirebaseMessaging.instance.subscribeToTopic(myController.textEditingControllerEmail.text.toLowerCase().replaceAll('@', '.'));
          Get.off(()=> HelloPage());
        }

        print("inside");

        if(json['attendance_log'].isNotEmpty){
          var lastPunchIn=json['attendance_log'][0]['last_punch_in'];
          if(json['attendance_log'][0]['emp_time_out']==null){
            myController.clockBtnText.value="Clock out";
            var locall=DateTime.parse(lastPunchIn).toLocal();
            startTimer(locall.microsecondsSinceEpoch);
          }
        }
        
        if(myController.shouldGoForward.value==true){
          print("xxxxxxxxxxxxxxx");
          if(json['attendance_log'].isEmpty){
            setClockin(csrfToken, sessionId);
          }else
          if(json['attendance_log'][0]['emp_time_out']==null){
            // myController.animatedWidth.value=null;
          }else{
            setClockin(csrfToken, sessionId);
          }
        }else{
          print("yyyyyyyyyyyyyyyy");
          // myController.animatedWidth.value=null;
          if(json['attendance_log'].isEmpty){
            return [];
          }
          return [json['attendance_log'][0]['emp_time_out']==null?'loggedIn':'loggedOut'];
        }
        // print(json);
      }catch(e){
        print("CATCHED $e");
        return [];
      }

      // print(json);
      // setClockin(csrfToken,sessionId);
      // setClockOut(csrftoken,sessionid);
    }
  }
  setClockin(csrfToken,sessionId) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };
    var response=await http.post(Uri.parse("https://scaleupallyio.kredily.com/attendanceLog/clockIn/"),headers: header);
    print(response.statusCode);
    if(response.statusCode==201){
      //created
      myController.clockBtnText.value="Clock out";
      startTimer(DateTime.now().microsecondsSinceEpoch);
      myController.animatedWidth.value=null;

    }else{
      Fluttertoast.showToast(msg: '${response.body}');
      myController.animatedWidth.value=null;
    }
    print(response.body);
  }
  setClockOut(csrfToken,sessionId) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };
    var response=await http.get(Uri.parse("https://scaleupallyio.kredily.com/attendanceLog/clockOut/"),headers: header);
    print(response.statusCode);
    if(response.statusCode==201){
      //created
      myController.clockBtnText.value="Start clock in";
      myController.countDownTime.value='';
      myController.timer!.cancel();
      myController.timer=null;

      myController.animatedWidth.value=null;
    }else{
      Fluttertoast.showToast(msg: '${response.body}');
      myController.animatedWidth.value=null;
    }
    print(response.body);
  }
  startTimer(locall){
    if(myController.timer!=null){
      myController.timer!.cancel();
      myController.timer=null;
    }
    myController.timer=Timer.periodic(Duration(seconds: 1), (timer) {
      var timex=DateTime.now().microsecondsSinceEpoch-locall;
      Duration duration=Duration(microseconds: int.parse('$timex'));
      myController.countDownTime.value='${(duration.inHours).toString().padLeft(2,'0')}:${(duration.inMinutes % 60).toString().padLeft(2,'0')}:${(duration.inSeconds % 60).toString().padLeft(2,'0')}';
    });
  }

  getLeaveStatus(csrfToken,sessionId) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };
    try{
      var response=await http.get(Uri.parse('https://scaleupallyio.kredily.com/leave-request/leave_accrual_user/'),headers: header);
      print(response.statusCode);
      var json=jsonDecode(response.body);
      return json['leave_bal_json_data'];
    }catch(e){
      print("ERRRRRRRRROR $e");
      var error="Something went wrong!";
      if(e.toString().contains("Failed host lookup")){
        error="You are not connected to internet";
      }
      Fluttertoast.showToast(msg: "Something went wrong!");
    }

  }
  getLeaveLogs(csrfToken,sessionId,years) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}'
    };
    print(years);
    var response=await http.get(Uri.parse('https://scaleupallyio.kredily.com/leave-request/user_leave_log_datatable?year=$years'),headers: header);
    // print(response.body);
    var json=jsonDecode(response.body);
    return json['json_data'];
  }

  cancelLeave(csrfToken,sessionId,leaveRequestUu) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}',
      'Content-Type': 'application/json'
    };
    var data=jsonEncode({
      "leave_request_uu":leaveRequestUu,
    });
    var request=await http.Request("GET",Uri.parse('https://scaleupallyio.kredily.com/leave-request/cancelLeave/'));
    request.body=data;
    request.headers.addAll(header);
    http.StreamedResponse response=await request.send();

    myController.cancelLeaveLoading.value=false;

    if (response.statusCode == 200) {
      // print(await response.stream.bytesToString());
      String body=await response.stream.bytesToString();
      var json=jsonDecode(body);
      if(json['status']=="success"){
        Fluttertoast.showToast(msg: json['message']);
        return "success";
      }else{
        Fluttertoast.showToast(msg: json['message']);
      }
    }
    else {
      print(response.reasonPhrase);
      Fluttertoast.showToast(msg: response.reasonPhrase.toString());
    }

  }

  applyLeave(csrfToken,sessionId,leaveType,startDate,startDaySession,endDate,endDaySession,reasonForLeave) async {
    var header={
      "X-CSRFToken":'$csrfToken',
      'Cookie': 'csrftoken=${csrfToken}; sessionid=${sessionId}',
      'Content-Type': 'application/json'
    };
    var data=jsonEncode({
      "leave_type":leaveType,
      "start_date":startDate,
      "start_day_session":startDaySession,
      "end_date":endDate,
      "end_day_session":endDaySession,
      "reason_for_leave":reasonForLeave,
    });
    try{
      var response=await http.post(Uri.parse('https://scaleupallyio.kredily.com/leave-request/add-new/'),headers: header,body: data);
      print(response.body);
      myController.applyLeaveLoading.value=false;
      var json=jsonDecode(response.body);
      if(json['status']=="error"){
        Fluttertoast.showToast(msg: json['error_msg']);
      }
      if(json['status']=="success"){
        Fluttertoast.showToast(msg: 'Leave Applied : status ${json['leave_obj']['status']}');
        return "success";
      }
    }catch(e){
      print(e);
      myController.applyLeaveLoading.value=false;
      Fluttertoast.showToast(msg: "Something went wrong");
    }
    // var json=jsonDecode(response.body);
  }

  sendNotification2(){
    Fluttertoast.showToast(msg: "Send");
    Map<String, dynamic> message = {
      'to': '/topics/topic_name', // Replace with the topic or device token you want to send the message to
      'notification': {
        'title': 'Title of the notification',
        'body': 'Body of the notification'
      }
    };
    var message2=jsonEncode({
      'to': '/topics/scaleup', // Replace with the topic or device token you want to send the message to
      'notification': {
        'title': 'Title of the notification',
        'body': 'Body of the notification'
      },
      'data': {
        'title': 'Title of the notification',
        'body': 'Body of the notification'
      }
    });

    FirebaseMessaging.instance.sendMessage(to: '/topics/scaleup',
      data: {'trer':'qwer'},
      messageType: 'RemoteMessageDataType.data',
    );
  }


  sendNotification(title,body,topic) async {
    //scaleup
    //replace @ with . in mail id
    var headers={
      "Authorization":"key=AAAA2l6H44s:APA91bHuB6WroEyzaWOMOfP13hn4CCe5UefvDJ4tFjj0xh8SdBrQeIl0csEqHxJ4mFCoGhoyT7rBUb9i4FOKNXYGy2t9CPUDhfMbiesQxUaUsBYgt5sTD_tbek3HgPhqk_ZX34kmXDNS",
      "Content-Type":"application/json"
    };
    var message=jsonEncode({
      'to': '/topics/${topic}', // Replace with the topic or device token you want to send the message to
      'notification': {
        'title': '$title',
        'body': '$body'
      },
      'data': {
        'title': '$title',
        'body': '$body'
      }
    });

    var response=await http.post(Uri.parse("https://fcm.googleapis.com/fcm/send"),headers: headers,body: message);
    print(response.statusCode);
    print(response.body);
    Fluttertoast.showToast(msg: "Send successfully");
    if(response.statusCode==200){
      return "success";
    }
  }
}