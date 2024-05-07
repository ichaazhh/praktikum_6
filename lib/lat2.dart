import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

// Model untuk menyimpan data universitas
class University {
  final String name;
  final List<String> domains;
  final List<String> webPages;

  University({
    required this.name,
    required this.domains,
    required this.webPages,
  });

  // Factory method untuk membuat objek University dari JSON
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      domains: List<String>.from(json['domains']),
      webPages: List<String>.from(json['web_pages']),
    );
  }
}

// Events
abstract class UniversityEvent {}

// Event untuk mengambil daftar universitas berdasarkan negara
class FetchUniversitiesEvent extends UniversityEvent {
  final String country;
  FetchUniversitiesEvent(this.country);
}

// Bloc
class UniversityBloc extends Bloc<UniversityEvent, List<University>> {
  UniversityBloc() : super([]) {
    on<FetchUniversitiesEvent>(_fetchUniversities);
  }

  // Method internal untuk mengambil daftar universitas dari API
  Future<void> _fetchUniversities(
    FetchUniversitiesEvent event,
    Emitter<List<University>> emit,
  ) async {
    try {
      final universities = await _fetchUniversitiesFromApi(event.country);
      emit(universities);
    } catch (e) {
      print('Error: $e');
      emit([]);
    }
  }

  Future<List<University>> _fetchUniversitiesFromApi(String country) async {
    final response = await http.get(
      Uri.parse('http://universities.hipolabs.com/search?country=$country'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => University.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UniversityBloc(),
        child: UniversitiesPage(),
      ),
    );
  }
}

class UniversitiesPage extends StatefulWidget {
  @override
  _UniversitiesPageState createState() => _UniversitiesPageState();
}

class _UniversitiesPageState extends State<UniversitiesPage> {
  final List<String> _aseanCountries = [
    'Indonesia',
    'Singapore',
    'Malaysia',
    'Thailand',
    'Philippines',
    'Vietnam',
    'Myanmar',
    'Cambodia',
    'Brunei',
    'Laos',
  ];

  String _selectedCountry = 'Indonesia';

  @override
  void initState() {
    super.initState();
    // Mengirim event FetchUniversitiesEvent saat halaman dimuat pertama kali
    context.read<UniversityBloc>().add(FetchUniversitiesEvent(_selectedCountry));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Universitas ASEAN'),
      ),
      body: Column(
        children: [
          // Dropdown untuk memilih negara ASEAN
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.orange, // Warna latar belakang hijau
                borderRadius: BorderRadius.circular(30), // Sudut bulat dengan border radius 30
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<String>(
                value: _selectedCountry,
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCountry = newValue!;
                    // Mengirim event FetchUniversitiesEvent saat negara dipilih ulang
                    context.read<UniversityBloc>().add(FetchUniversitiesEvent(newValue));
                  });
                },
                style: TextStyle(color: Colors.white, fontSize: 16.0),
                dropdownColor: Colors.orange, // Warna latar belakang dropdown hijau
                icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Icon panah dropdown putih
                iconSize: 36,
                underline: Container(), // Menghilangkan garis bawah default
                items: _aseanCountries.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        color: Colors.white, // Warna teks putih
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Menampilkan daftar universitas berdasarkan negara
          BlocBuilder<UniversityBloc, List<University>>(
            builder: (context, universities) {
              if (universities.isEmpty) {
                return CircularProgressIndicator();
              }
              return Expanded(
                child: Container(
                  child: ListView.builder(
                    itemCount: universities.length,
                    itemBuilder: (context, index) {
                      final university = universities[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          color: Color.fromARGB(255, 7, 87, 121), // Warna latar belakang biru
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  university.name,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Row(
                                  children: [
                                    Text(
                                      'Domains: ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    Text(
                                      university.domains.join(', '),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.0),
                                Row(
                                  children: [
                                    Text(
                                      university.webPages.join(', '),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18.0,// Font size URL website
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
