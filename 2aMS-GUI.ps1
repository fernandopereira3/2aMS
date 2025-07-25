# Agente Autonomo de Monitoramento de Sistema (2aMS) - Interface Grafica
# Importa as funcoes de diagnostico do arquivo separado

# Importar funcoes do arquivo separado
. "$PSScriptRoot\2aMS-Functions.ps1"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Set-ExecutionPolicy -ExecutionPolicy Bypass

# Funcoes do sistema original
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

# Interface Grafica
$form = New-Object System.Windows.Forms.Form
$form.Text = "2aMS - Agente Autonomo de Monitoramento de Sistema"
$form.Size = New-Object System.Drawing.Size(700, 720)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)

# Titulo
$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "2aMS v1.0 - Sistema de Monitoramento"
$titleLabel.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.ForegroundColor = [System.Drawing.Color]::Blue
$titleLabel.Location = New-Object System.Drawing.Point(20, 20)
$titleLabel.Size = New-Object System.Drawing.Size(400, 30)
$form.Controls.Add($titleLabel)

# Botoes
$buttonY = 70
$buttonHeight = 35
$buttonWidth = 200
$buttonSpacing = 45

# Primeira linha de botoes
$btnSystem = New-Object System.Windows.Forms.Button
$btnSystem.Text = "Informacoes do Sistema"
$btnSystem.Location = New-Object System.Drawing.Point(20, $buttonY)
$btnSystem.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnSystem.BackColor = [System.Drawing.Color]::LightBlue
$form.Controls.Add($btnSystem)

$btnHardware = New-Object System.Windows.Forms.Button
$btnHardware.Text = "Informacoes de Hardware"
$btnHardware.Location = New-Object System.Drawing.Point(240, $buttonY)
$btnHardware.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnHardware.BackColor = [System.Drawing.Color]::LightGreen
$form.Controls.Add($btnHardware)

$btnNetwork = New-Object System.Windows.Forms.Button
$btnNetwork.Text = "Informacoes de Rede"
$btnNetwork.Location = New-Object System.Drawing.Point(460, $buttonY)
$btnNetwork.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnNetwork.BackColor = [System.Drawing.Color]::LightCoral
$form.Controls.Add($btnNetwork)

# Segunda linha de botoes
$buttonY2 = $buttonY + $buttonSpacing

$btnProcesses = New-Object System.Windows.Forms.Button
$btnProcesses.Text = "Processos Criticos"
$btnProcesses.Location = New-Object System.Drawing.Point(20, $buttonY2)
$btnProcesses.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnProcesses.BackColor = [System.Drawing.Color]::LightYellow
$form.Controls.Add($btnProcesses)

$btnServices = New-Object System.Windows.Forms.Button
$btnServices.Text = "Servicos Criticos"
$btnServices.Location = New-Object System.Drawing.Point(240, $buttonY2)
$btnServices.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnServices.BackColor = [System.Drawing.Color]::LightPink
$form.Controls.Add($btnServices)

$btnPerformance = New-Object System.Windows.Forms.Button
$btnPerformance.Text = "Performance"
$btnPerformance.Location = New-Object System.Drawing.Point(460, $buttonY2)
$btnPerformance.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnPerformance.BackColor = [System.Drawing.Color]::LightGray
$form.Controls.Add($btnPerformance)

# Terceira linha de botoes
$buttonY3 = $buttonY2 + $buttonSpacing

$btnFolders = New-Object System.Windows.Forms.Button
$btnFolders.Text = "Pastas do Sistema"
$btnFolders.Location = New-Object System.Drawing.Point(20, $buttonY3)
$btnFolders.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnFolders.BackColor = [System.Drawing.Color]::LightSalmon
$form.Controls.Add($btnFolders)

$btnSecurity = New-Object System.Windows.Forms.Button
$btnSecurity.Text = "Informacoes de Seguranca"
$btnSecurity.Location = New-Object System.Drawing.Point(240, $buttonY3)
$btnSecurity.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnSecurity.BackColor = [System.Drawing.Color]::LightCyan
$form.Controls.Add($btnSecurity)

$btnEvents = New-Object System.Windows.Forms.Button
$btnEvents.Text = "Eventos do Sistema"
$btnEvents.Location = New-Object System.Drawing.Point(460, $buttonY3)
$btnEvents.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnEvents.BackColor = [System.Drawing.Color]::Wheat
$form.Controls.Add($btnEvents)

# Quarta linha de botoes
$buttonY4 = $buttonY3 + $buttonSpacing

$btnUpdates = New-Object System.Windows.Forms.Button
$btnUpdates.Text = "Atualizacoes Pendentes"
$btnUpdates.Location = New-Object System.Drawing.Point(20, $buttonY4)
$btnUpdates.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnUpdates.BackColor = [System.Drawing.Color]::Lavender
$form.Controls.Add($btnUpdates)

$btnComplete = New-Object System.Windows.Forms.Button
$btnComplete.Text = "Diagnostico Completo"
$btnComplete.Location = New-Object System.Drawing.Point(240, $buttonY4)
$btnComplete.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnComplete.BackColor = [System.Drawing.Color]::Orange
$btnComplete.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnComplete)

$btnClear = New-Object System.Windows.Forms.Button
$btnClear.Text = "Limpar Tela"
$btnClear.Location = New-Object System.Drawing.Point(460, $buttonY4)
$btnClear.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnClear.BackColor = [System.Drawing.Color]::LightSteelBlue
$form.Controls.Add($btnClear)

# Quinta linha de botoes (WinGet)
$buttonY5 = $buttonY4 + $buttonSpacing

$btnWinGetCheck = New-Object System.Windows.Forms.Button
$btnWinGetCheck.Text = "Verificar WinGet"
$btnWinGetCheck.Location = New-Object System.Drawing.Point(20, $buttonY5)
$btnWinGetCheck.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnWinGetCheck.BackColor = [System.Drawing.Color]::LightSeaGreen
$form.Controls.Add($btnWinGetCheck)

$btnWinGetUpgrade = New-Object System.Windows.Forms.Button
$btnWinGetUpgrade.Text = "WinGet Upgrade --All"
$btnWinGetUpgrade.Location = New-Object System.Drawing.Point(240, $buttonY5)
$btnWinGetUpgrade.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnWinGetUpgrade.BackColor = [System.Drawing.Color]::Gold
$btnWinGetUpgrade.Font = New-Object System.Drawing.Font("Arial", 9, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($btnWinGetUpgrade)

$btnWinGetPackages = New-Object System.Windows.Forms.Button
$btnWinGetPackages.Text = "Pacotes WinGet"
$btnWinGetPackages.Location = New-Object System.Drawing.Point(460, $buttonY5)
$btnWinGetPackages.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
$btnWinGetPackages.BackColor = [System.Drawing.Color]::PaleGreen
$form.Controls.Add($btnWinGetPackages)

# Area de texto para resultados
$textBox = New-Object System.Windows.Forms.TextBox
$textBox.Multiline = $true
$textBox.ScrollBars = "Vertical"
$textBox.Location = New-Object System.Drawing.Point(20, 340)
$textBox.Size = New-Object System.Drawing.Size(640, 300)
$textBox.Font = New-Object System.Drawing.Font("Consolas", 9)
$textBox.ReadOnly = $true
$textBox.BackColor = [System.Drawing.Color]::White
$form.Controls.Add($textBox)

# Barra de status
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "Pronto para executar diagnosticos..."
$statusLabel.Location = New-Object System.Drawing.Point(20, 650)
$statusLabel.Size = New-Object System.Drawing.Size(600, 20)
$statusLabel.ForegroundColor = [System.Drawing.Color]::Green
$form.Controls.Add($statusLabel)

# Inicializar diretorio de trabalho
$workingDir = Initialize-WorkingDirectory
$logFile = "diagnostico.log"

# Funcao para atualizar status
function Update-Status {
    param([string]$message)
    $statusLabel.Text = $message
    $form.Refresh()
}

# Eventos dos botoes
$btnSystem.Add_Click({
    Update-Status "Coletando informacoes do sistema..."
    $textBox.Text = Get-SystemInfo $logFile $workingDir
    Update-Status "Informacoes do sistema coletadas!"
})

$btnHardware.Add_Click({
    Update-Status "Coletando informacoes de hardware..."
    $textBox.Text = Get-HardwareInfo $logFile $workingDir
    Update-Status "Informacoes de hardware coletadas!"
})

$btnNetwork.Add_Click({
    Update-Status "Coletando informacoes de rede..."
    $textBox.Text = Get-NetworkInfo $logFile $workingDir
    Update-Status "Informacoes de rede coletadas!"
})

$btnProcesses.Add_Click({
    Update-Status "Coletando informacoes de processos..."
    $textBox.Text = Get-ProcessInfo $logFile $workingDir
    Update-Status "Informacoes de processos coletadas!"
})

$btnServices.Add_Click({
    Update-Status "Coletando informacoes de servicos..."
    $textBox.Text = Get-ServiceInfo $logFile $workingDir
    Update-Status "Informacoes de servicos coletadas!"
})

$btnPerformance.Add_Click({
    Update-Status "Coletando informacoes de performance..."
    $textBox.Text = Get-PerformanceInfo $logFile $workingDir
    Update-Status "Informacoes de performance coletadas!"
})

$btnFolders.Add_Click({
    Update-Status "Analisando pastas do sistema..."
    $textBox.Text = Get-SystemFolders $logFile $workingDir
    Update-Status "Analise de pastas concluida!"
})

$btnSecurity.Add_Click({
    Update-Status "Coletando informacoes de seguranca..."
    $textBox.Text = Get-SecurityInfo $logFile $workingDir
    Update-Status "Informacoes de seguranca coletadas!"
})

$btnEvents.Add_Click({
    Update-Status "Coletando eventos do sistema..."
    $textBox.Text = Get-SystemEvents $logFile $workingDir
    Update-Status "Eventos do sistema coletados!"
})

$btnUpdates.Add_Click({
    Update-Status "Verificando atualizacoes pendentes..."
    $textBox.Text = Get-UpdateInfo $logFile $workingDir
    Update-Status "Verificacao de atualizacoes concluida!"
})

# Eventos dos botoes WinGet
$btnWinGetCheck.Add_Click({
    Update-Status "Verificando instalacao do WinGet..."
    $textBox.Text = Test-WinGetInstalled $logFile $workingDir
    Update-Status "Verificacao do WinGet concluida!"
})

$btnWinGetUpgrade.Add_Click({
    Update-Status "Executando winget upgrade --all... (Isso pode demorar)"
    $textBox.Text = Start-WinGetUpgrade $logFile $workingDir
    Update-Status "Atualizacao WinGet concluida!"
})

$btnWinGetPackages.Add_Click({
    Update-Status "Listando pacotes instalados via WinGet..."
    $textBox.Text = Get-WinGetPackages $logFile $workingDir
    Update-Status "Lista de pacotes WinGet concluida!"
})

$btnComplete.Add_Click({
    Update-Status "Executando diagnostico completo..."
    $textBox.Text = "=== DIAGNOSTICO COMPLETO DO SISTEMA ===`r`n`r`n"
    
    $textBox.Text += "INFORMACOES DO SISTEMA:`r`n"
    $textBox.Text += Get-SystemInfo $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "INFORMACOES DE HARDWARE:`r`n"
    $textBox.Text += Get-HardwareInfo $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "INFORMACOES DE REDE:`r`n"
    $textBox.Text += Get-NetworkInfo $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "PROCESSOS CRITICOS:`r`n"
    $textBox.Text += Get-ProcessInfo $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "SERVICOS CRITICOS:`r`n"
    $textBox.Text += Get-ServiceInfo $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "PERFORMANCE DO SISTEMA:`r`n"
    $textBox.Text += Get-PerformanceInfo $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "PASTAS DO SISTEMA:`r`n"
    $textBox.Text += Get-SystemFolders $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "EVENTOS DO SISTEMA:`r`n"
    $textBox.Text += Get-SystemEvents $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "INFORMACOES DE SEGURANCA:`r`n"
    $textBox.Text += Get-SecurityInfo $logFile $workingDir
    $textBox.Text += "`r`n`r`n"
    
    $textBox.Text += "ATUALIZACOES PENDENTES:`r`n"
    $textBox.Text += Get-UpdateInfo $logFile $workingDir
    
    Update-Status "Diagnostico completo finalizado!"
})

$btnClear.Add_Click({
    $textBox.Text = ""
    Update-Status "Tela limpa. Pronto para novos diagnosticos..."
})

# Exibir mensagem inicial
$textBox.Text = @"

   2aMS v1.0

Bem-vindo ao Sistema de Monitoramento 2aMS!

Clique nos botoes acima para executar diferentes tipos de diagnosticos:

1 Informacoes do Sistema - Dados do SO
2 Informacoes de Hardware - CPU, Memoria, Discos
3 Informacoes de Rede - Adaptadores e IPs
4 Processos Criticos - Top 10 processos
5 Servicos Criticos - Status dos servicos importantes
6 Performance - Uso de memoria
7 Pastas do Sistema - Analise das principais pastas
8 Informacoes de Seguranca - Windows Defender e Firewall
9 Eventos do Sistema - Eventos criticos recentes
10 Atualizacoes Pendentes - Verificacao do Windows Update
11 Verificar WinGet - Verifica se o WinGet esta instalado
12 WinGet Upgrade --All - Atualiza todos os pacotes
13 Pacotes WinGet - Lista pacotes instalados via WinGet
14 Diagnostico Completo - Executa todos os diagnosticos

Todos os resultados sao salvos automaticamente em logs.
"@

# Exibir o formulario
$form.ShowDialog()