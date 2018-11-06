#include <AutoItConstants.au3>
#include <Array.au3>
#include <ButtonConstants.au3>
#include <Clipboard.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <File.au3>
#include <FileConstants.au3>
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include <GuiEdit.au3>
#include <InetConstants.au3>
#include <Misc.au3>
#include <MsgBoxConstants.au3>
#include <ScreenCapture.au3>
#include <ScrollBarsConstants.au3>
#include <StaticConstants.au3>
#include <StringConstants.au3>
#include <WinAPIFiles.au3>
#include <WindowsConstants.au3>

;#RequireAdmin

Global $author = "@HoPolloTV"
Global $version = "beta1.2.1"
Global $appName = "Devices Manager"

Global $reason = "Fermeture => Utilisateur"
Global $title = $appname & " v." & $version & " by " & $author
Global $tempFile = @TempDir & "/DevicesManagerTemp.txt"

Global $showRepeatOption, $actionResponse
Dim $aCybooks[0]
Global $internetStatus = False
Global $update = False

Global $Main = GUICreate($title, 450, 391, @DesktopWidth/2 - 391/2, @DesktopHeight/2 - 450/2)
Global $journal = GUICtrlCreateEdit("", 8, 136, 435, 249, BitOR($ES_AUTOVSCROLL,$ES_READONLY,$WS_VSCROLL))
GUICtrlSetData(-1, "")
GUICtrlSetCursor (-1, 2)
Global $uploadFilesBtn = GUICtrlCreateButton("Fichier", 272, 16, 75, 33)
Global $removeFilesBtn = GUICtrlCreateButton("Fichier", 365, 16, 75, 33)
Global $uploadFolderBtn = GUICtrlCreateButton("Dossier", 272, 50, 75, 33)
Global $removeFolderBtn = GUICtrlCreateButton("Dossier", 365, 50, 75, 33)
Global $Label1 = GUICtrlCreateGroup("Envoyer", 267, 2, 84, 86)
Global $Label2 = GUICtrlCreateGroup("Supprimer", 360, 2, 84, 86)
Global $devicesTargetInput = GUICtrlCreateCombo("", 64, 21, 145, 25, BitOR($CBS_DROPDOWN,$CBS_AUTOHSCROLL))
Global $repeatBtn = GUICtrlCreateButton("Repeter / Script", 8, 95, 99, 33)
GUICtrlSetState(-1, $GUI_DISABLE)
Global $tempFileBtn = GUICtrlCreateButton("<<", 150, 95, 35, 33)
GUICtrlSetTip(-1, "Accéder au fichier temporaire/script")
Global $Label3 = GUICtrlCreateLabel("Appareils :", 8, 24, 53, 17)
Global $status = GUICtrlCreateLabel("Aucun appareil amovible détecté", 8, 56, 200, 30)
$helpBtn = GUICtrlCreateButton("Aide", 230, 95, 80, 33)
GUICtrlSetTip(-1, "Obtenir de l'aide")
Global $copieBtn = GUICtrlCreateButton("Collecter", 365, 95, 80, 33)
GUICtrlSetTip(-1, "Copier de la structure d'un appareil vers le PC")
GUISetState(@SW_SHOW)

GUICtrlSetState($uploadFilesBtn, $GUI_DISABLE)
GUICtrlSetState($uploadFolderBtn, $GUI_DISABLE)
GUICtrlSetState($removeFilesBtn, $GUI_DISABLE)
GUICtrlSetState($removeFolderBtn, $GUI_DISABLE)
GUICtrlSetState($copieBtn, $GUI_DISABLE)


info("Bienvenue sur " & $title)
CheckForUpdates()
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

		 Case $repeatBtn
			info('===================================================================')
			info("Lecture du fichier temporaire/script :")
			RepeatAction($aCybooks)

		 Case $tempFileBtn
			info('Ouverture du fichier temporaire/script, merci de patienter...')
			OpenTempFileFolder($tempFile)

		 Case $helpBtn
			info("Ouverture de l'aide, merci de patienter...")
			HelpAction($internetStatus)

		 Case $copieBtn
			WipeTempFile($tempFile)
			CopieDevices($aCybooks)
	  EndSwitch
   WEnd

Global $tempFile = @TempDir & '\DevicesManagerTemp.txt'

Func GetDevices()
   ReadTempFile($tempFile)
   GUICtrlSetState($devicesTargetInput, $GUI_DISABLE)

   Local $aDrives = DriveGetDrive($DT_REMOVABLE)
   If Not @error Then
	  For $i = 1 To UBound($aDrives) - 1
		 Global $driveName = DriveGetLabel($aDrives[$i])
		 If $driveName <> '' Then ;Prevents from "phantoms" drives partitions
			_GUICtrlComboBox_AddString($devicesTargetInput, $driveName)
		 EndIf
	  Next

	  GUICtrlSetState($devicesTargetInput, $GUI_ENABLE)

	  If $aDrives[0] > 1 Then
		 GUICtrlSetData($status, $aDrives[0] & " appareils trouvés")
	  Else
		 GUICtrlSetData($status, $aDrives[0] & " appareil trouvé")
	  EndIf

	  Do
		 Local $userDevicesPicked = GUICtrlRead($devicesTargetInput)

		 Switch GUIGetMsg()
			Case $GUI_EVENT_CLOSE
			   Quit($reason)

			Case $helpBtn
			   info("Ouverture de l'aide, merci de patienter...")
			   HelpAction($internetStatus)

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
	  GUICtrlSetState($copieBtn, $GUI_ENABLE)
   Else
	  Sleep(200)
	  info("Aucun appareil détecté, vérifiez vos branchements USB ou contactez l'administrateur." & @CRLF & @CRLF & "Cliquez sur Ignorer si vous souhaitez (re)programmer le script de répétition.")
   EndIf
EndFunc

Func info($messageJournal, $autresInfos = "")
   GUICtrlSetData($journal, GUICtrlRead($journal) & @CRLF & $messageJournal)
   Local $end = StringLen(GUICtrlRead($journal))
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
	  info("Oops : Action indisponible, fichier temporaire inaccéssible.")
	  info('===================================================================')
   EndIf

   Dim $aLines[] = []

   For $line = 1 To _FileCountLines($hFileOpen)
	 Local $currentLine = FileReadLine($hFileOpen, $line)
	 _ArrayAdd($aLines, StringLower($currentLine))
   Next

   Local $adds = 0
   Local $rems = 0
   Local $colls = 0

   For $i = 0 To UBound($aLines) - 1
	  Local $aCurrentLine = StringTrimLeft($aLines[$i], 2) ; remove the 'x ' sign + space
	  For $f = 0 To UBound($aCybooks) - 1
		 info($aLines[$i])

		 If StringInStr($aLines[$i] , '= ') Then
			$destination = StringTrimLeft($aLines[$i], 2)	; remove the '= '
		 ElseIf StringInStr($aLines[$i], '+ ') Then
			$translatedDestination = $aCybooks[$f] & $destination & $aCurrentLine
			DirCopy($aCurrentLine, $translatedDestination)
			FileCopy($aCurrentLine, $translatedDestination, 8)
			$adds = $adds + 1
		 ElseIf StringInStr($aLines[$i], '- ') Then
			If Not StringInStr($aCurrentLine, $aCybooks[$f] & $destination & $aCurrentLine) Then ; rebuild path for "- text.txt" feature
			   $translatedSource = $aCybooks[$f] & $destination & '\' & $aCurrentLine
			EndIf
			DirRemove($translatedSource, 1)
			FileDelete($translatedSource)
			$rems = $rems + 1
		 ElseIf StringInStr($aLines[$i], '* ') Then
			$translatedSource = $aCybooks[$f] & $aCurrentLine
			DirCopy($translatedSource, $destination)
			FileCopy($translatedSource, $destination, 8)
			$colls = $colls + 1
		 EndIf
	  Next
   Next
   FileClose($hFileOpen)

   info(@CRLF & 'Exécution du script terminée, ' & UBound($aLines) - 1 & ' lignes (' & $adds &' ajouts/'& $rems &' suppréssions/'& $colls &' collectes).')
   info('===================================================================')
   Return
EndFunc

Func UploadFiles($aCybooks)
   Local $fileSource = FileOpenDialog("Envoi : Fichiers source", "", "Tous les fichiers (*.*)", 4)
   If @error Then
	  info("Oops => Sélection de fichiers source incorrecte")
	  Return
   EndIf

   Local $fileDestination = FileSelectFolder("Envoi : Destination fichier(s), choisissez une cible", $aCybooks[0])
   If @error Then
	  info("Oops => Sélection du dossier destination incorrect")
	  Return
   EndIf

   Local $splittedDestination = StringTrimLeft($fileDestination, 2)
   UpdateTempFile('= ' & $splittedDestination)

   For $i=0 To UBound($aCybooks) - 1
	  Local $folderSearch = FileExists($aCybooks[$i] & $splittedDestination)
	  If $folderSearch = 0 Then
		 Local $folderCreate = DirCreate($aCybooks[$i] & $splittedDestination)
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
   Local $succes = 0

   UpdateTempFile('+ ' & $fileSource)
   For $i=0 To UBound($aCybooks) - 1
	  Local $fileCopy = FileCopy($fileSource, $aCybooks[$i] & $splittedDestination, $FC_OVERWRITE + $FC_CREATEPATH)
	  If $fileCopy = 1 Then
		 info('Succès ' & StringUpper($aCybooks[$i]) & ' Envoi ' & $fileSource & ' => Succès !')
		 $succes = $succes + 1
	  Else
		 info('Oops ' & StringUpper($aCybooks[$i]) & ' Envoi ' & $fileSource & ' => Erreur !')
	  EndIf
   Next

  info('Transfert fichier accompli (' & $succes & '/' & UBound($aCybooks) &').')
EndFunc

Func UploadMultiplesFiles($fileSource, $aCyBooks, $splittedDestination)
   Local $items = StringSplit($fileSource, '|')
   Local $succes = 0

   For $f=2 To UBound($items) - 1
	  Local $newSource = $items[1] & '\' & $items[$f]
	  UpdateTempFile('+ ' & $newSource)
	  For $i=0 To UBound($aCybooks) - 1
		 Local $fileCopy = FileCopy($newSource, $aCybooks[$i] & $splittedDestination, $FC_OVERWRITE + $FC_CREATEPATH)
		 If $fileCopy = 1 Then
			info('Succes : ' & StringUpper($aCybooks[$i]) & ' Envoi ' & $items[$f] & ' => Succès !')
			$succes = $succes + 1
		 ElseIf $fileCopy = 0 Then
			info('Oops : ' & StringUpper($aCybooks[$i]) & ' Envoi ' & $items[$f] &' => Erreur !')
		 EndIf
	  Next
   Next

   info('Transferts fichiers terminés (' & $succes & '/' & UBound($items) &').')
EndFunc

Func UploadFolder($aCybooks)
   Local $folderSource = FileSelectFolder("Envoi : Dossier source", "")
   If $folderSource = "" Then
	  info("Oops : Dossier source incorrect.")
	  Return
   EndIf

   Local $folderDestination = FileSelectFolder("Envoi : Destination dossier(s)", $aCybooks[0])
   If $folderDestination = "" Then
	  info("Dossier de destination incorrect.")
	  Return
   EndIf

   Local $folderSplitted = StringTrimLeft($folderDestination, 2)
   UpdateTempFile('= ' & $folderSplitted)
   UpdateTempFile('+ ' & $folderSource)

   Local $succes = 0

   For $i=0 To UBound($aCybooks) - 1
	  Local $dirCopy = DirCopy($folderSource, $aCybooks[$i] & $folderSplitted, 1)
	  If $dirCopy Then
		 info('Succès : ' & StringUpper($aCybooks[$i]) & ' Envoi ' & $folderSource & ' => Succès !')
		 $succes = $succes + 1
	  Else
		 info('Oops : ' & StringUpper($aCybooks[$i]) & ' Envoi ' & $folderSource &  ' => Erreur !')
	  EndIf
   Next

   info('Transfert de dossier terminé (' & $succes & '/' & UBound($aCybooks) &').')
EndFunc

Func RemoveFiles($aCybooks)
   Local $fileSource = FileOpenDialog("Suppression : Fichier(s) source, choisissez un exemple", $aCybooks[0],"Tous les fichiers (*.*)", 4)
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

   Local $succes = 0

   For $i=0 To UBound($aCybooks) - 1
		Local $fileDelete = FileDelete($aCybooks[$i] & $splittedSource)
		If $fileDelete = 1 Then
			info('Succes : ' & StringUpper($aCybooks[$i]) & ' Suppression ' & $splittedSource & ' => Succès !')
			$succes = $succes + 1
		Else
			info('Oops : ' & StringUpper($aCybooks[$i]) & ' Suppression ' & $splittedSource & ' => Erreur !')
		EndIf
   Next

   info('Suppression de fichier terminée (' & $succes & '/' & UBound($aCybooks) & ').')
EndFunc

Func RemoveMultiplesFiles($fileSource, $aCybooks, $splittedSource)
   Local $items = StringSplit($fileSource, '|')
   Global $splittedSource = StringTrimLeft($items[1], 2)
   UpdateTempFile('= ' & $splittedSource)

   Local $succes = 0

   For $f=2 To UBound($items) - 1
	  Local $newSource = $splittedSource & '\' & $items[$f]
	  UpdateTempFile('- ' & $newSource)
	  For $i=0 To UBound($aCybooks) - 1
		 Local $fileDelete = FileDelete($aCybooks[$i] & $newSource)
		 If $fileDelete = 1 Then
			info('Succes : ' & StringUpper($aCybooks[$i]) & ' Suppression ' & $items[$f] & ' => Succès !')
			$succes = $succes + 1
		 Else
			info('Oops : ' & StringUpper($aCybooks[$i]) & ' Suppression ' & $items[$f] & ' => Erreur !')
		 EndIf
	  Next
   Next

   info('Suppressions terminées (' & $succes & '/' & UBound($items) &').')
   Return
EndFunc

Func RemoveFolder($aCybooks)
   Local $folderSource = FileSelectFolder("Suppression : Destination fichier(s), choisissez un exemple", $aCybooks[0])
   If $folderSource = '' Then
	  info("Dossier de destination incorrect.")
	  Return
   EndIf
   Local $splittedFolder = StringTrimLeft($folderSource, 2)
   UpdateTempFile('= ' & $splittedFolder)

   Local $succes = 0

   For $i=0 To UBound($aCybooks) - 1
	  Local $file = FileExists($aCybooks[$i] & $splittedFolder)
	  If $file = 1 Then
		 UpdateTempFile('- ' & $splittedFolder)
		 $dirDelete = DirRemove($aCybooks[$i] & $splittedFolder, 2)
		 If $dirDelete = 1 Then
			info('Succes : ' & StringUpper($aCybooks[$i]) & ' Suppression ' & $splittedFolder & ' => Succès !')
			$succes = $succes + 1
		 Else
			info('Oops : ' & StringUpper($aCybooks[$i]) & ' Suppression ' & $splittedFolder & ' => Erreur !')
		 EndIf
	  Else
		 info('Oops : ' & StringUpper($aCybooks[$i]) & ' Suppression => Dossier ' & $splittedFolder & ' introuvable')
	  EndIf
   Next
   info('Suppressions dossiers terminées (' & $succes & '/' & UBound($aCybooks) & ').')
EndFunc

Func CopieDevices($aCybooks)
   Local $deviceSource = FileSelectFolder("Copie : Dossier source, choisissez un exemple", $aCybooks[0])
   If $deviceSource = '' Then
	  info("Dossier de destination incorrect.")
	  Return
   EndIf

   Local $splittedDevicesSource = StringTrimLeft($deviceSource, 2)

   Local $destinationFolder = FileSelectFolder("Copie : Destination sur le PC", @HomeDrive)
   If $destinationFolder = '' Then
	  info("Dossier de destination incorrect.")
	  Return
   EndIf

   UpdateTempFile('= ' & $destinationFolder)

   Local $succes = 0

   For $i=0 To UBound($aCybooks) - 1
	  Local $file = FileExists($aCybooks[$i] & $splittedDevicesSource)
	  If $file = 1 Then
		 UpdateTempFile('* ' & $splittedDevicesSource)
		 $dirCopy = DirCopy($aCybooks[$i] & $splittedDevicesSource, $destinationFolder, 1)
		 If $dirCopy = 1 Then
			info('Succes : ' & StringUpper($aCybooks[$i]) & ' Collecte ' & $splittedDevicesSource & ' => Succes !')
			$succes = $succes + 1
		 Else
			info('Oops : ' & StringUpper($aCybooks[$i]) & ' Collecte ' & $splittedDevicesSource & ' => Succes !')
		 EndIf
	  Else
		 info('Oops : ' & StringUpper($aCybooks[$i]) & ' Copie => Dossier(s) introuvable(s)')
	  EndIf
   Next
   info('Collecte terminée (' & $succes & '/' & UBound($aCybooks) & ').')
EndFunc

Func CheckForUpdates()
   Ping("www.google.com")
   If @error Then
	  Return
   EndIf

   Local $dData = InetRead("https://raw.githubusercontent.com/hopollo/devicesmanager/master/version")
   Local $iBytesRead = @extended
   Local $sData = BinaryToString($dData, $SB_UTF8)

   Local $iCmp = StringCompare($version, $sData, $STR_CASESENSE)

   If $iCmp <> (-1) Then
	  info('IMPORTANT : Mise à jour disponible ! (v.' & String($sData) & '), cliquez sur "Aide" pour en savoir +')
   EndIf

   $internetStatus = True
   $update = True
EndFunc

Func HelpAction($internetStatus)
   If $internetStatus Then
	  If $update Then
		 ShellExecute("https://github.com/hopollo/devicesmanager/releases")
	  Else
		 $hHBITMAP = _ScreenCapture_CaptureWnd("", $Main)
		 _ClipBoard_Open(0)
		 _ClipBoard_SetDataEx($hHBITMAP, $CF_BITMAP)
		 _ClipBoard_Close()
		 ShellExecute("https://github.com/hopollo/devicesmanager/wiki")
	  EndIf
	   $update = False ;to restaure back the helpbutton actions
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
