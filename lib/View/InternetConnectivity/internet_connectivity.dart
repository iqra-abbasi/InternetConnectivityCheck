import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';

class InternetConnectivity extends StatefulWidget {
  InternetConnectivity({super.key});
  @override
  State<InternetConnectivity> createState() => _InternetConnectivityState();
}

class _InternetConnectivityState extends State<InternetConnectivity> {

  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late List<ConnectivityResult> result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // Get.snackbar( '$initConnectivity()','',
      //     backgroundColor: Colors.green,
      //     borderRadius: 20,
      //     icon: Icon(Icons.error),
      //     snackPosition: SnackPosition.TOP,
      //     snackStyle:SnackStyle.GROUNDED,
      //     onTap:(snap){
      //     });
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      print('Couldn\'t check connectivity status $e');
      return;
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(List<ConnectivityResult> result) async {
    setState(() {
      _connectionStatus = result;
    });

    // Determine the type of internet connection
    String message;
    Color backgroundColor;

    if (_connectionStatus.contains(ConnectivityResult.mobile)) {
      message = 'Mobile data';
      backgroundColor = Colors.blue;
    } else if (_connectionStatus.contains(ConnectivityResult.wifi)) {
      message = 'WiFi';
      backgroundColor = Colors.green;
    } else if (_connectionStatus.contains(ConnectivityResult.ethernet)) {
      message = 'Ethernet';
      backgroundColor = Colors.orange;
    } else {
      message = 'No internet connection';
      backgroundColor = Colors.red;
    }

    // Show a snack bar with the connection type
    Get.snackbar(
      'Connection Status',
      message,
      backgroundColor: backgroundColor,
      borderRadius: 30,
      snackPosition: SnackPosition.TOP,
      snackStyle: SnackStyle.FLOATING,
      duration: Duration(seconds: 2),
    );

    // Log the connection status change
    print('Connectivity changed: $_connectionStatus');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ListView(
            shrinkWrap: true,
            children: List.generate(
                _connectionStatus.length,
                    (index) => Center(
                  child: Center(
                    child: Text(
                      _connectionStatus[index].toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black
                      ),
                    ),
                  ),
                )),
          ),
          SizedBox(
            height: 30,
          ),
         // ElevatedButton(onPressed: (){initConnectivity();}, child: Text("Check Connection"))
        ],
      ),
    );
  }
}
