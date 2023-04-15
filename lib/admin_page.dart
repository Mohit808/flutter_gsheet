import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gsheets/gsheets.dart';
import 'package:intl/intl.dart';
import 'kredily_clock.dart';
import 'main.dart';

class AdminPage extends StatefulWidget {
  String csrfToken;
  String sessionId;
  AdminPage({Key? key,required this.csrfToken,required this.sessionId}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  bool value1=false;
  bool value2=false;
  var memberList=[];
  List<String> emailList=[];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  fetchData() async {
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
    setState(() {
    });
    // print("LIAAAAAAAAAAA ${memberList.length}");
    // print("LIAAAAAAAAAAA!!@@@ ${emailList.length}");
  }

  sendMess() async {
    if(value1==false && value2==false){
      Fluttertoast.showToast(msg: "Select one option");
      return;
    }
    var title,body;
    if(value1){
      title=KredilyClock.taskTitleString;
      body=KredilyClock.taskBodyString;
    }else{
      title=KredilyClock.hourTitleString;
      body=KredilyClock.hourBodyString;
    }
    var value=await KredilyClock().sendNotification(title,body,KredilyClock.topicScaleupString);
    if(value!=null){
      value1=false;value2=false;
      setState(() {
      });
    }
  }
  sendPersonalMsg() async {
    for(int i=0;i<emailList.length;i++){
      String title="Hours log Update";
      String body="${memberList[i]} Please update your hours log";
      print(memberList.length);
      print(emailList.length);
      print(i);
      var value=await KredilyClock().sendNotification(title,body,emailList[i].toLowerCase().replaceAll('@', '.'));
      if(value!=null){
        // print(emailList);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Admin Space",style: TextStyle(fontWeight: FontWeight.bold)),),
    body: RefreshIndicator(
      onRefresh: ()async{
        memberList=[];
        emailList=[];
        value1=false;
        value2=false;
        setState(() {
        });
        fetchData();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
          Row(
            children: [
              Checkbox(value: value1, onChanged: (onChanged){
                value1=!value1;
                value2=false;
                setState(() {
                });
              }),
              Text("TaskList message")
            ],
          ),
          Row(
            children: [
              Checkbox(value: value2, onChanged: (onChanged){
                value2=!value2;
                value1=false;
                setState(() {
                });
              }),
              Text("Hour logs message")
            ],
          ),
          Row(children: [
            Expanded(child: InkWell(onTap: (){
              sendMess();
            },child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(10)),child: Text("Send Message",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center),)))
          ],),
          SizedBox(height: 50,),
          Text(memberList.isEmpty?'':'Remaining hour logs members',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 22)),
          SizedBox(height: 16,),
          Text(memberList.isEmpty?'':memberList.join(", ").toString()),
          SizedBox(height: 16,),
          memberList.isEmpty?SizedBox():Row(children: [
            Expanded(child: InkWell(onTap: (){
              sendPersonalMsg();
              // fetchData();
            },child: Container(padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(10)),child: Text("Send Message to everyone",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center),)))
          ],),
        ],),
      ),
    ),
    );
  }
}
