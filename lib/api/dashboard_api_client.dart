import 'dart:async';

import 'package:weather_test_app/model/forcast.dart';

import '../model/weather.dart';
import 'api_client.dart';

class DashboardApiClient {
  static final DashboardApiClient _instance = DashboardApiClient._internal();

  DashboardApiClient._internal();

  factory DashboardApiClient() => _instance;

  Future<CurrentWeather?> fetchCurrentWeather() async {
    String url = "http://api.openweathermap.org/data/2.5/weather?lat=51.5072&lon=0.1276&appid=15761677a9bfa3ae3233b9198582053a&units=metric";
    return await ApiClient().getJsonForObject(
      (json) {
        CurrentWeather responseData = CurrentWeather.fromJson(json);
        return responseData;
      },
      url,
    );
  }

  Future<Forcast?> fetchFiveDaysForcast() async {
    String url = "https://api.openweathermap.org/data/2.5/forecast?lat=51.5072&lon=0.1276&appid=15761677a9bfa3ae3233b9198582053a&units=metric";
    return await ApiClient().getJsonForObject(
          (json) {
            Forcast responseData = Forcast.fromJson(json);
        return responseData;
      },
      url,
    );
  }
}
