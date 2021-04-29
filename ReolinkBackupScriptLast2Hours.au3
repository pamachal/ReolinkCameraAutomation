#include <AutoItConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#Include <GuiListView.au3>
#include <Date.au3>

;Author: Pavel Machala pavel.machala.ap@seznam.cz
;IMPORTANT Script works only on Windows 10 and screen resolution 1280x960
;You can donate this project via PayPal if you like

Example()

Func Example()

    Dim $Exit_Code =  false ;

    ; Run Reolink Client with the window maximized.
    Local $iPID = Run("C:\Program Files (x86)\Reolink Client\Reolink Client.exe", "", @SW_SHOWMAXIMIZED)

    ;Wait 1 seconds for the Reolink window to appear.
    WinWait("[CLASS:Reolink Client]", "", 1)

    ;Click Login
    MouseClick($MOUSE_CLICK_LEFT, 1113, 180, 1)
    Sleep(1000)

If $Exit_Code = false Then

   Do
	;Check if login succesfull otherwise attempt re-login
	;NOTE!!! Pixel position must match login indication icon in Reolink Client. Use AutoIt Windows Info tool to locate coordinates.
        If PixelGetColor (1068, 136) = 12698049 Then

           MouseClick($MOUSE_CLICK_LEFT, 1113, 180, 1)
           Sleep(1500)

        Else

			;Click Playback
			ControlClick("", "",1006,"",1)
			Sleep(2000)

			;Click Playback #second time due to Reolink client flaw to display Playback window on first attempt
			ControlClick("", "",1006,"",1)
			Sleep(5000)


			;Click Download List
			ControlClick("Reolink Client", "","[CLASS:Static; INSTANCE:140]","",1, 14,14)
			Sleep(2000)

			$hWnd = WinGetHandle("Download file")
			$hListView = ControlGetHandle($hWnd,"","[CLASS:SysListView32; INSTANCE:1]")
			$TotalCountOfItems = ControlListView($hWnd,"",$hListView,"GetItemCount")

			For $i = 0 To $TotalCountOfItems

			   $ItemDate = ControlListView($hWnd,"",$hListView,"GetText",$i,1)
			   $CurrentDate = _NowCalc ( );
			   $ItemDateTransformed = _DateTimeFormatEx( $ItemDate , "yyyy/MM/dd H:mm:ss")
			   $diff=_dateDiff("s",$ItemDateTransformed,$CurrentDate)

			   if $diff >7200 then ;Select here limit how old files should be downloaded in seconds)
				  ;Skip selection
			   Else
				  ;Select file
				  _GUICtrlListView_SetItemChecked($hListView, $i)
			   Endif

			 Next

			;Click Download
			ControlClick("", "",1997,"",1)

			$Exit_Code = true;

		 EndIf
    Until $Exit_Code
   Else
   EndIf

   ;Survive one attept to disconnect you by Client gives you extra 5 minutes to dowload the stuff
   WinWait("Auto Stop","",0)
   sleep(1000);
   ControlClick("Auto Stop", "",2129,"",1,35,14)
   sleep(5000);

   ;Giving another 5 minutes and then close Reolink client (total client runtime 25minutes)
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
