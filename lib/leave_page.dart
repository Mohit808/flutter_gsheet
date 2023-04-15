import 'package:flutter/material.dart';
import 'package:flutter_gsheet/apply_leave.dart';
import 'package:flutter_gsheet/kredily_clock.dart';
import 'package:flutter_gsheet/leave_logs.dart';
import 'package:flutter_gsheet/my_controller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class LeavePage extends StatefulWidget {
  String csrfToken;
  String sessionId;
  LeavePage({Key? key,required this.csrfToken,required this.sessionId}) : super(key: key);

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {

  List list=[];
  MyController myController=Get.put(MyController());
  @override
  void initState() {
    super.initState();
    getData();
  }
  getData() async{
    var listx=await KredilyClock().getLeaveStatus(widget.csrfToken, widget.sessionId);
    if(listx!=null){
      list=listx;
    }
    setState(() {
    });
    print("Listx ${list.length}");
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text("Leave",style: TextStyle(fontWeight: FontWeight.bold),),
    actions: [Material(borderRadius: BorderRadius.circular(8),elevation: 2,
      child: InkWell(onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (builder)=>LeaveLogsPage(csrfToken: widget.csrfToken,sessionId: widget.sessionId,)));
      },child: Container(decoration: BoxDecoration(color: Colors.grey[100],borderRadius: BorderRadius.circular(8)),padding: EdgeInsets.only(top: 4,bottom: 4,left: 16,right: 16),child: Text("Logs",style: TextStyle(fontWeight: FontWeight.bold),))),
    ),SizedBox(width: 24,)],),
      body: RefreshIndicator(
        onRefresh: () async{
          list=[];
          setState(() {
          });
          getData();
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
      ),
    );
  }
  Widget widgetList(index){
    var boxColor=Colors.deepOrange[100],headerTextColor= Colors.deepOrangeAccent,itemTextColor=Colors.deepOrangeAccent[200];

    if(index==0){
      boxColor=Colors.deepOrange[100];
      headerTextColor= Colors.deepOrangeAccent;
      itemTextColor=Colors.deepOrangeAccent[200];
    }

    if(index==1){
      boxColor=Colors.purple[100];
      headerTextColor= Colors.purpleAccent;
      itemTextColor=Colors.purpleAccent[200];
    }

    if(index==2){
      boxColor=Colors.blue[100];
      headerTextColor= Colors.blueAccent;
      itemTextColor=Colors.blueAccent[200];
    }
    if(index==3){
      boxColor=Colors.pink[100];
      headerTextColor= Colors.pinkAccent;
      itemTextColor=Colors.pinkAccent[200];
    }


    return Row(
      children: [
        Expanded(
          child: Material(elevation: 0,borderRadius: BorderRadius.circular(16),
            child: Container(margin: EdgeInsets.only(bottom: 16),padding: EdgeInsets.all(16),decoration: BoxDecoration(color: boxColor,borderRadius: BorderRadius.circular(16)),child:
            Column(crossAxisAlignment: CrossAxisAlignment.start,children: [
              Text(list[index]['leave_type'],style: TextStyle(color: headerTextColor,fontSize: 24,fontWeight: FontWeight.bold),),
              SizedBox(height: 16,),
              SizedBox(child: Text('Total Leaves ${list[index]['total_leaves']==""?'0.00':list[index]['total_leaves']}'.toString(),style: TextStyle(color: itemTextColor),)),
              SizedBox(height: 8,),
              SizedBox(child: Text('Availed Leaves ${list[index]['availed_leaves']}'.toString(),style: TextStyle(color: itemTextColor),)),
              SizedBox(height: 8,),
              SizedBox(child: Text('Leave Balance ${list[index]['Leave_balance'].isEmpty?'0.00':'${list[index]['Leave_balance']}'}'.toString(),style: TextStyle(color: itemTextColor,fontWeight: FontWeight.bold,fontSize: 16),)),
              SizedBox(height: 8,),
              InkWell(onTap: (){
                if(list[index]['Leave_balance']=="0.00"){
                  Fluttertoast.showToast(msg: "Insufficient Leave Balance. Please Check and Reapply.");
                  return;
                }
                Navigator.push(context, MaterialPageRoute(builder: (builder)=>ApplyLeave(csrfToken: widget.csrfToken,sessionId: widget.sessionId,type: list[index]['leave_type'],))).then((value){
                  if(value=="success"){
                    list=[];
                    setState(() {
                    });
                    getData();
                  }
                });
              },child: Material(elevation: 2,borderRadius: BorderRadius.circular(16),child: Container(padding: EdgeInsets.only(top: 8,bottom: 8,left: 16,right: 16),child: Text("Apply leave",style: TextStyle(color: headerTextColor,fontWeight: FontWeight.bold)),decoration: BoxDecoration(color: Colors.white,borderRadius: BorderRadius.circular(16)),)))

            ],),),
          ),
        ),
      ],
    );
  }
}
