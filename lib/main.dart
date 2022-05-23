import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_test_app/provider/dashboard_provider_model.dart';
import 'package:weather_test_app/ui/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProviderModel()),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(

          primarySwatch: Colors.blue,
        ),
        home: DashboardPage(),
      ),
    );
  }
}
