import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart'; // untuk ChangeNotifierProvider
import 'package:flutter_bloc/flutter_bloc.dart'; // untuk BlocProvider

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
      website: json['web_pages'][0], // Mendapatkan situs web pertama (jika ada)
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

  List<University> get universities => _universities;

  List<String> get aseanCountries => _aseanCountries;

  String get selectedCountry => _selectedCountry;

  set selectedCountry(String country) {
    _selectedCountry = country;
    fetchData(); // Memanggil kembali fetchData saat negara dipilih berubah
  }
}

// Cubit untuk mengelola state aplikasi
class CountryCubit extends Cubit<String> {
  CountryCubit() : super('Indonesia'); // Default: Indonesia

  void changeCountry(String country) {
    emit(country);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UniversitiesProvider()), // Memberikan akses ke UniversitiesProvider ke dalam widget tree
        BlocProvider(create: (context) => CountryCubit()), // Memberikan akses ke CountryCubit ke dalam widget tree
      ],
      child: MaterialApp(
        title: 'Daftar Universitas',
        home: Scaffold(
          appBar: AppBar(
            title: Text('Daftar Universitas ASEAN'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Combobox untuk memilih negara ASEAN
              Consumer<CountryCubit>(
                builder: (context, countryCubit, _) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.green, // Warna latar belakang hijau
                      borderRadius: BorderRadius.circular(30), // Sudut bulat dengan border radius
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButton<String>(
                      value: countryCubit.state,
                      dropdownColor: Colors.green, // Warna latar belakang dropdown hijau
                      icon: Icon(Icons.arrow_drop_down, color: Colors.white), // Icon panah dropdown putih
                      iconSize: 36,
                      underline: Container(), // Menghilangkan garis bawah default
                      items: context.read<UniversitiesProvider>().aseanCountries.map((country) {
                        return DropdownMenuItem<String>(
                          value: country,
                          child: Text(
                            country,
                            style: TextStyle(
                              color: Colors.white, // Warna teks putih
                              fontSize: 16,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (selectedCountry) {
                        // Memanggil changeCountry pada CountryCubit ketika negara dipilih berubah
                        context.read<CountryCubit>().changeCountry(selectedCountry!);
                        context.read<UniversitiesProvider>().selectedCountry = selectedCountry!;
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              Expanded(
                child: Consumer<UniversitiesProvider>(
                  builder: (context, universitiesProvider, _) {
                    return ListView.builder(
                      itemCount: universitiesProvider.universities.length,
                      itemBuilder: (context, index) {
                        University university = universitiesProvider.universities[index];
                        return Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.orange, // Warna latar belakang card orange
                          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          child: ListTile(
                            title: Text(
                              university.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Warna teks putih
                              ),
                            ),
                            subtitle: Text(
                              university.website,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white, // Warna teks putih
                              ),
                            ),
                            contentPadding: EdgeInsets.all(20),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
