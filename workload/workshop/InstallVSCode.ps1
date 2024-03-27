# Download VSCode Sources
Invoke-WebRequest -Uri 'https://aka.ms/vscode-win32-x64-system-stable' -OutFile 'c:\windows\temp\VSCode_x64.exe'
# Wait 10s
Start-Sleep -Seconds 10
# Install VSCode silently
Start-Process -FilePath 'c:\windows\temp\VSCode_x64.exe' -Args '/verysilent /suppressmsgboxes /mergetasks=!runcode' -Wait -PassThru
