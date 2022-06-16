import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:news_app/utils/string_constants.dart';

import '../datamodel/user_data.dart';

class UserDataRepository {
  final _dio = Dio();

  String getApiUrl() => StringConstants.apiUrl;

  Future<UserDataModel> loadUser() async {
    final response = await _dio.get(getApiUrl());
    if (response.statusCode != 200) throw Exception('Failed to load user with id');
    debugPrint(response.data[0].toString());
    return UserDataModel.fromJson(response.data[0]);
  }

  Future<List<UserDataModel>> loadTopUsers() async {
    final response = await _dio.get(getApiUrl());
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
