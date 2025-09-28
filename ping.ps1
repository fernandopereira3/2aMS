Set-ExecutionPolicy -ExecutionPolicy Bypass

function Show-MainMenu {
    Clear-Host
    Write-Host "=================================================="
    Write-Host "1. Teste com local conhecido"
    Write-Host "2. Teste de locais"
    Write-Host "0. Sair"
    Write-Host "=================================================="
    
    $op = Read-Host "Escolha uma opcao (0-8)"
    
    switch ($op) {
        "1" { Test-Connection1; Read-Host "Pressione Enter para continuar"; Show-MainMenu }
        "2" { Test-Connection2; Read-Host "Pressione Enter para continuar"; Show-MainMenu }
        "0" { 
            Write-Host "Encerrando..."
            exit
        }
        default {
            Write-Host "Opcao invalida"
            Start-Sleep -Seconds 2
            Show-MainMenu
        }
    }
}

function Test-Connection1 {
    $base = Read-Host "Insira a base EX: 192.186 "
    $local = Read-Host "Insira o local"
   for ($i=1; $i -le 254; $i++){
    $ip = $base + "." + $local + "." + $i
    Write-Host "Testando $ip" -NoNewline
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        Write-Host " - Conectado"
    } else {
        Write-Host " - Desconectado"
    }
}}

function Test-Connection2 {
    $base = Read-Host "Insira a base EX: 192.186 "
    for ($i=1; $i -le 254; $i++){
        $ip = $base + "." + $i + "." + 1
        Write-Host "Testando $ip" -NoNewline
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
            Write-Host " - Conectado"
        } else {
            Write-Host " - Desconectado"
        }
        }
     }

Show-MainMenu
# 192.168.64.1