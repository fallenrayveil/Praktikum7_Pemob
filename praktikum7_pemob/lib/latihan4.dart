import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class Universitas {
  String nama;
  String website;

  Universitas({required this.nama, required this.website});
}

class DaftarUniversitas {
  List<Universitas> universitas = [];

  DaftarUniversitas.fromJson(List<dynamic> json) {
    universitas = json.map((uni) {
      return Universitas(
        nama: uni['name'],
        website: uni['web_pages'][0],
      );
    }).toList();
  }
}

class Negara {
  final String nama;
  final String url;

  Negara({required this.nama, required this.url});
}

class NegaraAsean with ChangeNotifier {
  Negara _negaraTerpilih = daftarNegara[0];
  
  Negara get negaraTerpilih => _negaraTerpilih;

  void setNegaraTerpilih(Negara negara) {
    _negaraTerpilih = negara;
    notifyListeners();
  }
}

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NegaraAsean(),
      child: MaterialApp(
        title: 'Daftar Universitas',
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Universitas'),
          ),
          body: Column(
            children: [
              _buildPilihanNegara(),
              Expanded(child: _buildDaftarUniversitas()),
            ],
          ),
        ),
      ),
    );
  }

  // Widget untuk menampilkan pilihan negara
  Widget _buildPilihanNegara() { 
    return Consumer<NegaraAsean>(
      builder: (context, NegaraAsean, child) {
        return DropdownButton<Negara>(
          value: NegaraAsean.negaraTerpilih,
          onChanged: (Negara? nilaiBaru) {
            if (nilaiBaru != null) {
              NegaraAsean.setNegaraTerpilih(nilaiBaru);
            }
          },
          items: daftarNegara.map<DropdownMenuItem<Negara>>((Negara negara) {
            return DropdownMenuItem<Negara>(
              value: negara,
              child: Text(negara.nama),
            );
          }).toList(),
        );
      },
    );
  }

  // Widget untuk menampilkan daftar universitas
  Widget _buildDaftarUniversitas() {
    return Consumer<NegaraAsean>(
      builder: (context, NegaraAsean, child) {
        return FutureBuilder<DaftarUniversitas>(
          future: fetchData(NegaraAsean.negaraTerpilih.url),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return ListView.builder(
                itemCount: snapshot.data?.universitas.length ?? 0,
                itemBuilder: (context, index) {
                  final universitas = snapshot.data!.universitas[index];
                  return InkWell(
                    onTap: () async {
                      if (await canLaunch(universitas.website)) {
                        await launch(universitas.website);
                      } else {
                        throw 'Tidak bisa membuka ${universitas.website}';
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
      },
    );
  }
 
  // Fungsi untuk mengambil data dari API
  Future<DaftarUniversitas> fetchData(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return DaftarUniversitas.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal load');
    }
  }
}
