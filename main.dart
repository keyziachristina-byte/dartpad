import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// ===================== MODEL =====================
class Mahasiswa {
  final String nim;
  final String nama;
  final String prodi;
  final String kelas;

  const Mahasiswa({
    required this.nim,
    required this.nama,
    required this.prodi,
    required this.kelas,
  });
}

// ===================== APP =====================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Data Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const DataMahasiswaPage(),
    );
  }
}

// ===================== DAFTAR MAHASISWA =====================
class DataMahasiswaPage extends StatefulWidget {
  const DataMahasiswaPage({super.key});

  @override
  State<DataMahasiswaPage> createState() => _DataMahasiswaPageState();
}

class _DataMahasiswaPageState extends State<DataMahasiswaPage> {
  final List<Mahasiswa> _daftar = [
    const Mahasiswa(
        nim: '231001', nama: 'Andi Saputra', prodi: 'Informatika', kelas: 'TI-3A'),
    const Mahasiswa(
        nim: '231002', nama: 'Budi Santoso', prodi: 'Informatika', kelas: 'TI-3A'),
    const Mahasiswa(
        nim: '231003', nama: 'Citra Lestari', prodi: 'Informatika', kelas: 'TI-3B'),
    const Mahasiswa(
        nim: '231004', nama: 'Dewi Anggraini', prodi: 'Sistem Informasi', kelas: 'SI-3A'),
    const Mahasiswa(
        nim: '231005', nama: 'Eko Prasetyo', prodi: 'Sistem Informasi', kelas: 'SI-3B'),
  ];

  final _cariController = TextEditingController();
  String _kataKunci = '';
  String _prodiDipilih = 'Semua';
  final List<String> _opsiProdi = [
    'Semua',
    'Informatika',
    'Sistem Informasi',
    'Teknik Komputer',
  ];

  @override
  void dispose() {
    _cariController.dispose();
    super.dispose();
  }

  // TAHAP 7: filter berdasarkan nama atau NIM
  List<Mahasiswa> get _hasilFilter {
    final kunci = _kataKunci.toLowerCase();
    return _daftar.where((m) {
      final cocokCari =
          m.nama.toLowerCase().contains(kunci) || m.nim.contains(kunci);
      final cocokProdi = _prodiDipilih == 'Semua' || m.prodi == _prodiDipilih;
      return cocokCari && cocokProdi;
    }).toList();
  }

  Future<void> _tambahMahasiswa() async {
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(builder: (context) => const FormMahasiswaPage()),
    );

    if (hasil != null) {
      setState(() {
        _daftar.add(hasil);
      });
    }
  }

  Future<void> _lihatDetail(Mahasiswa mhs) async {
    final hasil = await Navigator.push<Object>(
      context,
      MaterialPageRoute(builder: (context) => DetailMahasiswaPage(mahasiswa: mhs)),
    );

    // TAHAP 5: data hasil edit menggantikan data lama
    if (hasil is Mahasiswa) {
      setState(() {
        final index = _daftar.indexOf(mhs);
        _daftar[index] = hasil;
      });
    } else if (hasil == 'hapus') {
      // TAHAP 6: data dikeluarkan dari daftar
      setState(() {
        _daftar.remove(mhs);
      });
    }
  }

  Widget _buildList(List<Mahasiswa> tampil) {
    // Empty state
    if (tampil.isEmpty) {
      return const Center(child: Text('Belum ada data mahasiswa'));
    }
    return ListView.builder(
      itemCount: tampil.length,
      itemBuilder: (context, index) {
        final mhs = tampil[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: CircleAvatar(child: Text(mhs.nama[0])),
            title: Text('${mhs.nim}  ${mhs.nama}'),
            subtitle: Text('${mhs.prodi}\n${mhs.kelas}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _lihatDetail(mhs),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tampil = _hasilFilter;

    return Scaffold(
      appBar: AppBar(title: const Text('Data Mahasiswa')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _tambahMahasiswa,
                icon: const Icon(Icons.add),
                label: const Text('Tambah Mahasiswa'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _cariController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Cari nama atau NIM...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _kataKunci = value.trim();
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: Row(
              children: [
                // Jumlah mahasiswa
                Expanded(
                  child: Text(
                    'Total Mahasiswa: ${_daftar.length}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Filter program studi
                DropdownButton<String>(
                  value: _prodiDipilih,
                  items: _opsiProdi
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _prodiDipilih = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(child: _buildList(tampil)),
        ],
      ),
    );
  }
}

// ===================== FORM (TAMBAH & EDIT) =====================
class FormMahasiswaPage extends StatefulWidget {
  final Mahasiswa? mahasiswa; // null = tambah, ada isi = edit

  const FormMahasiswaPage({super.key, this.mahasiswa});

  @override
  State<FormMahasiswaPage> createState() => _FormMahasiswaPageState();
}

class _FormMahasiswaPageState extends State<FormMahasiswaPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nimController;
  late final TextEditingController _namaController;
  late final TextEditingController _prodiController;
  late final TextEditingController _kelasController;

  bool get _modeEdit => widget.mahasiswa != null;

  @override
  void initState() {
    super.initState();
    // Data lama otomatis muncul pada form saat mode edit
    _nimController = TextEditingController(text: widget.mahasiswa?.nim ?? '');
    _namaController = TextEditingController(text: widget.mahasiswa?.nama ?? '');
    _prodiController = TextEditingController(text: widget.mahasiswa?.prodi ?? '');
    _kelasController = TextEditingController(text: widget.mahasiswa?.kelas ?? '');
  }

  @override
  void dispose() {
    _nimController.dispose();
    _namaController.dispose();
    _prodiController.dispose();
    _kelasController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final mhs = Mahasiswa(
        nim: _nimController.text.trim(),
        nama: _namaController.text.trim(),
        prodi: _prodiController.text.trim(),
        kelas: _kelasController.text.trim(),
      );
      Navigator.pop(context, mhs);
    }
  }

  String? _wajibIsi(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label wajib diisi';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modeEdit ? 'Form Edit Mahasiswa' : 'Form Tambah Mahasiswa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nimController,
                decoration: const InputDecoration(
                    labelText: 'NIM', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'NIM'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                    labelText: 'Nama', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'Nama'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _prodiController,
                decoration: const InputDecoration(
                    labelText: 'Program Studi', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'Program Studi'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _kelasController,
                decoration: const InputDecoration(
                    labelText: 'Kelas', border: OutlineInputBorder()),
                validator: (v) => _wajibIsi(v, 'Kelas'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _simpan,
                  child: Text(_modeEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ===================== DETAIL MAHASISWA =====================
class DetailMahasiswaPage extends StatelessWidget {
  final Mahasiswa mahasiswa;

  const DetailMahasiswaPage({super.key, required this.mahasiswa});

  Widget _item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // TAHAP 5: buka form edit, lalu kirim hasilnya kembali ke daftar
  Future<void> _edit(BuildContext context) async {
    final hasil = await Navigator.push<Mahasiswa>(
      context,
      MaterialPageRoute(
          builder: (context) => FormMahasiswaPage(mahasiswa: mahasiswa)),
    );

    if (hasil != null && context.mounted) {
      Navigator.pop(context, hasil);
    }
  }

  // TAHAP 6: dialog konfirmasi sebelum menghapus
  Future<void> _hapus(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Data'),
        content: const Text('Apakah Anda yakin ingin menghapus data ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true && context.mounted) {
      Navigator.pop(context, 'hapus');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Mahasiswa')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _item('NIM', mahasiswa.nim),
            _item('Nama', mahasiswa.nama),
            _item('Program Studi', mahasiswa.prodi),
            _item('Kelas', mahasiswa.kelas),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _edit(context),
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _hapus(context),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
