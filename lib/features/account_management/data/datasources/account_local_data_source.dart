import 'package:hive/hive.dart';
import 'package:myapp/core/error/exceptions.dart';
import 'package:myapp/features/account_management/data/models/account_model.dart';

abstract class AccountLocalDataSource {
  Future<void> saveAccount(AccountModel account);
  Future<List<AccountModel>> getAllAccounts();
  Future<void> updateAccount(AccountModel account);
  Future<void> deleteAccount(String id);
}

const String accountBox = 'accounts'; // Diubah menjadi lowerCamelCase

class AccountLocalDataSourceImpl implements AccountLocalDataSource {
  @override
  Future<void> saveAccount(AccountModel account) async {
    try {
      final box = await Hive.openBox<AccountModel>(accountBox);
      await box.put(account.id, account);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<List<AccountModel>> getAllAccounts() async {
    try {
      final box = await Hive.openBox<AccountModel>(accountBox);
      return box.values.toList();
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> updateAccount(AccountModel account) async {
    try {
      final box = await Hive.openBox<AccountModel>(accountBox);
      await box.put(account.id, account);
    } catch (e) {
      throw CacheException();
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    try {
      final box = await Hive.openBox<AccountModel>(accountBox);
      await box.delete(id);
    } catch (e) {
      throw CacheException();
    }
  }
}