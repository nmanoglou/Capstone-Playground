import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// https://pub.dev/packages/mobile_scanner

// start on home screen with button
// press button to launch qr reader
// on result, log the data and return to the home screen. Update the text on the home screen to the last code scanned

Future<void> main() async {
  // access shared prefs before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // initialise shared prefs
  await SharedPrefs.init();

  // get our environment variables
  await dotenv.load();

  runApp(MaterialApp(home: HomeScreen()));
}

const String lastScannedCodeKey = "last_scanned_code";

// Shared Preferences
class SharedPrefs {
  static SharedPreferences? instance = null;

  static Future<SharedPreferences> init() async =>
      instance = await SharedPreferences.getInstance();

  static String getLastQrMessage() =>
      instance?.getString(lastScannedCodeKey) ?? "No Data";

  static void updateLastQrMessage(String newVal) =>
      instance?.setString(lastScannedCodeKey, newVal);
}

// Home screen Widget
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  String? lastScannedCode = SharedPrefs.getLastQrMessage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner')),
      body: Center(
          child: Column(children: <Widget>[
            Spacer(),
            Padding(
                padding: EdgeInsets.all(15),
                child: Text(lastScannedCode ?? "No Data")),
            Spacer(),
            ElevatedButton(
                onPressed: () async {
                  await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => QrCodeScanner()));
                  _reSyncPreviousCodeString();
                },
                child: Text("Open Scanner")),
            Spacer(),
          ])),
    );
  }

  void _reSyncPreviousCodeString() {
    setState(() {
      lastScannedCode = SharedPrefs.getLastQrMessage();
    });
  }
}

// QR Code Widget
class QrCodeScanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Mobile Scanner')),
        body: MobileScanner(
            allowDuplicates: false,
            controller: MobileScannerController(),
            onDetect: (barcode, args) =>
            {codeDetected(barcode, args, context)}));
  }

  void codeDetected(Barcode barcode, MobileScannerArguments? args,
      BuildContext context) {
    if (barcode.rawValue == null) {
      debugPrint('Failed to scan Barcode');
    } else {
      final String code = barcode.rawValue!;
      debugPrint('Barcode found! $code');
      SharedPrefs.updateLastQrMessage(code);
      Navigator.pop(context);
    }
  }
}
