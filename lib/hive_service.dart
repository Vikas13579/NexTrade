import 'package:hive_flutter/hive_flutter.dart';
import 'package:nextrade/profilr_model.dart';

import 'model.dart';

class HiveService {
  static const String userBoxName = 'userBox';
  static const String stocksBoxName = 'stocksBox';
  static const String holdingsBoxName = 'holdingsBox';
  static const String ordersBoxName = 'ordersBox';
  static const String watchlistBoxName = 'watchlistBox';
  static const String transactionsBoxName = 'transactionsBox';
  static const String settingsBoxName = 'settingsBox';
  static const String profileBoxName = 'profileBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // ✅ Register adapter
    Hive.registerAdapter(ProfileModelAdapter());

    // Open boxes
    await Hive.openBox<Map>(userBoxName);
    await Hive.openBox<Map>(stocksBoxName);
    await Hive.openBox<HoldingModel>(holdingsBoxName);
    // await Hive.openBox<Map>(holdingsBoxName);
    await Hive.openBox<Map>(ordersBoxName);
    await Hive.openBox<Map>(watchlistBoxName);
    await Hive.openBox<Map>(transactionsBoxName);
    await Hive.openBox(settingsBoxName);

    // ✅ Profile box
    await Hive.openBox<ProfileModel>(profileBoxName);
  }

  // ───────────────────────── BOX GETTERS ─────────────────────────

  static Box<Map> get userBox => Hive.box<Map>(userBoxName);
  static Box<Map> get stocksBox => Hive.box<Map>(stocksBoxName);
  // static Box<Map> get holdingsBox => Hive.box<Map>(holdingsBoxName);
  static Box<Map> get ordersBox => Hive.box<Map>(ordersBoxName);
  static Box<Map> get watchlistBox => Hive.box<Map>(watchlistBoxName);
  static Box<Map> get transactionsBox => Hive.box<Map>(transactionsBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<HoldingModel> get holdingsBox =>
      Hive.box<HoldingModel>(holdingsBoxName);

  // ✅ Profile box getter
  static Box<ProfileModel> get profileBox =>
      Hive.box<ProfileModel>(profileBoxName);

  // ───────────────────────── PROFILE METHODS ─────────────────────────

  static ProfileModel? getProfile() {
    if (profileBox.isEmpty) return null;
    return profileBox.getAt(0);
  }

  static Future<void> saveProfile(ProfileModel profile) async {
    if (profileBox.isEmpty) {
      await profileBox.add(profile);
    } else {
      await profileBox.putAt(0, profile);
    }
  }

  static Future<void> clearProfile() async {
    await profileBox.clear();
  }

  // ───────────────────────── SETTINGS ─────────────────────────

  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  static bool isLoggedIn() =>
      getSetting<bool>('isLoggedIn', defaultValue: false) ?? false;

  static bool hasCompletedOnboarding() =>
      getSetting<bool>('onboardingDone', defaultValue: false) ?? false;

  static bool isBiometricEnabled() =>
      getSetting<bool>('biometricEnabled', defaultValue: false) ?? false;

  static String getTheme() =>
      getSetting<String>('theme', defaultValue: 'dark') ?? 'dark';

  static bool isNotificationsEnabled() =>
      getSetting<bool>('notifications', defaultValue: true) ?? true;

  // ───────────────────────── CLEAR ALL ─────────────────────────

  static Future<void> clearAll() async {
    await userBox.clear();
    await stocksBox.clear();
    await holdingsBox.clear();
    await ordersBox.clear();
    await watchlistBox.clear();
    await transactionsBox.clear();

    // ✅ YOU MISSED THIS
    await clearProfile();

    await saveSetting('isLoggedIn', false);
  }
}