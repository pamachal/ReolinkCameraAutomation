#include <AutoItConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>

;Author: Pavel Machala pavel.machala.ap@seznam.cz
;IMPORTANT Script works only on Windows 10 and screen resolution 1280x960

Example()

Func Example()

    Dim $Exit_Code =  false ;

    ; Run Reolink Client with the window maximized.
    Local $iPID = Run("C:\Program Files (x86)\Reolink Client\Reolink Client.exe", "", @SW_SHOWMAXIMIZED)

    ;Wait 1 seconds for the Reolink window to appear.
    WinWait("[CLASS:Reolink Client]", "", 1)

    ; Click Login
	MouseClick($MOUSE_CLICK_LEFT, 1113, 180, 1)
    Sleep(2000)

If $Exit_Code = false Then

   Do
		;Check if login succesfull otherwise attempt re-login
        If PixelGetColor (1068, 136) = 12698049 Then

           ; Click Login
		   MouseClick($MOUSE_CLICK_LEFT, 1113, 180, 1)
		   Sleep(2000)

        Else

			;Click Settings
			ControlClick("", "",1018,"",1,171,69)
			Sleep(2000)

			;Click IF Alarm
		    MouseClick($MOUSE_CLICK_LEFT, 270, 507, 1)
			;ControlClick("", "",6045,"",1,33,29)
			Sleep(5000)

			;Set Sensitivity
			ControlSend("Device Settings", "", "[CLASS:msctls_trackbar32; INSTANCE:1]", "{DOWN 100}")
			Sleep(2000)

			;Set Sensitivity
			ControlSend("Device Settings", "", "[CLASS:msctls_trackbar32; INSTANCE:1]", "{UP 16}")
			Sleep(2000)

			;Click OK
			ControlClick("", "",7281,"",1)
			Sleep(1000)

			$Exit_Code = true;

		 EndIf
    Until $Exit_Code
   Else
EndIf

    ; Close the Reolink Client process using the PID returned by Run.
	Sleep(5000)
    ProcessClose($iPID)
 EndFunc   ;==>Example

Exit