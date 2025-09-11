# Agente Autonomo de Monitoramento de Sistema (2aMS)
# Criado para coletar informacoes completas sobre o status da maquina

Set-ExecutionPolicy -ExecutionPolicy Bypass

function Show-Header {
    param([string]$Title)
    Write-Host ""
    Write-Host "$Title" -ForegroundColor Yellow -BackgroundColor DarkRed
    Write-Host ""
}

function Initialize-WorkingDirectory {
    $computerName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $workingDir = Join-Path $PSScriptRoot "${computerName}_${currentDate}"
    
    if (-not (Test-Path $workingDir)) {
        New-Item -ItemType Directory -Path $workingDir -Force | Out-Null
        Write-Host "Diretorio criado: $workingDir"
    }
    
    return $workingDir
}

function Write-Log {
    param([string]$Message, [string]$LogFile, [string]$WorkingDir)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $fullLogPath = Join-Path $WorkingDir $LogFile
    "[$timestamp] $Message" | Out-File -FilePath $fullLogPath -Append
}

function Get-SystemInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "INFORMACOES DO SISTEMA OPERACIONAL"
    try {
        $osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, WindowsBuildLabEx, TotalPhysicalMemory, CsProcessors
        Write-Host "Sistema Operacional: $($osInfo.WindowsProductName)"
        Write-Host "Versao: $($osInfo.WindowsVersion)"
        Write-Host "Build: $($osInfo.WindowsBuildLabEx)"
        Write-Host "Memoria Total: $([math]::Round($osInfo.TotalPhysicalMemory / 1GB, 2)) GB"
        Write-Host "Processadores: $($osInfo.CsProcessors)"
        Write-Log "Informacoes do SO coletadas: $($osInfo.WindowsProductName)" $LogFile $WorkingDir
        return $osInfo
    } catch {
        Write-Host "Erro ao coletar informacoes do sistema: $($_.Exception.Message)"
        return $null
    }
}

function Get-HardwareInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "INFORMACOES DE HARDWARE"
    
    try {
        # Informacoes do Sistema
        Write-Host "Sistema:"
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Manufacturer, Model, TotalPhysicalMemory, NumberOfProcessors
        Write-Host "Nome: $($computerSystem.Name)"
        Write-Host "Fabricante: $($computerSystem.Manufacturer)"
        Write-Host "Modelo: $($computerSystem.Model)"
        Write-Host "Memoria Total: $([math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)) GB"
        Write-Host "Numero de Processadores: $($computerSystem.NumberOfProcessors)"
        Write-Host ""
        
        # CPU
        Write-Host "Processador:"
        $cpu = Get-WmiObject -Class Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
        Write-Host "Nome: $($cpu.Name)"
        Write-Host "Nucleos: $($cpu.NumberOfCores)"
        Write-Host "Processadores Logicos: $($cpu.NumberOfLogicalProcessors)"
        Write-Host "Velocidade Maxima: $($cpu.MaxClockSpeed) MHz"
        Write-Host ""
        
        # Memoria
        Write-Host "Memoria:"
        $memory = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object Capacity, Speed, Manufacturer
        $totalMemoryGB = [math]::Round(($memory | Measure-Object Capacity -Sum).Sum / 1GB, 2)
        Write-Host "Memoria Total: $totalMemoryGB GB"
        foreach ($mem in $memory) {
            Write-Host "  Modulo: $([math]::Round($mem.Capacity / 1GB, 2)) GB - $($mem.Speed) MHz - $($mem.Manufacturer)"
        }
        Write-Host ""
        
        # Discos
        Write-Host "Discos:"
        $disks = Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace, FileSystem
        foreach ($disk in $disks) {
            if ($disk.Size -gt 0) {
                $sizeGB = [math]::Round($disk.Size / 1GB, 2)
                $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
                $usedPercent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 2)
                Write-Host "  Drive $($disk.DeviceID) - Total: $sizeGB GB - Livre: $freeGB GB - Usado: $usedPercent% - Sistema: $($disk.FileSystem)"
            }
        }
        
        Write-Log "Hardware coletado: Sistema $($computerSystem.Manufacturer) $($computerSystem.Model), CPU $($cpu.Name), RAM ${totalMemoryGB}GB" $LogFile $WorkingDir
        return @{ComputerSystem = $computerSystem; CPU = $cpu; Memory = $totalMemoryGB; Disks = $disks}
    } catch {
        Write-Host "Erro ao coletar informacoes de hardware: $($_.Exception.Message)"
        return $null
    }
}

function Get-NetworkInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "INFORMACOES DE REDE"
    try {
        $networkAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object Name, InterfaceDescription, LinkSpeed
        Write-Host "Adaptadores de Rede Ativos:"
        foreach ($adapter in $networkAdapters) {
            Write-Host "  Nome: $($adapter.Name)"
            Write-Host "  Descricao: $($adapter.InterfaceDescription)"
            Write-Host "  Velocidade: $($adapter.LinkSpeed)"
            Write-Host ""
        }
        
        $ipConfig = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1"} | Select-Object InterfaceAlias, IPAddress, PrefixLength
        Write-Host "Configuracao IP:"
        foreach ($ip in $ipConfig) {
            Write-Host "  Interface: $($ip.InterfaceAlias) - IP: $($ip.IPAddress)/$($ip.PrefixLength)"
        }
        
        Write-Log "Rede: $($networkAdapters.Count) adaptadores ativos" $LogFile $WorkingDir
        return $networkAdapters
    } catch {
        Write-Host "Erro ao coletar informacoes de rede: $($_.Exception.Message)"
        return $null
    }
}

function Get-ProcessInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "PROCESSOS CRITICOS"
    try {
        $topProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet, Id
        Write-Host "Top 10 Processos por CPU:"
        foreach ($process in $topProcesses) {
            $workingSetMB = [math]::Round($process.WorkingSet / 1MB, 2)
            $cpuTime = if ($process.CPU) { [math]::Round($process.CPU, 2) } else { "N/A" }
            Write-Host "  $($process.Name) (ID: $($process.Id)) - CPU: $cpuTime - RAM: $workingSetMB MB"
        }
        
        Write-Log "Top 10 processos por CPU coletados" $LogFile $WorkingDir
        return $topProcesses
    } catch {
        Write-Host "Erro ao coletar informacoes de processos: $($_.Exception.Message)"
        return $null
    }
}

function Get-ServiceInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "SERVICOS CRITICOS"
    try {
        $criticalServices = @('Spooler', 'BITS', 'Winmgmt', 'EventLog', 'Themes', 'AudioSrv')
        $services = Get-Service | Where-Object {$_.Name -in $criticalServices} | Select-Object Name, Status, StartType
        Write-Host "Servicos Criticos:"
        foreach ($service in $services) {
            Write-Host "  $($service.Name) - Status: $($service.Status) - Tipo: $($service.StartType)"
        }
        
        Write-Log "Servicos criticos verificados" $LogFile $WorkingDir
        return $services
    } catch {
        Write-Host "Erro ao coletar informacoes de servicos: $($_.Exception.Message)"
        return $null
    }
}

function Get-PerformanceInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "PERFORMANCE DO SISTEMA"
    try {
        # Memory Usage usando CimInstance
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $totalMemory = $computerSystem.TotalPhysicalMemory
        #$availableMemory = (Get-Counter "\Memory\Available MBytes").CounterSamples.CookedValue * 1MB
        #$usedMemory = $totalMemory - $availableMemory
        #$memoryUsagePercent = [math]::Round(($usedMemory / $totalMemory) * 100, 2)
        
        Write-Host "Uso da Memoria:"
        Write-Host "  Total: $([math]::Round($totalMemory / 1GB, 2)) GB"
        Write-Host "  Disponivel: $([math]::Round($availableMemory / 1GB, 2)) GB"
        Write-Host "  Em Uso: $([math]::Round($usedMemory / 1GB, 2)) GB ($memoryUsagePercent%)"
        
        Write-Log "Performance: RAM $memoryUsagePercent%" $LogFile $WorkingDir
        return $memoryUsagePercent
    } catch {
        Write-Host "Erro ao coletar informacoes de performance: $($_.Exception.Message)"
        return 0
    }
}

function Get-SystemEvents {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "EVENTOS CRITICOS DO SISTEMA"
    try {
        $criticalEvents = Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 10 -ErrorAction SilentlyContinue
        
        if ($criticalEvents) {
            Write-Host "Eventos criticos das ultimas 24 horas:"
            foreach ($event in $criticalEvents) {
                Write-Host "  ID: $($event.Id) - Nivel: $($event.LevelDisplayName) - Hora: $($event.TimeCreated.ToString('dd/MM/yyyy HH:mm:ss'))"
                Write-Host "  Mensagem: $($event.Message.Substring(0, [Math]::Min(100, $event.Message.Length)))..."
                Write-Host ""
            }
            Write-Log "$($criticalEvents.Count) eventos criticos encontrados" $LogFile $WorkingDir
        } else {
            Write-Host "Nenhum evento critico encontrado nas ultimas 24 horas"
            Write-Log "Nenhum evento critico encontrado" $LogFile $WorkingDir
        }
        
        return $criticalEvents
    } catch {
        Write-Host "Erro ao coletar eventos do sistema: $($_.Exception.Message)"
        return $null
    }
}

function Get-UpdateInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "ATUALIZACOES DO SISTEMA"
    try {
        # Verifica se o modulo PSWindowsUpdate esta disponivel
        if (Get-Module -ListAvailable -Name PSWindowsUpdate) {
            Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
            $updates = Get-WUList -ErrorAction SilentlyContinue
            
            if ($updates) {
                Write-Host "Atualizacoes pendentes encontradas: $($updates.Count)"
                foreach ($update in $updates | Select-Object -First 5) {
                    Write-Host "  - $($update.Title)"
                }
                Write-Log "$($updates.Count) atualizacoes pendentes" $LogFile $WorkingDir
                return $updates.Count
            } else {
                Write-Host "Nenhuma atualizacao pendente encontrada"
                Write-Log "Sistema atualizado" $LogFile $WorkingDir
                return 0
            }
        } else {
            # Metodo alternativo usando Windows Update Agent
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $updateSearcher = $updateSession.CreateUpdateSearcher()
            $searchResult = $updateSearcher.Search("IsInstalled=0")
            
            if ($searchResult.Updates.Count -gt 0) {
                Write-Host "Atualizacoes pendentes encontradas: $($searchResult.Updates.Count)"
                Write-Log "$($searchResult.Updates.Count) atualizacoes pendentes" $LogFile $WorkingDir
                return $searchResult.Updates.Count
            } else {
                Write-Host "Nenhuma atualizacao pendente encontrada"
                Write-Log "Sistema atualizado" $LogFile $WorkingDir
                return 0
            }
        }
    } catch {
        Write-Host "Erro ao verificar atualizacoes: $($_.Exception.Message)"
        Write-Host "Verificacao de atualizacoes nao disponivel"
        return 0
    }
}

function Get-SecurityInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "INFORMACOES DE SEGURANCA"
    try {
        # Verifica o status do Windows Defender
        $defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
        
        if ($defenderStatus) {
            Write-Host "Windows Defender:"
            Write-Host "  Protecao em tempo real: $($defenderStatus.RealTimeProtectionEnabled)"
            Write-Host "  Protecao baseada em comportamento: $($defenderStatus.BehaviorMonitorEnabled)"
            Write-Host "  Protecao de rede: $($defenderStatus.NISEnabled)"
            Write-Host "  Ultima verificacao: $($defenderStatus.QuickScanStartTime)"
            Write-Host "  Versao das definicoes: $($defenderStatus.AntivirusSignatureVersion)"
            
            Write-Log "Windows Defender ativo - Protecao em tempo real: $($defenderStatus.RealTimeProtectionEnabled)" $LogFile $WorkingDir
        } else {
            Write-Host "Nao foi possivel obter informacoes do Windows Defender"
        }
        
        # Verifica o Firewall do Windows
        $firewallProfiles = Get-NetFirewallProfile -ErrorAction SilentlyContinue
        if ($firewallProfiles) {
            Write-Host "\nFirewall do Windows:"
            foreach ($profile in $firewallProfiles) {
                Write-Host "  $($profile.Name): $($profile.Enabled)"
            }
            Write-Log "Firewall verificado" $LogFile $WorkingDir
        }
        
        return $defenderStatus
    } catch {
        Write-Host "Erro ao coletar informacoes de seguranca: $($_.Exception.Message)"
        return $null
    }
}

function Show-SystemSummary {
    param($osInfo, $hardwareInfo, $memoryUsage, $criticalEvents, $updateCount, $logFile, $workingDir, $startTime)
    
    Show-Header "RESUMO DO DIAGNOSTICO"
    $endTime = Get-Date
    $duration = $endTime - $startTime
    
    Write-Host "Relatorio de Status da Maquina"
    if ($osInfo) {
        Write-Host "   Versao: $($osInfo.WindowsProductName) $($osInfo.WindowsVersion)"
        Write-Host "   Build: $($osInfo.WindowsBuildLabEx)"
    }
    Write-Host "   Horario: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')"
    Write-Host "   Duracao da analise: $([math]::Round($duration.TotalSeconds, 2)) segundos"
    Write-Host "   Log salvo em: $(Join-Path $workingDir $logFile)"
    
    # Status geral
    $overallStatus = "SAUDAVEL"
    
    if ($memoryUsage -and $memoryUsage -gt 85) {
        $overallStatus = "ATENCAO"
    }
    
    if ($criticalEvents -and $criticalEvents.Count -gt 5) {
        $overallStatus = "CRITICO"
    }
    
    Write-Host "Status Geral do Sistema: $overallStatus"
    Write-Log "Diagnostico concluido. Status: $overallStatus" $logFile $workingDir
    
    # Recomendacoes
    Show-Header "RECOMENDACOES AUTOMATICAS"
    
    if ($memoryUsage -and $memoryUsage -gt 85) {
        Write-Host "Alto uso de memoria detectado ($memoryUsage%). Considere reiniciar aplicacoes ou adicionar mais RAM."
    }
    
    if ($hardwareInfo -and $hardwareInfo.Disks) {
        foreach ($disk in $hardwareInfo.Disks) {
            if ($disk.Size -gt 0) {
                $freePercent = ($disk.FreeSpace / $disk.Size) * 100
                if ($freePercent -lt 10) {
                    Write-Host "Pouco espaco em disco detectado no drive $($disk.DeviceID): $([math]::Round($freePercent, 2))% livre"
                }
            }
        }
    }
    
    if ($updateCount -and $updateCount -gt 0) {
        Write-Host "Existem $updateCount atualizacoes pendentes. Considere instalar."
    }
    
    Write-Host "Diagnostico completo finalizado"
}

function Get-SystemFolders {
    param([string]$LogFile, [string]$WorkingDir)
    
    Show-Header "PRINCIPAIS PASTAS DO SISTEMA"
    try {
        $systemFolders = @(
            "C:\",
            "C:\Windows",
            "C:\Windows\System32",
            "C:\Program Files",
            "C:\Program Files (x86)",
            "C:\Users",
            "C:\ProgramData",
            "C:\Temp",
            "$env:USERPROFILE",
            "$env:USERPROFILE\OneDrive\Desktop",
            "$env:USERPROFILE\OneDrive\Documents",
            "$env:USERPROFILE\OneDrive\Pictures",
            "$env:USERPROFILE\OneDrive\Downloads",
            "$env:USERPROFILE\Desktop",
            "$env:USERPROFILE\Documents",
            "$env:USERPROFILE\Pictures",
            "$env:USERPROFILE\Downloads",
            "$env:APPDATA",
            "$env:LOCALAPPDATA"
        )
        
        foreach ($folder in $systemFolders) {
            if (Test-Path $folder) {
                try {
                    $items = Get-ChildItem -Path $folder -ErrorAction SilentlyContinue | Measure-Object
                    $folderSize = Get-ChildItem -Path $folder -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum
                    $sizeGB = if ($folderSize.Sum) { [math]::Round($folderSize.Sum / 1GB, 2) } else { 0 }
                    
                    Write-Host "Pasta: $folder" 
                    Write-Host "  Itens: $($items.Count)"
                    Write-Host "  Tamanho: $sizeGB GB" -ForegroundColor Red
                    Write-Host ""
                    
                    Write-Log "Pasta $folder $($items.Count) itens, $sizeGB GB" $LogFile $WorkingDir
                } catch {
                    Write-Host "Pasta: $folder - Acesso negado ou erro"
                    Write-Host ""
                }
            } else {
                Write-Host "Pasta: $folder - Nao encontrada"
                Write-Host ""
            }
        }
        
        Write-Log "Analise de pastas do sistema concluida" $LogFile $WorkingDir
        return $systemFolders
    } catch {
        Write-Host "Erro ao analisar pastas do sistema: $($_.Exception.Message)"
        return $null
    }
}

function Start-SystemAgent {
    $startTime = Get-Date
    $workingDir = Initialize-WorkingDirectory
    $userName = $env:USERNAME
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $logFile = "${userName}_${currentDate}.log"
    
    Write-Host "Iniciando 2aMS..."
    Write-Host "Usando diretorio: $workingDir"
    Write-Host "Log sera salvo como: $logFile"
    Write-Log "Agente iniciado pelo usuario $userName" $logFile $workingDir
    
    try {
        $osInfo = Get-SystemInfo $logFile $workingDir
        $hardwareInfo = Get-HardwareInfo $logFile $workingDir
        $networkInfo = Get-NetworkInfo $logFile $workingDir
        $processInfo = Get-ProcessInfo $logFile $workingDir
        $serviceInfo = Get-ServiceInfo $logFile $workingDir
        $memoryUsage = Get-PerformanceInfo $logFile $workingDir
        $systemFolders = Get-SystemFolders $logFile $workingDir
        $criticalEvents = Get-SystemEvents $logFile $workingDir
        $updateCount = Get-UpdateInfo $logFile $workingDir
        $securityInfo = Get-SecurityInfo $logFile $workingDir
        
        Show-SystemSummary $osInfo $hardwareInfo $memoryUsage $criticalEvents $updateCount $logFile $workingDir $startTime
        
    } catch {
        Write-Host "Erro durante a execucao do agente: $($_.Exception.Message)"
        Write-Log "ERRO: $($_.Exception.Message)" $logFile $workingDir
    }
}

function Start-ContinuousMonitoring {
    param([int]$IntervalMinutes = 30)
    
    Write-Host "Iniciando monitoramento continuo (intervalo: $IntervalMinutes minutos)"
    Write-Host "Pressione Ctrl+C para parar"
    
    while ($true) {
        Start-SystemAgent
        Write-Host "Proxima verificacao em $IntervalMinutes minutos..."
        Start-Sleep -Seconds ($IntervalMinutes * 60)
    }
}

function Install-BasePrograms {
    winget install --id Google.Chrome --verbose --silent --force --accept-source-agreements
    winget install --id Microsoft.VCRedist.2012.x64 --verbose --silent --force --accept-source-agreements
    winget install --id Microsoft.VCRedist.2013.x64 --verbose --silent --force --accept-source-agreements
    winget install --id Microsoft.VCRedist.2015+.x64 --verbose --silent --force --accept-source-agreements
    winget install --id Spotify.Spotify --verbose --silent --force --accept-source-agreements
    winget install --id Discord.Discord --verbose --silent --force --accept-source-agreements
    winget install --id RARLab.WinRAR --verbose --silent --force --accept-source-agreements
    winget install --id Valve.Steam --verbose --silent --force --accept-source-agreements
    winget install --id Microsoft.Office --verbose --silent --force --accept-source-agreements
}

function Import-BasePrograms{
   winget import -i .\packages.json --ignore-unavailable 
}

function Save-Files{
     Write-Host "Indo ao servidor, verifique que esta tudo certo."
     $Server = "//10.0.0.2/programas/AUTO_BACKUP"
     cd $Server
     $computerName = $env:COMPUTERNAME
     $dateTime = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
     $folderName = "${computerName}_${dateTime}"
     Write-Host "Criando pasta $folderName"
     mkdir $folderName
     
     # Definir as pastas do sistema (mesmo array usado na função Get-SystemFolders)
     $systemFolders = @(
         "$env:USERPROFILE\Documents",
         "$env:USERPROFILE\Pictures", 
         "$env:USERPROFILE\Downloads",
         "$env:USERPROFILE\Desktop",
         "$env:USERPROFILE\Favorites",
         "$env:USERPROFILE\Music",
         "$env:USERPROFILE\Videos",
         "$env:USERPROFILE\Contacts",
         "$env:USERPROFILE\OneDrive",
         "$env:APPDATA",
         "$env:LOCALAPPDATA"
     )
     
     Write-Host "Agora copiando arquivos..."
     # Copiar cada pasta do sistema que existe
     foreach ($folder in $systemFolders) {
         if (Test-Path $folder) {
             try {
                 $folderName_safe = Split-Path $folder -Leaf
                 Copy-Item -Path $folder -Destination ".\$folderName\$folderName_safe" -Recurse -Force -Confirm:$false -ErrorAction SilentlyContinue
                 Write-Host "Copiado: $folder"
             } catch {
                 Write-Host "Erro ao copiar: $folder - $($_.Exception.Message)"
             }
         } else {
             Write-Host "Pasta não encontrada: $folder"
         }
     }
     Write-Host "Finalizado, verifique a integridade dos arquivos e se tudo esta certo."
}

function Show-QuickMenu {
    Clear-Host
    Write-Host "2aMS - MENU RAPIDO"
    Write-Host "=================="
    Write-Host "1. Diagnostico Completo"
    Write-Host "2. Apenas Hardware"
    Write-Host "3. Apenas Performance"
    Write-Host "4. Apenas Rede"
    Write-Host "5. Apenas Pastas do Sistema"
    Write-Host "6. Menu Principal"
    Write-Host "0. Sair"
    Write-Host "=================="
    
    $choice = Read-Host "Escolha uma opcao (0-6)"
    
    switch ($choice) {
        "1" { Start-SystemAgent; Read-Host "Pressione Enter para continuar"; Show-QuickMenu }
        "2" { 
            $workingDir = Initialize-WorkingDirectory
            $userName = $env:USERNAME
            $currentDate = Get-Date -Format "yyyy-MM-dd"
            $logFile = "${userName}_${currentDate}_hardware.log"
            Get-HardwareInfo $logFile $workingDir
            Read-Host "Pressione Enter para continuar"
            Show-QuickMenu 
        }
        "3" { 
            $workingDir = Initialize-WorkingDirectory
            $userName = $env:USERNAME
            $currentDate = Get-Date -Format "yyyy-MM-dd"
            $logFile = "${userName}_${currentDate}_performance.log"
            Get-PerformanceInfo $logFile $workingDir
            Read-Host "Pressione Enter para continuar"
            Show-QuickMenu 
        }
        "4" { 
            $workingDir = Initialize-WorkingDirectory
            $userName = $env:USERNAME
            $currentDate = Get-Date -Format "yyyy-MM-dd"
            $logFile = "${userName}_${currentDate}_network.log"
            Get-NetworkInfo $logFile $workingDir
            Read-Host "Pressione Enter para continuar"
            Show-QuickMenu 
        }
        "5" { 
            $workingDir = Initialize-WorkingDirectory
            $userName = $env:USERNAME
            $currentDate = Get-Date -Format "yyyy-MM-dd"
            $logFile = "${userName}_${currentDate}_folders.log"
            Get-SystemFolders $logFile $workingDir
            Read-Host "Pressione Enter para continuar"
            Show-QuickMenu 
        }
        "6" { Show-MainMenu }
        "0" { 
            Write-Host "Encerrando agente..."
            exit
        }
        default {
            Write-Host "Opcao invalida"
            Start-Sleep -Seconds 2
            Show-QuickMenu
        }
    }
}

function Show-MainMenu {
    Clear-Host
    Write-Host "AGENTE AUTONOMO DE MONITORAMENTO DE SISTEMA (2aMS)"
    Write-Host "=================================================="
    Write-Host "OPCOES PRINCIPAIS:"
    Write-Host "1. Diagnostico Completo (uma vez)"
    Write-Host "2. Monitoramento Continuo (30 min)"
    Write-Host "3. Monitoramento Continuo (60 min)"
    Write-Host "4. Instalar Programas Bases"
    Write-Host "5. Salvar Arquivos"
    Write-Host "6. Menu Rapido"
    Write-Host "7. Configuracoes"
    Write-Host "0. Sair"
    Write-Host "=================================================="
    
    $choice = Read-Host "Escolha uma opcao (0-7)"
    
    switch ($choice) {
        "1" { Start-SystemAgent; Read-Host "Pressione Enter para continuar"; Show-MainMenu }
        "2" { Start-ContinuousMonitoring -IntervalMinutes 30 }
        "3" { Start-ContinuousMonitoring -IntervalMinutes 60 }
        "4" { Install-BasePrograms }
        "5" { Save-Files }
        "6" { Show-QuickMenu }
        "7" { Show-ConfigMenu }
        "0" { 
            Write-Host "Encerrando agente..."
            exit
        }
        default {
            Write-Host "Opcao invalida"
            Start-Sleep -Seconds 2
            Show-MainMenu
        }
    }
}

function Show-ConfigMenu {
    Clear-Host
    Write-Host "CONFIGURACOES DO 2aMS"
    Write-Host "====================="
    Write-Host "1. Limpar logs antigos"
    Write-Host "2. Verificar permissoes"
    Write-Host "3. Testar conectividade"
    Write-Host "4. Voltar ao menu principal"
    Write-Host "====================="
    
    $choice = Read-Host "Escolha uma opcao (1-4)"
    
    switch ($choice) {
        "1" { 
            Get-ChildItem $PSScriptRoot -Filter "*_*" -Directory | Where-Object {$_.CreationTime -lt (Get-Date).AddDays(-7)} | Remove-Item -Recurse -Force
            Write-Host "Logs antigos removidos"
            Read-Host "Pressione Enter para continuar"
            Show-ConfigMenu
        }
        "2" { 
            if (([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
                Write-Host "Executando como Administrador - OK"
            } else {
                Write-Host "Executando com permissoes limitadas"
            }
            Read-Host "Pressione Enter para continuar"
            Show-ConfigMenu
        }
        "3" { 
            Test-NetConnection -ComputerName "8.8.8.8" -Port 53
            Read-Host "Pressione Enter para continuar"
            Show-ConfigMenu
        }
        "4" { Show-MainMenu }
        default {
            Write-Host "Opcao invalida"
            Start-Sleep -Seconds 2
            Show-ConfigMenu
        }
    }
}

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Para melhor funcionamento, execute como Administrador"
    Write-Host "Continuando com permissoes limitadas..."
    Start-Sleep -Seconds 3
}

Show-MainMenu