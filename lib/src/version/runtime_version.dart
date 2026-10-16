class RuntimeReleaseInfo {
  const RuntimeReleaseInfo({this.version, this.buildRef});

  final String? version;
  final String? buildRef;
}

String normalizeVersion(String? value) =>
    (value ?? '').trim().replaceFirst(RegExp('^v', caseSensitive: false), '');

bool isReleaseVersion(String value) =>
    RegExp(r'^\d+\.\d+\.\d+([-+][0-9A-Za-z.-]+)?$').hasMatch(value);
