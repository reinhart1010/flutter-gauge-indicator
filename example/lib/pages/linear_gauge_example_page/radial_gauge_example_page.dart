import 'dart:math';

import 'package:example/widgets/package_title.dart';
import 'package:example/widgets/value_slider.dart';
import 'package:flutter/material.dart';
import 'package:gauge_indicator/gauge_indicator.dart';

const colors = [
  Colors.green,
  Color(0xFF34C759),
  Colors.amber,
  Colors.red,
  Colors.blue,
  Colors.blueAccent,
  Colors.lightBlue,
  Colors.grey,
  Colors.black,
  Color(0xFFD9DEEB),
];

class RadialGaugeExamplePage extends StatefulWidget {
  const RadialGaugeExamplePage({Key? key}) : super(key: key);

  @override
  State<RadialGaugeExamplePage> createState() => _RadialGaugeExamplePageState();
}

class _RadialGaugeExamplePageState extends State<RadialGaugeExamplePage>
    with AutomaticKeepAliveClientMixin {
  double value = 65;
  double _sliderValue = 65;
  double _degree = 180;
  double _parentWidth = 150;
  double _parentHeight = 150;
  double _thickness = 12;
  double _spacing = 4;
  double _fontSize = 18;
  double _pointerSize = 16;

  var _segments = const <GaugeSegment>[
    GaugeSegment(
      from: 0,
      to: 33.3,
      color: Color(0xFFD9DEEB),
    ),
    GaugeSegment(
      from: 33.3,
      to: 66.6,
      color: Color(0xFF34C759),
    ),
    GaugeSegment(
      from: 66.6,
      to: 100,
      color: Color(0xFFD9DEEB),
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  void _randomizeSegments() {
    final random = Random();
    final a = random.nextDouble() * 100;
    final b = random.nextDouble() * 100;
    final stops = a > b ? [b, a] : [a, b];
    setState(() {
      _segments = <GaugeSegment>[
        GaugeSegment(
          from: 0,
          to: stops[0],
          color: colors[random.nextInt(colors.length)],
        ),
        GaugeSegment(
          from: stops[0],
          to: stops[1],
          color: colors[random.nextInt(colors.length)],
        ),
        GaugeSegment(
          from: stops[1],
          to: 100,
          color: colors[random.nextInt(colors.length)],
        ),
      ];
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
                  const PageTitle(title: 'gauge_indicator'),
                  Expanded(
                    child: ListView(
                      children: [
                        ValueSlider(
                          label: "Value",
                          min: 0,
                          max: 100,
                          value: _sliderValue,
                          onChanged: (val) {
                            setState(() {
                              _sliderValue = val;
                            });
                          },
                          onChangeEnd: (newVal) {
                            setState(() {
                              value = newVal;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Degrees",
                          min: 30,
                          max: 360,
                          value: _degree,
                          onChanged: (val) {
                            setState(() {
                              _degree = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Thickness",
                          min: 5,
                          max: 40,
                          value: _thickness,
                          onChanged: (val) {
                            setState(() {
                              _thickness = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Spacing",
                          min: 0,
                          max: 20,
                          value: _spacing,
                          onChanged: (val) {
                            setState(() {
                              _spacing = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Pointer size",
                          min: 16,
                          max: 36,
                          value: _pointerSize,
                          onChanged: (val) {
                            setState(() {
                              _pointerSize = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Font size",
                          min: 8,
                          max: 48,
                          value: _fontSize,
                          onChanged: (val) {
                            setState(() {
                              _fontSize = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Parent height",
                          min: 150,
                          max: 500,
                          value: _parentHeight,
                          onChanged: (val) {
                            setState(() {
                              _parentHeight = val;
                            });
                          },
                        ),
                        ValueSlider(
                          label: "Parent width",
                          min: 150,
                          max: 500,
                          value: _parentWidth,
                          onChanged: (val) {
                            setState(() {
                              _parentWidth = val;
                            });
                          },
                        ),
                        Center(
                          child: ElevatedButton(
                            onPressed: _randomizeSegments,
                            child: const Text("Randomize segments"),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFEFEFEF),
                      ),
                    ),
                    width: _parentWidth,
                    height: _parentHeight,
                    child: AnimatedRadialGauge(
                      builder: (context, _, value) => RadialGaugeLabel(
                        style: TextStyle(
                          color: const Color(0xFF002E5F),
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        value: value,
                      ),
                      duration: const Duration(milliseconds: 2000),
                      curve: Curves.elasticOut,
                      min: 0,
                      max: 100,
                      value: value,
                      axis: GaugeAxis(
                        degrees: _degree,
                        pointer: RoundedTrianglePointer(
                          size: _pointerSize,
                          borderRadius: _pointerSize * 0.125,
                          backgroundColor: const Color(0xFF002E5F),
                          border: GaugePointerBorder(
                            color: Colors.white,
                            width: _pointerSize * 0.125,
                          ),
                        ),
                        transformer: const GaugeAxisTransformer.colorFadeIn(
                          interval: Interval(0.0, 0.3),
                          background: Color(0xFFD9DEEB),
                        ),
                        style: GaugeAxisStyle(
                          thickness: _thickness,
                          segmentSpacing: _spacing,
                          blendColors: false,
                        ),
                        segments: _segments,
                      ),
                    ),
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
