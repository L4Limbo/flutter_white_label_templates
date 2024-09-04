import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum BuildType { debug, release, profile }

enum Label { base, premium }

const String _methodChannelName = 'flavor';
const String _methodName = 'getFlavor';

Future<(Label, BuildType)> getLabelAndBuildTypeFromPlatform() async {
  Label label = Label.base;
  BuildType buildType = BuildType.debug;
  try {
    String? flavorString = await (const MethodChannel(_methodChannelName))
        .invokeMethod<String>(_methodName);

    if (flavorString != null) {
      if (flavorString == Label.premium.name) {
        label = Label.premium;
      }

      if (kProfileMode) {
        buildType = BuildType.profile;
      } else if (kReleaseMode) {
        buildType = BuildType.release;
      }
    }
  } catch (e) {
    log('Failed: ${e.toString()}', name: 'AppConfig');
    log('FAILED TO LOAD FLAVOR', name: 'AppConfig');
  }
  return (label, buildType);
}
