import 'package:easy_moni/core/network/http_provider.dart';
import 'package:easy_moni/core/router/acquisition_progress_route_resolver.dart';
import 'package:easy_moni/pages/fillInforma/providers/acquisition_progress_provider.dart';
import 'package:easy_moni/services/auth_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final savedSessionRouteServiceProvider = Provider<SavedSessionRouteService>((
  ref,
) {
  return SavedSessionRouteService(
    acquisitionProgressApi: ref.watch(acquisitionProgressProvider),
  );
});

class SavedSessionRouteService {
  const SavedSessionRouteService({required this.acquisitionProgressApi});

  final AcquisitionProgressApi acquisitionProgressApi;

  Future<String?> resolveSavedSessionRoute() async {
    final savedToken = await AuthStorage.getToken();
    if (savedToken == null || savedToken.isEmpty) {
      return null;
    }

    HttpProvider.instance.restoreToken(savedToken);

    final progressResult = await acquisitionProgressApi.call();
    if (progressResult.isSuccess && progressResult.data != null) {
      return AcquisitionProgressRouteResolver.resolve(progressResult.data!);
    }

    await HttpProvider.instance.clearAuth();
    return null;
  }
}
