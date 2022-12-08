import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:hava_durumu_app/widgets/daily_weather_card.dart';
import 'package:hava_durumu_app/widgets/loading_widget.dart';
import 'search_page.dart';
import 'package:http/http.dart' as http;

//https://api.openweathermap.org/data/2.5/weather?lat=37.4219983&lon=-122.084&appid=0c55423352c00c7d95d612d2ad0af5e1
class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String location = 'Ankara';
  double? temperatur;
  final String key = '0c55423352c00c7d95d612d2ad0af5e1';
  var locationData;
  String code = "c";
  Position? devicePosition;
  String iconUrl = '';

  List<String> icons = [];
  List<double> temperatures = [];
  List<String> dates = [];

  Future<void> getLocationDataFromAPI() async {
    locationData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$key&units=metric'));
    final locationDataParsed = jsonDecode(locationData.body);
    print(locationDataParsed);

    setState(() {
      temperatur = locationDataParsed['main']['temp'];
      location = locationDataParsed['name'];
      code = locationDataParsed['weather'][0]['main'];
      iconUrl = locationDataParsed['weather'][0]['icon'];
    });
  }

  Future<void> getLocationDataFromAPIByLatLon() async {
    if (devicePosition != null) {
      locationData = await http.get(Uri.parse(
          'https://api.openweathermap.org/data/2.5/weather?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));
      final locationDataParsed = jsonDecode(locationData.body);
      print(locationDataParsed);

      setState(() {
        temperatur = locationDataParsed['main']['temp'];
        location = locationDataParsed['name'];
        code = locationDataParsed['weather'][0]['main'];
        iconUrl = locationDataParsed['weather'][0]['icon'];
      });
    }
  }

  Future<void> getDevicePosition() async {
    try {
      devicePosition = await _determinePosition();
      print('Device Prosition: $devicePosition');
    } catch (error) {
      print(error);
    } finally {
      //her ne olursa olsun bu kod çalışır.
    }
  }

  Future<void> getDailyForecastByLatLon() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?lat=${devicePosition!.latitude}&lon=${devicePosition!.longitude}&appid=$key&units=metric'));

    var forecastDataParsed = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  Future<void> getDailyForecast() async {
    var forecastData = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$key&units=metric'));

    var forecastDataParsed = jsonDecode(forecastData.body);
    temperatures.clear();
    icons.clear();
    dates.clear();

    setState(() {
      for (int i = 7; i < 40; i = i + 8) {
        temperatures.add(forecastDataParsed['list'][i]['main']['temp']);
        icons.add(forecastDataParsed['list'][i]['weather'][0]['icon']);
        dates.add(forecastDataParsed['list'][i]['dt_txt']);
      }
    });
  }

  void getInitialData() async {
    await getDevicePosition();
    await getLocationDataFromAPIByLatLon();
    //await getLocationDataFromAPI();
    await getDailyForecastByLatLon();
  }

  @override
  void initState() {
    getInitialData(); //init state de asyn olmadığı için yukarda bir üst fonk yazdık.
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage('assets/$code.jpg'), fit: BoxFit.cover),
      ),
      child: (temperatur == null ||
              devicePosition == null ||
              icons.isEmpty ||
              temperatures.isEmpty ||
              dates.isEmpty)
          ? const LoadingWidget()
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 150,
                      child: Image.network(
                          'http://openweathermap.org/img/wn/$iconUrl@4x.png'),
                    ),
                    Text(
                      "$temperatur°C",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 70,

                        shadows: <Shadow>[
                          Shadow(
                              color: Colors.black54,
                              blurRadius: 2,
                              offset: Offset(-8, 6))
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$location",
                          style:  TextStyle(
                            fontSize: 40,

                            shadows: <Shadow>[
                              Shadow(
                                  color: Colors.black54,
                                  blurRadius: 2,
                                  offset: Offset(-4, 2))
                            ],
                          ),
                        ),
                        IconButton(
                            onPressed: () async {
                              final selectedCity = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchPage()));
                              location = selectedCity;
                              print(location);
                              getLocationDataFromAPI();
                              getDailyForecast();
                            },
                            icon: const Icon(Icons.search))
                      ],
                    ),
                    buildWeatherCards(context),
                  ],
                ),
              )),
    );
  }

  Widget buildWeatherCards(BuildContext context) {
    List<DailyWeatherCard> cards = [];

    for (int i = 0; i < 5; i++) {
      cards.add(DailyWeatherCard(
          iconUrl: icons[i], temperatur: temperatures[i], date: dates[i]));
    }

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.20,
      width: MediaQuery.of(context).size.width *
          0.8, //ekranın genişliğini öğrendik ve onun %90 nı aldık
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
