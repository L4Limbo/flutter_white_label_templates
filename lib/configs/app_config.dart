import 'package:flutter/material.dart';
import 'package:white_label_mp/configs/app_environment.dart';
import 'package:white_label_mp/configs/app_theme.dart';
import 'package:white_label_mp/configs/method_channel_service.dart';

abstract class AppConfig {
  const AppConfig(this._buildType);

  final BuildType _buildType;

  BuildType get buildType => _buildType;
  String get appName;
  AppTheme get appTheme;
  String get assetsPath;
  AppEnvironment get appEnvironment;
  List<Locale> get supportedLocales;
}
