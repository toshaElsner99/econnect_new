import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkStatusService with ChangeNotifier {
  String connectionStatus = "No internet connection";
  bool connectionValue = false;

  NetworkStatusService._() {
    _setupConnectivityListener();
  }

  static final NetworkStatusService _instance = NetworkStatusService._();

  factory NetworkStatusService() => _instance;

  void _setupConnectivityListener() {
    final networkStatusController = StreamController<bool>.broadcast();

    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      switch (result) {
        case ConnectivityResult.none:
          connectionStatus = 'No internet connection';
          connectionValue = false;
          networkStatusController.add(false);
          break;
        case ConnectivityResult.mobile:
          connectionStatus = 'Connected via mobile data';
          connectionValue = true;
          networkStatusController.add(true);
          break;
        case ConnectivityResult.wifi:
          connectionStatus = 'Connected via WiFi';
          connectionValue = true;
          networkStatusController.add(true);
          break;
        default:
          connectionStatus = 'Connected';
          connectionValue = true;
          networkStatusController.add(true);
          break;
      }
      print('👨‍💻✔ CONNECTIVITY_VALUE_SERVICE_NETWORK:-----> [$connectionValue][$connectionStatus]');
      notifyListeners();
    });
  }
}
