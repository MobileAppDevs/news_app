import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bloc/user_list_bloc.dart';
import 'page/user_list_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hacker News',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Provider<UserListBloc>(
        create: (context) => UserListBloc(),
        dispose: (context, bloc) => bloc.dispose(),
        child: const UserListPage(),
      ),
    );
  }
}
