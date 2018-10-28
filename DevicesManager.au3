#include <File.au3>
#include <MsgBoxConstants.au3>
#include <WinAPIFiles.au3>
#include <Array.au3>
#include <FileConstants.au3>

;#RequireAdmin

Global $devicesTarget = 'Cybook'
Global $author = "@HoPolloTV"
Global $version = "beta1"
Global $appName = $devicesTarget & " Manager"

Global $reason = "Fermeture => utilisateur"
Global $title = $appname & " v." & $version & " by " & $author

Global $showRepeatOption, $actionResponse
Dim $aCybooks[0]
Global $tempFile = @TempDir & '\'& $devicesTarget &'Temp.txt'

GetDevices($tempFile)

Func GetDevices($tempFile)
   Local $aDrives = DriveGetDrive($DT_REMOVABLE)
   If Not @error Then
	 For $i = 1 To $aDrives[0]
		 Local $drivesLabels = DriveGetLabel($aDrives[$i] & "\")
		 If $drivesLabels = $devicesTarget Then
			 _ArrayAdd($aCybooks, $aDrives[$i])
		 EndIf
	  Next
	  Requierments($tempFile)
   Else
	  Local $userChoice = MsgBox(2, 'Erreur Fatale',"Aucune liseuse n'est détectée, vérifiez vos branchements USB ou contactez l'administrateur." & @CRLF & @CRLF & "Cliquez sur Ignorer si vous souhaitez (re)programmer la script de répétition.", 60)
	  Switch $userChoice
		 Case 3 ;$IDABORT
			Quit($reason)
		 Case 4 ;$IDRETRY
			GetDevices($tempFile)
		 Case 5 ;$IDIGNORE
			Requierments($tempFile)
		 Case Else
			Quit($reason)
	  EndSwitch
   EndIf
EndFunc

Func Requierments($tempFile)
   If FileExists($tempFile) Then
	  AskWithRepeat($tempFile)
   Else
	  AskWithoutRepeat($tempFile)
   EndIf
EndFunc

Func AskWithRepeat($tempFile)
   $actionResponse = InputBox($title, "Veuillez choisir une action pour les " & UBound($aCybooks) & " Cybooks : " & @CRLF  & @CRLF & "1 = Envoyer" & @CRLF & "2 = Supprimer" & @CRLF & "3 = Répeter les instructions précédentes ou lancer un script)" & @CRLF & "4 = Aide ", "", "", 300, 200, 0, 0)
EndFunc

Func AskWithoutRepeat($tempFile)
   $actionResponse = InputBox($title, "Veuillez choisir une action pour les " & UBound($aCybooks) & " Cybooks : " & @CRLF  & @CRLF & "1 = Envoyer" & @CRLF & "2 = Supprimer" & @CRLF & @CRLF & @CRLF & "4 = Aide ", "", "", 300, 200, 0, 0)
   createTempFile($tempFile)
EndFunc

Switch $actionResponse
   Case '1'
	  WipeTempFile($tempFile)
	  UploadAction()
   Case '2'
	  WipeTempFile($tempFile)
	  RemoveAction()
   Case '1.1'
	  UploadFiles($aCybooks)
   Case '1.2'
	  UploadFolder($aCybooks)
   Case '2.1'
	  RemoveFiles($aCybooks)
   Case '2.2'
	  RemoveFolder($aCybooks)
   Case '3'
	  RepeatAction($aCybooks)
   Case '4'
	  HelpAction()
   Case Else
	  WipeTempFile($tempFile)
	  $reason = "Fermeture => Parametre(s) incorrect(s) lors de la selection du type d'action"
	  Quit($reason)
EndSwitch

Func CreateTempFile($tempFile)
   ConsoleWrite('CreateTempFile()' & @CRLF)

   $fileHandle = FileWrite($tempFile, '')
   If Not @error Then
	  ConsoleWrite($fileHandle & @CRLF)
	  Return
   Else
	  $reason = 'Impossible de creer le fichier temporaire !'
	  Quit($reason)
   EndIf
EndFunc

Func WipeTempFile($tempFile)
   ConsoleWrite("WipeTempFile()" & @CRLF)

   FileDelete($tempFile)
EndFunc

Func UpdateTempFile($args)
   consolewrite("UpdateTempFile() " & $args & @CRLF)

   FileWrite($tempFile, $args & @CRLF)
EndFunc

Func RepeatAction($aCybooks)
   ConsoleWrite("RepeatAction()" & @CRLF)

   Local $hFileOpen = FileOpen($tempFile, $FO_READ)
   If $hFileOpen = -1 Then
	  MsgBox($MB_SYSTEMMODAL, "Erreur Fatale", "Action indisponible, impossible d'acceder au fichier temporaire", 120)
	  $reason = 'Fermeture => Fichier temporaire indisponible'
	  Quit($reason)
   EndIf

   Dim $aLines[] = []

   For $line = 1 To _FileCountLines($hFileOpen)
	  $currentLine = FileReadLine($hFileOpen, $line)
	  _ArrayAdd($aLines, StringLower($currentLine))
   Next

   For $i = 0 To UBound($aLines) - 1
	  $aCurrentLine = StringTrimLeft($aLines[$i],2)
	  For $f = 0 To UBound($aCybooks) - 1

		 If StringInStr($aLines[$i] , '=') Then
			Local $destination = StringTrimLeft($aLines[$i], 2)
			$translatedDestination = $aCybooks[$f] & $destination
		 EndIf

		 Local $translatedSource = $aCybooks[$f] & $aCurrentLine

		 If StringInStr($aLines[$i], '+') Then
			If Not StringInStr($aCurrentLine, $translatedDestination) Then
			   $translatedDestination = $aCybooks[$f] & $destination & $aCurrentLine
			EndIf
			DirCopy($aCurrentLine,$translatedDestination)
			FileCopy($aCurrentLine, $translatedDestination, 8)
		 ElseIf StringInStr($aLines[$i], '-') Then
			If Not StringInStr($aCurrentLine, $destination) Then
			   $translatedSource = $aCybooks[$f] & $destination & $aCurrentLine
			EndIf
			DirRemove($translatedSource, 1)
			FileDelete($translatedSource)
		 EndIf
	  Next
   Next
   FileClose($hFileOpen)

   $reason = 'Fermeture => Script terminé'
   Quit($reason)
EndFunc

Func UploadAction()
   ConsoleWrite("UploadtAction()" & @CRLF)

   Local $type = InputBox("Ajouts - Options", "Type d'item à ajouter aux " & UBound($aCybooks) & " Cybooks :" & @CRLF & @CRLF &  "1 = Fichier(s)"& @CRLF &"2 = Dossier", "2","", -1, -1, 0, 0)

   Switch $type
	  case '1'
		 UploadFiles($aCybooks)
	  Case '2'
		 UploadFolder($aCybooks)
	  Case Else
		 $reason = "Fermeture => Paramètre(s) incorrect(s) lors de la selection du type d'envoi"
		 Quit($reason)
   EndSwitch
EndFunc

Func UploadFiles($aCybooks)
   ConsoleWrite("UploadFiles()" & @CRLF)

   Local $fileSource = FileOpenDialog("Fichiers source", "", "Tous les fichiers (*.*)", 4)
   If @error Then
	  $reason = "Fermeture => Selection de fichiers incorrecte"
	  Quit($reason)
   EndIf

   Local $fileDestination = FileSelectFolder("Destination fichier(s), choisissez une cible", $aCybooks[0])
   If @error Then
	  $reason = "Fermeture => Selection du dossier destination"
	  Quit($reason)
   EndIf

   Local $splittedDestination = StringTrimLeft($fileDestination, 2)
   UpdateTempFile('= ' & $splittedDestination)

   For $i=0 To UBound($aCybooks) - 1
	  Local $folderSearch = FileExists($aCybooks[$i] & $splittedDestination)
	  If $folderSearch = 0 Then
		 $folderCreate = DirCreate($aCybooks[$i] & $splittedDestination)
		 If $folderCreate = 1 Then
			MsgBox(0,'Succes','Creation du dossier manquant => succès (' & $aCybooks[$i] & ')', .5)
		 ElseIf $folderCreate = 0 Then
			MsgBox(0,'Oops','Fermeture => Creation du dossier manquant => erreur (' & $aCybooks[$i] & ')', 3)
		 EndIf
	  EndIf
   Next

   If StringInStr($fileSource, '|') <> 0 Then
	  UploadMultiplesFiles($fileSource, $aCyBooks, $splittedDestination)
   Else
	  UploadSingleFile($fileSource, $aCyBooks, $splittedDestination)
   EndIf

EndFunc

Func UploadSingleFile($fileSource, $aCyBooks, $splittedDestination)
   UpdateTempFile('+ ' & $fileSource)
   For $i=0 To UBound($aCybooks) - 1
	  Local $fileCopy = FileCopy($fileSource, $aCybooks[$i] & $splittedDestination, $FC_OVERWRITE + $FC_CREATEPATH)
	  If $fileCopy = 1 Then
		 MsgBox(0, 'Succes', $devicesTarget & ' ('& StringUpper($aCybooks[$i]) & ") : Envoi " & $aCybooks[$i] & " => Succes !", .5)
	  ElseIf $fileCopy = 0 Then
		 MsgBox(0, 'Oops','Envoi => Erreur ! (' & $aCybooks[$i] & ')', 3)
	  EndIf
   Next

   $reason = "Fermeture => Transferts accomplis"
   Quit($reason)
EndFunc

Func UploadMultiplesFiles($fileSource, $aCyBooks, $splittedDestination)
   Local $items = StringSplit($fileSource, '|')

   For $f=2 To UBound($items) - 1
	  Local $newSource = $items[1] & '\' & $items[$f]
	  UpdateTempFile('+ ' & $newSource)
	  For $i=0 To UBound($aCybooks) - 1
		 Local $fileCopy = FileCopy($newSource, $aCybooks[$i] & $splittedDestination, $FC_OVERWRITE + $FC_CREATEPATH)
		 If $fileCopy = 1 Then
			MsgBox(0, 'Succes', $devicesTarget & ' ('& StringUpper($aCybooks[$i]) & ") : Envoi " & $items[$f] & " => Succes !", .5)
		 ElseIf $fileCopy = 0 Then
			MsgBox(0, 'Oops','Envoi => ERREUR ! (' & $aCybooks[$i] & ')', 3)
		 EndIf
	  Next
   Next

   $reason = "Fermeture => Transferts accomplies"
   Quit($reason)
EndFunc

Func UploadFolder($aCybooks)
   ConsoleWrite("UploadFolder()" & @CRLF)

   Local $folderSource = FileSelectFolder("Dossier source", "")
   If $folderSource = "" Then
	  WipeTempFile($tempFile)
	  $reason = "Fermeture => Dossier source incorrect"
	  Quit($reason)
   EndIf

   Local $folderDestination = FileSelectFolder("Destination dossier(s)", $aCybooks[0])
   If $folderDestination = "" Then
	  WipeTempFile($tempFile)
	  $reason = "Fermeture => Dossier de destination incorrect"
	  Quit($reason)
   EndIf

   Local $folderSplitted = StringTrimLeft($folderDestination, 2)
   UpdateTempFile('= ' & $folderSplitted)
   UpdateTempFile('+ ' & $folderSource)

   For $i=0 To UBound($aCybooks) - 1
	  Local $dirCopy = DirCopy($folderSource, $aCybooks[$i] & $folderSplitted, 1)
	  If $dirCopy Then
		 MsgBox(0, 'Succes', 'Envoi => succes ! (' & $aCybooks[$i] & ')', .5)
	  Else
		 MsgBox(0, 'Oops','Envoi => erreur ! (' & $aCybooks[$i] & ')', 1)
		 $reason = "Fermeture => Transfert de dossier impossible"
		 Quit($reason)
	  EndIf
   Next

   $reason = "Fermeture => Transferts accomplies"
   Quit($reason)
EndFunc

Func RemoveAction()
   Local $type = InputBox("Suppression - Options", "Type d'item à supprimer : " & @CRLF & @CRLF & "1 = Fichier(s) " & @CRLF & "2 = Dossier", "","", -1, -1, 0, 0)

   Switch $type
	  Case '1'
		 RemoveFiles($aCybooks)
	  Case '2'
		 RemoveFolder($aCybooks)
	  Case Else
		 $reason = "Fermeture => Paramètre(s) incorrect(s) lors de la selection du type de suppression"
		 Quit($reason)
   EndSwitch
EndFunc

Func RemoveFiles($aCybooks)
   ConsoleWrite("RemoveFiles()" & @CRLF)

   Local $fileSource = FileOpenDialog("Fichier(s) source, choisissez un exemple", $aCybooks[0],"Tous les fichiers (*.*)", 4)
   If @error Then
	  $reason = "Fermeture => Dossier de destination incorrect"
	  Quit($reason)
   EndIf

   Local $splittedSource = StringTrimLeft($fileSource, 2)
   Local $trimedSource = StringSplit($splittedSource, '\')

   If StringInStr($fileSource, '|') <> 0 Then
	  RemoveMultiplesFiles($fileSource, $aCybooks, $splittedSource)
   Else
	  RemoveSingleFile($fileSource, $aCybooks, $splittedSource, $trimedSource)
   EndIf

EndFunc

Func RemoveSingleFile($fileSource, $aCybooks, $splittedSource, $trimedSource)
   UpdateTempFile('= ' & $trimedSource[2]) ; Used to Change '= sourcePath\item.xx' to '= sourcePath\'
   UpdateTempFile('- ' & $splittedSource)
   For $i=0 To UBound($aCybooks) - 1
		Local $fileDelete = FileDelete($aCybooks[$i] & $splittedSource)
		If $fileDelete = 1 Then
			MsgBox(0, 'Succes', 'Suppression => succes ! (' & $aCybooks[$i] & ')',1)
		Else
			MsgBox(0, 'Oops', 'Suppression => ERREUR ! (' & $aCybooks[$i] & ')', 1)
		EndIf
   Next

   $reason = "Fermeture => Suppressions accomplies"
   Quit($reason)
EndFunc

Func RemoveMultiplesFiles($fileSource, $aCybooks, $splittedSource)
   ConsoleWrite("RemoveMultiplesFiles()" & @CRLF)

   Local $items = StringSplit($fileSource, '|')
   $splittedSource = StringTrimLeft($items[1], 2)
   UpdateTempFile('= ' & $splittedSource)
   For $f=2 To UBound($items) - 1
	  Local $newSource = $splittedSource & '\' & $items[$f]
	  UpdateTempFile('- ' & $newSource)
	  For $i=0 To UBound($aCybooks) - 1
		 Local $fileDelete = FileDelete($aCybooks[$i] & $newSource)
		 If $fileDelete = 1 Then
			MsgBox(0, 'Succes', $devicesTarget & ' ('& StringUpper($aCybooks[$i]) & ") : Suppression " & $items[$f] & " => Succes !", .5)
		 Else
			MsgBox(0, 'Oops','Suppression => ERREUR ! (' & $aCybooks[$i] & ')', 3)
		 EndIf
	  Next
   Next
 ; ISSUE After finishing this the tempFolder seems to delete himself
   $reason = "Fermeture => Suppressions accomplies"
   Quit($reason)
EndFunc

Func RemoveFolder($aCybooks)
   Local $folderSource = FileSelectFolder("Destination fichier(s), choisissez un exemple", $aCybooks[0])
   If $folderSource = '' Then
	  $reason = "Fermeture => Dossier de destination incorrect"
	  Quit($reason)
   EndIf
   Local $splittedFolder = StringTrimLeft($folderSource, 2)

   For $i=0 To UBound($aCybooks) - 1
	  $file = FileExists($aCybooks[$i] & $splittedFolder)

	  If $file = 1 Then
		 $dirDelete = DirRemove($aCybooks[$i] & $splittedFolder, 2)
		 If $dirDelete = 1 Then
			MsgBox(0, 'Succes', $devicesTarget & ' ('& StringUpper($aCybooks[$i]) & ") : Suppression " & $aCybooks[$i] & " => Succes !", .5)
		 Else
			MsgBox(0, 'Oops', 'Suppressions => Error  ! (' & $aCybooks[$i] & ')', 3)
		 EndIf
	  Else
		 MsgBox(0, 'Oops','Suppression => Dossier(s) introuvable(s) (' & $aCybooks[$i] & ')', 1)
	  EndIf
   Next
   $reason = "Fermeture => Suppressions accomplies"
   Quit($reason)
EndFunc

Func HelpAction()
   MsgBox(0,'Documentation ' & $title,"Comment ça marche ?" & @CRLF & 'Etape 1 : Branchez vos liseuses sur le hub USB.' & @CRLF & "Etape 2 : Choisissez l'action Envoi/Suppression/Répétition" & @CRLF & "Etape 3 : Pointez sur la cible dans la fenêtre qui s'ouvre" & @CRLF &'                Une sélection multiple est possible en maintenant enfoncée la                  touche CTRL et en cliquant sur plusieurs fichiers.' & @CRLF & 'N.B : vous pouvez créer un répertoire modèle dans un/une des '& $devicesTarget &' et y copier/coller vos fichiers.' & @CRLF & @CRLF & "Etape 4 : Validez vos choix pour propager automatiquement l'action aux autres " & $devicesTarget & " connectés." & @CRLF & @CRLF & "La répétition ré-exécute les mêmes actions sur plusieurs lots de " & $devicesTarget & @CRLF & "=============================================="& @CRLF & @CRLF & "Script API : (Attention aux Majuscules)" & @CRLF & "Emplacement script/fichier temporaire : " & $tempFile & @CRLF & @CRLF & "References :" & @CRLF & "= \Destination\generale => Dossier appliqué par les suivants + , - " & @CRLF & "+ C:\Chemin\dajouts.txt => Fichier à ajouter à la source" & @CRLF & "- \Chemin\de\suppression => Dossier à supprimer de la source" & @CRLF & @CRLF & "Exemple :" & @CRLF & '= \Digital Editions\Bundle\Manuals' & @CRLF & "- Cybook_Muse_ru.epub" & @CRLF & "+ C:\Users\HoPollo-Portable\Desktop\Test.txt" & @CRLF & @CRLF & "Retrouvez les mises à jours sur : github.com/hopollo/devicesmanager")
   Quit($reason)
EndFunc

Func Quit($reason)
   FileClose($tempFile)
   Beep(660,90)
	  Beep(440,80)
   MsgBox(0,"Credits", "Merci d'avoir utilisé " & $appName & " v." & $version & " by " & $author & @CRLF & @CRLF & $reason, 2)
	  Beep(440,100)
   Beep(660,50)

   Exit
EndFunc

While 1
   sleep(1000)
WEnd