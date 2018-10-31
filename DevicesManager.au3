#include <AutoItConstants.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <StaticConstants.au3>
#include <ScrollBarsConstants.au3>
#include <WinAPIFiles.au3>
#include <WindowsConstants.au3>

;#RequireAdmin

Global $author = "@HoPolloTV"
Global $version = "beta1.1"
Global $appName = "Devices Manager"

Global $reason = "Fermeture => Utilisateur"
Global $title = $appname & " v." & $version & " by " & $author
Global $tempFile = @TempDir & "/DevicesManagerTemp.txt"

Global $showRepeatOption, $actionResponse
Dim $aCybooks[0]

$Main = GUICreate($title, 450, 391, @DesktopWidth/2 - 391/2, @DesktopHeight/2 - 450/2)
Global $journal = GUICtrlCreateEdit("", 8, 136, 435, 249, BitOR($ES_AUTOVSCROLL,$ES_READONLY,$WS_VSCROLL))
GUICtrlSetData(-1, "")
GUICtrlSetCursor (-1, 2)
$uploadFilesBtn = GUICtrlCreateButton("Fichier", 272, 40, 75, 33)
$removeFilesBtn = GUICtrlCreateButton("Fichier", 370, 40, 75, 33)
$uploadFolderBtn = GUICtrlCreateButton("Dossier", 272, 88, 75, 33)
$removeFolderBtn = GUICtrlCreateButton("Dossier", 370, 88, 75, 33)
$Label1 = GUICtrlCreateLabel("Envoyer", 288, 8, 43, 17)
$Label2 = GUICtrlCreateLabel("Supprimer", 384, 8, 51, 17)
$devicesTargetInput = GUICtrlCreateCombo("", 64, 21, 145, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
$repeatBtn = GUICtrlCreateButton("Repeter / Script", 8, 88, 99, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
$tempFileBtn = GUICtrlCreateButton("<<", 125, 88, 35, 33)
$Label3 = GUICtrlCreateLabel("Appareils :", 8, 24, 53, 17)
$Pic1 = GUICtrlCreatePic("", 168, 8, 92, 76)
$status = GUICtrlCreateLabel("Aucun appareil amovible détecté", 8, 56, 200, 30)
$helpBtn = GUICtrlCreateButton("Aide", 176, 88, 80, 33)
GUISetState(@SW_SHOW)

GUICtrlSetState($uploadFilesBtn, $GUI_DISABLE)
GUICtrlSetState($uploadFolderBtn, $GUI_DISABLE)
GUICtrlSetState($removeFilesBtn, $GUI_DISABLE)
GUICtrlSetState($removeFolderBtn, $GUI_DISABLE)

GetDevices()

 While 1
	  Switch GUIGetMsg()
		 Case $GUI_EVENT_CLOSE
			Quit($reason)

		 Case $uploadFilesBtn
			WipeTempFile($tempFile)
			UploadFiles($aCybooks)

		 Case $uploadFolderBtn
			WipeTempFile($tempFile)
			UploadFolder($aCybooks)

		 Case $removeFilesBtn
			WipeTempFile($tempFile)
			RemoveFiles($aCybooks)

		 Case $removeFolderBtn
			WipeTempFile($tempFile)
			RemoveFolder($aCybooks)

		 Case $helpBtn
			info('Ouverture du fichier temporaire/script, merci de patienter...')
			HelpAction()

		 Case $repeatBtn
			info('===================================================================')
			info("Lecture du fichier temporaire/script :")
			RepeatAction($aCybooks)

		 Case $tempFileBtn
			info('Ouverture du fichier temporaire/script, merci de patienter...')
			OpenTempFileFolder($tempFile)
	  EndSwitch
   WEnd

Global $tempFile = @TempDir & '\DevicesManagerTemp.txt'

Func GetDevices()
   info("Bienvenue sur " & $title)
   ReadTempFile($tempFile)

   Local $aDrives = DriveGetDrive($DT_REMOVABLE)
   If Not @error Then
	  For $i = 1 To UBound($aDrives) - 1
		 Global $driveName = DriveGetLabel($aDrives[$i])
		 If $driveName <> '' Then ;Prevents from "phantoms" drives partitions
			_GUICtrlComboBox_AddString($devicesTargetInput, $driveName)
		 EndIf
	  Next

	  If $aDrives[0] > 1 Then
		 GUICtrlSetData($status, $aDrives[0] & " appareils trouvés")
	  Else
		 GUICtrlSetData($status, $aDrives[0] & " appareil trouvé")
	  EndIf

	  Do
		 $userDevicesPicked = GUICtrlRead($devicesTargetInput)

		 Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
			   Quit($reason)

			Case $helpBtn
			   info("Ouverture de l'aide, merci de patienter...")
			   HelpAction()

			Case $tempFileBtn
			   info('Ouverture du fichier temporaire/script, merci de patienter...')
			   OpenTempFileFolder($tempFile)
		 EndSwitch

	  Until _IsPressed("01") And StringLen($userDevicesPicked) > 3

	  GUICtrlSetState($devicesTargetInput, $GUI_DISABLE)
	  GUICtrlSetData($devicesTargetInput, $userDevicesPicked) ;Shows user selected item

	  For $i = 1 To UBound($aDrives) - 1
		 Local $drivesLabels = DriveGetLabel($aDrives[$i] & "\")
		 If $drivesLabels = $userDevicesPicked Then
			_ArrayAdd($aCybooks, $aDrives[$i])
		 EndIf
	  Next

	  If UBound($aCybooks) > 1 Then
		 GUICtrlSetData($status, UBound($aCybooks) & " appareils correspondants")
	  Else
		 GUICtrlSetData($status, UBound($aCybooks) & " appareil correspondant")
	  EndIf

	  GUICtrlSetState($repeatBtn, $GUI_ENABLE)
	  GUICtrlSetState($uploadFilesBtn, $GUI_ENABLE)
	  GUICtrlSetState($uploadFolderBtn, $GUI_ENABLE)
	  GUICtrlSetState($removeFilesBtn, $GUI_ENABLE)
	  GUICtrlSetState($removeFolderBtn, $GUI_ENABLE)
   Else
	  Sleep(200)
	  info("Aucun appareil détecté, vérifiez vos branchements USB ou contactez l'administrateur." & @CRLF & @CRLF & "Cliquez sur Ignorer si vous souhaitez (re)programmer la script de répétition.")
   EndIf
EndFunc

Func info($messageJournal, $autresInfos = "")
   GUICtrlSetData($journal, GUICtrlRead($journal) & @CRLF & $messageJournal)
   $end = StringLen(GUICtrlRead($journal))
   _GUICtrlEdit_SetSel($journal, $end, $end & @CRLF)
   _GUICtrlEdit_Scroll($journal, $SB_SCROLLCARET)
EndFunc

Func ReadTempFile($tempFile)
   If FileExists($tempFile) Then
	  info('Fichier temporaire ou script détecté, choisissez un appareil pour avoir accès au bouton.')
   Else
	  info("Fichier temporaire introuvable, un nouveau va être généré.")
	  CreateTempFile($tempFile)
	  Return
   EndIf
EndFunc

Func CreateTempFile($tempFile)
   ConsoleWrite('CreateTempFile()' & @CRLF)

   $fileHandle = FileWrite($tempFile, '')
   If Not @error Then
	  GUICtrlSetState($repeatBtn, $GUI_ENABLE)
	  info('Génération du fichier temporaire => Succès !')
	  Return
   Else
	  info('Oops : Impossible de créer le fichier temporaire !')
	  Return
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

Func OpenTempFileFolder($tempFile)
  Run("notepad.exe " & $tempFile)
EndFunc

Func RepeatAction($aCybooks)
   ConsoleWrite("RepeatAction()" & @CRLF)

   Local $hFileOpen = FileOpen($tempFile, $FO_READ)
   If $hFileOpen = -1 Then
	  info("Erreur Fatale", "Action indisponible, impossible d'accéder au fichier temporaire.")
	  info('===================================================================')
   EndIf

   Dim $aLines[] = []

   For $line = 1 To _FileCountLines($hFileOpen)
	  $currentLine = FileReadLine($hFileOpen, $line)
	  ;;_ArrayAdd($aLines, StringLower($currentLine))
   Next

   For $i = 0 To UBound($aLines) - 1
	  $aCurrentLine = StringTrimLeft($aLines[$i],2)
	  For $f = 0 To UBound($aCybooks) - 1
		 info($aLines[$i])
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

   info('Excécution du script terminée.')
   info('===================================================================')
   Return
EndFunc

Func UploadFiles($aCybooks)
   ConsoleWrite("UploadFiles()" & @CRLF)

   Local $fileSource = FileOpenDialog("Fichiers source", "", "Tous les fichiers (*.*)", 4)
   If @error Then
	  info("Oops => Sélection de fichiers source incorrecte")
	  Return
   EndIf

   Local $fileDestination = FileSelectFolder("Destination fichier(s), choisissez une cible", $aCybooks[0])
   If @error Then
	  info("Oops => Sélection du dossier destination")
	  Return
   EndIf

   Local $splittedDestination = StringTrimLeft($fileDestination, 2)
   UpdateTempFile('= ' & $splittedDestination)

   For $i=0 To UBound($aCybooks) - 1
	  Local $folderSearch = FileExists($aCybooks[$i] & $splittedDestination)
	  If $folderSearch = 0 Then
		 $folderCreate = DirCreate($aCybooks[$i] & $splittedDestination)
		 If $folderCreate = 1 Then
			info('Création du dossier manquant => Succès (' & StringUpper($aCybooks[$i]) & ')')
		 ElseIf $folderCreate = 0 Then
			info('Oops => Création du dossier manquant => Erreur (' & StringUpper($aCybooks[$i]) & ')')
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
		 info('Succès ' & StringUpper($aCybooks[$i]) & " : Envoi => Succès !")
	  ElseIf $fileCopy = 0 Then
		 info('Oops : Envoi => Erreur ! (' & $aCybooks[$i] & ')')
	  EndIf
   Next

  info("Transfert fichier accompli")
EndFunc

Func UploadMultiplesFiles($fileSource, $aCyBooks, $splittedDestination)
   Local $items = StringSplit($fileSource, '|')

   For $f=2 To UBound($items) - 1
	  Local $newSource = $items[1] & '\' & $items[$f]
	  UpdateTempFile('+ ' & $newSource)
	  For $i=0 To UBound($aCybooks) - 1
		 Local $fileCopy = FileCopy($newSource, $aCybooks[$i] & $splittedDestination, $FC_OVERWRITE + $FC_CREATEPATH)
		 If $fileCopy = 1 Then
			info('Succes : ' & StringUpper($aCybooks[$i]) & " : Envoi " & $items[$f] & " => Succes !")
		 ElseIf $fileCopy = 0 Then
			info('Oops : Envoi => Erreur ! (' & $aCybooks[$i] & ')')
		 EndIf
	  Next
   Next

   info("Transferts fichiers terminés")
EndFunc

Func UploadFolder($aCybooks)
   ConsoleWrite("UploadFolder()" & @CRLF)

   Local $folderSource = FileSelectFolder("Dossier source", "")
   If $folderSource = "" Then
	  info("Oops : Dossier source incorrect.")
	  Return
   EndIf

   Local $folderDestination = FileSelectFolder("Destination dossier(s)", $aCybooks[0])
   If $folderDestination = "" Then
	  info("Dossier de destination incorrect.")
	  Return
   EndIf

   Local $folderSplitted = StringTrimLeft($folderDestination, 2)
   UpdateTempFile('= ' & $folderSplitted)
   UpdateTempFile('+ ' & $folderSource)

   For $i=0 To UBound($aCybooks) - 1
	  Local $dirCopy = DirCopy($folderSource, $aCybooks[$i] & $folderSplitted, 1)
	  If $dirCopy Then
		 info('Succès : Envoi => Succès ! (' & $aCybooks[$i] & ')')
	  Else
		 info('Oops : Envoi => Erreur ! (' & $aCybooks[$i] & ')')
		 Info("Transfert de dossier impossible")
		 Return
	  EndIf
   Next

   info("Transferts accomplis")
EndFunc

Func RemoveFiles($aCybooks)
   ConsoleWrite("RemoveFiles()" & @CRLF)

   Local $fileSource = FileOpenDialog("Fichier(s) source, choisissez un exemple", $aCybooks[0],"Tous les fichiers (*.*)", 4)
   If @error Then
	  info("Dossier de destination incorrect")
	  Return
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
			info('Succes : Suppression => succes ! (' & $aCybooks[$i] & ')')
		Else
			info('Oops : Suppression => Erreur ! (' & $aCybooks[$i] & ')')
		EndIf
   Next

   info("Suppression fichier accomplie")
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
			info('Succes : ' & StringUpper($aCybooks[$i]) & " : Suppression " & $items[$f] & " => Succes !")
		 Else
			info('Oops : Suppression => Erreur ! (' & StringUpper($aCybooks[$i]) & ')')
		 EndIf
	  Next
   Next
 ; ISSUE After finishing this the tempFolder seems to delete himself
   info("Suppressions accomplies.")
   Return
EndFunc

Func RemoveFolder($aCybooks)
   Local $folderSource = FileSelectFolder("Destination fichier(s), choisissez un exemple", $aCybooks[0])
   If $folderSource = '' Then
	  info("Dossier de destination incorrect.")
	  Return
   EndIf
   Local $splittedFolder = StringTrimLeft($folderSource, 2)

   For $i=0 To UBound($aCybooks) - 1
	  $file = FileExists($aCybooks[$i] & $splittedFolder)

	  If $file = 1 Then
		 $dirDelete = DirRemove($aCybooks[$i] & $splittedFolder, 2)
		 If $dirDelete = 1 Then
			info('Succes : ' & StringUpper($aCybooks[$i]) " : Suppression => Succes !")
		 Else
			info('Oops : Suppressions => Erreur  ! (' & $aCybooks[$i] & ')')
		 EndIf
	  Else
		 info('Oops : Suppression => Dossier(s) introuvable(s) (' & $aCybooks[$i] & ')')
	  EndIf
   Next
   info("Suppressions dossiers terminées")
EndFunc

Func HelpAction()
   Ping("www.google.com")
   If not @error Then
	  ShellExecute("https://github.com/hopollo/devicesmanager/wiki")
   Else
	  MsgBox(0,'Documentation hors-ligne' & $title,"Comment ça marche ?" & @CRLF & 'Etape 1 : Branchez vos liseuses sur le hub USB.' & @CRLF & "Etape 2 : Choisissez l'action Envoi/Suppression/Répétition" & @CRLF & "Etape 3 : Pointez sur la cible dans la fenêtre qui s'ouvre" & @CRLF &'                Une sélection multiple est possible en maintenant enfoncée la                  touche CTRL et en cliquant sur plusieurs fichiers.' & @CRLF & 'N.B : vous pouvez créer un répertoire modèle dans un des appreils amovibles et y copier/coller vos fichiers.' & @CRLF & @CRLF & "Etape 4 : Validez vos choix pour propager automatiquement l'action aux autres appareils amovibles similaires connectés." & @CRLF & @CRLF & "La répétition ré-exécute les mêmes actions sur plusieurs lots d'appareils amovilbes" & @CRLF & "=============================================="& @CRLF & @CRLF & "Script API : (Attention aux Majuscules)" & @CRLF & "Emplacement script/fichier temporaire : " & $tempFile & @CRLF & @CRLF & "References :" & @CRLF & "= \Destination\generale => Dossier appliqué par les suivants + , - " & @CRLF & "+ C:\Chemin\dajouts.txt => Fichier à ajouter à la source" & @CRLF & "- \Chemin\de\suppression => Dossier à supprimer de la source" & @CRLF & @CRLF & "Exemple :" & @CRLF & '= \Digital Editions\Bundle\Manuals' & @CRLF & "- Cybook_Muse_ru.epub" & @CRLF & "+ C:\Users\HoPollo-Portable\Desktop\Test.txt" & @CRLF & @CRLF & "Retrouvez les mises à jours sur : github.com/hopollo/devicesmanager")
   Endif
EndFunc

Func Quit($reason)
   FileClose($tempFile)
   Beep(660,90)
	  Beep(440,80)
   info(@CRLF & "Fermeture, merci d'avoir utilisé " & $appName & @CRLF & $reason)
	  Beep(440,100)
   Beep(660,50)
   Sleep(2000)
   Exit
EndFunc
