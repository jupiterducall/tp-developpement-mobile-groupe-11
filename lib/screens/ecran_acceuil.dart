import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/localisation_service.dart';
import '../services/meteo_service.dart';
import '../viewmodels/ville_viewmodel.dart';
import 'ecran_liste_villes.dart';

class EcranAccueil extends StatelessWidget {
  const EcranAccueil({super.key});

  IconData _iconeMeteo(String condition) {
    switch (condition) {
      case 'Ensoleille':
        return Icons.wb_sunny;
      case 'Nuageux':
        return Icons.wb_cloudy;
      case 'Pluvieux':
        return Icons.umbrella_rounded;
      case 'Orageux':
        return Icons.thunderstorm;
      case 'Venteux':
        return Icons.air;
      default:
        return Icons.wb_cloudy;
    }
  }

  Color _couleurFond(String condition) {
    switch (condition) {
      case 'Ensoleille':
        return Colors.orange.shade100;
      case 'Nuageux':
        return Colors.grey.shade200;
      case 'Pluvieux':
        return Colors.blue.shade100;
      case 'Orageux':
        return Colors.deepPurple.shade100;
      case 'Venteux':
        return Colors.teal.shade100;
      default:
        return Colors.white;
    }
  }

  // Exercice A : Menu pour choisir entre Galerie et Caméra
  void _afficherMenuPhoto(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  _prendrePhoto(context, ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Appareil photo'),
                onTap: () {
                  _prendrePhoto(context, ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _prendrePhoto(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null && context.mounted) {
        context.read<VilleViewModel>().mettreAJourPhoto(image.path);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VilleViewModel>();
    final ville = vm.villeSelectionnee;

    return Scaffold(
      appBar: AppBar(
        title: const Text("App Meteo"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: ville == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Container(
                width: double.infinity,
                color: _couleurFond(ville.condition),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () => _afficherMenuPhoto(context),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _buildImageWidget(ville.photoPath),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Icon(
                          _iconeMeteo(ville.condition),
                          size: 100,
                          color: Colors.orange,
                        ),
                        const SizedBox(height: 20),
                        _buildMeteoDetails(context, vm),
                        const SizedBox(height: 25),
                        Text(
                          ville.nom,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        // Exercice B : Affichage des coordonnées GPS
                        _buildCoordonnees(ville.nom),
                        const SizedBox(height: 25),
                        _buildButtons(context),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildCoordonnees(String nomVille) {
    final coords = MeteoService.coords[nomVille];
    if (coords == null) return const SizedBox.shrink();

    return Text(
      "Lat: ${coords[0].toStringAsFixed(4)}, Lon: ${coords[1].toStringAsFixed(4)}",
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildImageWidget(String? photoPath) {
    if (photoPath == null) {
      return Container(
        width: double.infinity,
        height: 200,
        color: Colors.grey[200],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
            Text('Appuyez pour ajouter une photo'),
          ],
        ),
      );
    }

    if (kIsWeb ||
        photoPath.startsWith('http') ||
        photoPath.startsWith('blob:')) {
      return Image.network(
        photoPath,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 50),
      );
    }

    return Image.file(
      File(photoPath),
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 50),
    );
  }

  Widget _buildMeteoDetails(BuildContext context, VilleViewModel vm) {
    if (vm.chargement) {
      return const CircularProgressIndicator();
    }

    if (vm.erreur != null) {
      return Column(
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 10),
          Text(vm.erreur!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => vm.selectionnerVille(vm.villeSelectionnee!),
            child: const Text("Réessayer"),
          ),
        ],
      );
    }

    final meteo = vm.meteoActuelle;
    if (meteo == null) return const Text("Chargement...");

    return Column(
      children: [
        Text(
          "${meteo.temperature.toStringAsFixed(1)}°C",
          style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          "${meteo.conditionTexte} - ${meteo.humidite}% humidité",
          style: const TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 25),
        // Prévisions centrées
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: vm.previsions.map((p) {
              return Container(
                width: 100,
                height: 120,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      p.dateFormatee,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      p.conditionTexte,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "↑${p.tempMax.toStringAsFixed(0)}° ↓${p.tempMin.toStringAsFixed(0)}°",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.location_city),
            label: const Text("Changer de ville"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EcranListeVilles()),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 250,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.my_location),
            label: const Text('Ville la plus proche'),
            onPressed: () async {
              try {
                final service = LocalisationService();
                final position = await service.getPosition();

                if (position != null && context.mounted) {
                  final vm = context.read<VilleViewModel>();
                  final villeProche = service.trouverVilleProche(
                      position, vm.villes, MeteoService.coords);

                  if (villeProche != null) {
                    vm.selectionnerVille(villeProche);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Ville proche : ${villeProche.nom}')),
                    );
                  }
                } else if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Position introuvable. Vérifiez votre GPS.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erreur GPS : $e')),
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
