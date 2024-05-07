import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer' as developer; //import developer

class ActivityModel { //class model
  String aktivitas; //atribut
  String jenis; //atribut
  ActivityModel({required this.aktivitas, required this.jenis}); //constructor
}

class ActivityCubit extends Cubit<ActivityModel> {  //class model
  String url = "https://www.boredapi.com/api/activity"; //url API
  ActivityCubit() : super(ActivityModel(aktivitas: "", jenis: "")); //inisialisasi model

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) { //method
    String aktivitas = json['activity']; //isi atribut
    String jenis = json['type']; //isi atribut
    emit(ActivityModel(aktivitas: aktivitas, jenis: jenis)); //infokan bahwa data berubah
  }

  void fetchData() async { //method
    final response = await http.get(Uri.parse(url)); //panggil API
    if (response.statusCode == 200) { //jika berhasil
      setFromJson(jsonDecode(response.body)); //isi atribut dari json
    } else {
      throw Exception('Gagal load');  //jika gagal
    }
  }
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (_) => ActivityCubit(),
        child: const HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);
  @override
  Widget build(Object context) {
    return MaterialApp(
        home: Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          BlocBuilder<ActivityCubit, ActivityModel>(
            buildWhen: (previousState, state) {
              developer.log("${previousState.aktivitas} -> ${state.aktivitas}", //log
                  name: 'logyudi'); //log
              return true;
            },
            builder: (context, aktivitas) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ActivityCubit>().fetchData(); //futureActivity = fetchData();
                        },
                        child: const Text("Saya bosan ..."), //tombol
                      ),
                    ),
                    Text(aktivitas.aktivitas), //isi atribut
                    Text("Jenis: ${aktivitas.jenis}") //isi atribut
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}