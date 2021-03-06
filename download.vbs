'****************************************************************************************
' Definitions
'****************************************************************************************
vmArchive     = "latest.zip"
imageArchive  = "latest-32.zip"
useProxy      = False

'****************************************************************************************
' main()
'****************************************************************************************
CheckFolderExists("download")

Download vmArchive, "http://files.pharo.org/vm/pharo-spur32/win/", "./download"
Download imageArchive, "http://files.pharo.org/image/70/", "./download"

RecreateFolderExists("system")

Extract "./download/" & vmArchive 
Extract "./download/" & imageArchive

imageName = FirstImageNameInFolder(GetScriptPath & "\system\")

Set objShell = CreateObject("Wscript.Shell")
objShell.Run """" & GetScriptPath & "\system\Pharo.exe" & """" & " " & """" & GetScriptPath & "\system\" & imageName & """" & " " & """" & GetScriptPath & "\load.st" & """" 


'****************************************************************************************
' Find out the image name in the given directory
'****************************************************************************************
Function FirstImageNameInFolder(folderName)
	Set fso = CreateObject("Scripting.FileSystemObject")  
	Set folder = fso.GetFolder(folderName)  
	
	For each file In folder.Files 
		IF Right(file.Name, 6) = ".image" Then
			FirstImageNameInFolder = file.Name
			Exit For
		End if
	Next
End Function 

'****************************************************************************************
' Download a given file from the given base url into the given folder
'****************************************************************************************
Sub Download(file, url, folder)
	LogText "Downloading " & file & " from " & url
	WGetDownload url & file, folder  
End sub

Sub Extract(file)
	Unzip file, "./system"
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	WScript.Sleep 1000		 
End Sub

'****************************************************************************************
' Check that the download folder is empty, if not recreate it
'****************************************************************************************
Sub CheckFolderExists(folder)
	Set objFSO = CreateObject("Scripting.FileSystemObject")	
	folder = GetScriptPath & "\" & folder
	If objFSO.FolderExists(folder) = False Then
		LogText "Create folder " & folder
		objFSO.CreateFolder(folder)
		Exit Sub
	End if
End Sub

'****************************************************************************************
' Recreate a folder if it does not exist
'****************************************************************************************
Sub RecreateFolderExists(folder)
	Set objFSO = CreateObject("Scripting.FileSystemObject")	
	folder = GetScriptPath & "\" & folder
	If objFSO.FolderExists(folder) = False Then
		LogText "Create folder " & folder
		objFSO.CreateFolder(folder)
		Exit Sub
	End if
	
	If FolderEmpty(folder) = False then	
		objFSO.DeleteFolder folder
		WScript.Sleep 1000	'Delay necessary when cleaning the folder
		objFSO.CreateFolder(folder)		
	End if 
End Sub


'****************************************************************************************
' Unzip the given file
'****************************************************************************************
Sub Unzip(zipFile, folder)
	Set fso = CreateObject("Scripting.FileSystemObject")
	sourceFile = fso.GetAbsolutePathName(zipFile)
	destFolder = fso.GetAbsolutePathName(folder)
 
	Set objShell = CreateObject("Shell.Application")
	
	Set FilesInZip = objShell.NameSpace(sourceFile).Items()
	objShell.NameSpace(destFolder).copyHere FilesInZip, 16
End Sub

'****************************************************************************************
' Download the given URL using wget
'****************************************************************************************
Sub WGetDownload(url, folder)
	If useProxy = False Then
	   proxyOption = "--no-proxy"
	End if 
	Set objShell = CreateObject("Wscript.Shell")
	cmd = """" & GetScriptPath & "/bin/wget.exe" & """" & " " & proxyOption & " --directory-prefix=" & folder & " " & url  
	LogText cmd
	objShell.Run cmd, 0 , True
End sub

'****************************************************************************************
' Return the script path
'****************************************************************************************
Function GetScriptPath() 
	Set objShell = CreateObject("Wscript.Shell")
	strPath = Wscript.ScriptFullName
	Set objFSO = CreateObject("Scripting.FileSystemObject")
	Set objFile = objFSO.GetFile(strPath)
	GetScriptPath = objFSO.GetParentFolderName(objFile) 
End Function

'****************************************************************************************
' Return true if the folder is empty
'****************************************************************************************
Function FolderEmpty(folder)	
	Set objFSO  = CreateObject("Scripting.FileSystemObject")	
	If objFSO.FolderExists(folder) Then		
		Set objFolder = objFSO.GetFolder(folder)		
		If objFolder.Files.Count = 0 And objFolder.SubFolders.Count = 0 Then
			FolderEmpty = True
		Else
			FolderEmpty = False
		End If	
	End If
	Set objFSO = Nothing
End Function

'****************************************************************************************
' Debug output
'****************************************************************************************
Sub Debug(value) 
	If value = True then 
		WScript.Echo "True"
		Exit Sub
	end if 
	If value = False then 
		WScript.Echo "False"
		Exit Sub
	end if 
	WScript.Echo value
End Sub

'****************************************************************************************
' Log Text
'****************************************************************************************
Sub LogText(value)
	WScript.StdOut.Write value & vbCrLf 
End Sub 