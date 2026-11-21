// weather_screen.dart
// Halaman cuaca: input nama kota -> panggil WeatherService -> tampilkan hasil.

import 'package:flutter/material.dart';

import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final _service = WeatherService();
  final _controller = TextEditingController(text: 'Medan'); // kota default
  String _result = 'Belum ada data';
  bool _loading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Mengambil data cuaca lalu memperbarui tampilan.
  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchWeather(_controller.text);
      final temp = data['main']['temp'];
      final desc = data['weather'][0]['description'];
      if (!mounted) return;
      setState(() => _result = '$temp °C, $desc');
    } catch (e) {
      // Pesan error (401/404/dll) ditampilkan langsung ke pengguna.
      if (!mounted) return;
      setState(() => _result = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cuaca (Third Party API)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Kota'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _loading ? null : _load,
            child: const Text('Cari'),
          ),
          const SizedBox(height: 24),
          // Loading spinner saat menunggu, hasil teks setelahnya.
          _loading ? const CircularProgressIndicator() : Text(_result),
        ]),
      ),
    );
  }
}
