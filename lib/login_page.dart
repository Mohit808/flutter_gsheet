import 'package:flutter/material.dart';
import 'package:flutter_gsheet/kredily_clock.dart';
import 'package:flutter_gsheet/main.dart';
import 'package:flutter_gsheet/my_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController textEditingControllerPass=TextEditingController();
  var animateWidth;
  MyController myController=Get.put(MyController());
  bool visible=false;

  @override
  void initState() {
    super.initState();
    myController.isLoginPage.value=true;
  }

  @override
  void dispose() {
    myController.textEditingControllerEmail.text="";
    myController.isLoginPage.value=false;
    super.dispose();
  }

  onSubmit(){
    if(myController.textEditingControllerEmail.text.isEmpty){
      Fluttertoast.showToast(msg: "Email can't be empty");
      return;
    }
    if(!GetUtils.isEmail(myController.textEditingControllerEmail.text)){
      Fluttertoast.showToast(msg: "Invalid Email");
      return;
    }
    if(textEditingControllerPass.text.isEmpty){
      Fluttertoast.showToast(msg: "Pass can't be empty");
      return;
    }
    if(textEditingControllerPass.text.length<5){
      Fluttertoast.showToast(msg: "Pass is too small");
      return;
    }
    if(myController.loginLoading.value==true){
      return;
    }
    myController.loginLoading.value=true;

    sharedPreference.setString("email", myController.textEditingControllerEmail.text.toLowerCase());
    sharedPreference.setString("pass", textEditingControllerPass.text);
    KredilyClock().getKredily();
  }
  @override
  Widget build(BuildContext context) {
    var width=MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Login",style: TextStyle(fontWeight: FontWeight.bold)),),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              width<600?SizedBox():Expanded(flex: 2,child: SvgPicture.asset('assets/signin.svg',height: Get.size.height-100,)),
              Expanded(flex: width>600 && width<800?2:1,
                child: Column(mainAxisSize: MainAxisSize.min,children: [
                  Material(elevation: 1,borderRadius: BorderRadius.circular(150),child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Image.asset("assets/scaleup.png",scale: 1.2),
                  )),
                  SizedBox(height: 50,),
                  Container(padding: EdgeInsets.only(left: 16),decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.grey)),child: TextField(controller: myController.textEditingControllerEmail,keyboardType: TextInputType.emailAddress,decoration: InputDecoration(hintText: "Enter email",border: InputBorder.none),)),
                  SizedBox(height: 16,),
                  Container(padding: EdgeInsets.only(left: 16),decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),border: Border.all(color: Colors.grey)),child: TextField(onSubmitted: (value){onSubmit();},controller: textEditingControllerPass,obscureText: visible?false:true,decoration: InputDecoration(hintText: "Enter Password",border: InputBorder.none,suffixIcon: InkWell(onTap: (){
                    visible=!visible;
                    setState(() {
                    });
                  },child: Icon(visible?Icons.visibility_off:Icons.visibility))),)),
                  SizedBox(height: 50,),

                  Obx(() => myController.loginLoading.value==true?SizedBox():Row(children: [
                    Expanded(child: InkWell(onTap: (){
                      onSubmit();
                    },
                      child: AnimatedContainer(duration: Duration(seconds: 2),width: myController.animatedWidth.value,alignment: Alignment.center,decoration: BoxDecoration(color: Colors.blueAccent,borderRadius: BorderRadius.circular(10)),child: Row(mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text("SUBMIT",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),textAlign: TextAlign.center,)),
                        ],
                      ),),
                    ))
                  ],)),
                  Obx(() => myController.loginLoading.value==false?SizedBox():Row(mainAxisAlignment: MainAxisAlignment.center,children: [
                    Container(padding: EdgeInsets.all(8),decoration: BoxDecoration(color: Colors.red,borderRadius: BorderRadius.circular(30)),width: 50,height: 50,child: CircularProgressIndicator(color: Colors.white,),)
                  ],))
                ],),
              ),
              width<600?SizedBox():SizedBox(width: 24,)
            ],
          ),
        ),
      ),
    );
  }
}

