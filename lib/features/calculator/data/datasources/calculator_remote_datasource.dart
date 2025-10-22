import 'package:shared_preferences/shared_preferences.dart';

abstract interface class CalculatorRemoteDatasource {
  Future<int> getStored();
  Future<double> getValue();
  Future<double> add({required double amount});
  Future<double> subtract({required double amount});
  Future<double> reset();
}

class CalculatorRemoteDatasourceImpl implements CalculatorRemoteDatasource {
  final SharedPreferences prefs;
  // ignore: constant_identifier_names
  static const String STORED_KEY = "calculator";

  CalculatorRemoteDatasourceImpl(this.prefs);

  
  @override
  Future<int> getStored() async {
    bool hasKey = prefs.containsKey(STORED_KEY);

    int amount = 0;
    if (hasKey) {
      int? response = prefs.getInt(STORED_KEY);
      if (response != null) {
        amount = response;
      }
    }

    return amount;
  }

  @override
  Future<double> getValue() async {
    int stored = await getStored();
    return stored / 100;
  }
  
  @override
  Future<double> add({required double amount}) async {
    try {
      int stored = await getStored();
      int newValue = stored += (amount * 100).toInt();
      prefs.setInt(STORED_KEY, newValue);
      return await getValue();
    } catch (e) {
      return await getValue();
    }
  }
  
  @override
  Future<double> subtract({required double amount}) async {
    try {
      int stored = await getStored();
      int newValue = stored -= (amount * 100).toInt();
      prefs.setInt(STORED_KEY, newValue);
      return await getValue();
    } catch (e) {
      return await getValue();
    }
  }

  @override
  Future<double> reset() async {
    try {
      prefs.setInt(STORED_KEY, 0);
      return await getValue();
    } catch (e) {
      return await getValue();
    }
  }
}
