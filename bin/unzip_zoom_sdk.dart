import 'dart:convert';
import 'dart:core';
import 'dart:io';

// iOS Uri * zoom-sdk-ios-5.17.6.13115
const iosSDKUri =
    'https://www.dropbox.com/scl/fi/hwbozkrkelsafu0wnp2v8/MobileRTC?rlkey=oaxjme2fg95b8d74hynx4l1ly&dl=1';
const iosSimulateSDKUri =
    'https://www.dropbox.com/scl/fi/e3uq9qfr4up18iudch9ba/MobileRTC?rlkey=yx6wicw7vk44bj2z7jfuko98u&dl=1';

// Android Uri * zoom-sdk-android-5.17.6.19119
const androidMobileRtcUri =
    'https://www.dropbox.com/scl/fi/8mrh854g59x3dvssn33hl/mobilertc.aar?rlkey=f4tkfn32sl70im6jmazer76zx&dl=1';

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

  final size = File(savePath).lengthSync();
  print('file size: $size');
}
