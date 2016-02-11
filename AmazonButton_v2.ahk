/*
Amazon Button v2
The button stays offline until it 
Summary:
Command line usage:
AmazonButton_v2.exe IPaddress program_to_launch.exe
AmazonButton_v2.exe 192.168.1.100 calc.exe

*/
#SingleInstance Off
PingResults:="PingResults.txt" 
PingErr1:="Destination host unreachable"
PingErr2:="Request Timed Out"
PingErr3:="TTL Expired in Transit"
PingErr4:="Unknown Host"
PingErr5:="Ping Request could not find host"
Clickcount = 0


Main:
{	
	;FileDelete,%PingResults% ;Just in case the file is still there from a failed run 
	If 0 > 0
	{
		Computername = %1%
		;msgbox, Checking %computername% is on or not
		;computername = 192.168.1.172
		Goto Checkcomp
	}
	else
	{
		Msgbox, Must be run in command line with switches `n`nAmazonButton_v2 [Button IP] [Program to Launch]
		ExitApp
	}
}
Return

Checkcomp:
		gosub CheckCompison
		;Msgbox, Computer %ComputerName% is back online! :D 
		;run calc
		/*tooltip, 
		clickcount++
		tooltip, clickcount = %clickcount%
		*/
		run %2%
		gosub CheckCompisbackoff
goto main ;reset program after 5 seconds

;-----------------------------------------------------------------------------------------------------------------------------
;----------------------------------------------------------Subroutines ----------------------------------------------------------
;------------------------------------------------------------------------------------------------------------------------------

CheckCompison:
;tooltip, 
Loop
{
	pingCommand := "ping -n 1 " . ComputerName
	resultFromCommand := StdoutToVar_CreateProcess( pingCommand )

	PingError:=false

	IfInString,resultFromCommand,%PingErr1%
	{
		PingError:=true
		;msgbox, failed %PingErr1%
	}
	IfInString,resultFromCommand,%PingErr2%
	{
		PingError:=true
		;msgbox, failed %PingErr2%
	}
	IfInString,resultFromCommand,%PingErr3%
	{
		PingError:=true
		;msgbox, failed %PingErr3%
	}
	IfInString,resultFromCommand,%PingErr4%
	{
		PingError:=true
		;msgbox, failed %PingErr4%
	}
	IfInString,resultFromCommand,%PingErr5%
	{
		PingError:=true
		;msgbox, failed %PingErr5%
	}

	If PingError != 1
	{
		;msgbox, okay computer is back on break out of this constant check for device
		break
	}  
}
return

CheckCompisbackoff:
Loop
{
	sleep 2000
	pingCommand := "ping -n 1 " . ComputerName
	resultFromCommand := StdoutToVar_CreateProcess( pingCommand )

	PingError:=false

	IfInString,resultFromCommand,%PingErr1%
	{
		PingError:=true
		;msgbox, failed %PingErr1%
	}
	IfInString,resultFromCommand,%PingErr2%
	{
		PingError:=true
		;msgbox, failed %PingErr2%
	}
	IfInString,resultFromCommand,%PingErr3%
	{
		PingError:=true
		;msgbox, failed %PingErr3%
	}
	IfInString,resultFromCommand,%PingErr4%
	{
		PingError:=true
		;msgbox, failed %PingErr4%
	}
	IfInString,resultFromCommand,%PingErr5%
	{
		PingError:=true
		;msgbox, failed %PingErr5%
	}

	If PingError != 0
	{
		;msgbox, okay computer is back off break out of loop checking for no connection
		break
	}  
}
Return



; ----------------------------------------------------------------------------------------------------------------------
; Function .....: StdoutToVar_CreateProcess
; Description ..: Runs a command line program and returns its output.
; Parameters ...: sCmd      - Commandline to execute.
; ..............: sEncoding - Encoding used by the target process. Look at StrGet() for possible values.
; ..............: sDir      - Working directory.
; ..............: nExitCode - Process exit code, receive it as a byref parameter.
; Return .......: Command output as a string on success, empty string on error.
; AHK Version ..: AHK_L x32/64 Unicode/ANSI
; Author .......: Sean (http://goo.gl/o3VCO8), modified by nfl and by Cyruz
; License ......: WTFPL - http://www.wtfpl.net/txt/copying/
; Changelog ....: Feb. 20, 2007 - Sean version.
; ..............: Sep. 21, 2011 - nfl version.
; ..............: Nov. 27, 2013 - Cyruz version (code refactored and exit code).
; ..............: Mar. 09, 2014 - Removed input, doesn't seem reliable. Some code improvements.
; ..............: Mar. 16, 2014 - Added encoding parameter as pointed out by lexikos.
; ..............: Jun. 02, 2014 - Corrected exit code error.
; ----------------------------------------------------------------------------------------------------------------------
StdoutToVar_CreateProcess(sCmd, sEncoding:="CP0", sDir:="", ByRef nExitCode:=0) {
    DllCall( "CreatePipe",           PtrP,hStdOutRd, PtrP,hStdOutWr, Ptr,0, UInt,0 )
    DllCall( "SetHandleInformation", Ptr,hStdOutWr, UInt,1, UInt,1                 )
 
            VarSetCapacity( pi, (A_PtrSize == 4) ? 16 : 24,  0 )
    siSz := VarSetCapacity( si, (A_PtrSize == 4) ? 68 : 104, 0 )
    NumPut( siSz,      si,  0,                          "UInt" )
    NumPut( 0x100,     si,  (A_PtrSize == 4) ? 44 : 60, "UInt" )
    NumPut( hStdInRd,  si,  (A_PtrSize == 4) ? 56 : 80, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 60 : 88, "Ptr"  )
    NumPut( hStdOutWr, si,  (A_PtrSize == 4) ? 64 : 96, "Ptr"  )
 
    If ( !DllCall( "CreateProcess", Ptr,0, Ptr,&sCmd, Ptr,0, Ptr,0, Int,True, UInt,0x08000000
                                  , Ptr,0, Ptr,sDir?&sDir:0, Ptr,&si, Ptr,&pi ) )
        Return ""
      , DllCall( "CloseHandle", Ptr,hStdOutWr )
      , DllCall( "CloseHandle", Ptr,hStdOutRd )
 
    DllCall( "CloseHandle", Ptr,hStdOutWr ) ; The write pipe must be closed before reading the stdout.
    VarSetCapacity(sTemp, 4095)
    While ( DllCall( "ReadFile", Ptr,hStdOutRd, Ptr,&sTemp, UInt,4095, PtrP,nSize, Ptr,0 ) )
        sOutput .= StrGet(&sTemp, nSize, sEncoding)
 
    DllCall( "GetExitCodeProcess", Ptr,NumGet(pi,0), UIntP,nExitCode )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,0)                  )
    DllCall( "CloseHandle",        Ptr,NumGet(pi,A_PtrSize)          )
    DllCall( "CloseHandle",        Ptr,hStdOutRd                     )
    Return sOutput
}