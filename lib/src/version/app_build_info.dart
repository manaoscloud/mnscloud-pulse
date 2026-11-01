/// Stamped from pubspec.yaml by scripts/release-pulse.sh on every release.
const appBuildInfo = AppBuildInfo(product: "mnscloud-pulse", version: "1.0.31");

class AppBuildInfo {
  const AppBuildInfo({required this.product, required this.version});

  final String product;
  final String version;
}
