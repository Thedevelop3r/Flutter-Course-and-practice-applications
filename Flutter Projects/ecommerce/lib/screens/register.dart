import 'package:flutter/material.dart';
import 'package:ecommerce/models/user_model.dart';
import 'package:ecommerce/models/items_database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return const Register();
  }
}

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
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
        title: Text("Register"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                margin: EdgeInsets.only(top: 100.0),
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
                const Text(
                  'Register',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25.0,
                      color: Colors.grey),
                ),
                IconButton(
                  onPressed: () async {
                    if (UserName != null && PassWord.length >= 6) {
                      /// start programing the databse functionality here;

                      var newUSer = User(
                          Username: UserName,
                          Password: PassWord,
                          is_admin: false);

                      newUSer = await db.createUser(newUSer);
                      if (newUSer.UserId != null) {
                        Navigator.pop(context, newUSer);
                      }
                    }
                    // print(await Users());
                  },
                  icon: const Icon(Icons.login),
                  iconSize: 40.0,
                  color: Colors.green,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
