
# Description

This article is guide to create a white label flutter app with the **Build Variants Method**. The "white-theming" is applied in the following settings:
1. Theme
2. Assets
3. Localization
4. API Services
5. Firebase Setup

_In the future feature-flagging will be added and modularity in some features._
# iOS Setup
We first follow the Flutter Docs to add the configurations of our flavors in XCode and then
in `Runner/AppDelegate.swift` we add the following code config:

```swift
	`import UIKit
	import Flutter

	let kChannel = "flavor"
	let kMethodFlavor = "getFlavor"

	@UIApplicationMain
	@objc class AppDelegate: FlutterAppDelegate {
	override func application(
	_ application: UIApplication,
	didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
	) -> Bool {
	GeneratedPluginRegistrant.register(with: self)

	guard let controller = self.window.rootViewController as? FlutterViewController else { return true }
	let flavorChannel = FlutterMethodChannel(name:kChannel, binaryMessenger: controller as! FlutterBinaryMessenger)
	flavorChannel.setMethodCallHandler{ (call, result) in
		if call.method == kMethodFlavor {
			let flavor = Bundle.main.object(forInfoDictionaryKey: "Flavor") as! String
			result(flavor);
		}
	}

	return super.application(application, didFinishLaunchingWithOptions: launchOptions)
	}
	}
```



# Android Setup

In Android we first have to add productFlavors in the `app/build.gradle` file of the Android Project.
``` Groovy
    productFlavors {
        base {
            dimension "label"
            applicationId "app.label.white.base"
            resValue "string", "app_name", "Base"
        }
        premium {
            dimension "label"
            applicationId "app.label.white.premium"
            resValue "string", "app_name", "Premium"
        }
    }
```

The we add the BuildTypes to seperate builds into debug, profile and release.

```Groovy
    buildTypes {
        release {
            debug {
                applicationIdSuffix ".debug"
                debuggable true
            }
            profile {
                applicationIdSuffix ".profile"
            }
            release {
                signingConfig signingConfigs.debug
            }
        }
    }
```

We also have to create a MethodChannel which is a mechanism that allows us to call code fragments from native platforms.

`MainActivity.kt`
```kotlin
private const val kChannel = "flavor"
private const val kMethodFlavor = "getFlavor"
class MainActivity: FlutterActivity() {
   override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
       GeneratedPluginRegistrant.registerWith(flutterEngine);
       // Method channel
       MethodChannel(flutterEngine.dartExecutor.binaryMessenger, kChannel)
           .setMethodCallHandler { call, result ->
               if (call.method == kMethodFlavor) {
                   result.success(FLAVOR);
               } else {
                   result.notImplemented()
               }
           }
   }
}
```

## Dynamic Name and BundleID

Create properties for each label:
`android/base.properties`
```properties
APP_NAME=Base App 
APP_ID=com.example.base
```

`android/premium.properties`
```properties
APP_NAME=Premium App 
APP_ID=com.example.premium
```

Also in `main/AndroidManifest.xml` make app name variable
```xml
android:label="@string/app_name"
```

Modify `build.gradle`
```gradle
def getFlavorPropertyFile(flavor) {
    return rootProject.file("${flavor}.properties")
}

def getFlavorProperty(propertyName, flavor) {
    Properties properties = new Properties()
    File propFile = getFlavorPropertyFile(flavor)
    if (propFile.exists()) {
        properties.load(new FileInputStream(propFile))
        return properties.getProperty(propertyName)
    }
    return null
}

```

Use functions in productFlavors
```gradle
android {
    ...
    flavorDimensions "appType"

    productFlavors {
        base {
            dimension "appType"
            applicationId getFlavorProperty("APP_ID", "base")
            resValue "string", "app_name", getFlavorProperty("APP_NAME", "base")
        }
        premium {
            dimension "appType"
            applicationId getFlavorProperty("APP_ID", "premium")
            resValue "string", "app_name", getFlavorProperty("APP_NAME", "premium")
        }
    }
}
```

## Launch Icons
For launch icons we have to setup the following folders:
```plaintext
android/app/src/base/res/mipmap/
android/app/src/premium/res/mipmap/
```

And add their path to the `build.gradle`
```gradle
productFlavors {
	base {
		dimension "label"
		applicationId getFlavorProperty("APP_ID", "base")
		resValue "string", "app_name", getFlavorProperty("APP_NAME", "base")
		sourceSets.base.res.srcDirs += ['src/base', 'src/base/res']
	}
	
	premium {
		dimension "label"
		applicationId getFlavorProperty("APP_ID", "premium")
		resValue "string", "app_name", getFlavorProperty("APP_NAME", "premium")
		sourceSets.premium.res.srcDirs += ['src/premium', 'src/premium/res']
	}
}
```
# Code Configuration 

## Create config files

Each of our flavors will have different configuration. So we need to create a class to provide the custom-settings of each flavor.

**Settings**: 
* **buildType**: The type of the build e.g. basic, premium etc.
* **appName**: The name of the app.
* **theme**: The class that provides the ThemeData of the app. AppTheme class provides both the light and dark theme, if exists.
* **assetsPath**: The path of the assets of the current build.
* **appEnvironment**: This class provides information about the API theme of the backend services that app needs to communicate with the database.
* **supportedLocales**: The supported languages that are supported by the current build.

`AppConfig`
```dart
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
```

`AppEnvironment`
```dart
abstract class AppEnvironment {
  AppEnvironment();

  String get host;
}
```

`AppTheme`
```dart
abstract class AppTheme {
  AppTheme();

  ThemeData get lightTheme;
  ThemeData get darkTheme;
}
```

## Create Platform Config Getter 

Now we have to create a service that uses this method channel

`method_channel_service.dart`
```dart
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum BuildType { debug, release, profile }

enum Label { base, premium }

const String _methodChannelName = 'flavor';
const String _methodName = 'getFlavor';

Future<(Label, BuildType)> _getLabelAndBuildTypeFromPlatform() async {
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
```

Also a service to get the app config each time

`get_app_config_service.dart`

```dart
Future<AppConfig> getAppConfig() async {
  final (label, buildType) = await getLabelAndBuildTypeFromPlatform();
  
  return switch (label) {
    Label.base => BaseConfig(buildType),
    Label.premium => PremiumConfig(buildType),
  };
}
```

# Firebase Configuration

After the default Firebase setup to a Flutter project:

In `android/app` folder create folders for each theme.
```
android/
└── app/
	├── base/google-services.json
	└── premium/google-services.json
```

Setup each firebase configuration in the AppConfig instance by passing the `FirebaseOptions` of each flavor.

```dart
firebaseOptions = FirebaseOptions(
	apiKey: 'PREMIUM_API_KEY',
	appId: 'PREMIUM_APP_ID',
	messagingSenderId: 'PREMIUM_MESSAGING_SENDER_ID',
	projectId: 'PREMIUM_PROJECT_ID',
);
```
# Usage

To run different themes of the same app we have to update our `main` function.

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appConfig = await getAppConfig();
  
  runApp(MyApp(appConfig: appConfig));
}
```

To run the app use the command: `flutter run --flavor [environment name]`

# Resources
- [Flutter Flavors](https://docs.flutter.dev/deployment/flavors)
- [Flutter White Labeling: BuildVariants VS. Dependencies](https://medium.com/newsoft-official/flutter-white-labeling-buildvariants-vs-dependencies-d7758983affb)
- [Build flavors in Flutter](https://medium.com/@animeshjain/build-flavors-in-flutter-android-and-ios-with-different-firebase-projects-per-flavor-27c5c5dac10b)
