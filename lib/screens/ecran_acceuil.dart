import 'package:flutter/material.dart ';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodel.dart';
import 'ecran_liste_villes.dart';
class EcranAccueil extends StatelessWidget{
  const EcranAccueil ({ super.key }) ;
// Retourne une icone selon la condition meteo
  IconData _iconeMeteo ( String condition ) {
    switch ( condition ) {
      case ' Ensoleille ': return Icons . wb_sunny ;
      case ' Nuageux ': return Icons.water;
      case ' Pluvieux ': return Icons . umbrella_rounded ;
      //Exercice complmentaire
      case 'Orageux': return Icons.thunderstorm;
      case 'Venteux': return Icons.air;
      default : return Icons . wb_cloudy ;
    }
  }
  Color _couleurFond(String condition) {
    switch (condition) {
      case 'Ensoleille': return Colors.orange.shade100;
      case 'Nuageux':    return Colors.grey.shade200;
      case 'Pluvieux':   return Colors.blue.shade100;
      case 'Orageux':    return Colors.deepPurple.shade100;
      case 'Venteux':    return Colors.teal.shade100;
      default:           return Colors.white;
    }
  }
  @override
  Widget build ( BuildContext context ) {
    // On lit les donnees depuis le ViewModel
    final vm = context . watch < VilleViewModel >() ;
    final ville = vm . villeSelectionnee ;

    return Scaffold (
      appBar : AppBar (
        title : Text ( ' App Meteo ') ,
        backgroundColor : Colors . green ,
        foregroundColor : Colors . white ,
      ) ,
      body: ville == null
          ? Center(child: CircularProgressIndicator())
          : Container(                              // ← nouveau
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: _couleurFond(ville.condition), // ← couleur dynamique
        ),
        child: Column(                        // ← la Column est maintenant enfant
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _iconeMeteo(ville.condition),
              size: 100,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Consumer<VilleViewModel>(
              builder: (context, vm, _) {
                if (vm.chargement) {
                  return CircularProgressIndicator();
                }
                if (vm.erreur != null) {
                  return Column(children: [
                    Icon(Icons.wifi_off, size: 60, color: Colors.red),
                    Text(vm.erreur!, style: TextStyle(color: Colors.red)),
                    ElevatedButton(
                      onPressed: () => vm.selectionnerVille(vm.villeSelectionnee!),
                      child: Text('Réessayer'),
                    ),
                  ]);
                }
                final meteo = vm.meteoActuelle;
                if (meteo == null) return Text('Chargement...');

                return Column(children: [
                  Text(
                    '${meteo.temperature.toStringAsFixed(1)}°C',
                    style: TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${meteo.conditionTexte} - ${meteo.humidite}% humidité',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    meteo.heureFormatee, // ← nouveau
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),

                  // ← Prévisions 3 jours
                  SizedBox(
                    height: 100,
                    child: Center(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true, // ← prend uniquement la largeur nécessaire
                        itemCount: vm.previsions.length,
                        itemBuilder: (context, index) {
                          final p = vm.previsions[index];
                          return Container(
                            width: 90,
                            margin: EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(p.dateFormatee,
                                    style: TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text(p.conditionTexte,
                                  style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 4),
                                Text('↑${p.tempMax.toStringAsFixed(0)}° ↓${p.tempMin.toStringAsFixed(0)}°',
                                    style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ]);
              },
            ),
            Text(
              ville.nom,
              style: TextStyle(fontSize: 28, color: Colors.grey[700]),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              icon: Icon(Icons.list),
              label: Text('Changer de ville'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EcranListeVilles()),
                );
              },
            ),
          ],
        ),
      ),
      );
    }
  }