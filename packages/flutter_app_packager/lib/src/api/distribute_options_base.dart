class DistributeOptionsBase {
  DistributeOptionsBase({
    this.appName,
    this.output,
  });

  factory DistributeOptionsBase.fromJson(Map<String, dynamic> json) {
    return DistributeOptionsBase(
      appName: json['app_name'] as String?,
      output: json['output'] as String?,
    );
  }

  final String? appName;
  final String? output;
}
