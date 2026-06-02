import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'web_image_picker_stub.dart'
    if (dart.library.html) 'web_image_picker_web.dart';

class LocationService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/location');

  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkLocationPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestLocationPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> isServiceEnabled() async {
    try {
      final bool result = await _channel.invokeMethod('isLocationServiceEnabled');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<Map<String, double>?> getCurrentLocation() async {
    try {
      final Map<dynamic, dynamic> result = await _channel.invokeMethod('getCurrentLocation');
      return {
        'latitude': result['latitude'] as double,
        'longitude': result['longitude'] as double,
      };
    } on PlatformException {
      return null;
    }
  }
}

class ContactsService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/contacts');

  static Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkContactsPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> requestPermission() async {
    try {
      final bool result = await _channel.invokeMethod('requestContactsPermission');
      return result;
    } on PlatformException {
      return false;
    }
  }

  static Future<List<Map<String, String>>?> getContacts() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getContacts');
      return result.map((item) {
        final map = item as Map<dynamic, dynamic>;
        return {
          'id': map['id'] as String,
          'name': map['name'] as String,
          'phone': map['phone'] as String,
        };
      }).toList();
    } on PlatformException {
      return null;
    }
  }
}

class CameraService {
  static const MethodChannel _channel = MethodChannel('com.easy_moni/camera');

  /// 从相册选择图片，返回 Base64 编码的图片数据
  static Future<Uint8List?> pickFromGallery() async {
    if (kIsWeb) {
      return pickImageBytesForWeb();
    }
    try {
      final String? base64 = await _channel.invokeMethod('pickFromGallery');
      if (base64 == null || base64.isEmpty) {
        return null;
      }
      return base64Decode(base64);
    } on PlatformException {
      return null;
    }
  }
}
