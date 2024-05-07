import 'package:flutter_bloc/flutter_bloc.dart'; //import flutter bloc
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

//event parent
abstract class DataEvent {}

//event mulai pengambilan data
class FetchDataEvent extends DataEvent {} 

//event jika data sudah selesai diambil
class DataSiapEvent extends DataEvent {
  late ActivityModel activity;
  DataSiapEvent(ActivityModel act) : activity = act; //constructor
}

class ActivityBloc extends Bloc<DataEvent, ActivityModel> { //class model
  String url = "https://www.boredapi.com/api/activity"; //url API
  ActivityBloc() : super(ActivityModel(aktivitas: "", jenis: "")) { //inisialisasi model
    
    //penanganan event
    on<FetchDataEvent>((event, emit) {
      fetchData(); //request ambi ldata
    });
    on<DataSiapEvent>((even, emit) {
      emit(even.activity);  //selesai, emit state data terakhir
    });
  }

  //map dari json ke atribut
  void setFromJson(Map<String, dynamic> json) {
    String aktivitas = json['activity']; //isi atribut
    String jenis = json['type']; //isi atribut
    //tambahkan event bahwa data sudah difetch dan siap
    add(DataSiapEvent(ActivityModel(aktivitas: aktivitas, jenis: jenis))); 
  }

  void fetchData() async { //method
    final response = await http.get(Uri.parse(url)); //panggil API
    if (response.statusCode == 200) { //jika berhasil
      setFromJson(jsonDecode(response.body)); //isi atribut dari json
    } else {
      throw Exception('Gagal load'); //jika gagal
    }
  }
}

class ActivityModel { //class model
  String aktivitas; //atribut
  String jenis; //atribut
  ActivityModel({required this.aktivitas, required this.jenis}); //constructor
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider( //provider
        create: (_) => ActivityBloc(), //inisialisasi bloc
        child: const HalamanUtama(), //tampilkan halaman utama
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
          BlocBuilder<ActivityBloc, ActivityModel>(
            builder: (context, aktivitas) {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<ActivityBloc>().add(FetchDataEvent()); //futureActivity = fetchData();
                        }, 
                        child: const Text("Saya bosan ..."), //tombol
                      ),
                    ),
                    Text(aktivitas.aktivitas), //isi atribut
                    Text("Jenis: ${aktivitas.jenis}") //tampilkan atribut
                  ]));
            },
          ),
        ]),
      ),
    ));
  }
}