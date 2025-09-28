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
        "1" { Test-Ping1 }
        "2" { Test-Connection2 }
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
        
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
            # Tentar resolver o nome DNS do host
            try {
                $dnsInfo = Resolve-DnsName -Name $ip -ErrorAction Stop
                $hostName = $dnsInfo.NameHost
                if ([string]::IsNullOrEmpty($hostName)) {
                    $hostName = "Sem nome registrado"
                }
            }
            catch {
                $hostName = "Sem nome registrado"
            }
            
            Write-Host " - Conectado - Host: $hostName" -ForegroundColor Green
            "$ip - Conectado - Host: $hostName" | Out-File -FilePath $logFile -Append
        } else {
            Write-Host " - Desconectado" -ForegroundColor Red
            "$ip - Desconectado" | Out-File -FilePath $logFile -Append
        }
    }

    $del = Write-Host "Deseja apagar o arquivo de log? (S/N)"
    if ($del -eq "S" -or $del -eq "s") {
        Remove-Item -Path $logFile -Force
    }
    Write-Host "`nResultados salvos em: $logFile" -ForegroundColor Yellow
    Show-MainMenu
}

function Test-Connection2 {
    Clear-Host
    $base = Read-Host "Insira a base EX: 192.186 "
    
    # Criar nome do arquivo de log com data e hora
    $timestamp = Get-Date -Format "dd-MM-yyyy_HH-mm"
    $logFile = "subredes_${base}_${timestamp}.log"
    
    # Adicionar cabeçalho ao arquivo de log
    "Teste de ping em subredes realizado em $(Get-Date)" | Out-File -FilePath $logFile
    "Base: $base" | Out-File -FilePath $logFile -Append
    "------------------------------------------------" | Out-File -FilePath $logFile -Append

    for ($i=1; $i -le 254; $i++){
        $ip = $base + "." + $i + "." + 1
        Write-Host "Testando $ip" -NoNewline
        if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
            Write-Host " - Conectado" -ForegroundColor Green
            "$ip - Conectado" | Out-File -FilePath $logFile -Append
        } else {
            Write-Host " - Desconectado" -ForegroundColor Red
            "$ip - Desconectado" | Out-File -FilePath $logFile -Append
        }
    }
    
    $del = Write-Host "Deseja apagar o arquivo de log? (S/N)"
    if ($del -eq "S" -or $del -eq "s") {
        Remove-Item -Path $logFile -Force
    }
    Write-Host "`nResultados salvos em: $logFile" -ForegroundColor Yellow
    Show-MainMenu
}

Show-MainMenu
# 192.168.64.1