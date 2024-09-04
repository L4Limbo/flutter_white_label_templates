import 'package:flutter/material.dart';
import 'package:white_label_mp/configs/app_config.dart';
import 'package:white_label_mp/configs/app_environment.dart';
import 'package:white_label_mp/configs/app_theme.dart';
import 'package:white_label_mp/flavors/base/base_app_environment.dart';
import 'package:white_label_mp/flavors/base/base_app_theme.dart';

class BaseConfig extends AppConfig {
  BaseConfig(super.flavor);

  @override
  String get appName => 'Base';

  @override
  String get assetsPath => 'assets/base';

  @override
  List<Locale> get supportedLocales => const <Locale>[
        Locale('en', 'US'),
        Locale('uk', 'US'),
      ];

  @override
  AppEnvironment get appEnvironment => BaseAppEnvironment();

  @override
  AppTheme get appTheme => BaseAppTheme();
}
