#include <AutoItConstants.au3>
#include <GUIConstantsEx.au3>
#include <MsgBoxConstants.au3>

;Author: Pavel Machala pavel.machala.ap@seznam.cz
;IMPORTANT Script works only on Windows 10 and screen resolution 1280x960

Example()

Func Example()

    Dim $Exit_Code =  false ;

    ;Run Reolink Client with the window maximized.
    Local $iPID = Run("C:\Program Files (x86)\Reolink Client\Reolink Client.exe", "", @SW_SHOWMAXIMIZED)

    ;Wait 1 seconds for the Reolink window to appear.
    WinWait("[CLASS:Reolink Client]", "", 1)

    ;Click Login
    MouseClick($MOUSE_CLICK_LEFT, 1141, 179, 1)
    Sleep(1000)

If $Exit_Code = false Then

   Do
	;Check if login succesfull otherwise attempt re-login
        ;NOTE!!! Pixel position must match login indication icon in Reolink Client. Use AutoIt Windows Info tool to locate coordinates.
	
        If PixelGetColor (1068, 136) = 12698049 Then

           MouseClick($MOUSE_CLICK_LEFT, 1141, 179, 1)
		   Sleep(1500)

        Else

			;Click Playback
			ControlClick("", "",1006,"",1)
			Sleep(2000)

			;Click Playback #second time due to Reolink client flaw to display Playback window on first attempt
			ControlClick("", "",1006,"",1)
			Sleep(2000)

			;Click Download List
			ControlClick("Reolink Client", "","[CLASS:Static; INSTANCE:140]","",1, 14,14)
			Sleep(2000)

			;Click Select All
			ControlClick("", "",1995,"",1)
			Sleep(500)

			; Click Download
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
   ;Survive second attept to disconnect you by Client gives you extra 5 minutes to dowload the stuff
   WinWait("Auto Stop","",0)
   sleep(1000);
   ControlClick("Auto Stop", "",2129,"",1,35,14)

   ;Giving another 5 minutes and then close Reolink Client (total client runtime 15minutes)
   sleep(300000)

   ; Close the Reolink Client process using the PID returned by Run.
    ProcessClose($iPID)

 EndFunc

Exit
