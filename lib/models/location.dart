import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:theweather/state/state.dart';

final controller = Get.put(MyStateController());
final location = Location();
late StreamSubscription listener;
late PermissionStatus permissionStatus;


Future<void> enableLocationListener() async {
  controller.isEnableLocation.value = await location.serviceEnabled();
  if (!controller.isEnableLocation.value) {
    controller.isEnableLocation.value = await location.requestService();
    if (!controller.isEnableLocation.value) {
      return;
    }
  }

  permissionStatus = await location.hasPermission();
  if (permissionStatus == PermissionStatus.denied) {
    permissionStatus = await location.requestPermission();
    if (permissionStatus != PermissionStatus.granted) {
      return;
    }
  }

  controller.locationData.value = await location.getLocation();
  listener = location.onLocationChanged.listen((event) {});
}

