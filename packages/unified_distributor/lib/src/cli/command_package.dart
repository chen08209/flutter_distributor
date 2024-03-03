import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:unified_distributor/src/extensions/string.dart';
import 'package:unified_distributor/src/unified_distributor.dart';

/// Package an application bundle for a specific platform and target
///
/// This command wrapper defines, parses and transforms all passed arguments,
/// so that they may be passed to `unified_distributor`. The distributor will
/// then build an application bundle using `flutter_app_packager`.
class CommandPackage extends Command {
  CommandPackage(this.distributor) {
    argParser.addOption(
      'platform',
      valueHelp: [
        'android',
        'ios',
        'linux',
        'macos',
        'ohos',
        'windows',
        'web',
      ].join(','),
      help: 'The platform to package the application for',
    );

    argParser.addOption(
      'targets',
      aliases: ['target'],
      valueHelp: [
        'apk',
        'aab',
        'app',
        'appimage',
        'deb',
        'dmg',
        'exe',
        'hap',
        'ipa',
        'msix',
        'pkg',
        'rpm',
        'zip',
      ].join(','),
      help: 'Comma separated list of bundle types to build.',
    );

    argParser.addOption('channel', valueHelp: '');
    argParser.addOption('artifact-name', valueHelp: '');
    argParser.addOption(
      'description',
      valueHelp: '',
    );
    argParser.addFlag(
      'skip-clean',
      help: 'Whether or not to skip \'flutter clean\' before packaging.',
    );

    argParser.addOption(
      'flutter-build-args',
      valueHelp: 'verbose,obfuscate',
      help: 'Arguments to pass directly to flutter build',
    );

    argParser.addOption(
      'build-target',
      valueHelp: 'path',
      help: 'The --target argument passed to \'flutter build\'',
    );

    argParser.addOption(
      'build-flavor',
      valueHelp: '',
      help: 'The --flavor argument passed to \'flutter build\'',
    );

    argParser.addOption(
      'build-target-platform',
      valueHelp: '',
      help: 'The --target-platform argument passed to \'flutter build\'',
    );

    argParser.addOption(
      'build-export-options-plist',
      valueHelp: '',
      help: 'The --export-options-plist argument passed \'flutter build\'',
    );

    argParser.addOption(
      'hook-pre',
      valueHelp: '',
      help: 'Shell command to run before packaging.',
    );

    argParser.addOption(
      'hook-post',
      valueHelp: '',
      help: 'Shell command to run after packaging.',
    );

    argParser.addMultiOption(
      'build-dart-define',
      valueHelp: 'foo=bar',
      help: [
        'The --dart-define argument(s) passed to \'flutter build\'',
        'You may add multiple \'--build-dart-define key=value\' pairs',
      ].join('\n'),
    );
  }

  final UnifiedDistributor distributor;

  @override
  String get name => 'package';

  @override
  String get description => [
        'Package the current Flutter application for distribution',
        '',
        'Options prefixed with --build- are passed directly to \'flutter build\'',
        'For more details on build options, refer to the \'flutter build\' documentation.',
      ].join('\n');

  @override
  Future run() async {
    final String? platform = argResults?['platform'];
    final List<String> targets = '${argResults?['targets'] ?? ''}'
        .split(',')
        .where((e) => e.isNotEmpty)
        .toList();
    final String? channel = argResults?['channel'];
    final String? artifactName = argResults?['artifact-name'];
    final String? flutterBuildArgs = argResults?['flutter-build-args'];
    final bool isSkipClean = argResults?.wasParsed('skip-clean') ?? false;
    final String? hookPre = argResults?['hook-pre'];
    final String? hookPost = argResults?['hook-post'];
    final Map<String, dynamic> buildArguments =
        _generateBuildArgs(flutterBuildArgs);

    // At least `platform` and one `targets` is required for flutter build
    if (platform == null) {
      print('\nThe \'platform\' options is mandatory!'.red(bold: true));
      exit(1);
    }

    if (targets.isEmpty) {
      print('\nAt least one \'target\' must be specified!'.red(bold: true));
      exit(1);
    }

    final Map<String, dynamic>? hooks;
    if (hookPre != null || hookPost != null) {
      hooks = {};
      if (hookPre != null) hooks['pre'] = hookPre;
      if (hookPost != null) hooks['post'] = hookPost;
    } else {
      hooks = null;
    }

    return distributor.package(
      platform,
      targets,
      channel: channel,
      artifactName: artifactName,
      cleanBeforeBuild: !isSkipClean,
      buildArguments: buildArguments,
      description: argResults?['description'],
      hooks: hooks,
    );
  }

  Map<String, dynamic> _generateBuildArgs(String? flutterBuildArgs) {
    Map<String, dynamic> buildArguments = {};

    if (argResults?.options == null) return buildArguments;

    for (final option in argResults!.options) {
      if (!option.startsWith('build-')) continue;
      if (!argResults!.wasParsed(option)) continue;
      dynamic value = argResults?[option];
      if (value == null) continue;

      if (value is List) {
        if (value.isEmpty) continue;
        final map = <String, String>{};
        for (final item in value) {
          if (item is String && item.contains('=')) {
            final idx = item.indexOf('=');
            map[item.substring(0, idx)] = item.substring(idx + 1);
          }
        }
        value = map;
      }

      buildArguments[option.replaceFirst('build-', '')] = value;
    }

    for (final arg in flutterBuildArgs?.split(',') ?? <String>[]) {
      if (arg.isEmpty) continue;
      final eqIndex = arg.indexOf('=');
      if (eqIndex != -1) {
        buildArguments[arg.substring(0, eqIndex)] =
            arg.substring(eqIndex + 1);
      } else {
        buildArguments[arg] = true;
      }
    }

    return buildArguments;
  }
}
