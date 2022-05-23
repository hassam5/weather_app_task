import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_test_app/ui/widget/current_weather_widget.dart';
import 'package:weather_test_app/ui/widget/forcast_widget.dart';

import '../model/weather.dart';
import '../provider/dashboard_provider_model.dart';

class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardProviderModel data;

  @override
  void initState() {
    super.initState();
    data = Provider.of<DashboardProviderModel>(context, listen: false);
    data.fetchCurrentWeather(context);
    data.fetchFiveDaysForcast(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Alpian Weather Task"),
        actions: [
          IconButton(
            onPressed: () {
              data.updateData();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<DashboardProviderModel>(builder: (context, model, child) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              children: [
                (model.isCurrentWeatherLoading && model.currentWeather == null)
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      )
                    : model.currentWeather == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Sorry, Something Went Wrong While fetching Current Weather"),
                            ),
                          )
                        : CurrentWeatherWidget(model.currentWeather ?? new CurrentWeather()),
                (model.isForcastLoading && model.forcast == null)
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(),
                      )
                    : model.forcast == null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text("Sorry, Something Went Wrong While fetching forcast"),
                            ),
                          )
                        : ForcastWidget(model.filteredForcast ?? []),
              ],
            ),
          ),
        );
      }),
    );
  }
}
