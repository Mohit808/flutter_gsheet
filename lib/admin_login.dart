import 'dart:io';
import 'dart:isolate';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gsheet/main.dart';
import 'package:flutter_gsheet/my_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'kredily_clock.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  MyController myController=Get.put(MyController());

  @override
  void initState() {
    super.initState();
    var value=sharedPreference.get("isAdmin");
    if(value!=null && value!=''){
      // myController.isAdmin.value="yes";
      Future.delayed(Duration(seconds: 0),()=> myController.isAdmin.value="yes");

    }
    checkLoggedIn();
  }
  checkLoggedIn() async {
    User? cuu=FirebaseAuth.instance.currentUser;
    print(cuu);
    if(cuu==null){
      myController.isLoggedIn.value="notLoggedIn";
    }else{
      myController.isLoggedIn.value="loggedIn";
    }
  }

  onSubmit() async {
    GoogleSignInAccount? sign=await GoogleSignIn().signIn();
    if(sign!=null){
      print(sign);
      var auth=await sign.authentication;
      AuthCredential credential=GoogleAuthProvider.credential(idToken:  auth.idToken,accessToken: auth.accessToken);
      FirebaseAuth.instance.signInWithCredential(credential);
      myController.isLoggedIn.value="loggedIn";
      setState(() {
      });
    }
  }
  checkDatabase() async {
    print("called");
    DatabaseEvent databaseEvent=await FirebaseDatabase.instance.ref().child("admin").once();
    print(databaseEvent.snapshot.value);
    if(databaseEvent.snapshot.value==sharedPreference.get("email")){
      sharedPreference.setString("isAdmin", "yes");
      myController.isAdmin.value="yes";
      setState(() {
      });
    }else{
      Fluttertoast.showToast(msg: "You are not admin");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Admin Login",style: TextStyle(fontWeight: FontWeight.bold),),),
    body: Padding(padding: EdgeInsets.all(16),child: Center(
      child: Column(mainAxisSize: MainAxisSize.min,children: [
        myController.isLoggedIn.value=="loggedIn"?Text("Logged In already"):SizedBox(),
        myController.isLoggedIn.value=="notLoggedIn"?Row(children: [
          Expanded(child: InkWell(onTap: (){
            onSubmit();
          },
            child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text("LOGIN WITH GOOGLE",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                ),
              ],
            ),),
          ))
        ],):SizedBox(),

        SizedBox(height: 16,),

        Obx(() => myController.isLoggedIn.value=="loggedIn" && myController.isAdmin.value!="yes"?Row(children: [
        Expanded(child: InkWell(onTap: (){
          checkDatabase();
        },
          child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Check admin availability",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              ),
            ],
          ),),
        ))
      ],):SizedBox()),
        SizedBox(height: 16,),
        Obx(() => myController.isLoggedIn.value=="loggedIn" && myController.isAdmin.value=="yes"?Row(children: [
        Expanded(child: InkWell(onTap: (){
          setAlarm();
        },
          child: Container(alignment: Alignment.center,decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Use alarm manager",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
              ),
            ],
          ),),
        ))
      ],):SizedBox()),
      ],),
    ),),);
  }

  setAlarm(){
    var alrm=sharedPreference.get("alarm");
    if(alrm==null){
      sharedPreference.setString("alarm", "true");
      alrmmm(id,durationMin,hour,min) async {
        await AndroidAlarmManager.initialize();
        if (Platform.isAndroid) {
          await AndroidAlarmManager.periodic(
            Duration(minutes: durationMin),
            id,
            printHello,
            wakeup: true,
            startAt: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, hour, min),
            rescheduleOnReboot: true,
          );
        }
      }
      alrmmm(0,12,11,00); // id,duration, on hours, on minute
      alrmmm(1,24,19,30);
      Fluttertoast.showToast(msg: "Alarm set successfully");

    }else{
      Fluttertoast.showToast(msg: "Alarm has already been set");
    }
  }
  Future<void> printHello() async {
    final int isolateId = Isolate.current.hashCode;

    final now = DateTime.now();
    final year = now.year;
    final month = now.month;

    final firstDayOfMonth = DateTime(year, month, 1);
    final firstSaturday = _getNextSaturday(firstDayOfMonth);

    final secondSaturday = _getNextSaturday(firstSaturday.add(Duration(days: 7)));

    final fifthSaturday = _getNextSaturday(firstSaturday.add(Duration(days: 28)));
    final fourthSaturday = fifthSaturday.subtract(Duration(days: 7));

    print('Second Saturday of the month: ${secondSaturday.toString()}');
    print('Fourth Saturday of the month: ${fourthSaturday.toString()}');
    print('fifthSaturday Saturday of the month: ${fifthSaturday.toString()}');

    String ss=DateFormat("yyyy-MM-dd").format(secondSaturday);
    String fs=DateFormat("yyyy-MM-dd").format(fourthSaturday);
    String fis=DateFormat("yyyy-MM-dd").format(fifthSaturday);
    String nn=DateFormat("yyyy-MM-dd").format(now);
    if(nn==ss || nn==fs || nn==fis){
      return;
    }

    print("[$now] Hello, world! isolate=${isolateId} function='$printHello'");
    // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin=FlutterLocalNotificationsPlugin();
    // await flutterLocalNotificationsPlugin.initialize(InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher')));

    if(now.hour==11){
      await KredilyClock().sendNotification(KredilyClock.taskTitleString,KredilyClock.taskBodyString,KredilyClock.topicScaleupString);
      // flutterLocalNotificationsPlugin.show(12, 'Auto Task notification ', 'TaskList Notification Has send successfully', NotificationDetails(android: AndroidNotificationDetails("12","sad","das")),payload: "");

    }else if(now.hour==23){
      fetchData();
      // flutterLocalNotificationsPlugin.show(12, 'Remaining members hour logs', 'Notification send to remaining member who has not fill their hour logs', NotificationDetails(android: AndroidNotificationDetails("12","sad","das")),payload: "");

    }else if(now.hour==19){
      await KredilyClock().sendNotification(KredilyClock.hourTitleString,KredilyClock.hourBodyString,KredilyClock.topicScaleupString);
      // flutterLocalNotificationsPlugin.show(12, 'Auto Hour logs notification ', 'Hour logs Notification Has send successfully', NotificationDetails(android: AndroidNotificationDetails("12","sad","das")),payload: "");
    }
  }
  DateTime _getNextSaturday(DateTime date) {
    final daysUntilNextSaturday = DateTime.saturday - date.weekday;
    return date.add(Duration(days: daysUntilNextSaturday));
  }
  fetchData() async {

    const credential=r''' 
  {
  "type": "service_account",
  "project_id": "myspreadsheet-381908",
  "private_key_id": "5a247c08321454e70eec2cebfbb962ae64b326a8",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCxxXEznqdC+XZM\nSTuDW3IDiYJyPVs8ZeX1IJnJ4Fz7hpF79+sguHzICV5Dgf0zCYJnilY+yoLpl62J\nK6FA9fTq2cWS70zQPsJXPw9kiwkCyV4D1MuwdWDuVglQ0anxe3KwCVec2QMshpv4\nvgjZx6rEPTiXWh+Syn9vzIyJF4M0at6aCQHk8Qh1CHgIqrL1B/XhVtgUGIY5HE2x\nE/kBO5UQCu9BRx3HuWmv49Xa8rOnztiZuaVpWGgnUPDNUfUp3kEhrkGtTDB7GlMb\nly7q47QIMCqAtBFdC1K4WL04mCaS4yAtEtwORh2CAEAbbVfn3VMc0fINVSGGuqBW\nwPCieGmLAgMBAAECggEAEasHbLN0eT4U6VEP9qa0hrB4hAUgF7ki6UFzt3Iym5cM\nx47k0gwz7qertDbrpNJpoQPJPZVf/HpkN3FcJfor/Nlm/wsEjd/m7cfpLjt5Sksc\nKnJQSjnoR9fKNjuYUdVMmT1cdUzGOXspbkfo1kg3ayiQgs5ku/CfSMvCHe/1zNQ1\n4QfO4yxlAFhqprw4FbC4b1/FvImt8dWGZQRjVxunMTdzLnYxTTL1wuVZpHiwCT4+\nPBiViNXllN2+bMFdOaNUu1OenEYtiFMDbnhPYRBOmCKeLypAtSCTf8UQLqSbMRfy\nq7qv90aIwuOJCackZdKQTGLt8Qs9dUCK4TLe+3jWdQKBgQDZUKM/w8FaIFqcmuEO\nveY5u80nTmiWJXIRORePcH+4QjSbuQZDl2+wu09r9jGIGuXcDh+D62yPQgflV1mX\nDINiS+/AX365Ix5wRktrqNgHFarnJUNgJ77uoVqKt3qmz8T5cu8ERo7I3i974y7c\nuvwAwG+nvSpp4IlmjZnixJjHZQKBgQDRar0cyF69S7ilXJP69eqHav9rE2mG9d/g\nNAonhFB5lrqVF9UDo0xCUzKCJojoWFTVs105yMbJrNBVd+eB5mM1MnIzaNnz1ffE\n03V4GJLaG9bc+z+lqGfb2iE830si5qluQGeS7DqFxYuiqs4hrw2chw7bV5uOYaDS\nRZh5uGK2LwKBgQCrEWVRHsIoNmvd97XOqwJ+1C2NEZYXC+cdU7oOOlrwK33KT/50\nWtObZfgBXs5i+/mSHrQEXuEYbLxWd0qZM0qBqJFU+FeDWffuHgfk+gcEnLPqPVUq\nbl9I7k+d/w1YHxpJ24X38asYyH7MoWwUakVSOioq+yhWLGE9D57h+iziWQKBgBzi\nGukwXZjAK9xq02Imrs00nbvX9pMNsG4M32Wp4yuR9XQA0Hlq+WagcPPwequJG1JK\nJc6FeZ1xP166ZezNqNs6dPPQP1dZKI42GBqTURXSByV9Zb7kZka1ZCYwKf3LUI0L\nRv3FpSC0KVkrM7kDmt3+5rar86GEp5i4zpnjK4IzAoGBAI+PdOSU/tAH8t9jn+9Q\nnF+Y+Hfg7xZc+UT0Fy3ISJ1ockXLBFaPgXUQLevV2UenERxhKzjFhRC56TBcbfWi\n3zZBNWKb+L88iNqH97b8JRBWL5CpTOOmHTNrW/qi3JTsmn95diIuAtERSc0Rnjpg\nkmiphw5oawHb6dY8cVVbNqIS\n-----END PRIVATE KEY-----\n",
  "client_email": "flutter-gsheets@myspreadsheet-381908.iam.gserviceaccount.com",
  "client_id": "116491668632362320015",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/flutter-gsheets%40myspreadsheet-381908.iam.gserviceaccount.com"
}
''';

    var spreadSheetId="1TRjzU-PAkm3_rQJpmL1aWo4r-jJDh200XlmAVfvZukI";
    var spreadSheet;
    final gsheets = GSheets(credential);
    spreadSheet =await gsheets.spreadsheet(spreadSheetId);

    var memberList=[];
    List<String> emailList=[];
    Worksheet sheet=spreadSheet.worksheetByTitle("Data sheet");
    memberList=(await sheet.values.columnByKey("Team Member Name"))!;
    var statusList=(await sheet.values.columnByKey("Current Status"))!;
    var levelList=(await sheet.values.columnByKey("Level of Members"))!;
    emailList=(await sheet.values.columnByKey("Email"))!;

    statusList=statusList.sublist(0,memberList.length);
    levelList=levelList.sublist(0,memberList.length);
    emailList=emailList.sublist(0,memberList.length);

    for(int i=0;i<statusList.length;i++){
      if(statusList[i]=="Inactive"){
        memberList[i]='-1';
        emailList[i]='-1';
      }
      if(levelList[i]=="Lead Member"){
        memberList[i]='-1';
        emailList[i]='-1';
      }
    }
    memberList.removeWhere((e) => e=='-1');
    emailList.removeWhere((e) => e=='-1');

    int indd=memberList.indexOf("Sparsh Gupta");
    memberList.removeAt(indd);
    emailList.removeAt(indd);

    print('AFTERRRR ${memberList.length}');
    print('AFTERRRR ${emailList.length}');

    // print(memberList);
    // print(emailList);

    Worksheet sheet2=spreadSheet.worksheetByTitle("Worksheet1");
    var allRow=await sheet2.values.allRows();

    if(allRow.isEmpty) return;
    if(allRow[allRow.length-1][0].isEmpty) return;
    const gsDateBase = 2209161600 / 86400;
    const gsDateFactor = 86400000;

    final date = double.tryParse(allRow[allRow.length-1][0]);
    if (date == null) return null;
    final millis = (date - gsDateBase) * gsDateFactor;
    DateTime dateTimeGet=DateTime.fromMillisecondsSinceEpoch(millis.toInt(), isUtc: true);
    String formattedDateTime=DateFormat('dd-MM-yyyy').format(dateTimeGet);
    String formattedNow=DateFormat('dd-MM-yyyy').format(DateTime.now());
    if(formattedDateTime==formattedNow){

      List newList=allRow.where((element) => element[0]==allRow[allRow.length-1][0]).map((e) => e[1]).toList();
      // memberList.removeWhere((e) => newList.contains(e));
      List indexList=[];
      for(int i=0;i<memberList.length;i++){
        if(newList.contains(memberList[i])){
          indexList.add(i);
        }
      }
      for(int x=indexList.length;x>0;x--){
        print("INDEXXXXXXXXXX $x");
        memberList.removeAt(x);
        emailList.removeAt(x);
      }
    }
    for(int i=0;i<emailList.length;i++){
      String title="Hours log Update";
      String body="${memberList[i]} Please update your hours log";
      print(memberList.length);
      print(emailList.length);
      print(i);
      var value=await KredilyClock().sendNotification(title,body,emailList[i].toLowerCase().replaceAll('@', '.'));
    }
  }
}
