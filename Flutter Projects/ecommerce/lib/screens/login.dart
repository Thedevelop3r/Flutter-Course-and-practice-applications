import 'package:ecommerce/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce/models/user_model.dart';
import 'package:ecommerce/models/items_database_helper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Login(),
    );
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late TextEditingController _controllerA;
  late TextEditingController _controllerB;

  late String UserName;
  late String PassWord;
  final db = ItemsDatabase.instance;
  late final user;
  late final useridSQL;

  @override
  void initState() {
    super.initState();
    _controllerA = TextEditingController();
    _controllerB = TextEditingController();
    createUserNow();
  }

  Future createUserNow() async {
    user = User(
        Username: 'bilal', Password: '123456', is_admin: true, UserId: null);
    try {
      User checkuser = await db.readUser('bilal');
      useridSQL = checkuser;
    } catch (e) {
      print(e);
      useridSQL = await db.createUser(user);
    }

    final userdata = await db.userAuth(user.Username, user.Password);
    print('UserID: $useridSQL <SQL>');
    print('$userdata <SQL>');
  }

  Future<bool> UserAuth(String username, String password) async {
    try {
      final resultUser = await db.userAuth(username, password);
      if (resultUser.Username == UserName &&
          resultUser.Password == PassWord &&
          resultUser.is_admin == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                height: 200,
                width: 300.0,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextField(
                      onChanged: (String username) {
                        UserName = username;
                      },
                      controller: _controllerA,
                      decoration: InputDecoration(
                          label: const Text(
                            "Username",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          hintText: 'Type your username',
                          icon: const Icon(Icons.account_box),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    TextField(
                      onChanged: (String password) {
                        PassWord = password;
                      },
                      controller: _controllerB,
                      decoration: InputDecoration(
                          label: const Text(
                            "Password",
                            style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          ),
                          hintText: 'Type your password',
                          icon: Icon(Icons.password_outlined),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.0))),
                    )
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Login',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Colors.grey),
                ),
                IconButton(
                  onPressed: () async {
                    if (UserName != null && PassWord.length >= 6) {
                      /// start programing the databse functionality here;
                      ///
                      if (await UserAuth(UserName, PassWord)) {
                        User loggeduser = await db.readUser(UserName);

                        return Navigator.pop(context, loggeduser);
                      } else {
                        User dummy = User(
                            Username: 'Guesst',
                            is_admin: false,
                            Password: '123456',
                            UserId: 200);
                        return Navigator.pop(context, dummy);
                      }
                    }
                  },
                  icon: const Icon(Icons.login),
                  iconSize: 40.0,
                  color: Colors.green,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'New to store ! register now',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.0,
                      color: Colors.black54),
                ),
                IconButton(
                  onPressed: () async {
                    User userregistered = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterPage()));

                    Navigator.pop(context, [userregistered]);
                  },
                  icon: const Icon(Icons.app_registration),
                  iconSize: 40.0,
                  color: Colors.purpleAccent,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
