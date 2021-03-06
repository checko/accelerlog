import 'dart:io';
import 'dart:core';
import 'package:synchronized/synchronized.dart';

class Lager {

  static final _lock = Lock();  // uses the “synchronized” package
  static File _logFile;

  static Future initializeLogging(String canonicalLogFileName) async {
    _logFile = _createLogFile(canonicalLogFileName);
    final text = '${new DateTime.now()}: LOGGING STARTED\n';
    /// per its documentation, `writeAsString` “Opens the file, writes
    /// the string in the given encoding, and closes the file”
    return _logFile.writeAsString(text, mode: FileMode.write, flush: true);
  }

  static Future log(String s) async {
    var now = new DateTime.now();
    final text = '${now.hour}:${now.minute}:${now.second}.${now.millisecond} $s\n';
    return _lock.synchronized(() async {
      await _logFile.writeAsString(text, mode: FileMode.append, flush: true);
    });
  }

  static Future lograw(String s) async {
    return _lock.synchronized(() async {
      await _logFile.writeAsString(s, mode: FileMode.append, flush: true);
    });
  }

  static File _createLogFile(canonicalLogFileName) => File(canonicalLogFileName);

}