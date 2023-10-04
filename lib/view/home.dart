import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hanghae_athletic/core/board.dart';
import 'package:hanghae_athletic/service/firestore.dart';
import 'package:hanghae_athletic/state/user.dart';
import 'package:hanghae_athletic/util/size.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../state/audioplayer.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AudioPlayerState audioPlayerState = Get.put(AudioPlayerState());
  final TextEditingController _controller = TextEditingController();
  final User userState = Get.put(User());

  // audio play state
  bool isPlay = true;
  Duration duration = const Duration(milliseconds: 0);

  // my points
  int points = 0;
  String? nickname;

  @override
  void initState() {
    super.initState();

    _init();
  }

  _init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _controller.text = prefs.getString('nickname')!;
      points = prefs.getInt('points')!;
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig size = SizeConfig(context);
    // AudioPlayerState audioPlayerState = Get.find<AudioPlayerState>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (isPlay) {
                    audioPlayerState.pause();
                    isPlay = false;
                  } else {
                    audioPlayerState.play();
                    isPlay = true;
                  }
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '브금',
                    style: TextStyle(
                      fontFamily: 'BM',
                      color: Colors.white,
                      fontSize: size.width(20),
                    ),
                  ),
                  SizedBox(
                    width: size.width(10),
                  ),
                  Icon(
                    isPlay ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: size.width(26),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.width(50),
            ),
            Text(
              "너도나도",
              style: TextStyle(
                color: Colors.white,
                fontSize: size.width(40),
                fontFamily: 'BM',
                fontWeight: FontWeight.w700,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: "테",
                    style: TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: size.width(40),
                      fontFamily: 'BM',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "트",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: size.width(40),
                      fontFamily: 'BM',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "리",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: size.width(40),
                      fontFamily: 'BM',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: "스",
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: size.width(40),
                      fontFamily: 'BM',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: size.width(20),
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: size.width(226),
              child: Text(
                '내 점수 : $points',
                style: TextStyle(
                  fontFamily: 'BM',
                  color: Colors.white,
                  fontSize: size.width(16),
                ),
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '내 이름 : ',
                  style: TextStyle(
                    fontFamily: 'BM',
                    color: Colors.white,
                    fontSize: size.width(16),
                  ),
                ),
                Container(
                  width: size.width(160),
                  child: TextFormField(
                    maxLength: 8,
                    controller: _controller,
                    // initialValue: userState.nickname.value,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      border: UnderlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: Icon(
                        Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    onFieldSubmitted: (value) async {
                      if (value != null) {
                        print('??');
                        userState.updateNickname(value);
                        setState(() {
                          nickname = value;
                        });
                      }
                    },
                    style: TextStyle(
                      decorationThickness: 0,
                      fontFamily: 'BM',
                      fontSize: size.width(16),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              alignment: Alignment.center,
              width: size.width(270),
              height: size.width(150),
              child: StreamBuilder(
                stream: Record().scoreOnSnapShot(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && !snapshot.hasError) {
                    var dataList = snapshot.data.docs;
                    return ListView.builder(
                      itemCount: dataList.length > 5 ? 5 : dataList.length,
                      itemBuilder: (context, index) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${index + 1} 등: ${dataList![index]['nickname']}',
                              style: TextStyle(
                                fontFamily: 'BM',
                                fontSize: size.width(16),
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              '${dataList![index]['score']} 점',
                              style: TextStyle(
                                fontFamily: 'BM',
                                fontSize: size.width(16),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return Text(
                    '로딩중',
                    style: TextStyle(
                      fontFamily: 'BM',
                      color: Colors.white,
                      fontSize: size.width(30),
                    ),
                  );
                },
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameBoard(),
                    ),
                    (route) => false);
              },
              style: ButtonStyle(
                overlayColor: MaterialStateProperty.resolveWith((states) {
                  if (states.contains(MaterialState.pressed)) {
                    return Colors.white
                        .withOpacity(0.1); // Set your desired splash color here
                  }
                  return null;
                }),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width(28),
                  vertical: size.width(12),
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    width: 2,
                    color: Colors.white,
                  ),
                  borderRadius: BorderRadius.circular(
                    size.width(50),
                  ),
                ),
                child: Text(
                  '시작하기',
                  style: TextStyle(
                    fontFamily: 'BM',
                    color: Colors.white,
                    fontSize: size.width(24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
