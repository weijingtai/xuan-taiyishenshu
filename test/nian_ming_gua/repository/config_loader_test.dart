import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taiyishenshu/nian_ming_gua/repository/nian_ming_gua_config_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NianMingGuaConfigLoader tests', () {
    setUpAll(() {
      // Mock the flutter/assets channel to return the real sixty_four_gua_stems.json
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (ByteData? message) async {
        if (message == null) return null;
        final key = utf8.decode(message.buffer.asUint8List(
          message.offsetInBytes,
          message.lengthInBytes,
        ));
        
        if (key == 'assets/nian_ming_gua/sixty_four_gua_stems.json') {
          final file = File('assets/nian_ming_gua/sixty_four_gua_stems.json');
          if (file.existsSync()) {
            final content = file.readAsStringSync();
            return ByteData.view(Uint8List.fromList(utf8.encode(content)).buffer);
          }
        }
        return null;
      });
    });

    tearDownAll(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test('loadNianMingGuaConfigs should correctly load 64 configurations', () async {
      final configs = await loadNianMingGuaConfigs();

      // Hand-calculated expected values from sixty_four_gua_stems.json:
      // Number of configurations is 64
      expect(configs.length, 64);

      // Verify "乾" (index 0 in json)
      final qian = configs.firstWhere((c) => c.guaName == '乾');
      expect(qian.guaName, '乾');
      expect(qian.startStemIndex, 0);
      expect(qian.repeatAtYao4, false);
      expect(qian.yunIndex, 1);
      expect(qian.yunName, '天地否泰之运');

      // Verify "坤" (index 1 in json)
      final kun = configs.firstWhere((c) => c.guaName == '坤');
      expect(kun.guaName, '坤');
      expect(kun.startStemIndex, 4);
      expect(kun.repeatAtYao4, false);
      expect(kun.yunIndex, 1);
      expect(kun.yunName, '天地否泰之运');

      // Verify "否" (index 11 in sequence)
      final fou = configs.firstWhere((c) => c.guaName == '否');
      expect(fou.guaName, '否');
      expect(fou.startStemIndex, 1);
      expect(fou.repeatAtYao4, true);
      expect(fou.yunIndex, 1);
      expect(fou.yunName, '天地否泰之运');

      // Verify "泰" (index 10 in sequence)
      final tai = configs.firstWhere((c) => c.guaName == '泰');
      expect(tai.guaName, '泰');
      expect(tai.startStemIndex, 4);
      expect(tai.repeatAtYao4, true);
      expect(tai.yunIndex, 1);
      expect(tai.yunName, '天地否泰之运');
    });
  });
}
