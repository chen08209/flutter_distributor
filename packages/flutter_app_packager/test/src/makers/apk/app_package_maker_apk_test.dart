import 'dart:io';

import 'package:flutter_app_packager/src/api/make_config.dart';
import 'package:flutter_app_packager/src/makers/apk/app_package_maker_apk.dart';
import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:test/test.dart';

void main() {
  group('AppPackageMakerApk', () {
    late Directory tempDir;
    late Directory buildDir;
    late Directory distDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('apk_test_');
      buildDir = Directory(p.join(tempDir.path, 'build'))..createSync();
      distDir = Directory(p.join(tempDir.path, 'dist'))..createSync();
    });

    tearDown(() {
      tempDir.deleteSync(recursive: true);
    });

    test('packages single apk when not split', () async {
      final inputApk = File(p.join(buildDir.path, 'app-release.apk'))
        ..writeAsStringSync('dummy apk');

      final config = MakeConfig()
        ..platform = 'android'
        ..packageFormat = 'apk'
        ..buildMode = 'release'
        ..outputDirectory = distDir
        ..buildOutputDirectory = buildDir
        ..buildOutputFiles = [inputApk]
        ..pubspec = Pubspec('test_app', version: Version.parse('1.0.0'));

      final maker = AppPackageMakerApk();
      final result = await maker.make(config);

      expect(result.artifacts.length, 1);
      expect(result.artifacts.first.path, p.join(distDir.path, 'test_app-1.0.0-android.apk'));
      expect(File(result.artifacts.first.path).existsSync(), isTrue);
    });

    test('packages multiple split-per-abi apks with respective abi suffixes', () async {
      final arm64Apk = File(p.join(buildDir.path, 'app-arm64-v8a-release.apk'))
        ..writeAsStringSync('arm64');
      final armV7Apk = File(p.join(buildDir.path, 'app-armeabi-v7a-release.apk'))
        ..writeAsStringSync('armv7');

      final config = MakeConfig()
        ..platform = 'android'
        ..packageFormat = 'apk'
        ..buildMode = 'release'
        ..outputDirectory = distDir
        ..buildOutputDirectory = buildDir
        ..buildOutputFiles = [arm64Apk, armV7Apk]
        ..pubspec = Pubspec('test_app', version: Version.parse('1.0.0'));

      final maker = AppPackageMakerApk();
      final result = await maker.make(config);

      expect(result.artifacts.length, 2);
      final paths = result.artifacts.map((e) => e.path).toList();
      expect(paths, contains(p.join(distDir.path, 'test_app-1.0.0-android-arm64-v8a.apk')));
      expect(paths, contains(p.join(distDir.path, 'test_app-1.0.0-android-armeabi-v7a.apk')));
      for (final artifact in result.artifacts) {
        expect(File(artifact.path).existsSync(), isTrue);
      }
    });
  });
}
