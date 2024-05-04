import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yummy_chat_lecture3/screens/chart.dart';
import 'package:yummy_chat_lecture3/screens/mainpage.dart';
import 'package:yummy_chat_lecture3/screens/chart.dart';


void main() {
  const buttonSpacing = SizedBox(width: 10);

  runApp(MaterialApp(
    home: ChatScreen(),
  ));
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  int userPoint = 0;
  late Stream<int> userPointStream;
  User? loggedUser;
  String userTier = '';
  final _authentication = FirebaseAuth.instance;
  int counttier = 0;

  @override
  void initState() {
    super.initState();
    userPointStream = _getUserPointStream();
    initApp();
  }

  Stream<int> _getUserPointStream() async* {
    while (true) {
      yield await getPointFromFirebase();
      await Future.delayed(Duration(seconds: 1)); // 1초마다 업데이트
    }
  }

  Future<void> initApp() async {
    await getCurrentUser();
    userTier = await getTierFromFirebase();
    await updateCountTier();
    setState(() {});
  }

  Future<String> getTierFromFirebase() async {
    try {
      final userRef = FirebaseFirestore.instance.collection('user').doc(
          loggedUser!.uid);
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
      message =
      "현재 단계는 sprout 단계입니다\nsmall tree에 도달하기 위해 $counttier번 음식물쓰레기를 더 줄여보세요!";
    } else if (smallercount >= 20) {
      message = "최고 단계인 big tree에 도달하셨습니다!\n꾸준히 음식물쓰레기를 줄이도록 노력하세요!";
    } else if (smallercount >= 10 && counttier < 20) {
      message =
      "현재 단계는 small tree 단계입니다\nbig tree에 도달하기 위해 $counttier번 음식물쓰레기를 더 줄여보세요!";
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

  Future<int> getcountFromFirebase() async {
    try {
      final userRef = FirebaseFirestore.instance.collection('user').doc(
          loggedUser!.uid);
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

  Future<void> _showNumberInputDialog(BuildContext context) async {
    int inputValue = 0;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('숫자 입력'),
              content: TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  print("Input value: $value");
                  setState(() {
                    inputValue = int.tryParse(value) ?? 0;
                    print("Parsed value: $inputValue");
                  });
                },
                decoration: InputDecoration(
                  hintText: '충전할 포인트를 입력하세요',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    if (inputValue > 0) {
                      await updatePointInFirebase(inputValue);
                    }
                  },
                  child: Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> updatePointInFirebase(int value) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentReference userDocRef = FirebaseFirestore.instance.collection(
            'user').doc(user.uid);

        DocumentSnapshot snapshot = await userDocRef.get();

        if (snapshot.exists) {
          int userPoint = snapshot.get('point');
          int newPoint = userPoint + value;

          await userDocRef.update({'point': newPoint});

          snapshot = await userDocRef.get();
          userPoint = snapshot.get('point');

          // 환전 성공 메시지 창을 보여주기 위한 코드 추가
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('성공적으로 환전이 진행되었습니다.'),
            duration: Duration(seconds: 2),
          ));
        }
      } catch (e) {
        print("Firestore 업데이트 오류: $e");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('포인트 업데이트 중 오류가 발생했습니다.'),
          duration: Duration(seconds: 2),
        ));
      }
    }
  }

  Future<String> generateUserUIDQRCode() async {
    String userUID = await readUserUIDFromFirebase();
    return userUID;
  }

  Future<String> readUserUIDFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    } else {
      return '';
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

  Future<int> getRankFromFirebase() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    if (snapshot.exists) {
      return snapshot.get('sum_per_nums');
    } else {
      return 0;
    }
  }

  Future<void> _showChallengePopup(BuildContext context) async {
    int myRank = await getRankFromFirebase(); // 사용자의 랭킹 포인트 가져오기

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('대결 결과'),
          content: Text(
              '상대 사용자가 대결을 수락하였습니다!\n'
                  '상대 사용자의 랭킹 포인트 : 100\n'
                  '나의 랭킹 포인트: $myRank\n'
                  '대결에서 승리하였습니다\n50 point 지급'), // 메시지 업데이트
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 팝업 닫기
              },
              child: Text('닫기'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showRankingDialog(BuildContext context) async {
    QuerySnapshot usersSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .orderBy('sum_per_nums', descending: true)
        .limit(5) // Limit the query to retrieve only the top 5 users
        .get();
    List<QueryDocumentSnapshot> users = usersSnapshot.docs;

    List<Widget> rankingItems = []; // Create a list to store each user's ranking item

    for (int i = 0; i < users.length; i++) {
      QueryDocumentSnapshot currentUser = users[i];
      String userName = currentUser.get('userName');
      String sum_per_nums = currentUser.get('sum_per_nums').toString();

      // Create an ElevatedButton for each user
      ElevatedButton challengeButton = ElevatedButton(
        onPressed: () {
          _showChallengePopup(context);
          // Handle the challenge button click action
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.blue, // Customize the button color
        ),
        child: Text('도전하기'), // Customize the button text
      );

      // Create a row with ranking, name, sum_per_nums, and the challenge button
      Widget rankingItem = Row(
        children: [
          Text('${i + 1}. $userName : $sum_per_nums'),
          challengeButton,
        ],
      );
      // Add the ranking item to the list
      rankingItems.add(rankingItem);
    }


    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<int>(
          future: getRankFromFirebase(), // sum_per_nums 값을 가져오는 비동기 함수
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else {
              int myRank = snapshot.data ?? 0; // 가져온 순위 데이터 또는 기본 값

              return AlertDialog(
                title: Text('랭킹'),
                content: Container(
                  width: 300, // 원하는 폭으로 조절
                  height: 200, // 원하는 높이로 조절
                  child: Column(
                    children: [
                      Column(
                        children: rankingItems, // Add the list of ranking items
                      ),
                      Text('나의 랭킹 포인트 : $myRank'), // 나의 랭킹 포인트 추가
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('닫기'),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 6,
          title: Text(
            "QR 코드",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              icon: Icon(
                Icons.exit_to_app_sharp,
                color: Colors.white,
              ),
              iconSize: 40,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatApp()),
                );
                // Button click action
              },
            ),
          ],
          automaticallyImplyLeading: false, // 화살표 아이콘 없애기
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child:
                    FutureBuilder<String>(
                      future: generateUserUIDQRCode(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasData) {
                          return QrImageView(
                            data: snapshot.data!,
                            version: QrVersions.auto,
                            size: 300.0,
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                  Center(
                    child:
                    StreamBuilder<DateTime>(
                      stream: Stream.periodic(
                          Duration(seconds: 1), (i) => DateTime.now()),
                      builder: (context, snapshot) {
                        return Text(
                          DateFormat('M/d H:mm').format(snapshot.data ??
                              DateTime
                                  .now()),
                          style: TextStyle(fontSize: 30, color: Colors.black),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      "QR 코드를 스캔해주세요",
                      style: TextStyle(fontSize: 35, color: Colors.black),
                    ),
                  ),
                  SizedBox(height: 35),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        Text(
                          "현재 포인트",
                          style: TextStyle(fontSize: 33, color: Colors.black),
                        ),
                        StreamBuilder<int>(
                          stream: userPointStream,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              return Center(
                                child: Text(
                                    ": ${snapshot.data} point",
                                    style: TextStyle(
                                        fontSize: 33, color: Colors.black)),
                              );
                            }
                          },
                        ),
                      ]
                  ),
                  SizedBox(height: 45),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showNumberInputDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            fixedSize: Size(180, 60),
                          ),
                          child: Text(
                            "환전하기",
                            style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) =>
                                  ChartApp()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightGreenAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            fixedSize: Size(180, 60),
                          ),
                          child: Text(
                            "통계 확인하기",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                      ]
                  ),
                  SizedBox(height: 30),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showRankingDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlueAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            fixedSize: Size(180, 60),
                          ),
                          child: Text(
                            "랭킹 확인하기",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            _showCountTierDialog(context);
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.yellowAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            fixedSize: Size(180, 60),
                          ),
                          child: Text(
                            "단계 확인하기",
                            style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),

                      ]
                  ),
                ]
            ),
          ),
        ),
      );
    }
  }
