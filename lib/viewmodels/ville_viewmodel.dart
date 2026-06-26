import 'package:flutter/foundation.dart';
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
      Ville(nom: 'Cotonou', pays: 'Benin',    temperature: 29, condition: 'Ensoleille', humidite: 75),
      Ville(nom: 'Parakou', pays: 'Benin',    temperature: 32, condition: 'Ensoleille', humidite: 60),
      Ville(nom: 'Lagos',   pays: 'Nigeria',  temperature: 31, condition: 'Nuageux',    humidite: 80),
      Ville(nom: 'Abidjan', pays: 'CI',       temperature: 27, condition: 'Pluvieux',   humidite: 85),
      Ville(nom: 'Lomé',    pays: 'Togo',     temperature: 28, condition: 'Orageux',    humidite: 90),
      Ville(nom: 'Dakar',   pays: 'Sénégal',  temperature: 26, condition: 'Venteux',    humidite: 70),
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
        // ← Utiliser le cache
        print('[CACHE] Données de ${ville.nom} depuis le cache (${dureeEcoulee.inMinutes} min)');
        _meteoActuelle = cacheExistant.$1;
        _previsions    = cacheExistant.$2;
        notifyListeners();
        return; // ← On arrête ici, pas d'appel API
      }
    }

    // Cache absent ou expiré → appel API
    print('[CACHE] Chargement depuis l\'API pour ${ville.nom}');
    _chargement = true;
    notifyListeners();

    final (meteo, previsions) = await _meteoService.getMeteo(ville.nom);

    if (meteo != null) {
      _meteoActuelle = meteo;
      _previsions    = previsions;
      // ← Sauvegarder dans le cache avec l'heure actuelle
      _cache[ville.nom] = (meteo, previsions, DateTime.now());
    } else {
      _erreur = 'Impossible de charger la meteo';
    }
    _chargement = false;
    notifyListeners();
  }

  void ajouterVille(Ville ville) {
    _villes.add(ville);
    notifyListeners();
  }
}