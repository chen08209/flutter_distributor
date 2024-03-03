import 'package:flutter_app_packager/src/makers/exe/make_exe_config.dart';
import 'package:test/test.dart';

void main() {
  group('MakeExeConfig', () {
    test('parses string locales and map locales safely', () {
      final configWithStringLocales = MakeExeConfig.fromJson({
        'app_id': 'com.example.app',
        'locales': ['en', 'zh', 'ja'],
      });

      expect(configWithStringLocales.locales?.length, 3);
      expect(configWithStringLocales.locales?[0].lang, 'en');
      expect(configWithStringLocales.locales?[1].lang, 'zh');
      expect(configWithStringLocales.locales?[2].lang, 'ja');

      final configWithMapLocales = MakeExeConfig.fromJson({
        'app_id': 'com.example.app',
        'locales': [
          {'lang': 'en'},
          {'lang': 'zh', 'file': 'custom_zh.isl'},
        ],
      });

      expect(configWithMapLocales.locales?.length, 2);
      expect(configWithMapLocales.locales?[0].lang, 'en');
      expect(configWithMapLocales.locales?[0].file, isNull);
      expect(configWithMapLocales.locales?[1].lang, 'zh');
      expect(configWithMapLocales.locales?[1].file, 'custom_zh.isl');
    });

    test('defaults to en locale if null or empty', () {
      final config = MakeExeConfig.fromJson({
        'app_id': 'com.example.app',
      });

      expect(config.locales?.length, 1);
      expect(config.locales?.first.lang, 'en');
    });
  });
}
