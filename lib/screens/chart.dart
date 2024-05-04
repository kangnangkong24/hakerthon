import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:yummy_chat_lecture3/screens/chat_screen.dart';

void main() {
  runApp(ChartApp());
}

class ChartApp extends StatelessWidget {
  const ChartApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyChartPage(),
    );
  }
}

class MyChartPage extends StatelessWidget {
  const MyChartPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chart', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green.shade500,
        elevation: 0.0,
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
                MaterialPageRoute(builder: (context) => ChatScreen()),
              );
              // Button click action
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.white,
      body: ChartWithText(),
    );
  }
}

class ChartWithText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        Column(
          children: [
            Text(
              '지난 달의 쓰레기 배출량',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              color: Colors.white,
              height: 400,
              width: 400,
              child: LineChart(
                LineChartData(
                  gridData: gridData,
                  titlesData: titlesData,
                  borderData: borderData,
                  lineBarsData: lineBarsData,
                  minX: 0,
                  maxX: 14,
                  minY: 0,
                  maxY: 8,
                ),
              ),
            ),
            SizedBox(height: 50,),
            Center(
              child: Text(
                '가장 많이 버린 날 : 780\n가장 적게 버린 날 : 330\n지날 달의 평균 : 560',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),
            SizedBox(height: 50,),
            Center(
              child: Text(
                  '9월달의 배출량 평균보다 줄었으므로\n 10월 31일에 1000point 지급!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
            )
          ],
        ),

        Column(
          children: [
            Text(
              '이번 달의 쓰레기 배출량',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              color: Colors.white,
              height: 400,
              width: 400,
              child: LineChart(
                LineChartData(
                  gridData: gridData,
                  titlesData: titlesData,
                  borderData: borderData,
                  lineBarsData: lineBarsData2,
                  minX: 0,
                  maxX: 14,
                  minY: 0,
                  maxY: 8,
                ),
              ),
            ),

            SizedBox(height: 50,),
            Center(
              child: Text(
                '가장 많이 버린 날 : 570\n가장 적게 버린 날: 210\n이번 달의 평균 : 355.7',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

            ),
            SizedBox(height: 50,),
            Center(
              child: Text(
                  '평균 배출량을 250g 이상 줄이면\n 11월 30일에 1000point 지급 가능!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
            )
          ],
        ),

      ],
    );
  }
  }


// 나머지 코드는 그대로 사용


// 나머지 코드는 그대로 사용


List<LineChartBarData> get lineBarsData => [lineChartBarData1];
List<LineChartBarData> get lineBarsData2 => [lineChartBarData2];

FlTitlesData get titlesData => FlTitlesData(
  bottomTitles: AxisTitles(
    sideTitles: bottomTitles,
  ),
  rightTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
  topTitles: AxisTitles(
    sideTitles: SideTitles(showTitles: false),
  ),
  leftTitles: AxisTitles(
    sideTitles: leftTitles(),
  ),
);

Widget leftTitlesWidget(double value, TitleMeta meta) {
  const style = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  String text;
  switch (value.toInt()) {
    case 2:
      text = '200';
      break;
    case 4:
      text = '400';
      break;
    case 6:
      text = '600';
      break;
    case 8:
      text = '800';
      break;
    default:
      return Container();
  }
  return Text(text, style: style, textAlign: TextAlign.center);
}

SideTitles leftTitles() => SideTitles(
  getTitlesWidget: leftTitlesWidget,
  showTitles: true,
  interval: 1,
  reservedSize: 40,
);

Widget bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.bold,
    color: Colors.grey,
  );
  Widget text;
  switch (value.toInt()) {
    case 1:
      text = const Text('10/3', style: style);
      break;
    case 3:
      text = const Text('10/8', style: style);
      break;
    case 5:
      text = const Text('10/13', style: style);
      break;
    case 7:
      text = const Text('10/18', style: style);
      break;
    case 9:
      text = const Text('10/23', style: style);
      break;
    case 11:
      text = const Text('10/27', style: style);
      break;
    case 13:
      text = const Text('10/31', style: style);
      break;
    default:
      text = const Text('');
      break;
  }
  return SideTitleWidget(
    axisSide: meta.axisSide,
    space: 10,
    child: text,
  );
}

SideTitles get bottomTitles => SideTitles(
  showTitles: true,
  reservedSize: 32,
  interval: 1,
  getTitlesWidget: bottomTitleWidgets,
);

FlGridData get gridData => FlGridData(
  show: true, // Show grid lines
  drawHorizontalLine: true,
  drawVerticalLine: true,
  horizontalInterval: 1, // You can adjust this interval as needed
  verticalInterval: 1.1, // You can adjust this interval as needed
);


FlBorderData get borderData => FlBorderData(
  show: true,
  border: Border(
    bottom: BorderSide(color: Colors.grey, width: 4),
    left: const BorderSide(color: Colors.grey),
    right: const BorderSide(color: Colors.transparent),
    top: const BorderSide(color: Colors.transparent),
  ),
);

LineChartBarData get lineChartBarData1 => LineChartBarData(
  isCurved: true,
  color: Colors.purple,
  barWidth: 6,
  isStrokeCapRound: true,
  dotData: FlDotData(show: false),
  spots: const [
    FlSpot(1, 4.5),
    FlSpot(3, 6.0),
    FlSpot(5, 7.8),
    FlSpot(7, 4.6),
    FlSpot(9, 7.2),
    FlSpot(11, 3.3),
    FlSpot(13, 5.8),
  ],
);

LineChartBarData get lineChartBarData2 => LineChartBarData(
  isCurved: true,
  color: Colors.blue, // You can change the color
  barWidth: 6,
  isStrokeCapRound: true,
  dotData: FlDotData(show: false),
  spots: const [
    // Define the data points for this month's graph
    FlSpot(1, 3.4),
    FlSpot(3, 2.5),
    FlSpot(5, 3.8),
    FlSpot(7, 2.1),
    FlSpot(9, 3.8),
    FlSpot(11, 3.6),
    FlSpot(13, 5.7),
  ],
);