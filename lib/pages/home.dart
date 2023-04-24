import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:webrtc_video_conference/api/meeting_api.dart';
import 'package:http/http.dart';
import 'package:webrtc_video_conference/models/meeting_detail.dart';
import 'package:webrtc_video_conference/pages/join_screen.dart';

class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static final GlobalKey<FormState> globalKey=GlobalKey<FormState>();
  String meetingId="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Video Conference"),
        backgroundColor: Colors.white,
      ),
      body: Form(
        key: globalKey,
        child: formUI(),
      ),
    );
  }

  formUI() {

    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome to Video Conference",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 25,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              FormHelper.inputFieldWidget(
                  context,
                  "meetingId",
                  'Enter your meeting Id',
                  (onValidate){
                    if(onValidate.isEmpty){
                      return "Meeting Id can not be Null";
                    }
                    return null;
                  },
                  (onSaved){
                    meetingId=onSaved;
                  },
                borderRadius: 10,
                borderFocusColor: Colors.redAccent,
                borderColor: Colors.redAccent,
                hintColor: Colors.grey,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Flexible(
                      child: FormHelper.submitButton(
                          "Join",
                          (){
                            if(validateAndSave()){
                              validateMeeting(meetingId);
                            }
                          },
                      ),
                  ),
                  Flexible(
                    child: FormHelper.submitButton(
                      "Start",
                          () async {
                        var respone= await startMeeting();
                        final body=json.decode(respone!.body);

                        final meetId=body['data'];
                        validateMeeting(meetId);

                        },
                    ),
                  ),
                ],
              ),
            ],
        ),
      ),
    );
  }

  bool validateAndSave(){
    final form=globalKey.currentState;
    if(form!.validate()){
      form.save();
      return true;
    }

    return false;
  }

  void validateMeeting(String meetingId) async {
    try{
        Response response=await joinMeeting(meetingId);
        var data=jsonDecode(response.body);
        final meetingDetails=MeetingDetail.fromJson(data['data']);
        goToJoinScreen(meetingDetails);
    }
    catch(err){
        FormHelper.showSimpleAlertDialog(
            context,
            "Video Conference",
            "Invalid Conference Id",
            'OK',
            (){
              Navigator.of(context).pop();
            }
        );
    }
  }

  goToJoinScreen(MeetingDetail? meetingDetail){
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context)=>JoinScreen(
              meetingDetail: meetingDetail,
            )
        ),);
  }

}
