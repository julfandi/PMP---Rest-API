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
  bool isEdit = false; // ini untuk tombol contoh
  int? selectedId; // ini untuk id yang di pilih

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

    // edit mode
    if (isEdit) {
      bool success = await ApiServices.updateMahasiswa(
        id: selectedId!, 
        nim: nimController.text, 
        nama: namaController.text,
      );

      if(success) {
        setState(() {
          isEdit = false; // kalau edit berhasil jadi tombol simpan
          selectedId = null;
        });
        // ketika tombol edit di tekan maka controller akan di isi 
        nimController.clear();
        namaController.clear();
        getData();

        // messsage
        ScaffoldMessenger.of(
          context,
          ).showSnackBar(const SnackBar(content: Text('Data berhasil di update')),
        );
      }
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

  // ini untuk hapus data
  Future<void> hapusData(int id) async {
    bool success = await ApiServices.deleteMahasiswa(id);

    if(success) {
      getData();
      ScaffoldMessenger.of(
        context,
        ).showSnackBar(const SnackBar(content: Text('Data berhasil di hapus')));
    } else {
      ScaffoldMessenger.of(
        context,
        ).showSnackBar(const SnackBar(content: Text('Data gagal di hapus')));
    }
  }

  // alert dialog untuk hapus data tidak perlu future karena tidak pakai async and await
  void konfirmasiHpus(int id) {
    showDialog(context:  context, builder: (context) {
      return AlertDialog(
        title: const Text('Konfirmasi Hapus Data'),
        content: const Text('Yakin Ingin Menghapus Data?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            } , 
            child: const Text('Batal'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              hapusData(id);
            }, 
              child: const Text('Hapus'),
          )
        ],
      );
    });
  }

  void editData(Mahasiswa data) {
    setState(() {
      isEdit = true;
      selectedId = data.id; 
    });
    nimController.text = data.nim;
    namaController.text = data.nama;
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
                    child: ElevatedButton(onPressed: tambahData, child: Text(isEdit ? 'Update' : 'Simpan')),
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
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      editData(data);
                                    },
                                  ),

                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      konfirmasiHpus(data.id);
                                    },
                                  ),
                                ],
                              ),
                            ) ,
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