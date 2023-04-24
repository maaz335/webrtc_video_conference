import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';
import 'package:webrtc_video_conference/models/meeting_detail.dart';
import 'package:webrtc_video_conference/pages/meeting_page.dart';

class JoinScreen extends StatefulWidget {
  final MeetingDetail? meetingDetail;

  JoinScreen({this.meetingDetail});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  static final GlobalKey<FormState> globalKey=GlobalKey<FormState>();
  String userName='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join Meeting"),
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
            FormHelper.inputFieldWidget(
              context,
              "userId",
              'Enter your Name',
                  (onValidate){
                if(onValidate.isEmpty){
                  return "Name can not be Null";
                }
                return null;
              },
                  (onSaved){
                userName=onSaved;
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
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context){
                          return MeetingPage(meetingDetail: widget.meetingDetail!,meetingId: widget.meetingDetail!.id,
                          name: userName,);
                        }));
                      }
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

}
