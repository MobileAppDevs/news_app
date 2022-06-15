import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../datamodel/UserData.dart';
import '../repository/hacker_news_repository.dart';
import 'base_bloc.dart';

class UserListBloc extends Bloc {
  static const int intPageSize = 10;
  static const int pageSize = 3;

  late UserDataModel fetchedUserData;
  final List<int> _userIds = [];
  final List<UserDataModel> _topUsers = [];
  final _repository = UserDataRepository();

  var _isLoadingMoreTopUsers = false;
  var _currentUserIndex = 0;

  final StreamController<List<UserDataModel>> _usersStreamController = StreamController();

  Stream<List<UserDataModel>> get users => _usersStreamController.stream;

  UserListBloc() {
    _loadInitUser();
  }

  void _loadInitUser() async {
    try {
      fetchedUserData = await _repository.loadTopUserIds();
      debugPrint(fetchedUserData.toString());
    } catch (e) {
      _usersStreamController.sink.addError('Unknown Error');
      return;
    }

    loadMoreUsers(pageSize: intPageSize);
  }

  void loadMoreUsers({int pageSize = pageSize}) async {
    if (_isLoadingMoreTopUsers) return;

    _isLoadingMoreTopUsers = true;
    final UserSize = min(_currentUserIndex + pageSize, _userIds.length);
    for (int index = _currentUserIndex; index < UserSize; index++) {
      try {
        String str = _repository.loadTopUserIds().toString();
        debugPrint(str);
        // _topUser.add(await _repository.loadUser(_topUserIds[index]));
      } catch (e) {
        print('Failed to load users with id ${_userIds[index]}');
      }
    }
    _currentUserIndex = _topUsers.length;
    _usersStreamController.sink.add(_topUsers);
    _isLoadingMoreTopUsers = false;
  }

  bool hasMoreUsers() => _currentUserIndex < _userIds.length;

  @override
  void dispose() {
    _usersStreamController.close();
    _repository.dispose();
  }
}
