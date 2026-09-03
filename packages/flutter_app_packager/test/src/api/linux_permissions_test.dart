@TestOn('posix')
library linux_permissions_test;

import 'dart:io';

import 'package:flutter_app_packager/src/api/linux_permissions.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';

int _mode(String filePath) => FileStat.statSync(filePath).mode & 0x1ff;

void main() {
  test('normalizeLinuxPermissions pins modes regardless of umask', () async {
    final root = Directory.systemTemp.createTempSync('linux_permissions');
    addTearDown(() => root.deleteSync(recursive: true));
    final dir = Directory(path.join(root.path, 'opt', 'app'))
      ..createSync(recursive: true);
    final data = File(path.join(dir.path, 'data'))..writeAsStringSync('x');
    final exe = File(path.join(dir.path, 'app'))..writeAsStringSync('x');
    await Process.run('chmod', ['0777', dir.path, exe.path]);
    await Process.run('chmod', ['0666', data.path]);

    await normalizeLinuxPermissions(root.path);

    expect(_mode(dir.path), 0x1ed, reason: '0755');
    expect(_mode(exe.path), 0x1ed, reason: '0755');
    expect(_mode(data.path), 0x1a4, reason: '0644');
  });
}
