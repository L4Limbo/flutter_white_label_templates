import 'package:flutter/material.dart';
import 'package:white_label_mp/configs/app_theme.dart';

class BaseAppTheme extends AppTheme {
  @override
  ThemeData get darkTheme => ThemeData(scaffoldBackgroundColor: Colors.green);

  @override
  ThemeData get lightTheme => ThemeData(scaffoldBackgroundColor: Colors.amber);
}
