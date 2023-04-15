import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'kredily_clock.dart';
import 'my_controller.dart';

class LeaveLogsPage extends StatefulWidget {
  String csrfToken;
  String sessionId;
  LeaveLogsPage({Key? key,required this.csrfToken,required this.sessionId}) : super(key: key);

  @override
  State<LeaveLogsPage> createState() => _LeaveLogsPageState();
}

class _LeaveLogsPageState extends State<LeaveLogsPage> {
  List list=[];
  MyController myController=Get.put(MyController());
  List<String> listDates=[];
  var selectedDatevalue;


  @override
  void initState() {
    super.initState();
    var year=DateTime.now().year;
    var year2=DateTime.now().subtract(Duration(days: 365)).year;
    var year3=DateTime.now().add(Duration(days: 365)).year;
    listDates.add('$year-$year3');
    listDates.add('$year2-$year');
    selectedDatevalue=listDates[0];
    getData(listDates[0]);
  }
  getData(date) async{
    list=await KredilyClock().getLeaveLogs(widget.csrfToken, widget.sessionId,date);
    setState(() {
    });
    print("Listx ${list}");
  }

  Future<void> cancelLeaveFunction(index) async {
    if(myController.cancelLeaveLoading.value==true){
      Fluttertoast.showToast(msg: "Work in progress! please wait...");
      return;
    }

    myController.cancelLeaveLoading.value=true;

    var value=await KredilyClock().cancelLeave(widget.csrfToken, widget.sessionId, list[index][6]['leave_request_uu']);

    if(value=="success"){
      list[index][6]['allow_cancel_button']=false;
      list[index][5]='Cancelled';
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Logs',style: TextStyle(fontWeight: FontWeight.bold),),
      actions: [
        // Text("2023-2024"),
        dropDown(selectedDatevalue),
        SizedBox(width: 16,)
      ],),

        body: RefreshIndicator(
          onRefresh: () async{
            list=[];
            setState(() {
            });
            getData(selectedDatevalue);
          },
          child: list.isEmpty?Center(child: CircularProgressIndicator(color: Colors.red,),):SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                ListView.builder(primary: false,shrinkWrap: true,itemCount: list.length,itemBuilder: (itemBuilder,index){
                  return widgetList(index);
                })
              ],),
            ),
          ),
        )
    );
  }
  Widget widgetList(index){

    return Row(
      children: [
        Expanded(
          child: Material(elevation: 0,borderRadius: BorderRadius.circular(16),
            child: Container(margin: EdgeInsets.only(bottom: 16),padding: EdgeInsets.all(16),decoration: BoxDecoration(color: Colors.grey[100],borderRadius: BorderRadius.circular(16)),child:
            Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
              Text('${list[index][0]}',style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold),),
              SizedBox(height: 4,),
              SizedBox(child: Text('Start Date : ${list[index][1]}'.toString())),
              SizedBox(height: 4,),
              SizedBox(child: Text('End Date : ${list[index][2]}'.toString())),
              SizedBox(height: 4,),
              SizedBox(child: Text('Days : ${list[index][3]}'.toString(),)),
              SizedBox(height: 4,),
              SizedBox(child: Text('Applied On : ${list[index][4]}'.toString(),)),
              SizedBox(height: 4,),
              SizedBox(child: Text('Status : ${list[index][5]}'.toString())),
              SizedBox(height: 8,),
              list[index][6]['allow_cancel_button']==false?SizedBox():InkWell(onTap: () async {
                cancelLeaveFunction(index);
              },child: Material(elevation: 2,borderRadius: BorderRadius.circular(16),child: Obx(() => Container(width: myController.cancelLeaveLoading==true?50:null,padding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),child:
              myController.cancelLeaveLoading==true?
              SizedBox(height: 20,child: CircularProgressIndicator(color: Colors.white,),):
              Text("Cancel",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),decoration: BoxDecoration(color: Colors.deepOrangeAccent,borderRadius: BorderRadius.circular(16)),)))),

              // SizedBox(height: 40,width: 40,child: Container(decoration: BoxDecoration(color: Colors.deepOrangeAccent,borderRadius: BorderRadius.circular(30)),padding: EdgeInsets.all(8),child: CircularProgressIndicator(color: Colors.white,))),
            ],),),
          ),
        ),
      ],
    );
  }
  dropDown(value){
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        items: listDates
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            value = newValue!;
            selectedDatevalue=value;
            list=[];
            setState(() {
            });
            getData(value);
          });
        },
      ),
    );
  }
}
