# Agente Autonomo de Monitoramento de Sistema (2aMS)
# Criado para coletar informacoes completas sobre o status da maquina

# Configuracao de politica de execucao para o script atual
Set-ExecutionPolicy -ExecutionPolicy Bypass

# Funcao para exibir cabecalho
function Show-Header {
    param([string]$Title)
    Write-Host "`n" -ForegroundColor Green
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host "  $Title" -ForegroundColor Yellow
    Write-Host "=" * 60 -ForegroundColor Green
    Write-Host ""
}

# Funcao para criar diretorio de trabalho
function Initialize-WorkingDirectory {
    $computerName = $env:COMPUTERNAME
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $workingDir = Join-Path $PSScriptRoot "${computerName}_${currentDate}"
    
    if (-not (Test-Path $workingDir)) {
        New-Item -ItemType Directory -Path $workingDir -Force | Out-Null
        Write-Host "📁 Diretorio criado: $workingDir" -ForegroundColor Green
    }
    
    return $workingDir
}

# Funcao para salvar logs
function Write-Log {
    param([string]$Message, [string]$LogFile, [string]$WorkingDir)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullLogPath = Join-Path $WorkingDir $LogFile
    "[$timestamp] $Message" | Out-File -FilePath $fullLogPath -Append
}

# Funcao principal do agente
function Start-SystemAgent {
    $startTime = Get-Date
    $workingDir = Initialize-WorkingDirectory
    $logFile = "system_status_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
    
    Write-Host "🤖 Iniciando 2aMS..." -ForegroundColor Cyan
    Write-Host "📁 Usando diretorio: $workingDir" -ForegroundColor Cyan
    Write-Log "Agente iniciado" $logFile $workingDir
    
    try {
        # 1. Informacoes do Sistema Operacional
        Show-Header "INFORMACOES DO SISTEMA OPERACIONAL"
        $osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, WindowsBuildLabEx, TotalPhysicalMemory, CsProcessors
        $osInfo | Format-List
        Write-Log "Informacoes do SO coletadas: $($osInfo.WindowsProductName)" $logFile $workingDir
        
        # 2. Informacoes de Hardware
        Show-Header "INFORMACOES DE HARDWARE"
        
        # CPU
        Write-Host "🔧 Processador:" -ForegroundColor Yellow
        $cpu = Get-WmiObject -Class Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
        $cpu | Format-List
        
        # Memoria
        Write-Host "💾 Memoria:" -ForegroundColor Yellow
        $memory = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object Capacity, Speed, Manufacturer
        $totalMemoryGB = [math]::Round(($memory | Measure-Object Capacity -Sum).Sum / 1GB, 2)
        Write-Host "Memoria Total: $totalMemoryGB GB"
        $memory | Format-Table
        
        # Discos
        Write-Host "💿 Discos:" -ForegroundColor Yellow
        $disks = Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace, FileSystem
        $disks | ForEach-Object {
            $_.Size = [math]::Round($_.Size / 1GB, 2)
            $_.FreeSpace = [math]::Round($_.FreeSpace / 1GB, 2)
        }
        $disks | Format-Table
        
        Write-Log "Hardware coletado: CPU $($cpu.Name), RAM ${totalMemoryGB}GB" $logFile $workingDir
        
        # 3. Informacoes de Rede
        Show-Header "INFORMACOES DE REDE"
        $networkAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object Name, InterfaceDescription, LinkSpeed
        $networkAdapters | Format-Table
        
        $ipConfig = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1"} | Select-Object InterfaceAlias, IPAddress, PrefixLength
        $ipConfig | Format-Table
        
        Write-Log "Rede: $($networkAdapters.Count) adaptadores ativos" $logFile $workingDir
        
        # 4. Processos em Execucao
        Show-Header "PROCESSOS CRITICOS"
        $topProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet, Id
        $topProcesses | ForEach-Object {
            $_.WorkingSet = [math]::Round($_.WorkingSet / 1MB, 2)
        }
        $topProcesses | Format-Table
        
        Write-Log "Top 10 processos por CPU coletados" $logFile $workingDir
        
        # 5. Servicos do Sistema
        Show-Header "SERVICOS CRITICOS"
        $criticalServices = @('Spooler', 'BITS', 'Winmgmt', 'EventLog', 'Themes', 'AudioSrv')
        $services = Get-Service | Where-Object {$_.Name -in $criticalServices} | Select-Object Name, Status, StartType
        $services | Format-Table
        
        Write-Log "Servicos criticos verificados" $logFile $workingDir
        
        # 6. Performance do Sistema
        Show-Header "PERFORMANCE DO SISTEMA"
        
        # CPU Usage
        $cpuUsage = Get-Counter "\Processor(_Total)\% Processor Time" -SampleInterval 1 -MaxSamples 3
        $avgCpuUsage = [math]::Round(($cpuUsage.CounterSamples | Measure-Object CookedValue -Average).Average, 2)
        Write-Host "🔥 Uso medio da CPU: $avgCpuUsage%" -ForegroundColor $(if($avgCpuUsage -gt 80) {'Red'} elseif($avgCpuUsage -gt 60) {'Yellow'} else {'Green'})
        
        # Memory Usage
        $totalMemory = (Get-WmiObject -Class Win32_ComputerSystem).TotalPhysicalMemory
        $availableMemory = (Get-Counter "\Memory\Available MBytes").CounterSamples.CookedValue
        $memoryUsagePercent = [math]::Round((($totalMemory/1MB - $availableMemory) / ($totalMemory/1MB)) * 100, 2)
        Write-Host "🧠 Uso da Memoria: $memoryUsagePercent%" -ForegroundColor $(if($memoryUsagePercent -gt 85) {'Red'} elseif($memoryUsagePercent -gt 70) {'Yellow'} else {'Green'})
        
        Write-Log "Performance: CPU $avgCpuUsage%, RAM $memoryUsagePercent%" $logFile $workingDir
        
        # 7. Eventos do Sistema (ultimas 24h)
        Show-Header "EVENTOS CRITICOS (ULTIMAS 24H)"
        $yesterday = (Get-Date).AddDays(-1)
        $criticalEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2; StartTime=$yesterday} -MaxEvents 10 -ErrorAction SilentlyContinue
        if ($criticalEvents) {
            $criticalEvents | Select-Object TimeCreated, Id, LevelDisplayName, Message | Format-Table -Wrap
        } else {
            Write-Host "✅ Nenhum evento critico encontrado nas ultimas 24 horas" -ForegroundColor Green
        }
        
        Write-Log "Eventos criticos verificados" $logFile $workingDir
        
        # 8. Atualizacoes Pendentes
        Show-Header "ATUALIZACOES DO SISTEMA"
        try {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            $searchResult = $updateSearcher.Search("IsInstalled=0")
            
            if ($searchResult.Updates.Count -gt 0) {
                Write-Host "⚠️  $($searchResult.Updates.Count) atualizacoes pendentes encontradas" -ForegroundColor Yellow
                $searchResult.Updates | Select-Object Title, Description | Format-List
            } else {
                Write-Host "✅ Sistema atualizado" -ForegroundColor Green
            }
        } catch {
            Write-Host "❌ Nao foi possivel verificar atualizacoes: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # 9. Seguranca - Antivirus
        Show-Header "STATUS DE SEGURANCA"
        try {
            $antivirusStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
            if ($antivirusStatus) {
                Write-Host "🛡️  Windows Defender:" -ForegroundColor Yellow
                Write-Host "   Protecao em Tempo Real: $($antivirusStatus.RealTimeProtectionEnabled)" -ForegroundColor $(if($antivirusStatus.RealTimeProtectionEnabled) {'Green'} else {'Red'})
                Write-Host "   Ultima Verificacao: $($antivirusStatus.QuickScanStartTime)" -ForegroundColor Cyan
            }
        } catch {
            Write-Host "❌ Nao foi possivel verificar status do antivirus" -ForegroundColor Red
        }

    
        # 10. Resumo Final
        Show-Header "RESUMO DO DIAGNOSTICO"
        $endTime = Get-Date
        $duration = $endTime - $startTime
        
        Write-Host "📊 Relatorio de Status da Maquina" -ForegroundColor Cyan
        Write-Host "   Versao: $($osInfo.WindowsProductName) $($osInfo.WindowsVersion)" -ForegroundColor White
        Write-Host "   Build: $($osInfo.WindowsBuildLabEx)" -ForegroundColor White
        Write-Host "   Winget instalado: $($winget -match "winget version")" -ForegroundColor $(if($winget -match "winget version") {'Green'} else {'Red'})
        Write-Host "   Horario: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')" -ForegroundColor White
        Write-Host "   Duracao da analise: $([math]::Round($duration.TotalSeconds, 2)) segundos" -ForegroundColor White
        Write-Host "   Log salvo em: $(Join-Path $workingDir $logFile)" -ForegroundColor White
        
        # Status geral
        $overallStatus = "SAUDAVEL"
        $statusColor = "Green"
        
        if ($avgCpuUsage -gt 80 -or $memoryUsagePercent -gt 85) {
            $overallStatus = "ATENÇÃO"
            $statusColor = "Yellow"
        }
        
        if ($criticalEvents -and $criticalEvents.Count -gt 5) {
            $overallStatus = "CRITICO"
            $statusColor = "Red"
        }
        
        Write-Host "`n🎯 Status Geral do Sistema: $overallStatus" -ForegroundColor $statusColor
        
        Write-Log "Diagnostico concluido. Status: $overallStatus" $logFile $workingDir
        
        # Recomendacoes automaticas
        Show-Header "RECOMENDACOES AUTOMATICAS"
        
        if ($avgCpuUsage -gt 80) {
            Write-Host "⚠️  Alto uso de CPU detectado. Considere fechar aplicacoes desnecessarias." -ForegroundColor Yellow
        }
        
        if ($memoryUsagePercent -gt 85) {
            Write-Host "⚠️  Alto uso de memoria detectado. Considere reiniciar aplicacoes ou adicionar mais RAM." -ForegroundColor Yellow
        }
        
        $lowDiskSpace = $disks | Where-Object {($_.FreeSpace / $_.Size) -lt 0.1}
        if ($lowDiskSpace) {
            Write-Host "⚠️  Pouco espaço em disco detectado nos drives: $($lowDiskSpace.DeviceID -join ', ')" -ForegroundColor Yellow
        }
        
        Write-Host "`n✅ Diagnostico completo finalizado!" -ForegroundColor Green
        
    } catch {
        Write-Host "❌ Erro durante a execucao do agente: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO: $($_.Exception.Message)" $logFile $workingDir
    }
}

# Funcao para execucao continua (modo daemon)
function Start-ContinuousMonitoring {
    param(
        [int]$IntervalMinutes = 30
    )
    
    Write-Host "🔄 Iniciando monitoramento continuo (intervalo: $IntervalMinutes minutos)" -ForegroundColor Cyan
    Write-Host "Pressione Ctrl+C para parar" -ForegroundColor Yellow
    
    while ($true) {
        Start-SystemAgent
        Write-Host "`n⏰ Proxima verificacao em $IntervalMinutes minutos..." -ForegroundColor Cyan
        Start-Sleep -Seconds ($IntervalMinutes * 60)
    }
}

# Menu principal
function Show-Menu {
    Clear-Host
    Write-Host "🤖 AGENTE AUTONOMO DE MONITORAMENTO DE SISTEMA (2aMS)" -ForegroundColor Cyan
    Write-Host "=" * 50 -ForegroundColor Green
    Write-Host "1. Executar diagnostico completo (uma vez)" -ForegroundColor White
    Write-Host "2. Iniciar monitoramento continuo (30)" -ForegroundColor White
    Write-Host "3. Iniciar monitoramento continuo (60)" -ForegroundColor White
    Write-Host "4. Sair" -ForegroundColor White
    Write-Host "=" * 50 -ForegroundColor Green
    
    $choice = Read-Host "Escolha uma opção (1-4)"
    
    switch ($choice) {
        "1" { Start-SystemAgent }
        "2" { Start-ContinuousMonitoring -IntervalMinutes 30 }
        "3" { Start-ContinuousMonitoring -IntervalMinutes 60 }
        "4" { 
            Write-Host "Encerrando agente..." -ForegroundColor Yellow
            exit
        }
        default {
            Write-Host "❌ Opcao invalida!" -ForegroundColor Red
            Start-Sleep -Seconds 2
            Show-Menu
        }
    }
}

# Verificar se está sendo executado como administrador

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "⚠️  Para melhor funcionamento, execute como Administrador" -ForegroundColor Red
    Write-Host "Continuando com permissoes limitadas..." -ForegroundColor Yellow
    Start-Sleep -Seconds 3
}

# Iniciar o menu principal
Show-Menu