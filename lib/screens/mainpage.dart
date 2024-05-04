import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummy_chat_lecture3/screens/chart.dart';
import 'package:yummy_chat_lecture3/screens/chat_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ChatApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _authentication = FirebaseAuth.instance;
  final _numberController = TextEditingController();
  User? loggedUser;
  double trashButtonTop = 0.0;
  Stream<int>? userPointStream;
  String userTier = ''; // 사용자의 tier 값
  int counttier = 0;

  @override
  void initState() {
    super.initState();
    initApp();
    userPointStream = _getUserPointStream();
  }

  Future<void> initApp() async {
    await getCurrentUser();
    userTier = await getTierFromFirebase();
    setState(() {});
  }

  Stream<int> _getUserPointStream() async* {
    while (true) {
      yield await getPointFromFirebase();
      await Future.delayed(Duration(seconds: 1));
    }
  }

  Future<void> getCurrentUser() async {
    try {
      final user = _authentication.currentUser;
      if (user != null) {
        loggedUser = user;
        print(loggedUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String> getTierFromFirebase() async {
    try {
      final userRef = FirebaseFirestore.instance.collection('user').doc(loggedUser!.uid);
      DocumentSnapshot snapshot = await userRef.get();

      if (snapshot.exists) {
        return snapshot.get('tier');
      } else {
        return ''; // 기본 값 설정
      }
    } catch (e) {
      print('Error getting tier: $e');
      return ''; // 에러 처리 시 기본 값 설정
    }
  }

  Future<int> getPointFromFirebase() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (snapshot.exists) {
      return snapshot.get('point');
    } else {
      return 0;
    }
  }
  Future<int> getcountFromFirebase() async {
    try {
      final userRef = FirebaseFirestore.instance.collection('user').doc(loggedUser!.uid);
      DocumentSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        int smallercount = snapshot.get('smallercount');
        return smallercount;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting smallercount: $e');
      return 0; // 에러 처리 시 0 반환
    }
  }
  Future<void> updateCountTier() async {
    int smallercount = await getcountFromFirebase();
    if (smallercount < 10) {
      setState(() {
        counttier = 10 - smallercount;
      });
    } else if (smallercount >= 20) {
      setState(() {
        counttier = 0;
      });
    } else {
      setState(() {
        counttier = 20 - smallercount; // 수정된 부분
      });
    }
  }


  Future<void> _showCountTierDialog(BuildContext context) async {
    await updateCountTier();
    int smallercount = await getcountFromFirebase();
    String message = "";
    if (smallercount <= 10) {
      message = "현재 단계는 새싹 단계입니다\n작은 묘목에 도달하기 위해 $counttier번 음식물쓰레기를 더 줄여보세요!";
    } else if (smallercount >= 20) {
      message = "최고 단계인 큰 묘목에 도달하셨습니다!\n꾸준히 음식물쓰레기를 줄이도록 노력하세요!";
    } else if (smallercount>=10 && counttier<20) {
      message = "현재 단계는 작은 묘목 단계입니다\n큰 묘목에 도달하기 위해 $counttier번 음식물쓰레기를 더 줄여보세요!";
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("단계 확인하기"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 창 닫기
              },
              child: Text("닫기"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      appBar: AppBar(
        title: Text('Mainpage', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
        elevation: 0.0,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(0.0, 30.0, 0.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _showCountTierDialog(context);

                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.blueGrey[50],
                  elevation: 0.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                  fixedSize: Size(150, 150),
                ),
                child: CircleAvatar(
                  backgroundImage: AssetImage(getImageByTier(userTier)),
                  radius: 60.0,
                ),
              ),
            ),
            StreamBuilder<int>(
              stream: userPointStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  return Center(
                    child: Text(
                      '$userTier  ${snapshot.data} point',
                      style: TextStyle(
                        color: Colors.black,
                        letterSpacing: 1.0,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  );
                }
              },
            ),
            Divider(
              height: 40.0,
              color: Colors.grey[850],
              thickness: 0.5,
              endIndent: 0.0,
            ),
            AnimatedPositioned(
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              top: trashButtonTop,
              right: 0,
              left: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      trashButtonTop = trashButtonTop == 0.0 ? 100.0 : 0.0;
                    });
                  },
                  child: Container(
                    width: 300,
                    height: 80,
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ChatScreen()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.lightGreenAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                          fixedSize: Size(300, 80),
                        ),
                        child: Text(
                          "쓰레기 버리러 가기",
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Divider(
              height: 40.0,
              color: Colors.grey[850],
              thickness: 0.5,
              endIndent: 0.0,
            ),
            GestureDetector(
              onTap: () async {
              },
              child: Container(
                child: Text(
                  '  ',
                  style: TextStyle(
                    color: Colors.black,
                    letterSpacing: 2.0,
                    fontSize: 20.0,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyApp(),
    );
  }
}

String getImageByTier(String? tier) {
  if (tier == 'sprout') {
    return 'image/sprout.jpeg';
  } else if (tier == 'small tree') {
    return 'image/smalltree.png';
  } else if (tier == 'big tree') {
    return 'image/bigtree.png';
  } else {
    return 'image/sprout.jpeg';
  }
}
