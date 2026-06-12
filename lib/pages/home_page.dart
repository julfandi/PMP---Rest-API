import 'package:flutter/material.dart';
import '../models/mahasiswa.dart';
import '../services/api_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();  
}

class _HomePageState extends State<HomePage>{
  final nimController = TextEditingController();
  final namaController = TextEditingController();

  List<Mahasiswa> mahasiswaList = [];

  bool isLoading = true;

  @override
    void initState() {
      super.initState();
      getData();
    }

    Future<void> getData() async {
      setState(() {
        isLoading = true;
      });

    try {
      mahasiswaList = await ApiServices.getMahasiswa();
    } catch (e) {
      ScaffoldMessenger.of(context)
            .showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> tambahData() async {
    if (nimController.text.isEmpty || namaController.text.isEmpty){
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data Wajib di isi')));
      return;
    }

    bool success = await ApiServices.tambahMahasiswa(
      nim: nimController.text, 
      nama: namaController.text,
    );

    if(success) {
      nimController.clear();
      namaController.clear();

      getData();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data Berhasil di simpan')));
    } else {
       ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Gagal Menyimpan data')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API FLUTTER'),
      ),

      body: RefreshIndicator(
        onRefresh: getData,
          child: Padding(
            padding: const EdgeInsets.all(16),
              child: Column(
                children: [


                  TextField(
                    controller: nimController,
                    decoration: const InputDecoration(
                      labelText: 'NIM',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller:  namaController,
                    decoration: const InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder()
                    ),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: tambahData, child: const Text('Simpan')),
                  ),

                  const SizedBox(height: 20,),
                  Expanded(child: isLoading ? const Center(
                    child: CircularProgressIndicator(),
                  ): ListView.builder(
                    itemCount: mahasiswaList.length,
                    itemBuilder: (context, index) {
                      final data = mahasiswaList[index];

                      return Card(
                        child:
                            ListTile(
                              leading: CircleAvatar(
                                child: Text('${data.id}'),
                              ),
                              title:  Text(data.nama),
                              subtitle: Text(data.nim),
                            ) ,
                      );
                    }                  
                  )
                )
              ],            
            ),
          ),
        ),
     );
  }
}