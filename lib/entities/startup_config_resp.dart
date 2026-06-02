import 'dart:convert';
import 'package:flutter/foundation.dart';

/// /api/common/startup/config 响应实体
class StartupConfigResp {
  final AppListConfig? appListConfig;
  final int? compressionRatio;
  final String? countryCode;
  final List<String>? faceLiveStep;
  final List<FaceStep>? faceStep;
  final Switches? switches;

  const StartupConfigResp({
    this.appListConfig,
    this.compressionRatio,
    this.countryCode,
    this.faceLiveStep,
    this.faceStep,
    this.switches,
  });

  factory StartupConfigResp.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else if (json is String) {
        map = Map<String, dynamic>.from(jsonDecode(json) as Map);
      } else {
        debugPrint('StartupConfigResp.fromJson: 未知类型 ${json.runtimeType}');
        return const StartupConfigResp();
      }

      return StartupConfigResp(
        appListConfig: map['appListConfig'] != null
            ? AppListConfig.fromJson(map['appListConfig'])
            : null,
        compressionRatio: _parseInt(map['compressionRatio']),
        countryCode: map['countryCode']?.toString(),
        faceLiveStep: _parseStringList(map['faceLiveStep']),
        faceStep: _parseFaceStepList(map['faceStep']),
        switches: map['switches'] != null
            ? Switches.fromJson(map['switches'])
            : null,
      );
    } catch (e, stack) {
      debugPrint('StartupConfigResp.fromJson 异常: $e\n$stack');
      return const StartupConfigResp();
    }
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String>? _parseStringList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => e.toString()).toList();
    }
    return null;
  }

  static List<FaceStep>? _parseFaceStepList(dynamic value) {
    if (value == null) return null;
    if (value is List) {
      return value.map((e) => FaceStep.fromJson(e)).toList();
    }
    return null;
  }

  @override
  String toString() {
    return 'StartupConfigResp(appListConfig: $appListConfig, compressionRatio: $compressionRatio, countryCode: $countryCode, faceLiveStep: $faceLiveStep, faceStep: $faceStep, switches: $switches)';
  }
}

class AppListConfig {
  final List<String>? permission;
  final int? wayType;

  const AppListConfig({this.permission, this.wayType});

  factory AppListConfig.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else {
        return const AppListConfig();
      }

      List<String>? permList;
      if (map['permission'] is List) {
        permList = (map['permission'] as List).map((e) => e.toString()).toList();
      }

      return AppListConfig(
        permission: permList,
        wayType: StartupConfigResp._parseInt(map['wayType']),
      );
    } catch (e) {
      debugPrint('AppListConfig.fromJson 异常: $e');
      return const AppListConfig();
    }
  }

  @override
  String toString() => 'AppListConfig(permission: $permission, wayType: $wayType)';
}

class FaceStep {
  final String? description;
  final String? key;

  const FaceStep({this.description, this.key});

  factory FaceStep.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else {
        return const FaceStep();
      }

      return FaceStep(
        description: map['description']?.toString(),
        key: map['key']?.toString(),
      );
    } catch (e) {
      debugPrint('FaceStep.fromJson 异常: $e');
      return const FaceStep();
    }
  }

  @override
  String toString() => 'FaceStep(description: $description, key: $key)';
}

class Switches {
  final int? idConfirmationPopup;

  const Switches({this.idConfirmationPopup});

  factory Switches.fromJson(dynamic json) {
    try {
      Map<String, dynamic> map;
      if (json is Map<String, dynamic>) {
        map = json;
      } else if (json is Map) {
        map = Map<String, dynamic>.from(json);
      } else {
        return const Switches();
      }

      return Switches(
        idConfirmationPopup: StartupConfigResp._parseInt(map['idConfirmationPopup']),
      );
    } catch (e) {
      debugPrint('Switches.fromJson 异常: $e');
      return const Switches();
    }
  }

  @override
  String toString() => 'Switches(idConfirmationPopup: $idConfirmationPopup)';
}
