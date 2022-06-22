import 'package:example/pages/linear_gauge_example_page/linear_gauge_example_page.dart';
import 'package:example/pages/linear_gauge_example_page/radial_gauge_example_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        tabBarTheme: const TabBarTheme(
          labelColor: Colors.black,
        ),
      ),
      home: const DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TabBar(tabs: [
            Tab(
              text: 'Radial gauge',
            ),
            Tab(
              text: 'Linear gauge',
            ),
          ]),
          body: TabBarView(
            children: [
              RadialGaugeExamplePage(),
              LinearGaugeExamplePage(),
            ],
          ),
        ),
      ),
    );
  }
}
