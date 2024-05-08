import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // import flutter_bloc

void main() {
  runApp(MyApp());
}

class Universitas { // class Universitas
  String nama; // atribut nama bertipe String
  String website; // atribut website bertipe String

  Universitas({required this.nama, required this.website}); // konstruktor Universitas
}

class DaftarUniversitas { // class DaftarUniversitas
  List<Universitas> universitas = []; // list universitas

  DaftarUniversitas.fromJson(List<dynamic> json) { // konstruktor DaftarUniversitas
    universitas = json.map((uni) { // mapping json
      return Universitas( // return Universitas
        nama: uni['name'], // mengambil nama universitas
        website: uni['web_pages'][0], // mengambil situs web pertama dari daftar
      );
    }).toList(); 
  }
}

class Negara { // class Negara 
  final String nama; // atribut nama bertipe String
  final String url; // atribut url bertipe String

  Negara({required this.nama, required this.url}); // konstruktor Negara
}

// class NegaraCubit
final List<Negara> daftarNegara = [
  Negara(nama: 'Indonesia', url: "http://universities.hipolabs.com/search?country=Indonesia"),
  Negara(nama: 'Singapura', url: "http://universities.hipolabs.com/search?country=Singapore"),
  Negara(nama: 'Malaysia', url: "http://universities.hipolabs.com/search?country=Malaysia"),
  Negara(nama: 'Myanmar', url: "http://universities.hipolabs.com/search?country=Myanmar"),
  Negara(nama: 'Thailand', url: "http://universities.hipolabs.com/search?country=Thailand"),
  Negara(nama: 'Vietnam', url: "http://universities.hipolabs.com/search?country=Vietnam"),
  Negara(nama: 'Filipina', url: "http://universities.hipolabs.com/search?country=Philippines"),
  Negara(nama: 'Laos', url: "http://universities.hipolabs.com/search?country=Laos"),
  Negara(nama: 'Kamboja', url: "http://universities.hipolabs.com/search?country=Cambodia"),
  Negara(nama: 'Brunei', url: "http://universities.hipolabs.com/search?country=Brunei"),
];

class NegaraCubit extends Cubit<Negara> { // class NegaraCubit
  NegaraCubit() : super(daftarNegara[0]); // super daftarNegara

  void pilihNegara(Negara negara) => emit(negara); // emit negara
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Universitas',
      home: BlocProvider(
        create: (context) => NegaraCubit(),
        child: DaftarUniversitasPage(),
      ),
    );
  }
}

// class DaftarUniversitasPage
class DaftarUniversitasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas'),
      ),
      body: Column(
        children: [
          PilihanNegaraDropdown(),
          Expanded(child: DaftarUniversitasList()),
        ],
      ),
    );
  }
}

// class PilihanNegaraDropdown
class PilihanNegaraDropdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NegaraCubit, Negara>( 
      builder: (context, negara) {
        return DropdownButton<Negara>(
          value: negara,
          onChanged: (newValue) { 
            context.read<NegaraCubit>().pilihNegara(newValue!); // pilih negara
          },
          items: daftarNegara.map<DropdownMenuItem<Negara>>((Negara negara) { // mapping daftarNegara
            return DropdownMenuItem<Negara>( // return DropdownMenuItem
              value: negara, 
              child: Text(negara.nama),
            );
          }).toList(),
        );
      },
    );
  }
}

// class DaftarUniversitasList
class DaftarUniversitasList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final negara = context.watch<NegaraCubit>().state; // watch negara dari NegaraCubit
    return FutureBuilder<DaftarUniversitas>( // FutureBuilder DaftarUniversitas
      future: fetchData(negara.url), // fetchData
      builder: (context, snapshot) { 
        if (snapshot.connectionState == ConnectionState.waiting) { // jika connectionState waiting
          return Center(child: CircularProgressIndicator()); // return CircularProgressIndicator
        } else if (snapshot.hasError) { // jika snapshot error
          return Center(child: Text('Error: ${snapshot.error}')); // return Text
        } else {
          return ListView.builder( 
            itemCount: snapshot.data?.universitas.length ?? 0, // berisikan jumlah data universitas
            itemBuilder: (context, index) { 
              final universitas = snapshot.data!.universitas[index]; // universitas dari snapshot
              return InkWell( 
                onTap: () async { 
                  if (await canLaunch(universitas.website)) { // jika bisa launch
                    await launch(universitas.website); // launch
                  } else {
                    throw 'Tidak bisa membuka ${universitas.website}'; // throw error
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        universitas.nama,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(
                        universitas.website,
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

Future<DaftarUniversitas> fetchData(String url) async { // fetchData
  final response = await http.get(Uri.parse(url)); // http get

  if (response.statusCode == 200) { // jika response status code 200
    return DaftarUniversitas.fromJson(jsonDecode(response.body)); // return DaftarUniversitas
  } else {
    throw Exception('Gagal load'); // throw error
  } 
}
