import 'package:colorize/colorize.dart';
import 'package:kraken/bridge.dart';
import 'package:kraken/src/element/binding.dart';
import 'package:test/test.dart';
import 'bridge/from_native.dart';
import 'bridge/to_native.dart';
import 'dart:io';

final Directory javascriptSource = Directory('./unit/js_api/src');

void main() {
  initTestFramework();
  registerDartTestMethodsToCpp();
  addOnJSErrorListener((String errmsg) {
    Colorize color = Colorize(errmsg);
    color.red();
    print(color);
  });
  setUp(() {
    ElementsFlutterBinding.ensureInitialized().scheduleWarmUpFrame();
  });

  List<FileSystemEntity> cases = javascriptSource.listSync();

  for (FileSystemEntity file in cases) {
    if (file.path.endsWith('.js')) {
      String code = File(file.path).readAsStringSync();
      evaluateTestScripts(code);
    }
  }
}
