import 'package:flutter_app_packager/src/api/make_error.dart';
import 'package:shell_executor/shell_executor.dart';

/// dpkg-deb, rpmbuild and mksquashfs record the tree's modes verbatim, so the
/// builder's umask would otherwise become the package's. Directories end up
/// 0755 and files 0644, keeping any executable bit, as dh_fixperms does.
Future<void> normalizeLinuxPermissions(String directoryPath) async {
  final result = await $('chmod', ['-R', 'u=rwX,go=rX', directoryPath]);
  if (result.exitCode != 0) {
    throw MakeError(result.stderr as String);
  }
}
