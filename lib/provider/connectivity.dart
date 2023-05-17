import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class ConnectivityChangeNotifier extends ChangeNotifier {
  ConnectivityChangeNotifier() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      resultHandler(result);
    });
  }
  ConnectivityResult _connectivityResult = ConnectivityResult.none;
  bool isOnline = false;

  ConnectivityResult get connectivity => _connectivityResult;
  bool get svgUrl => isOnline;
  void resultHandler(ConnectivityResult result) {
    _connectivityResult = result;
    if (result == ConnectivityResult.none) {
      isOnline = false;
    } else if (result == ConnectivityResult.mobile) {
      isOnline = true;
    } else if (result == ConnectivityResult.wifi) {
      isOnline = true;
    }
    notifyListeners();
  }

  void initialLoad() async {
    ConnectivityResult connectivityResult =
    await (Connectivity().checkConnectivity());
    resultHandler(connectivityResult);
  }
}