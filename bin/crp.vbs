If GetOS = "Windows XP" Then
	CreateSRP
End If

If GetOS = "Windows Vista" Or GetOS = "Windows 7" Or GetOS = "Windows 8" Or GetOS = "Windows Server" Then
	If WScript.Arguments.length =0 Then
  		Set objShell = CreateObject("Shell.Application")
		objShell.ShellExecute "wscript.exe", """" & _
  		  WScript.ScriptFullName & """" & " uac","", "runas", 1
	Else
  		CreateSRP
  	End If
End If

Sub CreateSRP
	Set SRP = getobject("winmgmts:\\.\root\default:Systemrestore")
	sDesc = "Manual Restore Point"
	sDesc = InputBox ("Press 'OK' after Entering Name of Restore Point or Press 'Cancel' to Skip Restore Point Creation", "Manual Restore Point Creation","Enter Name of Restore Point Here")
	If Trim(sDesc) <> "" Then
		sOut = SRP.createrestorepoint (sDesc, 0, 100)
		If sOut <> 0 Then
	 		WScript.echo "Error " & sOut & _
	 		  ": Unable to create Restore Point."
		End If
	End If
End Sub

Function GetOS    
    Set objWMI = GetObject("winmgmts:{impersonationLevel=impersonate}!\\" & _
    	".\root\cimv2")
    Set colOS = objWMI.ExecQuery("Select * from Win32_OperatingSystem")
    For Each objOS in colOS
        If instr(objOS.Caption, "Windows 8") Then
        	GetOS = "Windows 8"
        ElseIf instr(objOS.Caption, "Windows 7") Then
        	GetOS = "Windows 7"    
        ElseIf instr(objOS.Caption, "Vista") Then
        	GetOS = "Windows Vista"
        ElseIf instr(objOS.Caption, "Windows XP") Then
      		GetOS = "Windows XP"
        ElseIf instr(objOS.Caption, "Server") Then
      		GetOS = "Windows Server"
        End If
	Next
End Function

Wscript.Quit