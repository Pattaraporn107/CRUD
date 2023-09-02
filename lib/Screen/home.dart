import 'package:flutter/material.dart';
import 'package:flutter_application_8/Screen/side_menu.dart';
import 'package:flutter_application_8/Screen/user%20Info.dart';
import 'package:flutter_application_8/models/config.dart';
import 'package:flutter_application_8/models/login_result.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_8/Screen/user from.dart';

class Home extends StatefulWidget {
  static const routeName = '/';
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Widget mainBody = Container();
  List<Users> _userList = [];

  Future<void> getUsers() async {
    var url = Uri.http(Configure.server, "users");
    var resp = await http.get(url);
    setState(() {
      _userList = usersFromJson(resp.body);
      mainBody = showUsers();
    });
    return;
  }

 
  Future<void> removeUsers( user) async {
  var url = Uri.http(Configure.server, "users/${user.id}");
  var resp = await http.delete(url);
  print(resp.body);
  return;
}

   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("Home")
      ),
      drawer: const SideMenu(),
      body: mainBody,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          String result = await Navigator.push(
              context, MaterialPageRoute(builder: (context) => UserForm()));
          if (result == "refresh") {
            getUsers();
          }
        },
        child: const Icon(Icons.person_add_alt_1),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Users user = Configure.login;
    if (user.id != null) {
      getUsers();
    }
  }

 

  Widget showUsers() {
    return ListView.builder(
        itemCount: _userList.length,
        itemBuilder: (constext, index) {
          Users user = _userList[index];
          return Dismissible(
            key: UniqueKey(),
            direction: DismissDirection.endToStart,
            child: Card(
              child: ListTile(
                title: Text("${user.fullname}"),
                subtitle: Text("${user.email}"),


                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => UserInfo(),
                          settings: RouteSettings(arguments: user)));
                }, //to show info


                trailing: IconButton(
                  onPressed: () async {
                    String result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UserForm(),
                            settings: RouteSettings(arguments: user)));
                    if (result == "refresh") {
                      getUsers();
                    }
                  }, // to edit
                  icon: Icon(Icons.edit),
                ),
              ),
            ),


            onDismissed: (direction) {
              removeUsers(user);
            }, // to delete
            background: Container(
              color: Colors.red,
              margin: EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          );
        });
  }
}

