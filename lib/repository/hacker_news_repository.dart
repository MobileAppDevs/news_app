import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../datamodel/UserData.dart';

class UserDataRepository {
  final _dio = Dio();

  Future<UserDataModel> loadUser() async {
    final response = await _dio.get('https://api.github.com/users');
    if (response.statusCode != 200) throw Exception('Failed to load user with id');
    debugPrint(response.data[0].toString());
    return UserDataModel.fromJson(response.data[0]);
  }

  Future<UserDataModel> loadTopUserIds() async {
    final response = await _dio.get('https://api.github.com/users');
    if (response.statusCode != 200) throw Exception('Failed to load top user ids');
    debugPrint(response.data[0].toString());
    return UserDataModel.fromJson(response.data[0]);
  }

  void dispose() {
    _dio.close();
  }
}
