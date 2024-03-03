import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:unified_distributor/src/cli/command_package.dart';
import 'package:unified_distributor/src/cli/command_publish.dart';
import 'package:unified_distributor/src/cli/command_release.dart';
import 'package:unified_distributor/src/cli/command_upgrade.dart';
import 'package:unified_distributor/unified_distributor.dart';

class UnifiedDistributorCommandLineInterface {
  UnifiedDistributorCommandLineInterface(
    String executableName,
    String description, {
    String? packageName,
    String? displayName,
  }) {
    _distributor = UnifiedDistributor(
      packageName ?? executableName,
      displayName ?? executableName,
    );

    if (packageName != 'fastforge') {
      String note = [
        '╔════════════════════════════════════════════════════════════════════════════╗',
        '║ Important Notice: flutter_distributor has been renamed to fastforge.       ║',
        '║ You can continue to use flutter_distributor, but we recommend migrating to ║',
        '║ fastforge for the latest features and updates.                             ║',
        '║                                                                            ║',
        '║ Please visit https://fastforge.dev for more information.                   ║',
        '╚════════════════════════════════════════════════════════════════════════════╝',
      ].join('\n').yellow(bold: true);
      description = '$note\n\n$description';
    }

    _runner = CommandRunner(executableName, description);
    _runner.addCommand(CommandPackage(_distributor));
    _runner.addCommand(CommandPublish(_distributor));
    _runner.addCommand(CommandRelease(_distributor));
    _runner.addCommand(CommandUpgrade(_distributor));
    _runner.argParser
      ..addFlag(
        'version',
        help: 'Reports the version of this tool.',
        negatable: false,
      );
  }

  late final UnifiedDistributor _distributor;
  late final CommandRunner _runner;

  String get displayName => _distributor.displayName;
  String get packageName => _distributor.packageName;

  Future<void> run(List<String> args) async {
    ArgResults argResults = _runner.parse(args);
    if (argResults.wasParsed('version')) {
      String? currentVersion = await _distributor.getCurrentVersion();
      if (currentVersion != null) {
        logger.info(currentVersion);
        return;
      }
    }

    return _runner.runCommand(argResults);
  }
}
