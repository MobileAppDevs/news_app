import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import '../bloc/user_list_bloc.dart';
import '../datamodel/user_data.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  late UserListBloc _bloc;

  final _scrollController = ScrollController();

  UserListBloc userListBloc = UserListBloc();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMoreUsersIfNeed);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = Provider.of<UserListBloc>(context);
  }

  void updateSelectedUserList() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: userListBloc.usersStream,
      builder: (BuildContext context, AsyncSnapshot<List<UserDataModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Flutter Tabs Demo'),
                  bottom: const TabBar(
                    key: Key('tabBar'),
                    tabs: [
                      Tab(
                        key: Key('tab1'),
                        text: "All Users",
                      ),
                      Tab(
                        key: Key('tab2'),
                        text: "Selected Users",
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  key: const Key('tabBarView'),
                  children: [
                    ListView.builder(
                      controller: _scrollController,
                      itemCount: _bloc.hasMoreUsers() ? snapshot.data!.length + 1 : snapshot.data!.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (index == snapshot.data!.length) {
                          return const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return User(
                          user: snapshot.data![index],
                          listIndex: index,
                          updatedSelectedUserList: updateSelectedUserList,
                          userListBloc: userListBloc,
                        );
                      },
                    ),
                    ListView.builder(
                      itemCount: userListBloc.selectedUserList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(userListBloc.selectedUserList[index].login),
                          leading: CircleAvatar(backgroundImage: NetworkImage(userListBloc.selectedUserList[index].avatarUrl)),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text('${snapshot.error}')));
          }
          return const Center(child: Scaffold(body: Center(child: Text('other state'))));
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Scaffold(body: Center(child: CircularProgressIndicator())));
        } else {
          return const Center(child: Scaffold(body: Center(child: Text('other state'))));
        }
      },
    );
  }

  void _loadMoreUsersIfNeed() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent) {}
    // final offsetToEnd = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
    // final threshold = MediaQuery.of(context).size.height / 3;
    // final shouldLoadMore = offsetToEnd < threshold;
    // if (shouldLoadMore) {
    //   _bloc.loadMoreUsers();
    // }
  }
}

class User extends StatefulWidget {
  const User({Key? key, required this.user, required this.listIndex, required this.updatedSelectedUserList, required this.userListBloc}) : super(key: key);

  final UserDataModel user;
  final int listIndex;
  final void Function() updatedSelectedUserList;
  final UserListBloc userListBloc;

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(widget.user.login),
        leading: CircleAvatar(backgroundImage: NetworkImage(widget.user.avatarUrl)),
        trailing: Checkbox(
          value: widget.user.isSelected,
          onChanged: (value) async {
            widget.user.isSelected = value;
            setState(() {});
            await GetStorage().write(widget.listIndex.toString(), widget.user);
            if (value!) {
              widget.userListBloc.selectedUserList.add(widget.user);
              widget.updatedSelectedUserList();
            } else {
              widget.userListBloc.selectedUserList.removeWhere((element) => element == widget.user);
              widget.updatedSelectedUserList();
            }
          },
        ),
      ),
    );
  }
}
