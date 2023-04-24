import 'package:flutter/material.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';
import 'package:webrtc_video_conference/models/meeting_detail.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:webrtc_video_conference/pages/home.dart';
import 'package:webrtc_video_conference/utils/user.utils.dart';
import 'package:webrtc_video_conference/widgets/control_panel.dart';
import 'package:webrtc_video_conference/widgets/remote_connection.dart';

class MeetingPage extends StatefulWidget {

  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;

  MeetingPage({required this.meetingDetail,this.name,this.meetingId});

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer=RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints={
    'audio':true,
    'video':true
  };

  bool isConnectionFailed=false;
  WebRTCMeetingHelper? meetingHelper;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        onMeetingEnd: onMeetingEnd,
        isConnectionFailed: isConnectionFailed,
        onRecconect: handleReconnect,
        videoEnabled: isVideoEnabled(),
        andioEnabled: isAudioEnabled(),
      ),
    );
  }

  void startMeeting() async {
    final String userId= await loadUserId();
    meetingHelper=WebRTCMeetingHelper(
      url: 'http://192.168.1.9:4000',
      meetingId: widget.meetingDetail.id,
      userId: userId,
      name: widget.name,
    );
    MediaStream _localStream =
    await navigator.mediaDevices.getUserMedia(mediaConstraints);

    _localRenderer.srcObject = _localStream;

    meetingHelper!.stream = _localStream;

    meetingHelper!.on(
        'open',
        context,
            (ev, context) {
          setState(() {
            isConnectionFailed=false;
          });
            });
    meetingHelper!.on(
        'connection',
        context,
            (ev, context) {
          setState(() {
            isConnectionFailed=false;
          });
        });
    meetingHelper!.on(
        'user-left',
        context,
            (ev, context) {
          setState(() {
            isConnectionFailed=false;
          });
        });
    meetingHelper!.on(
        'video-toggle',
        context,
            (ev, context) {
          setState(() {});
        });
    meetingHelper!.on(
        'audio-toggle',
        context,
            (ev, context) {
          setState(() {});
        });
    meetingHelper!.on(
        'meeting-ended',
        context,
            (ev, context) {
          onMeetingEnd();
        });
    meetingHelper!.on(
        'connection-setting-changed',
        context,
            (ev, context) {
              setState(() {
                isConnectionFailed=false;
              });
        });
    meetingHelper!.on(
        'stream-changed',
        context,
            (ev, context) {
          setState(() {
            isConnectionFailed=false;
          });
        });
    setState(() {

    });
  }

  initRenderer() async {
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    initRenderer();
    startMeeting();
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    _localRenderer.dispose();
    if(meetingHelper!=null){
      meetingHelper!.destroy();
      meetingHelper=null;
    }
  }

  void onMeetingEnd(){
    if(meetingHelper != null){
      meetingHelper!.endMeeting();
      meetingHelper = null;
      goToHomePage();
    }
  }

  void onVideoToggle(){
    if(meetingHelper!=null){
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }
  void onAudioToggle(){
    if(meetingHelper!=null){
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }
  bool isAudioEnabled(){
    return meetingHelper!= null ? meetingHelper!.audioEnabled! : false;
  }
  bool isVideoEnabled(){
    return meetingHelper!= null ? meetingHelper!.videoEnabled! : false;
  }

  void handleReconnect(){
    if(meetingHelper!=null){
      meetingHelper!.reconnect();
    }
  }

  void goToHomePage() {
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context)=>HomeScreen(),),
    );
  }

  _buildMeetingRoom(){
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty! ?
            GridView.count(
              crossAxisCount: meetingHelper!.connections.length < 6 ? 1 : 2,
              children: List.generate(meetingHelper!.connections.length, (index) {
                return Padding(padding: EdgeInsets.all(1),
                  child: RemoteConnection(
                    renderer: meetingHelper!.connections[index].renderer,
                    connection: meetingHelper!.connections[index],
                  ),
                );
              })
            ) : Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Waiting for the participants to Join!',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 24,
              ),
            ),
          ),
        ), Positioned(child: SizedBox(
          width: 150,
          height: 200,
          child: RTCVideoView(_localRenderer),
        ),bottom: 10,right: 0,),
      ],
    );
  }

}


