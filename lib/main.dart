// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors/sensors.dart';
import 'package:path_provider/path_provider.dart';

import 'package:gsensorlog/file_logger.dart';

Future<String> _getDocsDir() async {
  final directory = await getExternalStorageDirectory();
  return directory.path;
}

var _logFilename = "gvalue.txt";
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var docsDir = await _getDocsDir();
  String canonFilename = '$docsDir/$_logFilename';

  await Lager.initializeLogging(canonFilename);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sensors Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  int second=0;
  double sumx=0;
  double sumy=0;
  double sumz=0;
  int sumi=0;
  List<double> _accelerometerValues;
  List<StreamSubscription<dynamic>> _streamSubscriptions =
      <StreamSubscription<dynamic>>[];

  @override
  Widget build(BuildContext context) {
    final List<String> accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1))?.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(width: 1.0, color: Colors.black38),
              ),
            ),
          ),
          Padding(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
          ),
       ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions
        .add(accelerometerEvents.listen((AccelerometerEvent event) {
      var now = new DateTime.now();
      sumx += event.x;
      sumy += event.y;
      sumz += event.z;
      sumi++;
      if(now.second != second) {
        second = now.second;
        sumx=sumx/sumi;
        sumy=sumy/sumi;
        sumz=sumz/sumi;
        setState(() {
          _accelerometerValues = <double>[sumx, sumy, sumz];
          String times = "${now.hour}:${now.minute}:${now.second}";
          String gdata = "${sumx.toStringAsFixed(2)},${sumy.toStringAsFixed(2)},${sumz.toStringAsFixed(2)}";
          Lager.lograw("$gdata\n");
        });
        sumx = 0;
        sumy = 0;
        sumz = 0;
        sumi = 0;
      }
    }));
  }
}
