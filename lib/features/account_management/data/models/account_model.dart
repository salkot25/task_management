import 'package:hive/hive.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';

part 'account_model.g.dart';

@HiveType(typeId: 0)
class AccountModel extends HiveObject implements Account {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String website;
  @override
  @HiveField(2)
  final String username;
  @override
  @HiveField(3)
  final String password;

  AccountModel({
    required this.id,
    required this.website,
    required this.username,
    required this.password,
  });

  factory AccountModel.fromEntity(Account account) {
    return AccountModel(
      id: account.id,
      website: account.website,
      username: account.username,
      password: account.password,
    );
  }

   Account toEntity() {
    return Account(
      id: id,
      website: website,
      username: username,
      password: password,
    );
  }

  @override
  List<Object?> get props => [id, website, username, password];

  @override
  bool get stringify => true;
}
