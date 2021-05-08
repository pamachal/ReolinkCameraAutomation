#include <AutoItConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>
#Include <GuiListView.au3>
#include <Date.au3>

;Author: Pavel Machala pavel.machala.ap@seznam.cz
;IMPORTANT Script works only on Windows 10 and screen resolution 1280x960

Example()

Func Example()

    Dim $Exit_Code =  false ;
	Dim $TotalCountOfCheckedItems =  0 ;

    ; Run Reolink Client with the window maximized.
    Local $iPID = Run("C:\Program Files (x86)\Reolink Client\Reolink Client.exe", "", @SW_SHOWMAXIMIZED)

	;Wait 1 seconds for the Reolink window to appear.
    WinWait("[CLASS:Reolink Client]", "", 1)

    ; Click Login
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
			Sleep(5000)

			$hWnd = WinGetHandle("Download file")
			$hListView = ControlGetHandle($hWnd,"","[CLASS:SysListView32; INSTANCE:1]")
			$TotalCountOfItems = ControlListView($hWnd,"",$hListView,"GetItemCount")

			For $i = 0 To $TotalCountOfItems

			   $ItemDate = ControlListView($hWnd,"",$hListView,"GetText",$i,1)
			   ;MsgBox($MB_SYSTEMMODAL ,"ItemDate", $ItemDate )

			   $CurrentDate = _NowCalc ( );
			   ;MsgBox($MB_SYSTEMMODAL ,"Current Date", $CurrentDate)

			   $ItemDateTransformed = _DateTimeFormatEx( $ItemDate , "yyyy/MM/dd H:mm:ss")
			   ;MsgBox($MB_SYSTEMMODAL ,"ItemDateTransformed", $ItemDateTransformed)

			   $diff=_dateDiff("s",$ItemDateTransformed,$CurrentDate)
			   ;MsgBox($MB_SYSTEMMODAL, "Video file time difference", $diff)

			   if $diff >3600 then
				  ;MsgBox(0,'','Older than current date minus 1hours - skip the file')
			   Else
				  ;MsgBox(0,'','Younger than current date minus 1hours ')
				  _GUICtrlListView_SetItemChecked($hListView, $i)
				  $TotalCountOfCheckedItems = $TotalCountOfCheckedItems + 1
			   Endif

			 Next

			;Click Download
			ControlClick("", "",1997,"",1)

			$Exit_Code = true;

		 EndIf
    Until $Exit_Code
   Else
   EndIf

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

   If $TotalCountOfCheckedItems >40 then
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