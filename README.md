Devices Manager
================
Gestionnaire de fichiers d'une série d'outils amovibles.

## Téléchargements : 
[Exécutables pour Windows disponibles dans la section Releases](https://github.com/hopollo/devicesmanager/releases).

## Fonctionnalités :
 - **Ajouts** : ajouter les fichiers/dossiers au lot d'appareils.
 - **Suppressions** : supprimer les fichiers/dossiers du lot d'appareils.
 - **Repeat ou Script** : effectuer une deuxième passe similaire ou pré-définissez les mouvements de fichiers/dossiers à appliquer au lot d'appareils.
 
## Bugs : 
[Signaler un bug](https://github.com/hopollo/devicesmanager/issues/new) ou [Consulter les bugs connus](https://github.com/hopollo/devicesmanager/issues)

## Histoire :
Devices Manager a été crée pour répondre à la demande de professeurs et documentalistes utilisant un grand nombre des liseuses (Cybooks).
Le transfert des fichiers était fait manuellement liseuses par liseuses 30 fois.
Cet outils permet d'automatiser ces transferts sur une série d'appareils similaires d'une traire ou en plusieurs passes.

### Pré-requis :
Les appareils amovibles visés doivent avoir exactement le même nom, exemple : Cybook (H:), Cybook (P:), Cybook (L:)

### API
Avec Devices Manager, il est possible de créer son propre script d'instructions de mouvements de données à appliquer aux autres appareils du meme type.

Remarque : L'ajout/suppression de dossiers multiples est uniquement possible par écriture de script.
    
    References (Important : Attention aux majuscules et espaces)
    
    Mise en place d'une destination : Il s'agit de préciser la destination de toutes les liseuses.
      "= Destination\dans\vos\appareils"
    
    Ajouts fichier(s) ou dossier(s) : 
      "+ C:\Chemin\des\fichiers\fichier.txt" ou "+ C:\Chemin\des\dossiers\a\ajouter"
   
    Suppressions fichier(s) ou dossier(s) :
      "- Source\des\fichiers\ciblés\aSupprimer.img ou "- \Source\des\dossiers\a\supprimer\"

  Exemple complet :
  ```
    = \Destination\dans\mes\liseuses
    - fichier_1_Deja_Present.txt
    - \Destination\dans\mes\liseuses\fichier_2_Deja_Present.txt
    + C:\Chemin\des\fichiers\fichier_3.txt
    + C:\Chemin\des\fichiers\fichier_4.txt
    + C:\Chemin\du\dossier_1
    = \Autre\Destination\dans\mes\liseuses
    + C:\Chemin\des\fichiers\photo_1.img
  ```
 
## Contribution :
Vous souhaitez soutenir le project ? Des options s'offrent à vous : 
- **Signalements** aider à la chasse bugs
- **Partages** faire connaitre l'outil et développer une communauté
- **Former** aider les autres à utiliser l'outil
- **Pull-request** apporter des suggestions de code

### Me soutenir :
[Faire un don](https://streamelements.com/hopollo/tip)
