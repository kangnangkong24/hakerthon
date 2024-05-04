import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        title: const Text('내 통계 확인하기'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.teal,
                  style: BorderStyle.solid,
                  width: 2,
                ),
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Column(
                children: [
                  const Text(
                    '음식물 쓰레기 배출량',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Stack(
                    children: [
                      Positioned(
                        top: 320, // Adjust the top position as needed
                        left: 50, // Adjust the left position as needed
                        child: Container(
                          width: 255, // Adjust the width as needed
                          height: 25, // Adjust the height as needed
                          color: Colors.teal[100],
                          // Choose your desired color
                          child: Center(
                            child: Text(
                              '8/23        8/24       8/25       8/26       8/27',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 3, // Adjust the top position as needed
                        left: 50, // Adjust the left position as needed
                        child: Container(
                          width: 255, // Adjust the width as needed
                          height: 25, // Adjust the height as needed
                          color: Colors.teal[100],
                          // Choose your desired color
                          child: Center(
                            child: Text(
                              '8/23        8/24       8/25       8/26       8/27',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
