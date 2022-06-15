import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/user_list_bloc.dart';
import '../datamodel/UserData.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({Key? key}) : super(key: key);

  @override
  UserListPageState createState() => UserListPageState();
}

class UserListPageState extends State<UserListPage> {
  late UserListBloc _bloc;

  final _scrollController = ScrollController();

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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _bloc.users,
      builder: (BuildContext context, AsyncSnapshot<List<UserDataModel>> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return DefaultTabController(
              length: 2,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text('Flutter Tabs Demo'),
                  bottom: const TabBar(
                    tabs: [
                      Tab(text: "All Users"),
                      Tab(text: "Selected Users"),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: [
                    ListView.builder(itemBuilder: (context, index) {
                      return const ListTile(
                        title: Text('item'),
                        // title: Text(snapshot.data![index].login),
                      );
                    }),
                    ListView.separated(
                      itemBuilder: (context, index) {
                        return ListTile(
                            title: Text(
                          snapshot.data![index].login,
                          style: const TextStyle(color: Colors.black),
                        ));
                      },
                      separatorBuilder: (context, index) => const VerticalDivider(),
                      itemCount: snapshot.data!.length,
                    ),
                  ],
                ),
              ),
            );
          }
          if (snapshot.hasError) return Scaffold(body: Center(child: Text('${snapshot.error}')));
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
    final offsetToEnd = _scrollController.position.maxScrollExtent - _scrollController.position.pixels;
    final threshold = MediaQuery.of(context).size.height / 3;
    final shouldLoadMore = offsetToEnd < threshold;
    if (shouldLoadMore) {
      _bloc.loadMoreUsers();
    }
  }

  Widget _buildUsers({required List<UserDataModel> users}) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _bloc.hasMoreUsers() ? users.length + 1 : users.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == users.length) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return _buildUserCardView(userData: users[index]);
      },
    );
  }

  Widget _buildUserCardView({required UserDataModel userData}) {
    return Card(
      child: ListTile(
        title: Text(userData.login),
        subtitle: Text(userData.avatarUrl),
        onTap: () => _launchUrl(userData.url),
      ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }
}
