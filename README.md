# Devices Manager

## Mission 
Devices Manager a été creer pour répondre à la demande de professeurs et documentalistes utilisant un grand nombre des liseuses (Cybooks).
La problématique était que manuellement ils faisaient les suppressions/ajouts de certain fichiers dans toutes leurs liseuses une par une.
Ma solution est donc d'avoir mis en place un programme permettant de faire ça automatiquement.

## Comment ça marche
- Branchez vos liseuses. (Remarque : Vos liseuses doivent imperativement porter le même nom exemple H:/Cybook, P:/Cybook, L:Cybook)
- Lancez le programme (Remarque : Le nom du programme sera composé par la suite du nom de vos appareils, exemple Cybook Manager)
- Choisiez une action, et attendez la fin des exécutions.

## API
  Avec Devices Manager, il est possible de creer son propre script d'instructions afin d'y avoir un nombre illimité d'ajouts et suppréssions dans une même boucle.

  Remarque : L'ajout/suppression de dossiers multiples est uniquement possible par écriture de script.
    
    References (Important : Attention aux majuscules et espaces)
    * Mse en place d'une destination : Il s'agit de préciser la destination de toutes les liseuses.
      "= Destination\dans\vos\appareils"
    
    * Ajouts fichier(s) ou dossier(s) : 
      "+ C:\Chemin\des\fichiers\fichier.txt" ou "+ C:\Chemin\des\dossiers\a\ajouter"
   
    * Suppressions fichier(s) ou dossier(s) :
      "- Source\des\fichiers\ciblés\aSupprimer.img ou "- \Source\des\dossiers\a\supprimer\"

  Remarque : La lecture de script se fait de haut en bas, ligne par ligne, vous pouvez donc combiner plusieurs instructions différentes comme :
  
    = \Destination\dans\mes\liseuses
    - fichier_1_Deja_Present.txt
    - \Destination\dans\mes\liseuses\fichier_2_Deja_Present.txt
    + C:\Chemin\des\fichiers\fichier_3.txt
    + C:\Chemin\des\fichiers\fichier_4.txt
    + C:\Chemin\du\dossier_1
    = \Autre\Destination\dans\mes\liseuses
    + C:\Chemin\des\fichiers\photo_1.img
