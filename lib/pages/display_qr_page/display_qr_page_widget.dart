// File: lib/pages/display_qr_page.dart
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '/services/paychangu_service.dart';
import 'display_qr_page_model.dart';
export 'display_qr_page_model.dart';

class DisplayQrPageWidget extends StatefulWidget {
  const DisplayQrPageWidget({
    super.key,
    this.merchantId,
    this.transactionAmount,
  });

  final String? merchantId;
  final String? transactionAmount;

  static String routeName = 'DisplayQrPage';
  static String routePath = '/displayQrPage';

  @override
  State<DisplayQrPageWidget> createState() => _DisplayQrPageWidgetState();
}

class _DisplayQrPageWidgetState extends State<DisplayQrPageWidget> {
  late DisplayQrPageModel _model;
  late String paymentUrl;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => DisplayQrPageModel());
    
    // Set the data from widget parameters
    _model.merchantId = widget.merchantId ?? '';
    _model.transactionAmount = widget.transactionAmount ?? '';
    
    // Generate PayChangu payment URL for QR code
    _generatePaymentUrl();
    
    // Also generate the traditional QR data
    _model.generateQrData();
  }

  void _generatePaymentUrl() {
    try {
      final amount = double.tryParse(_model.transactionAmount) ?? 0.0;
      if (amount > 0 && PayChanguService.instance.isInitialized) {
        paymentUrl = PayChanguService.instance.generatePaymentUrl(
          merchantId: _model.merchantId,
          amount: amount,
          firstName: 'Albert',
          lastName: 'Ngonda',
          email: 'ngondaamn@gmail.com',
        );
      } else {
        // Fallback to traditional QR data
        paymentUrl = _model.qrData;
      }
    } catch (e) {
      debugPrint('Error generating payment URL: $e');
      // Fallback to traditional QR data
      paymentUrl = _model.qrData;
    }
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: const [],
            flexibleSpace: FlexibleSpaceBar(
              title: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                    child: Icon(
                      Icons.qr_code_2_rounded,
                      color: FlutterFlowTheme.of(context).primaryText,
                      size: 32.0,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'PayChangu Payment QR',
                      style: FlutterFlowTheme.of(context).headlineMedium.override(
                        font: GoogleFonts.interTight(),
                        color: FlutterFlowTheme.of(context).primary,
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              centerTitle: true,
              expandedTitleScale: 1.0,
              titlePadding: const EdgeInsetsDirectional.fromSTEB(60.0, 0.0, 16.0, 0.0),
            ),
            elevation: 0.0,
          ),
        ),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Payment Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: PayChanguService.instance.isInitialized 
                        ? const Color(0xFF10B981) 
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PayChanguService.instance.isInitialized 
                            ? Icons.check_circle 
                            : Icons.warning,
                        color: Colors.white,
                        size: 20.0,
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          PayChanguService.instance.isInitialized
                              ? 'PayChangu Payment Ready'
                              : 'Using fallback QR (PayChangu not available)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // QR Code Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Stack(
                    alignment: const AlignmentDirectional(1.0, -1.0),
                    children: [
                      Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(
                          maxWidth: 380.0,
                        ),
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: const Color(0xFFE0E0E0),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              // QR Code
                              Container(
                                width: 300.0,
                                height: 300.0,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                  border: Border.all(
                                    color: const Color(0xFFE0E0E0),
                                    width: 1.0,
                                  ),
                                ),
                                child: _model.qrVisible
                                    ? (paymentUrl.isNotEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: QrImageView(
                                              data: paymentUrl,
                                              version: QrVersions.auto,
                                              size: 268.0,
                                              backgroundColor: Colors.white,
                                              foregroundColor: Colors.black,
                                              errorCorrectionLevel: QrErrorCorrectLevel.M,
                                            ),
                                          )
                                        : const Center(
                                            child: CircularProgressIndicator(),
                                          ))
                                    : Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.timer_off_rounded,
                                              size: 48.0,
                                              color: FlutterFlowTheme.of(context).secondaryText,
                                            ),
                                            const SizedBox(height: 12.0),
                                            Text(
                                              'QR Code Expired',
                                              style: FlutterFlowTheme.of(context).headlineSmall.override(
                                                font: GoogleFonts.interTight(),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Text(
                                              'Please generate a new QR code',
                                              style: FlutterFlowTheme.of(context).bodyMedium.override(
                                                font: GoogleFonts.inter(),
                                                color: FlutterFlowTheme.of(context).secondaryText,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              
                              const SizedBox(height: 16.0),
                              
                              // Instructions
                              Text(
                                PayChanguService.instance.isInitialized
                                    ? 'Scan this QR code with any mobile money app or camera to make payment via PayChangu'
                                    : 'Scan this QR code with any device to view payment details',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(),
                                  color: FlutterFlowTheme.of(context).secondaryText,
                                  fontSize: 14.0,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Timer Badge
                      Positioned(
                        top: 16.0,
                        right: 16.0,
                        child: Container(
                          constraints: const BoxConstraints(minWidth: 60.0),
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: _model.timeRemaining <= 0 
                                ? const Color(0xFFE53E3E)
                                : const Color(0xFF10B981),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                color: Colors.white,
                                size: 14.0,
                              ),
                              const SizedBox(width: 4.0),
                              ValueListenableBuilder<int>(
                                valueListenable: _model.timerNotifier,
                                builder: (context, timeRemaining, child) {
                                  if (timeRemaining <= 0) {
                                    return const Text(
                                      'EXPIRED',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12.0,
                                      ),
                                    );
                                  }
                                  final minutes = (timeRemaining ~/ 60).toString().padLeft(2, '0');
                                  final seconds = (timeRemaining % 60).toString().padLeft(2, '0');
                                  return Text(
                                    '$minutes:$seconds',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.0,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Transaction Details Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 380.0),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(
                        color: const Color(0xFFE0E0E0),
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.receipt_long,
                                color: FlutterFlowTheme.of(context).primary,
                                size: 20.0,
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                'Transaction Details',
                                style: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.interTight(),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const Divider(height: 1.0),
                        
                        // Details
                        _buildDetailRow('Amount', 'MWK ${_model.transactionAmount}'),
                        _buildDetailRow('Transaction ID', _model.transactionId),
                        _buildDetailRow('Merchant', _model.merchantId),
                        _buildDetailRow('Security Token', _model.securityToken),
                        if (PayChanguService.instance.isInitialized)
                          _buildDetailRow('Payment Method', 'PayChangu Gateway'),
                      ],
                    ),
                  ),
                ),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () async {
                            context.safePop();
                          },
                          text: 'Close',
                          options: FFButtonOptions(
                            height: 50.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(),
                              color: FlutterFlowTheme.of(context).primaryText,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0.0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: FFButtonWidget(
                          onPressed: () {
                            // Refresh the QR code
                            _generatePaymentUrl();
                            _model.generateQrData();
                            setState(() {});
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('QR Code refreshed'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          text: 'Refresh QR',
                          icon: const Icon(Icons.refresh, size: 18.0),
                          options: FFButtonOptions(
                            height: 50.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: FlutterFlowTheme.of(context).primary,
                            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                              font: GoogleFonts.interTight(),
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            elevation: 0.0,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.inter(),
              color: FlutterFlowTheme.of(context).secondaryText,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.inter(),
                color: FlutterFlowTheme.of(context).primaryText,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}