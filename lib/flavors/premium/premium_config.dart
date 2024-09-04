import 'package:flutter/material.dart';
import 'package:white_label_mp/configs/app_config.dart';
import 'package:white_label_mp/configs/app_environment.dart';
import 'package:white_label_mp/configs/app_theme.dart';
import 'package:white_label_mp/flavors/premium/premium_app_environment.dart';
import 'package:white_label_mp/flavors/premium/premium_app_theme.dart';

class PremiumConfig extends AppConfig {
  PremiumConfig(super.flavor);

  @override
  String get appName => 'Premium';

  @override
  String get assetsPath => 'assets/premium';

  @override
  List<Locale> get supportedLocales => const <Locale>[
        Locale('en', 'US'),
        Locale('uk', 'US'),
      ];

  @override
  AppEnvironment get appEnvironment => PremiumAppEnvironment();

  @override
  AppTheme get appTheme => PremiumAppTheme();
}
