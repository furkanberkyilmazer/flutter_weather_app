import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//https://openweathermap.org/
class SearchPage extends StatefulWidget {


  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

   String selectedCity='';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:const BoxDecoration(
          image:DecorationImage(image: AssetImage('assets/search.jpg'),
          fit: BoxFit.cover),
      ),
      child:Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
               Padding(
                 padding: const EdgeInsets.symmetric(horizontal: 50.0),
                 child: TextField(
                   onChanged: (value){
                     selectedCity=value;
                   },
                   decoration: InputDecoration(hintText: 'Şehir Seçiniz',border: OutlineInputBorder(borderSide: BorderSide.none)),
                   style: TextStyle(fontSize: 30),
                   textAlign: TextAlign.center,
                 ),
               ),
              ElevatedButton(onPressed: () async {
                 var response=await http.get(Uri.parse('https://api.openweathermap.org/data/2.5/weather?q=$selectedCity&appid=0c55423352c00c7d95d612d2ad0af5e1'));


                if(response.statusCode==200) {
                  Navigator.pop(context, selectedCity
                      .toString()); //veri yolladığımız için contextin yanına göndermek istediğimiz veriyi yazdık.
                }
                else{
                  _showMyDialog();

                }
              },
                  child: Text("Select City"))
            ],
          ),
        ),

      ),
    );
  }


   Future<void> _showMyDialog() async {
     return showDialog<void>(
       context: context,
       barrierDismissible: false, // user must tap button!
       builder: (BuildContext context) {
         return AlertDialog(
           title: const Text('Location not found'),
           content: SingleChildScrollView(
             child: ListBody(
               children: const <Widget>[
                 Text('Please select a valid location'),

               ],
             ),
           ),
           actions: <Widget>[
             TextButton(
               child: const Text('Ok'),
               onPressed: () {
                 Navigator.of(context).pop();
               },
             ),
           ],
         );
       },
     );
   }
}
