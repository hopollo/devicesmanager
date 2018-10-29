Devices Manager
================
Gestionnaire de fichiers d'une série d'outils amovibles.

## Fonctionnalités :
 - **Ajouts** : ajouter les fichiers/dossiers au lot d'appareils.
 - **Suppression** : supprimez les fichiers/dossiers au lot d'appareils.
 - **Script** : pré-définissez tous les mouvements de fichiers/dossiers à appliquer au lot d'appareils.
 
## Téléchargements : 
[Exécutables pour Windows disponibles dans la section Releases](https://github.com/hopollo/devicesmanager/releases).

## Histoire :
Devices Manager a été creer pour répondre à la demande de professeurs et documentalistes utilisant un grand nombre des liseuses (Cybooks).
La problématique était que manuellement ils faisaient les suppressions/ajouts de certain fichiers dans toutes leurs liseuses une par une.
Ma solution est donc d'avoir mis en place un programme permettant de faire ça automatiquement.

### Pré-requis :
Les appareils amovibles visés doivent avoir exactement le même nom, exemple : Cybook (H:), Cybook (P:), Cybook (L:)

### API
Avec Devices Manager, il est possible de créer son propre script d'instructions de mouvements de donnés à appliquer aux autres appareils du meme type.

Remarque : L'ajout/suppression de dossiers multiples est uniquement possible par écriture de script.
    
    References (Important : Attention aux majuscules et espaces)
    * Mise en place d'une destination : Il s'agit de préciser la destination de toutes les liseuses.
      "= Destination\dans\vos\appareils"
    
    * Ajouts fichier(s) ou dossier(s) : 
      "+ C:\Chemin\des\fichiers\fichier.txt" ou "+ C:\Chemin\des\dossiers\a\ajouter"
   
    * Suppressions fichier(s) ou dossier(s) :
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
