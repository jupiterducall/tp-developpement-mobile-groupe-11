import 'package:flutter/material.dart ';
import 'package:provider/provider.dart';
import '../viewmodels/ville_viewmodel.dart';
import '../models/ville.dart';
import 'ecran_ajouter_ville.dart';
class EcranListeVilles extends StatelessWidget {
  const EcranListeVilles ({ super.key }) ;
  @override
  Widget build(BuildContext context ) {
// On lit la liste des villes depuis le ViewModel
    final vm = context . watch <VilleViewModel>() ;

    return Scaffold (
      appBar : AppBar (
        title : Text ( ' Choisir une ville ') ,
        backgroundColor : Colors.blue ,
        foregroundColor : Colors.white ,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Ajouter une ville',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EcranAjouterVille()),
              );
            },
          ),
        ],
      ),
      body : ListView . builder (
        itemCount : vm.villes.length ,
        itemBuilder : ( context , index ) {
          final ville = vm.villes[index];
          final ville1 = vm.villes[1];
          final estSelectionnee = ville.nom == vm.villeSelectionnee ?. nom ;

          return ListTile (
            leading : Icon (
              Icons . location_city ,
              color : estSelectionnee ? Colors.blue : Colors.grey,
            ) ,
            title : Text (
              ville . nom ,
              style : TextStyle (
                fontWeight : estSelectionnee
                    ? FontWeight . bold
                    : FontWeight . normal ,
              ) ,
            ) ,
            subtitle : Text( '${ville.pays} - ${ville.temperature}C ') ,
            trailing : estSelectionnee
                ? Icon ( Icons.check_circle , color : Colors.blue)
                : null ,
            onTap : () {
// Utiliser context . read () pour appeler une action
              if(TextButton == 'Parakou'){
                context.read<VilleViewModel>().selectionnerVille (ville1);
                Navigator.pop(context) ; // revenir a l ' ecranprecedent
              }
              else{
                context.read<VilleViewModel>().selectionnerVille (ville);
                Navigator.pop(context) ; // revenir a l ' ecranprecedent
              }
            },
          ) ;
        } ,
      ) ,
    ) ;
  }
}