import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; //import provider

void main() {
  runApp(
    ChangeNotifierProvider<ActivityModel>( 
      create: (context) => ActivityModel(aktivitas: "-", jenis: "-"), //inisialisasi model
      child: const MyApp(),
    ),
  );
}

// menampung data hasil pemanggilan API

class ActivityModel extends ChangeNotifier { //class model
  String url = "https://www.boredapi.com/api/activity"; //url API

  String aktivitas; //atribut
  String jenis; //atribut

  ActivityModel({required this.aktivitas, required this.jenis}); //constructor

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) { 
    aktivitas = json['activity']; //isi atribut
    jenis = json['type']; //isi atribut
    notifyListeners(); //infokan bahwa data berubah
  }

  void fetchData() async {
    final response = await http.get(Uri.parse(url)); //panggil API
    if (response.statusCode == 200) { //jika berhasil
      setFromJson(jsonDecode(response.body)); //isi atribut dari json
    } else {
      throw Exception('Gagal load'); //jika gagal
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [ 
          Consumer<ActivityModel>(
            builder: (context, aktivitas, child) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20), 
                      child: ElevatedButton(
                        onPressed: () {
                          //futureActivity = fetchData();
                          aktivitas.fetchData();
                        },
                        child: const Text("Saya bosan ..."), //tombol
                      ),
                    ),
                    Text(aktivitas.aktivitas), //tampilkan atribut
                    Text("Jenis: ${aktivitas.jenis}") //tampilkan atribut
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}