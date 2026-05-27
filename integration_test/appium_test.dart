import 'package:appium_flutter_server/appium_flutter_server.dart';
import 'package:canvas/main.dart' as app;

void main() {
  // Server ini memungkinkan Appium mengontrol aplikasi via driver Integration
  initializeTest(app: const app.CanvasApp());
}
