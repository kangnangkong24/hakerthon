import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:yummy_chat_lecture3/screens/mainpage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AuthScreen(),
    );
  }
}

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  var _isLogin = true;
  String _userEmail = '';
  String _userName = '';
  String _userPassword = '';

  var _userNum = 0;

  Future<void> _submitAuthForm() async {
    UserCredential userCredential;

    try {
      if (_isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (ctx) => Placeholder()), // Change to your ChatApp route
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: _userEmail,
          password: _userPassword,
        );

        // Firestore에 사용자 정보 저장
        await _firestore.collection('user').doc(userCredential.user!.uid).set({
          'userName': _userName,
          'email': _userEmail,
          'point': 0,
          'user_nums': _userNum,
        });

        // 회원가입 성공 알림 메시지 출력
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('회원가입이 성공적으로 완료되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('스마틈스'),
          backgroundColor: Colors.green,
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                _isLogin = index == 0;
              });
            },
            tabs: [
              Tab(text: '로그인'),
              Tab(text: '회원가입'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    key: ValueKey('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: '이메일'),
                    onChanged: (value) {
                      setState(() {
                        _userEmail = value;
                      });
                    },
                  ),
                  TextField(
                    key: ValueKey('password'),
                    obscureText: true,
                    decoration: InputDecoration(labelText: '비밀번호'),
                    onChanged: (value) {
                      setState(() {
                        _userPassword = value;
                      });
                    },
                  ),
                  ElevatedButton(
                    child: Text('로그인'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ChatApp()),
                      );
                      // Button click action
                    },
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  TextField(
                    key: ValueKey('name'),
                    decoration: InputDecoration(labelText: '이름'),
                    onChanged: (value) {
                      setState(() {
                        _userName = value;
                      });
                    },
                  ),
                  TextField(
                    key: ValueKey('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(labelText: '이메일'),
                    onChanged: (value) {
                      setState(() {
                        _userEmail = value;
                      });
                    },
                  ),
                  TextField(
                    key: ValueKey('password'),
                    obscureText: true,
                    decoration: InputDecoration(labelText: '비밀번호'),
                    onChanged: (value) {
                      setState(() {
                        _userPassword = value;
                      });
                    },
                  ),
                  TextField(
                    key: ValueKey('nums'),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '가구원수'),
                    onChanged: (value) {
                      setState(() {
                        _userNum = int.parse(value);
                      });
                    },
                  ),
                  ElevatedButton(
                    child: Text('회원가입'),
                    onPressed: _submitAuthForm,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}