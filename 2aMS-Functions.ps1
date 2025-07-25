# Agente Autonomo de Monitoramento de Sistema (2aMS) - Funcoes de Diagnostico
# Criado para coletar informacoes completas sobre o status da maquina

Set-ExecutionPolicy -ExecutionPolicy Bypass

function Initialize-WorkingDirectory {
    $computerName = $env:COMPUTERNAME
    $userName = $env:USERNAME
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $workingDir = Join-Path $PSScriptRoot "${computerName}_${currentDate}"
    
    if (-not (Test-Path $workingDir)) {
        New-Item -ItemType Directory -Path $workingDir -Force | Out-Null
    }
    
    return $workingDir
}

function Write-Log {
    param([string]$Message, [string]$LogFile, [string]$WorkingDir)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $userName = $env:USERNAME
    $currentDate = Get-Date -Format "yyyy-MM-dd"
    $logFileName = "${userName}_${currentDate}.log"
    $fullLogPath = Join-Path $WorkingDir $logFileName
    "[$timestamp] $Message" | Out-File -FilePath $fullLogPath -Append
}

function Get-SystemInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $osInfo = Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, WindowsBuildLabEx, TotalPhysicalMemory, CsProcessors
        $result = @()
        $result += "Sistema Operacional: $($osInfo.WindowsProductName)"
        $result += "Versao: $($osInfo.WindowsVersion)"
        $result += "Build: $($osInfo.WindowsBuildLabEx)"
        $result += "Memoria Total: $([math]::Round($osInfo.TotalPhysicalMemory / 1GB, 2)) GB"
        $result += "Processadores: $($osInfo.CsProcessors)"
        Write-Log "Informacoes do SO coletadas: $($osInfo.WindowsProductName)" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar informacoes do sistema: $($_.Exception.Message)"
    }
}

function Get-HardwareInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        
        # Informacoes do Sistema
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem | Select-Object Name, Manufacturer, Model, TotalPhysicalMemory, NumberOfProcessors
        $result += "=== SISTEMA ==="
        $result += "Nome: $($computerSystem.Name)"
        $result += "Fabricante: $($computerSystem.Manufacturer)"
        $result += "Modelo: $($computerSystem.Model)"
        $result += "Memoria Total: $([math]::Round($computerSystem.TotalPhysicalMemory / 1GB, 2)) GB"
        $result += "Numero de Processadores: $($computerSystem.NumberOfProcessors)"
        $result += ""
        
        # CPU
        $cpu = Get-WmiObject -Class Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
        $result += "=== PROCESSADOR ==="
        $result += "Nome: $($cpu.Name)"
        $result += "Nucleos: $($cpu.NumberOfCores)"
        $result += "Processadores Logicos: $($cpu.NumberOfLogicalProcessors)"
        $result += "Velocidade Maxima: $($cpu.MaxClockSpeed) MHz"
        $result += ""
        
        # Memoria
        $memory = Get-WmiObject -Class Win32_PhysicalMemory | Select-Object Capacity, Speed, Manufacturer
        $totalMemoryGB = [math]::Round(($memory | Measure-Object Capacity -Sum).Sum / 1GB, 2)
        $result += "=== MEMORIA ==="
        $result += "Memoria Total: $totalMemoryGB GB"
        foreach ($mem in $memory) {
            $result += "  Modulo: $([math]::Round($mem.Capacity / 1GB, 2)) GB - $($mem.Speed) MHz - $($mem.Manufacturer)"
        }
        $result += ""
        
        # Discos
        $disks = Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace, FileSystem
        $result += "=== DISCOS ==="
        foreach ($disk in $disks) {
            if ($disk.Size -gt 0) {
                $sizeGB = [math]::Round($disk.Size / 1GB, 2)
                $freeGB = [math]::Round($disk.FreeSpace / 1GB, 2)
                $usedPercent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 2)
                $result += "  Drive $($disk.DeviceID) - Total: $sizeGB GB - Livre: $freeGB GB - Usado: $usedPercent% - Sistema: $($disk.FileSystem)"
            }
        }
        
        Write-Log "Hardware coletado: Sistema $($computerSystem.Manufacturer) $($computerSystem.Model), CPU $($cpu.Name), RAM ${totalMemoryGB}GB" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar informacoes de hardware: $($_.Exception.Message)"
    }
}

function Get-NetworkInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        
        $networkAdapters = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object Name, InterfaceDescription, LinkSpeed
        $result += "=== ADAPTADORES DE REDE ATIVOS ==="
        foreach ($adapter in $networkAdapters) {
            $result += "Nome: $($adapter.Name)"
            $result += "Descricao: $($adapter.InterfaceDescription)"
            $result += "Velocidade: $($adapter.LinkSpeed)"
            $result += ""
        }
        
        $ipConfig = Get-NetIPAddress | Where-Object {$_.AddressFamily -eq "IPv4" -and $_.IPAddress -ne "127.0.0.1"} | Select-Object InterfaceAlias, IPAddress, PrefixLength
        $result += "=== CONFIGURACAO IP ==="
        foreach ($ip in $ipConfig) {
            $result += "Interface: $($ip.InterfaceAlias) - IP: $($ip.IPAddress)/$($ip.PrefixLength)"
        }
        
        Write-Log "Rede: $($networkAdapters.Count) adaptadores ativos" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar informacoes de rede: $($_.Exception.Message)"
    }
}

function Get-ProcessInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        $topProcesses = Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet, Id
        $result += "=== TOP 10 PROCESSOS POR CPU ==="
        foreach ($process in $topProcesses) {
            $workingSetMB = [math]::Round($process.WorkingSet / 1MB, 2)
            $cpuTime = if ($process.CPU) { [math]::Round($process.CPU, 2) } else { "N/A" }
            $result += "$($process.Name) (ID: $($process.Id)) - CPU: $cpuTime - RAM: $workingSetMB MB"
        }
        
        Write-Log "Top 10 processos por CPU coletados" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar informacoes de processos: $($_.Exception.Message)"
    }
}

function Get-ServiceInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        $criticalServices = @('Spooler', 'BITS', 'Winmgmt', 'EventLog', 'Themes', 'AudioSrv')
        $services = Get-Service | Where-Object {$_.Name -in $criticalServices} | Select-Object Name, Status, StartType
        $result += "=== SERVICOS CRITICOS ==="
        foreach ($service in $services) {
            $result += "$($service.Name) - Status: $($service.Status) - Tipo: $($service.StartType)"
        }
        
        Write-Log "Servicos criticos verificados" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar informacoes de servicos: $($_.Exception.Message)"
    }
}

function Get-PerformanceInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        
        # Memory Usage usando CimInstance
        $computerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
        $totalMemory = $computerSystem.TotalPhysicalMemory
        $availableMemory = (Get-Counter "\Memory\Available MBytes").CounterSamples.CookedValue * 1MB
        $usedMemory = $totalMemory - $availableMemory
        $memoryUsagePercent = [math]::Round(($usedMemory / $totalMemory) * 100, 2)
        
        $result += "=== USO DA MEMORIA ==="
        $result += "Total: $([math]::Round($totalMemory / 1GB, 2)) GB"
        $result += "Disponivel: $([math]::Round($availableMemory / 1GB, 2)) GB"
        $result += "Em Uso: $([math]::Round($usedMemory / 1GB, 2)) GB ($memoryUsagePercent%)"
        
        Write-Log "Performance coletada: Memoria $memoryUsagePercent% em uso" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar informacoes de performance: $($_.Exception.Message)"
    }
}

function Get-SystemFolders {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        $folders = @(
            "C:\Windows",
            "C:\Program Files",
            "C:\Program Files (x86)",
            "C:\Users",
            "C:\Temp",
            "C:\Windows\Temp"
        )
        
        $result += "=== PRINCIPAIS PASTAS DO SISTEMA ==="
        foreach ($folder in $folders) {
            if (Test-Path $folder) {
                try {
                    $items = Get-ChildItem -Path $folder -ErrorAction SilentlyContinue
                    $totalSize = ($items | Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
                    $sizeGB = if ($totalSize) { [math]::Round($totalSize / 1GB, 2) } else { 0 }
                    $itemCount = $items.Count
                    $result += "$folder - Itens: $itemCount - Tamanho: $sizeGB GB"
                } catch {
                    $result += "$folder - Acesso negado ou erro"
                }
            } else {
                $result += "$folder - Pasta nao encontrada"
            }
        }
        
        Write-Log "Analise de pastas do sistema concluida" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao analisar pastas do sistema: $($_.Exception.Message)"
    }
}

function Get-SystemEvents {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        $events = Get-WinEvent -FilterHashtable @{LogName='System'; Level=1,2,3; StartTime=(Get-Date).AddDays(-1)} -MaxEvents 10 -ErrorAction SilentlyContinue
        $result += "=== EVENTOS CRITICOS DO SISTEMA (ULTIMAS 24H) ==="
        foreach ($event in $events) {
            $result += "[$($event.TimeCreated)] ID: $($event.Id) - $($event.LevelDisplayName) - $($event.ProviderName)"
            $result += "Mensagem: $($event.Message.Substring(0, [Math]::Min(100, $event.Message.Length)))..."
            $result += ""
        }
        
        Write-Log "Eventos criticos coletados" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar eventos do sistema: $($_.Exception.Message)"
    }
}

function Get-UpdateInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        $session = New-Object -ComObject Microsoft.Update.Session
        $searcher = $session.CreateUpdateSearcher()
        $searchResult = $searcher.Search("IsInstalled=0")
        
        $result += "=== ATUALIZACOES PENDENTES ==="
        $result += "Total de atualizacoes pendentes: $($searchResult.Updates.Count)"
        
        if ($searchResult.Updates.Count -gt 0) {
            foreach ($update in $searchResult.Updates | Select-Object -First 5) {
                $result += "- $($update.Title)"
            }
            if ($searchResult.Updates.Count -gt 5) {
                $result += "... e mais $($searchResult.Updates.Count - 5) atualizacoes"
            }
        } else {
            $result += "Nenhuma atualizacao pendente encontrada."
        }
        
        Write-Log "Verificacao de atualizacoes concluida: $($searchResult.Updates.Count) pendentes" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao verificar atualizacoes: $($_.Exception.Message)"
    }
}

function Get-SecurityInfo {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        
        # Windows Defender
        $defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
        $result += "=== WINDOWS DEFENDER ==="
        if ($defenderStatus) {
            $result += "Antivirus Habilitado: $($defenderStatus.AntivirusEnabled)"
            $result += "Protecao em Tempo Real: $($defenderStatus.RealTimeProtectionEnabled)"
            $result += "Ultima Verificacao: $($defenderStatus.QuickScanAge) dias atras"
        } else {
            $result += "Nao foi possivel obter status do Windows Defender"
        }
        $result += ""
        
        # Firewall
        $firewallProfiles = Get-NetFirewallProfile
        $result += "=== FIREWALL ==="
        foreach ($profile in $firewallProfiles) {
            $result += "$($profile.Name): $($profile.Enabled)"
        }
        
        Write-Log "Informacoes de seguranca coletadas" $LogFile $WorkingDir
        return $result -join "`r`n"
    } catch {
        return "Erro ao coletar informacoes de seguranca: $($_.Exception.Message)"
    }
}

function Test-WinGetInstalled {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        $result += "=== VERIFICACAO DO WINGET ==="
        
        # Verificar se o comando winget existe
        $wingetCommand = Get-Command winget -ErrorAction SilentlyContinue
        
        if ($wingetCommand) {
            # WinGet encontrado, obter versao
            try {
                $wingetVersion = & winget --version 2>$null
                $result += "Status: INSTALADO"
                $result += "Versao: $wingetVersion"
                $result += "Caminho: $($wingetCommand.Source)"
                
                # Verificar se pode executar comandos basicos
                $testCommand = & winget list --count 1 2>$null
                if ($LASTEXITCODE -eq 0) {
                    $result += "Funcionalidade: OK - Comandos funcionando corretamente"
                } else {
                    $result += "Funcionalidade: AVISO - WinGet instalado mas com problemas de execucao"
                }
                
                Write-Log "WinGet verificado: Instalado - Versao $wingetVersion" $LogFile $WorkingDir
            } catch {
                $result += "Status: INSTALADO (com problemas)"
                $result += "Erro ao obter versao: $($_.Exception.Message)"
                Write-Log "WinGet verificado: Instalado mas com problemas" $LogFile $WorkingDir
            }
        } else {
            $result += "Status: NAO INSTALADO"
            $result += "Recomendacao: Instalar WinGet atraves da Microsoft Store ou GitHub"
            $result += "Link: https://github.com/microsoft/winget-cli/releases"
            Write-Log "WinGet verificado: Nao instalado" $LogFile $WorkingDir
        }
        
        # Verificar versao do Windows (WinGet requer Windows 10 1809+)
        $osVersion = [System.Environment]::OSVersion.Version
        $result += ""
        $result += "=== COMPATIBILIDADE ==="
        $result += "Versao do Windows: $($osVersion.Major).$($osVersion.Minor).$($osVersion.Build)"
        
        if ($osVersion.Major -ge 10 -and $osVersion.Build -ge 17763) {
            $result += "Compatibilidade: OK - Sistema suporta WinGet"
        } else {
            $result += "Compatibilidade: INCOMPATIVEL - WinGet requer Windows 10 build 17763 ou superior"
        }
        
        return $result -join "`r`n"
    } catch {
        return "Erro ao verificar WinGet: $($_.Exception.Message)"
    }
}

function Get-WinGetPackages {
    param([string]$LogFile, [string]$WorkingDir, [int]$MaxPackages = 10)
    
    try {
        $result = @()
        
        # Verificar se WinGet esta disponivel
        $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
        
        if (-not $wingetAvailable) {
            $result += "=== PACOTES WINGET ==="
            $result += "WinGet nao esta instalado ou disponivel"
            $result += "Execute a funcao Test-WinGetInstalled para mais detalhes"
            return $result -join "`r`n"
        }
        
        $result += "=== PACOTES INSTALADOS VIA WINGET ==="
        
        try {
            # Listar pacotes instalados
            $installedPackages = & winget list --accept-source-agreements 2>$null | Select-Object -Skip 2
            
            if ($installedPackages) {
                $packageCount = 0
                $result += "Primeiros $MaxPackages pacotes instalados:"
                $result += ""
                
                foreach ($package in $installedPackages) {
                    if ($packageCount -ge $MaxPackages) { break }
                    if ($package -and $package.Trim() -ne "") {
                        $result += $package.Trim()
                        $packageCount++
                    }
                }
                
                $totalPackages = ($installedPackages | Where-Object { $_ -and $_.Trim() -ne "" }).Count
                $result += ""
                $result += "Total de pacotes encontrados: $totalPackages"
                
                Write-Log "WinGet: $totalPackages pacotes instalados listados" $LogFile $WorkingDir
            } else {
                $result += "Nenhum pacote instalado via WinGet encontrado"
                Write-Log "WinGet: Nenhum pacote encontrado" $LogFile $WorkingDir
            }
        } catch {
            $result += "Erro ao listar pacotes: $($_.Exception.Message)"
            $result += "Isso pode indicar que o WinGet nao esta funcionando corretamente"
        }
        
        return $result -join "`r`n"
    } catch {
        return "Erro ao verificar pacotes WinGet: $($_.Exception.Message)"
    }
}

function Start-WinGetUpgrade {
    param([string]$LogFile, [string]$WorkingDir)
    
    try {
        $result = @()
        $result += "=== ATUALIZACAO DE PACOTES WINGET ==="
        
        # Verificar se WinGet esta disponivel
        $wingetAvailable = Get-Command winget -ErrorAction SilentlyContinue
        
        if (-not $wingetAvailable) {
            $result += "ERRO: WinGet nao esta instalado ou disponivel"
            $result += "Execute a verificacao do WinGet primeiro"
            Write-Log "WinGet Upgrade: Falhou - WinGet nao disponivel" $LogFile $WorkingDir
            return $result -join "`r`n"
        }
        
        $result += "Iniciando processo de atualizacao..."
        $result += "Comando: winget upgrade --all"
        $result += ""
        
        Write-Log "WinGet Upgrade: Iniciando atualizacao de todos os pacotes" $LogFile $WorkingDir
        
        try {
            # Executar winget upgrade --all
            $upgradeOutput = & winget upgrade --all --accept-source-agreements --accept-package-agreements 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                $result += "=== RESULTADO DA ATUALIZACAO ==="
                $result += "Status: SUCESSO"
                $result += ""
                $result += "Saida do comando:"
                foreach ($line in $upgradeOutput) {
                    $result += $line.ToString()
                }
                Write-Log "WinGet Upgrade: Concluido com sucesso" $LogFile $WorkingDir
            } else {
                $result += "=== RESULTADO DA ATUALIZACAO ==="
                $result += "Status: CONCLUIDO COM AVISOS/ERROS"
                $result += "Codigo de saida: $LASTEXITCODE"
                $result += ""
                $result += "Saida do comando:"
                foreach ($line in $upgradeOutput) {
                    $result += $line.ToString()
                }
                Write-Log "WinGet Upgrade: Concluido com codigo $LASTEXITCODE" $LogFile $WorkingDir
            }
        } catch {
            $result += "ERRO ao executar winget upgrade: $($_.Exception.Message)"
            $result += "Verifique se o WinGet esta funcionando corretamente"
            Write-Log "WinGet Upgrade: Erro - $($_.Exception.Message)" $LogFile $WorkingDir
        }
        
        return $result -join "`r`n"
    } catch {
        return "Erro geral ao executar atualizacao WinGet: $($_.Exception.Message)"
    }
}