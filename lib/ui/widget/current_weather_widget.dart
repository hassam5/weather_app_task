import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_test_app/model/weather.dart';

class CurrentWeatherWidget extends StatelessWidget {
  CurrentWeather currentWeather;

  CurrentWeatherWidget(this.currentWeather);

  @override
  Widget build(BuildContext context) {
    // Weather description
    // Temperature in Celsius Degrees (current, min and max)
    // Humidity percentage
    // Date of last update
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          showItem(
            "Last Updated At:",
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
            color: Colors.green,
          ),
          SizedBox(
            height: 12,
          ),
          showItem(
            "Description:",
            showDescription(currentWeather.weather),
          ),
          SizedBox(
            height: 12,
          ),
          showItem("Current Temperature", currentWeather.main!.temp.toString() + " C"),
          SizedBox(
            height: 12,
          ),
          showItem("Min Temperature", currentWeather.main!.tempMin.toString() + " C"),
          SizedBox(
            height: 12,
          ),
          showItem("Max Temperature", currentWeather.main!.tempMax.toString() + " C"),
          SizedBox(
            height: 12,
          ),
          showItem("Humidity", currentWeather.main!.humidity.toString() + "%"),
          SizedBox(
            height: 12,
          ),
        ],
      ),
    );
  }

  Widget showItem(String title, String value, {Color color = Colors.black}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: color),
        ),
      ],
    );
  }

  String showDescription(final List<WeatherElement>? weather) {
    String description = "";
    weather!.forEach((element) {
      description = description + (element.description ?? "") + " | ";
    });
    return description;
  }
}
