import 'package:cloud_functions/cloud_functions.dart';

class PairingRemoteDatasource {
  PairingRemoteDatasource(this._functions);

  final FirebaseFunctions _functions;

  Future<Map<String, dynamic>> createInviteCode() async {
    final result = await _functions.httpsCallable('createInviteCode').call();
    return Map<String, dynamic>.from(result.data as Map);
  }

  Future<Map<String, dynamic>> joinCouple(String code) async {
    final result = await _functions.httpsCallable('joinCouple').call({
      'code': code,
    });
    return Map<String, dynamic>.from(result.data as Map);
  }
}

