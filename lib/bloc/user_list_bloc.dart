import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../datamodel/user_data.dart';
import '../repository/user_data_repository.dart';
import 'base_bloc.dart';

class UserListBloc extends Bloc {
  static const int intPageSize = 10;
  static const int pageSize = 3;

  late List<UserDataModel> fetchedUserData;
  late List<UserDataModel> selectedUserList = [];
  final List<int> _userIds = [];
  final List<UserDataModel> _topUsers = [];
  final _repository = UserDataRepository();

  var _isLoadingMoreUsers = false;
  var _currentUserIndex = 0;

  final StreamController<List<UserDataModel>> usersStreamController = StreamController();

  Stream<List<UserDataModel>> get usersStream => usersStreamController.stream;

  StreamSink get streamSink => usersStreamController.sink;

  UserListBloc() {
    _loadInitUser();
  }

  void _loadInitUser() async {
    try {
      fetchedUserData = await _repository.loadTopUsers();
      streamSink.add(fetchedUserData);
    } catch (e) {
      streamSink.addError('Unknown Error');
      return;
    }
  }

  void loadMoreUsers({int pageSize = pageSize}) async {
    if (_isLoadingMoreUsers) return;

    _isLoadingMoreUsers = true;
    final userSize = min(_currentUserIndex + pageSize, _userIds.length);
    for (int index = _currentUserIndex; index < userSize; index++) {
      try {
        String str = _repository.loadTopUsers().toString();
        debugPrint(str);
        // _topUser.add(await _repository.loadUser(_topUserIds[index]));
      } catch (e) {
        print('Failed to load users with id ${_userIds[index]}');
      }
    }
    _currentUserIndex = _topUsers.length;
    streamSink.add(_topUsers);
    _isLoadingMoreUsers = false;
  }

  bool hasMoreUsers() => _currentUserIndex < _userIds.length;

  @override
  void dispose() {
    usersStreamController.close();
    _repository.dispose();
  }
}
