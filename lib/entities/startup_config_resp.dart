import 'dart:convert';

class StartupConfigResp {
  final int? compressionRatio;
  final String? countryCode;
  final List<String>? faceLiveStep;
  final List<FaceStep>? faceStep;
  final Switches? switches;

  const StartupConfigResp({
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
        return const StartupConfigResp();
      }

      return StartupConfigResp(
        compressionRatio: _parseInt(map['compressionRatio']),
        countryCode: map['countryCode']?.toString(),
        faceLiveStep: _parseStringList(map['faceLiveStep']),
        faceStep: _parseFaceStepList(map['faceStep']),
        switches: map['switches'] != null
            ? Switches.fromJson(map['switches'])
            : null,
      );
    } catch (e) {
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
    return 'StartupConfigResp(compressionRatio: $compressionRatio, countryCode: $countryCode, faceLiveStep: $faceLiveStep, faceStep: $faceStep, switches: $switches)';
  }
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
        idConfirmationPopup: StartupConfigResp._parseInt(
          map['idConfirmationPopup'],
        ),
      );
    } catch (e) {
      return const Switches();
    }
  }

  @override
  String toString() => 'Switches(idConfirmationPopup: $idConfirmationPopup)';
}
