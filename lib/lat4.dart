import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

// Model untuk merepresentasikan informasi universitas
class University {
  String name;
  String website;

  University({required this.name, required this.website});

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0], // Ambil situs web pertama (jika ada)
    );
  }
}

// Kelas provider untuk mengelola state dan data universitas
class UniversitiesProvider extends ChangeNotifier {
  late List<University> _universities;
  List<String> _aseanCountries = [
    'Indonesia',
    'Singapore',
    'Malaysia',
    'Thailand',
    'Vietnam',
    'Philippines',
    'Brunei',
    'Myanmar',
    'Cambodia',
    'Laos'
  ];
  late String _selectedCountry;

  UniversitiesProvider() {
    _universities = [];
    _selectedCountry = _aseanCountries[0]; // Default: Indonesia
    fetchData(); // Memanggil fungsi fetchData saat objek UniversitiesProvider dibuat
  }

  // Fungsi async untuk mengambil data universitas berdasarkan negara yang dipilih
  Future<void> fetchData() async {
    String url = "http://universities.hipolabs.com/search?country=$_selectedCountry";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      _universities = data.map((item) {
        return University.fromJson(item);
      }).toList();

      notifyListeners(); // Memberitahu listener bahwa data telah diperbarui
    } else {
      throw Exception('Gagal load data');
    }
  }

  // Getter untuk mendapatkan list universitas
  List<University> get universities => _universities;

  // Getter untuk mendapatkan list negara ASEAN
  List<String> get aseanCountries => _aseanCountries;

  // Getter untuk mendapatkan negara yang dipilih
  String get selectedCountry => _selectedCountry;

  // Setter untuk mengubah negara yang dipilih dan memanggil fetchData
  set selectedCountry(String country) {
    _selectedCountry = country;
    fetchData(); // Memanggil kembali fetchData saat negara dipilih berubah
  }
}

// MyApp adalah widget utama yang menjalankan aplikasi
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UniversitiesProvider(),
      child: MaterialApp(
        title: 'Daftar Universitas',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Daftar Universitas ASEAN'),
          ),
          body: Consumer<UniversitiesProvider>(
            builder: (context, universitiesProvider, _) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // DropdownButton untuk memilih negara
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButton<String>(
                        value: universitiesProvider.selectedCountry,
                        items: universitiesProvider.aseanCountries.map((country) {
                          return DropdownMenuItem<String>(
                            value: country,
                            child: Text(
                              country,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (selectedCountry) {
                          universitiesProvider.selectedCountry = selectedCountry!;
                        },
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                        iconSize: 36,
                        underline: Container(), // Menghilangkan garis bawah default
                      ),
                    ),
                    SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: universitiesProvider.universities.length,
                        itemBuilder: (context, index) {
                          // Card untuk menampilkan informasi universitas
                          return Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Colors.blue, // Warna latar belakang biru pada card
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: ListTile(
                              title: Text(
                                universitiesProvider.universities[index].name,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white, // Warna teks putih
                                ),
                              ),
                              subtitle: Text(
                                universitiesProvider.universities[index].website,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white, // Warna teks putih
                                ),
                              ),
                              contentPadding: EdgeInsets.all(20),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
