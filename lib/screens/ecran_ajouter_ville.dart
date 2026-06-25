import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodel.dart';
import '../models/ville.dart';

class EcranAjouterVille extends StatefulWidget {
  const EcranAjouterVille({super.key});

  @override
  State<EcranAjouterVille> createState() => _EcranAjouterVilleState();
}

class _EcranAjouterVilleState extends State<EcranAjouterVille> {
  // Contrôleurs pour lire ce que l'utilisateur tape
  final _nomController        = TextEditingController();
  final _paysController       = TextEditingController();
  final _temperatureController = TextEditingController();
  final _humiditeController   = TextEditingController();

  // Condition sélectionnée dans le DropdownButton
  String _conditionSelectionnee = 'Ensoleille';

  final List<String> _conditions = [
    'Ensoleille', 'Nuageux', 'Pluvieux', 'Orageux', 'Venteux'
  ];

  // Clé pour valider le formulaire
  final _formKey = GlobalKey<FormState>();

  void _valider() {
    // Vérifie que tous les champs obligatoires sont remplis
    if (_formKey.currentState!.validate()) {
      final nouvelleVille = Ville(
        nom:         _nomController.text.trim(),
        pays:        _paysController.text.trim(),
        temperature: double.parse(_temperatureController.text.trim()),
        condition:   _conditionSelectionnee,
        humidite:    int.parse(_humiditeController.text.trim()),
      );

      // Appel de la méthode du ViewModel
      context.read<VilleViewModel>().ajouterVille(nouvelleVille);

      // Retour à l'écran précédent
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Libérer la mémoire des contrôleurs
    _nomController.dispose();
    _paysController.dispose();
    _temperatureController.dispose();
    _humiditeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une ville'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Champ Nom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom de la ville',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              SizedBox(height: 12),

              // Champ Pays
              TextFormField(
                controller: _paysController,
                decoration: InputDecoration(
                  labelText: 'Pays',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                val == null || val.isEmpty ? 'Champ obligatoire' : null,
              ),
              SizedBox(height: 12),

              // Champ Température
              TextFormField(
                controller: _temperatureController,
                decoration: InputDecoration(
                  labelText: 'Température (°C)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Champ obligatoire';
                  if (double.tryParse(val) == null) return 'Nombre invalide';
                  return null;
                },
              ),
              SizedBox(height: 12),

              // Dropdown Condition
              DropdownButtonFormField<String>(
                value: _conditionSelectionnee,
                decoration: InputDecoration(
                  labelText: 'Condition météo',
                  border: OutlineInputBorder(),
                ),
                items: _conditions.map((c) =>
                    DropdownMenuItem(value: c, child: Text(c))
                ).toList(),
                onChanged: (val) {
                  setState(() => _conditionSelectionnee = val!);
                },
              ),
              SizedBox(height: 12),

              // Champ Humidité
              TextFormField(
                controller: _humiditeController,
                decoration: InputDecoration(
                  labelText: 'Humidité (%)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Champ obligatoire';
                  final n = int.tryParse(val);
                  if (n == null || n < 0 || n > 100) return 'Valeur entre 0 et 100';
                  return null;
                },
              ),
              SizedBox(height: 24),

              // Bouton Valider
              ElevatedButton.icon(
                icon: Icon(Icons.add),
                label: Text('Ajouter la ville'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _valider,
              ),
            ],
          ),
        ),
      ),
    );
  }
}