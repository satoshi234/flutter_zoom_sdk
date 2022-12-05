import 'dart:convert';
import 'dart:core';
import 'dart:io';

// iOS Uri
const iosSDKUri =
    'https://firebasestorage.googleapis.com/v0/b/flutterzoomsdk.appspot.com/o/zoomSdk%2FiOS%2Fzoom-sdk-ios-5.12.8.5463%2Fios-arm64%2FMobileRTC?alt=media&token=199bb3c4-f9af-4b3f-8802-98caacf7099c';
const iosSimulateSDKUri =
    'https://firebasestorage.googleapis.com/v0/b/flutterzoomsdk.appspot.com/o/zoomSdk%2FiOS%2Fzoom-sdk-ios-5.12.8.5463%2Fios-x86_64-simulator%2FMobileRTC?alt=media&token=b4acc054-41fa-4b8d-8fdf-ec8fb35d3925';

// Android Uri
const androidCommonLibUri =
    'https://firebasestorage.googleapis.com/v0/b/flutterzoomsdk.appspot.com/o/zoomSdk%2FAndroid%2Fzoom-sdk-android-5.12.8.9901%2Fcommonlib.aar?alt=media&token=9fc52737-b1d3-44aa-bec3-27d750133709';
const androidMobileRtcUri =
    'https://firebasestorage.googleapis.com/v0/b/flutterzoomsdk.appspot.com/o/zoomSdk%2FAndroid%2Fzoom-sdk-android-5.12.8.9901%2Fmobilertc.aar?alt=media&token=a9089eb9-5017-4af6-85f0-8f22c1ecb24a';

void main(List<String> args) async {
  var location = Platform.script.toString();
  var isNewFlutter = location.contains(".snapshot");
  if (isNewFlutter) {
    var sp = Platform.script.toFilePath();
    var sd = sp.split(Platform.pathSeparator);
    sd.removeLast();
    var scriptDir = sd.join(Platform.pathSeparator);
    var packageConfigPath = [scriptDir, '..', '..', '..', 'package_config.json']
        .join(Platform.pathSeparator);
    var jsonString = File(packageConfigPath).readAsStringSync();
    Map<String, dynamic> packages = jsonDecode(jsonString);
    var packageList = packages["packages"];
    String? zoomFileUri;
    for (var package in packageList) {
      if (package["name"] == "flutter_zoom_sdk") {
        zoomFileUri = package["rootUri"];
        break;
      }
    }
    if (zoomFileUri == null) {
      print("flutter_zoom_sdk package not found!");
      return;
    }
    location = zoomFileUri;
  }
  if (Platform.isWindows) {
    location = location.replaceFirst("file:///", "");
  } else {
    location = location.replaceFirst("file://", "");
  }
  if (!isNewFlutter) {
    location = location.replaceFirst("/bin/unzip_zoom_sdk.dart", "");
  }

  await checkAndDownloadSDK(location);

  print('Complete');
}

Future<void> checkAndDownloadSDK(String location) async {
  var iosSDKFile = location +
      '/ios/MobileRTC.xcframework/ios-arm64_armv7/MobileRTC.framework/MobileRTC';
  bool exists = await File(iosSDKFile).exists();

  if (!exists) {
    await downloadFile(Uri.parse(iosSDKUri), iosSDKFile);
  }

  var iosSimulateSDKFile = location +
      '/ios/MobileRTC.xcframework/ios-i386_x86_64-simulator/MobileRTC.framework/MobileRTC';
  exists = await File(iosSimulateSDKFile).exists();

  if (!exists) {
    await downloadFile(Uri.parse(iosSimulateSDKUri), iosSimulateSDKFile);
  }

  var androidCommonLibFile = location + '/android/libs/commonlib.aar';
  exists = await File(androidCommonLibFile).exists();
  if (!exists) {
    await downloadFile(Uri.parse(androidCommonLibUri), androidCommonLibFile);
  }
  var androidRTCLibFile = location + '/android/libs/mobilertc.aar';
  exists = await File(androidRTCLibFile).exists();
  if (!exists) {
    await downloadFile(Uri.parse(androidMobileRtcUri), androidRTCLibFile);
  }
}

Future<void> downloadFile(Uri uri, String savePath) async {
  print('Download ${uri.toString()} to $savePath');
  File destinationFile = await File(savePath).create(recursive: true);

  final request = await HttpClient().getUrl(uri);
  final response = await request.close();
  await response.pipe(destinationFile.openWrite());
}
