// campus_map.dart
// Peta interaktif memakai flutter_map + OpenStreetMap (tanpa API key).
// Berisi 3 marker; saat diketuk muncul SnackBar berisi nama lokasi.
// CATATAN: koordinat di bawah hanya contoh, ganti dengan lokasi pilihan Anda
// (klik kanan di openstreetmap.org / Google Maps untuk menyalin koordinat).

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// Model sederhana untuk sebuah lokasi.
class _Place {
  final String name;
  final LatLng point;
  const _Place(this.name, this.point);
}

// Daftar lokasi yang ditampilkan sebagai marker.
const _places = [
  _Place('Kampus', LatLng(-6.2088, 106.8456)),
  _Place('Perpustakaan', LatLng(-6.2095, 106.8470)),
  _Place('Kantin', LatLng(-6.2080, 106.8440)),
];

class CampusMap extends StatelessWidget {
  const CampusMap({super.key});

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      // Pusat & zoom awal peta.
      options: MapOptions(
        initialCenter: _places.first.point,
        initialZoom: 15,
      ),
      children: [
        // Lapisan gambar peta (tile) dari OpenStreetMap.
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'del.ac.id.pam_notes',
        ),
        // Lapisan marker; tiap lokasi dibungkus GestureDetector agar bisa diketuk.
        MarkerLayer(
          markers: _places
              .map(
                (p) => Marker(
                  point: p.point,
                  width: 44,
                  height: 44,
                  child: GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(p.name)),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 44,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        // Atribusi wajib sesuai lisensi OpenStreetMap.
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap contributors'),
          ],
        ),
      ],
    );
  }
}
