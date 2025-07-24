import 'package:hive/hive.dart';
import 'package:myapp/features/account_management/domain/entities/account.dart';

part 'account_model.g.dart';

@HiveType(typeId: 0)
class AccountModel extends Account {
  @override // Tambahkan @override
  @HiveField(0)
  final String id;
  @override // Tambahkan @override
  @HiveField(1)
  final String website;
  @override // Tambahkan @override
  @HiveField(2)
  final String username;
  @override // Tambahkan @override
  @HiveField(3)
  final String password;

  const AccountModel({
    required this.id,
    required this.website,
    required this.username,
    required this.password,
  }) : super(id: id, website: website, username: username, password: password);

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
}