import 'package:white_label_mp/configs/app_config.dart';
import 'package:white_label_mp/configs/method_channel_service.dart';
import 'package:white_label_mp/flavors/base/base_config.dart';
import 'package:white_label_mp/flavors/premium/premium_config.dart';

Future<AppConfig> getAppConfig() async {
  final (label, buildType) = await getLabelAndBuildTypeFromPlatform();

  return switch (label) {
    Label.base => BaseConfig(buildType),
    Label.premium => PremiumConfig(buildType),
  };
}
