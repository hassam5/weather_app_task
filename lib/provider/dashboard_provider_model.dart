import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:weather_test_app/model/filter_forcast.dart';
import 'package:weather_test_app/model/forcast.dart';

import '../api/dashboard_api_client.dart';
import '../model/weather.dart';

/// Mix-in [DiagnosticableTreeMixin] to have access to [debugFillProperties] for the devtool
// ignore: prefer_mixin
class DashboardProviderModel with ChangeNotifier, DiagnosticableTreeMixin {
  //Current Weather
  bool isCurrentWeatherLoading = true;
  CurrentWeather? currentWeather;

  //Five day's forcast
  bool isForcastLoading = true;
  Forcast? forcast;
  List<FilterForcast>? filteredForcast = [];

  //Attendance Tracking API's & Methods
  Future<bool> fetchCurrentWeather(context) async {
    try {
      currentWeather = await DashboardApiClient().fetchCurrentWeather();
      isCurrentWeatherLoading = false;
      notifyListeners();
    } catch (ex) {
      // Utils.handleException(ex, context, null);
    }
    return true;
  }

  //Attendance Tracking API's & Methods
  Future<bool> fetchFiveDaysForcast(context) async {
    try {
      forcast = await DashboardApiClient().fetchFiveDaysForcast();
      isForcastLoading = false;
      forcast!.list!.forEach((element) {
        if (!contains(element.date ?? "")) {
          filteredForcast!.add(new FilterForcast(element.date ?? "", [], false));
        }
      });

      filteredForcast!.forEach((element) {
        forcast!.list!.forEach((forcastEelement) {
          if (element.date == forcastEelement.date) {
            element.list!.add(forcastEelement);
          }
        });
      });
      filteredForcast!.first.isSelected = true;
      notifyListeners();
    } catch (ex) {
      // Utils.handleException(ex, context, null);
    }
    return true;
  }

  bool contains(String date) {
    for (int i = 0; i < filteredForcast!.length; i++) {
      if (filteredForcast![i].date == date) {
        return true;
      }
    }
    return false;
  }

  updateData() {
    //Current Weather
    isCurrentWeatherLoading = true;
    currentWeather = null;

    //Five day's forcast
    isForcastLoading = true;
    forcast = null;
    filteredForcast = [];
    notifyListeners();
    fetchFiveDaysForcast(null);
    fetchCurrentWeather(null);
  }
}
