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
        "1" { Test-Ping1; Read-Host "Pressione Enter para continuar"; Show-MainMenu }
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

function Test-Ping1 {
    Clear-Host
    $base = Read-Host "Insira a base EX: 192.186 "
    $local = Read-Host "Insira o local"
    
    # Criar nome do arquivo de log com data e hora
    $timestamp = Get-Date -Format "dd-MM-yyyy_HH-mm"
    $logFile = "ping_log_${local}_${timestamp}.log"
    
    # Adicionar cabeçalho ao arquivo de log
    "Teste de ping realizado em $(Get-Date)" | Out-File -FilePath $logFile
    "Local: $local" | Out-File -FilePath $logFile -Append
    "------------------------------------------------" | Out-File -FilePath $logFile -Append
    
    for ($i=1; $i -le 254; $i++){
        $ip = $base + "." + $local + "." + $i
        Write-Host "Testando $ip" -NoNewline
        
        if (ping $ip -n 1 -a) {
            # Capturar a saída do comando ping para extrair o nome do host
            $pingOutput = ping $ip -n 1 -a | Out-String
            # Extrair o nome do host da saída do ping (se disponível)
            $hostName = "Desconhecido"
            if ($pingOutput -match "Disparando para ([^\s]+) \[") {
                $hostName = $matches[1]
            }
            
            Write-Host " - Conectado - Host: $hostName" -ForegroundColor Green
            "$ip - Conectado - Host: $hostName" | Out-File -FilePath $logFile -Append
        } else {
            Write-Host " - Desconectado" -ForegroundColor Red
            "$ip - Desconectado" | Out-File -FilePath $logFile -Append
        }
    }
    
    Write-Host "`nResultados salvos em: $logFile" -ForegroundColor Yellow
}

function Test-Connection2 {
    Clear-Host
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