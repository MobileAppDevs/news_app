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

  Future<List<UserDataModel>> loadTopUsers() async {
    final response = await _dio.get('https://api.github.com/users');
    if (response.statusCode != 200) throw Exception('Failed to load top user ids');
    debugPrint(response.data[0].toString());
    List<UserDataModel> lst = List<UserDataModel>.from(response.data.map((x) => UserDataModel.fromJson(x)));
    return List<UserDataModel>.from(response.data.map((x) => UserDataModel.fromJson(x)));
    // return UserDataModel.fromJson(response.data);
  }

  void dispose() {
    _dio.close();
  }
}
