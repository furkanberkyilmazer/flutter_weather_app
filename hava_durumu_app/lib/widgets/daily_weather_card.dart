import 'package:flutter/material.dart';

class DailyWeatherCard extends StatelessWidget {
  const DailyWeatherCard({Key? key, required this.iconUrl, required this.temperatur, required this.date}) : super(key: key);

  final String iconUrl;
  final double temperatur ;
  final String date;
  @override
  Widget build(BuildContext context) {

    DateTime parsedTime=DateTime.parse(date);
    parsedTime.weekday;
    List<String> dates=["Pazartesi","Sali","Carsamba","Persembe","Cuma","Cumartesi","Pazar"];


    return Card(
      color: Colors.transparent,
      child: SizedBox(
        height: 120,
        width: 100,
        child: Column(
          children: [
            Image.network('http://openweathermap.org/img/wn/$iconUrl@2x.png'),
            Text(
              "$temperatur°C",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(dates[(parsedTime.weekday)-1]),
          ],
        ),
      ),
    );
  }
}
