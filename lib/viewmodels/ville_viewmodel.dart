import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/ville.dart';
import '../models/meteo_data.dart';
import '../models/prevision_jour.dart';
import '../services/meteo_service.dart';

class VilleViewModel extends ChangeNotifier {
  List<Ville> _villes = [];
  Ville? _villeSelectionnee;
  final MeteoService _meteoService = MeteoService();
  MeteoData? _meteoActuelle;
  List<PrevisionJour> _previsions = [];
  bool _chargement = false;
  String? _erreur;

  // ← Cache : ville → (meteo, previsions, heure du chargement)
  final Map<String, (MeteoData, List<PrevisionJour>, DateTime)> _cache = {};

  List<Ville> get villes => _villes;
  Ville? get villeSelectionnee => _villeSelectionnee;
  MeteoData? get meteoActuelle => _meteoActuelle;
  List<PrevisionJour> get previsions => _previsions;
  bool get chargement => _chargement;
  String? get erreur => _erreur;

  VilleViewModel() {
    _initialiser();
  }

  void _initialiser() {
    _villes = [
      Ville(
          nom: 'Cotonou',
          pays: 'Benin',
          temperature: 29,
          condition: 'Ensoleille',
          humidite: 75),
      Ville(
          nom: 'Parakou',
          pays: 'Benin',
          temperature: 32,
          condition: 'Ensoleille',
          humidite: 60),
      Ville(
          nom: 'Lagos',
          pays: 'Nigeria',
          temperature: 31,
          condition: 'Nuageux',
          humidite: 80),
      Ville(
          nom: 'Abidjan',
          pays: 'CI',
          temperature: 27,
          condition: 'Pluvieux',
          humidite: 85),
      Ville(
          nom: 'Lomé',
          pays: 'Togo',
          temperature: 28,
          condition: 'Orageux',
          humidite: 90),
      Ville(
          nom: 'Dakar',
          pays: 'Sénégal',
          temperature: 26,
          condition: 'Venteux',
          humidite: 70),
    ];
    _villeSelectionnee = _villes.first;
    notifyListeners();
  }

  Future<void> selectionnerVille(Ville ville) async {
    _villeSelectionnee = ville;
    _erreur = null;

    // Vérifier si le cache est valide (moins de 30 minutes)
    final cacheExistant = _cache[ville.nom];
    if (cacheExistant != null) {
      final dureeEcoulee = DateTime.now().difference(cacheExistant.$3);
      if (dureeEcoulee.inMinutes < 30) {
        if (kDebugMode) {
          print(
              '[CACHE] Données de ${ville.nom} depuis le cache (${dureeEcoulee.inMinutes} min)');
        }
        _meteoActuelle = cacheExistant.$1;
        _previsions = cacheExistant.$2;
        notifyListeners();
        _verifierAlerteChaleur();
        return;
      }
    }

    if (kDebugMode) {
      print('[CACHE] Chargement depuis l\'API pour ${ville.nom}');
    }
    _chargement = true;
    notifyListeners();

    try {
      final (meteo, previsions) = await _meteoService.getMeteo(ville.nom);

      if (meteo != null) {
        _meteoActuelle = meteo;
        _previsions = previsions;
        _cache[ville.nom] = (meteo, previsions, DateTime.now());
        await _verifierAlerteChaleur();
      } else {
        _erreur = 'Impossible de charger la météo';
      }
    } catch (e) {
      _erreur = 'Une erreur est survenue';
    } finally {
      _chargement = false;
      notifyListeners();
    }
  }

  void ajouterVille(Ville ville) {
    _villes.add(ville);
    notifyListeners();
  }

  void mettreAJourPhoto(String cheminPhoto) {
    if (_villeSelectionnee == null) return;
    final index = _villes.indexWhere((v) => v.nom == _villeSelectionnee!.nom);
    if (index == -1) return;

    _villes[index] = _villes[index].copierAvecPhoto(cheminPhoto);
    _villeSelectionnee = _villes[index];
    notifyListeners();
  }

  Future<void> _verifierAlerteChaleur() async {
    if (_meteoActuelle == null) return;
    if (_meteoActuelle!.temperature > 33) {
      final plugin = FlutterLocalNotificationsPlugin();

      const androidDetails = AndroidNotificationDetails(
        'canal_alerte',
        'Alertes Meteo',
        importance: Importance.high,
        priority: Priority.high,
      );

      const notificationDetails = NotificationDetails(android: androidDetails);

      await plugin.show(
        1,
        'Alerte chaleur !',
        'Il fait ${_meteoActuelle!.temperature.toStringAsFixed(0)}°C à ${_villeSelectionnee!.nom}',
        notificationDetails,
      );
    }
  }
}
