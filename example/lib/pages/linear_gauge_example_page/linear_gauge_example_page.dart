import 'dart:math';
import 'package:example/widgets/package_title.dart';
import 'package:example/widgets/value_slider.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

class LinearGaugeExamplePage extends StatefulWidget {
  const LinearGaugeExamplePage({Key? key}) : super(key: key);

  @override
  State<LinearGaugeExamplePage> createState() => _LinearGaugeExamplePageState();
}

class _LinearGaugeExamplePageState extends State<LinearGaugeExamplePage>
    with AutomaticKeepAliveClientMixin {
  double _parentWidth = 750;
  double _parentHeight = 50;

  int _max = 50;
  double value = 49;
  double verticalSegmentMargin = 2;
  double separatorThickness = 1;
  double minSegmentThickness = 10;
  double cornerRadius = 8;

  List<LinearGaugeSegment> _segments = const [
    LinearGaugeSegment(color: Color.fromRGBO(39, 197, 102, 1)),
  ];

  @override
  bool get wantKeepAlive => true;

  void _randomizeValues() {
    final random = Random();
    final isSingleSegment = random.nextBool();

    final List<LinearGaugeSegment> segments;
    final int max;
    if (isSingleSegment) {
      max = 15;
      segments = const [
        LinearGaugeSegment(color: Color.fromRGBO(39, 197, 102, 1)),
      ];
    } else {
      max = 40;
      segments = [
        LinearGaugeSegment(start: 0, color: Colors.green[50]!),
        LinearGaugeSegment(start: 5, color: Colors.green[100]!),
        LinearGaugeSegment(start: 10, color: Colors.green[200]!),
        LinearGaugeSegment(start: 15, color: Colors.green[300]!),
        const LinearGaugeSegment(
          start: 20,
          color: Color.fromRGBO(39, 197, 102, 1),
        ),
      ];
    }
    setState(() {
      _max = max;
      value = random.nextDouble() * max;
      verticalSegmentMargin = random.nextDouble() * 8;
      separatorThickness = 1 + random.nextDouble() * 3;
      minSegmentThickness = random.nextDouble() * 10;
      _segments = segments;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: Color(0xFFDDDDDD))),
              ),
              width: 350,
              child: Column(
                children: [
                  const PageTitle(title: 'Linear indicator'),
                  Expanded(
                    child: ListView(
                      children: [
                        ValueSlider(
                          label: "Value",
                          min: 0,
                          max: _max.toDouble(),
                          value: value,
                          onChanged: (val) {
                            setState(() {
                              value = val;
                            });
                          },
                          onChangeEnd: (newVal) {
                            setState(() {
                              value = newVal;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Max",
                          min: 0,
                          max: 100,
                          value: _max.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              _max = val.toInt();
                              value = value.clamp(0, _max).toDouble();
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Vertical segment margin",
                          min: 0,
                          max: 50,
                          value: verticalSegmentMargin.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              verticalSegmentMargin = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Separator thickness",
                          min: 0,
                          max: 10,
                          value: separatorThickness.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              separatorThickness = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Minimal segment thickness",
                          min: 0,
                          max: 50,
                          value: minSegmentThickness.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              minSegmentThickness = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Corner radius",
                          min: 0,
                          max: 50,
                          value: cornerRadius.toDouble(),
                          onChanged: (val) {
                            setState(() {
                              cornerRadius = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Parent width",
                          min: 10,
                          max: 750,
                          value: _parentWidth,
                          onChanged: (val) {
                            setState(() {
                              _parentWidth = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Parent height",
                          min: 20,
                          max: 200,
                          value: _parentHeight,
                          onChanged: (val) {
                            setState(() {
                              _parentHeight = val;
                            });
                          },
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: _randomizeValues,
                            child: const Text("Randomize values"),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: DecoratedBox(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: _parentHeight,
                      width: _parentWidth,
                      child: AnimatedLinearGauge(
                        value: value,
                        max: _max,
                        backgroundColor: const Color.fromRGBO(70, 70, 73, 1),
                        verticalSegmentMargin: verticalSegmentMargin,
                        cornerRadius: cornerRadius,
                        separatorThickness: separatorThickness,
                        minimumSegmentThickness: minSegmentThickness,
                        segments: _segments,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.ease,
                      ),
                    ),
                  ],
                ),
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(44, 44, 46, 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
