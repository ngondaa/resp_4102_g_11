import '/flutter_flow/flutter_flow_util.dart';
import 'display_qr_page_widget.dart' show DisplayQrPageWidget;
import 'package:flutter/material.dart';
import 'dart:async';

class DisplayQrPageModel extends FlutterFlowModel<DisplayQrPageWidget> {
  ///  State fields for stateful widgets in this page.
  
  String merchantId = '';
  String transactionAmount = '';
  String transactionId = '';
  String securityToken = '';
  String qrData = '';
  
  Timer? _timer;
  int timeRemaining = 180; // 3 minutes in seconds
  final ValueNotifier<int> timerNotifier = ValueNotifier<int>(180);
  bool qrVisible = true;
  
  @override
  void initState(BuildContext context) {
    // Generate transaction ID (simple format for demo)
    transactionId = 'TXN${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    // Generate security token (simple format for demo)
    securityToken = 'TK${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Start countdown timer
    _startTimer();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeRemaining > 0) {
        timeRemaining--;
        timerNotifier.value = timeRemaining;
      } else {
        // Hide QR code when timer reaches 0
        qrVisible = false;
        timerNotifier.value = 0;
        timer.cancel();
      }
    });
  }
  
  void generateQrData() {
    // Create JSON-like string for QR code data
    qrData = '{"merchantId":"$merchantId","amount":"$transactionAmount","transactionId":"$transactionId","token":"$securityToken","timestamp":"${DateTime.now().toIso8601String()}"}';
  }
  
  String get formattedTime {
    final minutes = (timeRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (timeRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    timerNotifier.dispose();
  }
}
