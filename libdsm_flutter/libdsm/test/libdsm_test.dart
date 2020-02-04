import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libdsm/libdsm.dart';

void main() {
  const MethodChannel channel = MethodChannel('open.flutter/libdsm');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'DSM_init'){
        return '123456';
      }
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('init', () async {
    Dsm dsm = Dsm();
    await dsm.init();
    expect(dsm.dsmId, '123456');
  });
}
