#include <AutoItConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#Include <GuiListView.au3>
#include <Date.au3>
#include <Array.au3>
#include <File.au3>
#include <StringConstants.au3>
#include <WinAPIFiles.au3>
#include <FileConstants.au3>

;Author: Pavel Machala pavel.machala.ap@seznam.cz
;IMPORTANT Script works only on Windows 10 and screen resolution 1280x960

Example()

Func Example()

    Dim $Exit_Code =  false ;
	Dim $TotalCountOfCheckedItems =  0 ;
	Dim $TotalCountOfUnCheckedItems =  0 ;

	; Create a constant variable in Local scope of the filepath that will be read/written to.
    Local Const $sFilePath = _WinAPI_GetTempFileName(@TempDir)
	;MsgBox($MB_SYSTEMMODAL, "", $sFilePath)

    ; Create a temporary file to write data to.
    If Not FileWrite($sFilePath, "Start of the FileWrite example, line 1. " & @CRLF) Then
        ;MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
        Return False
    EndIf

    ; Open the file for writing (append to the end of a file) and store the handle to a variable.
    Local $hFileOpen = FileOpen($sFilePath, $FO_APPEND)
    If $hFileOpen = -1 Then
        ;MsgBox($MB_SYSTEMMODAL, "", "An error occurred whilst writing the temporary file.")
        Return False
	 EndIf

    ; Run Reolink Client with the window maximized.
    Local $iPID = Run("C:\Program Files (x86)\Reolink Client\Reolink Client.exe", "", @SW_SHOWMAXIMIZED)

	;Wait 1 seconds for the Reolink window to appear.
    WinWait("[CLASS:Reolink Client]", "", 1)

    ; Click Login
	MouseClick($MOUSE_CLICK_LEFT, 1113, 180, 1)
    Sleep(3000)

If $Exit_Code = false Then

   Do
		;Check if login succesfull otherwise attempt re-login
		;NOTE!!! Pixel position must match login indication icon in Reolink Client. Use AutoIt Windows Info tool to locate coordinates.
        If PixelGetColor (1068, 136) = 12698049 Then

           MouseClick($MOUSE_CLICK_LEFT, 1113, 180, 1)
		   Sleep(4000)

        Else

			;Click Playback
			;ControlClick("", "",1006,"",1)
			MouseClick($MOUSE_CLICK_LEFT, 165, 30, 1)
			Sleep(3000)

			;Click Playback #second time due to Reolink client flaw to display Playback window on first attempt
			;ControlClick("", "",1006,"",1)
			MouseClick($MOUSE_CLICK_LEFT, 165, 30, 1)
			Sleep(7000)


			;Click Download List
			ControlClick("Reolink Client", "","[CLASS:Static; INSTANCE:140]","",1, 14,14)
			Sleep(5000)

			$hWnd = WinGetHandle("Download file")
			$hListView = ControlGetHandle($hWnd,"","[CLASS:SysListView32; INSTANCE:1]")
			$TotalCountOfItems = ControlListView($hWnd,"",$hListView,"GetItemCount")

			For $i = 0 To $TotalCountOfItems

			   $ItemDate = ControlListView($hWnd,"",$hListView,"GetText",$i,1)
			   $ItemID = ControlListView($hWnd,"",$hListView,"GetText",$i,0)
			   $CurrentDate = _NowCalc ( );
			   $ItemDateTransformed = _DateTimeFormatEx( $ItemDate , "yyyy/MM/dd H:mm:ss")
			   $diff=_dateDiff("s",$ItemDateTransformed,$CurrentDate)


			   ;List all the files and folders in the directory where Reolink download the files
			   Local $aFileList = _FileListToArray("Y:\Records", "*")
			   If @error = 1 Then
				  ;MsgBox($MB_SYSTEMMODAL, "", "Path was invalid.")
				  Exit
				  EndIf
				  If @error = 4 Then
					 ;MsgBox($MB_SYSTEMMODAL, "", "No file(s) were found.")
				  Exit
			   EndIf

			   Dim $TotalNumberOfFilesOnDisk =  0 ;

			    _GUICtrlListView_SetItemChecked($hListView, $i)
				$TotalCountOfCheckedItems = $TotalCountOfCheckedItems + 1

			   for $x = 1 to UBound($aFileList) -1

			   $TotalNumberOfFilesOnDisk = $TotalNumberOfFilesOnDisk + 1

			   Local $sText = $aFileList[$x] ; Define a variable with a string of text.
			   Local $aArray = StringSplit($sText, '_', $STR_ENTIRESPLIT)

			    $prefix = "01"
			    $untrasformed = $aArray[3]
			    $transformed = $prefix & $untrasformed

			    if $transformed == $ItemID Then

			  	  _GUICtrlListView_SetItemChecked($hListView, $i , False)
				  $TotalCountOfUnCheckedItems = $TotalCountOfUnCheckedItems + 1

			   EndIf

			   ;Next
			   Next
			Next

			;Click Download
			ControlClick("", "",1997,"",1)

			$Exit_Code = true;

		 EndIf
    Until $Exit_Code
   Else
   EndIf

   $TotalCountOfCheckedItems = $TotalCountOfCheckedItems - $TotalCountOfUnCheckedItems

     ;Survive one attept to disconnect you by Client gives you extra 5 minutes more than 10 items, or extra 10 minutes for more than 20 items....
  If $TotalCountOfCheckedItems >10 then
    WinWait("Auto Stop","",0)
    sleep(1000);
    ControlClick("Auto Stop", "",2129,"",1,35,14)
    sleep(5000);
  EndIf

   If $TotalCountOfCheckedItems >20 then
	  WinWait("Auto Stop","",0)
	  sleep(1000);
	  ControlClick("Auto Stop", "",2129,"",1,35,14)
	  sleep(5000);

   EndIf

   If $TotalCountOfCheckedItems >30 then
	  WinWait("Auto Stop","",0)
	  sleep(1000);
	  ControlClick("Auto Stop", "",2129,"",1,35,14)
	  sleep(5000);

   EndIf

   ;Giving another 5 minutes and then close Reolink client
   sleep(300000)
   ;Close the Reolink Client process using the PID returned by Run.
   ProcessClose($iPID)

 EndFunc

 Func _DateTimeFormatEx($sDate, $sFormat = "yyyy/MM/dd hh:mm:ss")
    ; Verify If InputDate is valid
    If Not _DateIsValid($sDate) Then
        Return SetError(1, 0, "")
    EndIf
    $hGui = GUICreate("")
    $idDate = GUICtrlCreateDate($sDate, 10, 10)
    GUICtrlSendMsg($idDate, 0x1032, 0, $sFormat) ; or "dddd, MMMM d, yyyy hh:mm:ss tt"); or "hh:mm tt"
    $FormatedDate = GUICtrlRead($idDate)
    GUIDelete($hGui)
    Return $FormatedDate
EndFunc   ;==>_DateTimeFormatEx

Exit
