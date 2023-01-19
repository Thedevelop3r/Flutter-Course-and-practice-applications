final String tableUsers = 'users';

class UserFields {
  static final List<String> values = [id, username, password, is_admin];

  static final String id = '_id';
  static final String username = 'username';
  static final String password = 'password';
  static final String is_admin = 'isadmin';
}

class User {
  int? UserId;
  final String Username;
  final String Password;
  final bool is_admin;

  User(
      {this.UserId,
      required this.Username,
      required this.Password,
      required this.is_admin});

  Map<String, Object?> toJson() => {
        UserFields.id: UserId,
        UserFields.username: Username,
        UserFields.password: Password,
        UserFields.is_admin: is_admin ? 1 : 0
      };

  static User fromJson(Map<String, Object?> json) => User(
      UserId: json[UserFields.id] as int?,
      Username: json[UserFields.username] as String,
      Password: json[UserFields.password] as String,
      is_admin: json[UserFields.is_admin] == 1);

  User copy(
          {int? UserId, String? username, String? password, bool? is_admin}) =>
      User(
          UserId: UserId ?? this.UserId,
          Username: Username,
          Password: Password,
          is_admin: is_admin ?? this.is_admin);

  @override
  String toString() {
    return 'User{Id: $UserId, Username: $Username, Password: $Password}';
  }
}
