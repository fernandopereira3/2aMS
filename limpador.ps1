# Script de Limpeza do Sistema - PowerShell
# Versão melhorada do limpador.bat
# Autor: Sistema de Limpeza Automatizada
# Data: $(Get-Date -Format 'dd/MM/yyyy')

# Configuração de política de execução para o script atual
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# Função para exibir mensagens coloridas
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Função para criar diretório com verificação
function New-DirectorySafe {
    param([string]$Path)
    
    if (-not (Test-Path $Path)) {
        try {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
            Write-ColorOutput "✓ Diretório criado: $Path" "Green"
        }
        catch {
            Write-ColorOutput "✗ Erro ao criar diretório: $Path - $($_.Exception.Message)" "Red"
        }
    }
    else {
        Write-ColorOutput "ℹ Diretório já existe: $Path" "Yellow"
    }
}

# Função para remover diretório com verificação
function Remove-DirectorySafe {
    param([string]$Path)
    
    if (Test-Path $Path) {
        try {
            Remove-Item -Path $Path -Recurse -Force -ErrorAction Stop
            Write-ColorOutput "✓ Diretório removido: $Path" "Green"
        }
        catch {
            Write-ColorOutput "✗ Erro ao remover diretório: $Path - $($_.Exception.Message)" "Red"
        }
    }
    else {
        Write-ColorOutput "ℹ Diretório não encontrado: $Path" "Yellow"
    }
}

# Início do script
Write-ColorOutput "=== INICIANDO LIMPEZA DO SISTEMA ===" "Cyan"
Write-ColorOutput "Data/Hora: $(Get-Date)" "Gray"
Write-ColorOutput "" 

# 1. Limpeza da pasta TEMP
Write-ColorOutput "[1/5] Limpando arquivos temporários..." "Blue"
try {
    $tempPath = $env:TEMP
    if (Test-Path $tempPath) {
        Get-ChildItem -Path $tempPath -Force -ErrorAction SilentlyContinue | 
        ForEach-Object {
            try {
                Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
            }
            catch {
                # Ignora arquivos em uso
            }
        }
        Write-ColorOutput "✓ Limpeza de arquivos temporários concluída" "Green"
    }
}
catch {
    Write-ColorOutput "✗ Erro na limpeza de arquivos temporários: $($_.Exception.Message)" "Red"
}

# 2. Limpeza da Lixeira (apenas se existir)
Write-ColorOutput "[2/5] Limpando Lixeira..." "Blue"
$recycleBinPath = "C:\`$Recycle.Bin"
if (Test-Path $recycleBinPath) {
    Remove-DirectorySafe $recycleBinPath
}
else {
    Write-ColorOutput "ℹ Lixeira não encontrada ou já limpa" "Yellow"
}

# 3. Backup e limpeza da pasta Downloads
Write-ColorOutput "[3/5] Processando pasta Downloads..." "Blue"
$downloadsPath = "$env:USERPROFILE\Downloads"
if (Test-Path $downloadsPath) {
    # Criar backup se houver arquivos importantes
    $backupPath = "$env:USERPROFILE\Downloads_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    $importantFiles = Get-ChildItem -Path $downloadsPath -File | Where-Object { $_.Extension -in @('.pdf', '.doc', '.docx', '.xls', '.xlsx', '.ppt', '.pptx') }
    
    if ($importantFiles.Count -gt 0) {
        New-DirectorySafe $backupPath
        $importantFiles | ForEach-Object {
            try {
                Copy-Item $_.FullName -Destination $backupPath -Force
            }
            catch {
                Write-ColorOutput "⚠ Não foi possível fazer backup de: $($_.Name)" "Yellow"
            }
        }
        Write-ColorOutput "✓ Backup de arquivos importantes criado em: $backupPath" "Green"
    }
    
    Remove-DirectorySafe $downloadsPath
}

# 4. Limpeza da pasta Imagens (com mais cuidado)
Write-ColorOutput "[4/5] Processando pasta Imagens..." "Blue"
$imagesPath = "$env:USERPROFILE\Pictures"
if (Test-Path $imagesPath) {
    # Apenas remove arquivos temporários de imagem, não todas as imagens
    try {
        Get-ChildItem -Path $imagesPath -File -Recurse | 
        Where-Object { $_.Name -like "*temp*" -or $_.Name -like "*tmp*" -or $_.Extension -eq ".cache" } | 
        ForEach-Object {
            try {
                Remove-Item $_.FullName -Force
                Write-ColorOutput "✓ Arquivo temporário removido: $($_.Name)" "Green"
            }
            catch {
                Write-ColorOutput "⚠ Não foi possível remover: $($_.Name)" "Yellow"
            }
        }
    }
    catch {
        Write-ColorOutput "✗ Erro ao processar pasta de imagens: $($_.Exception.Message)" "Red"
    }
}

# 5. Recriação dos diretórios essenciais
Write-ColorOutput "[5/5] Recriando diretórios essenciais..." "Blue"
New-DirectorySafe "$env:USERPROFILE\Downloads"
New-DirectorySafe "$env:USERPROFILE\Pictures"

# Limpeza adicional do sistema
Write-ColorOutput "\n=== LIMPEZA ADICIONAL ===" "Cyan"

# Limpeza do cache do Windows
Write-ColorOutput "Limpando cache do sistema..." "Blue"
try {
    $cachePaths = @(
        "$env:LOCALAPPDATA\Temp",
        "$env:WINDIR\Temp",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache"
    )
    
    foreach ($cachePath in $cachePaths) {
        if (Test-Path $cachePath) {
            Get-ChildItem -Path $cachePath -Force -ErrorAction SilentlyContinue | 
            ForEach-Object {
                try {
                    Remove-Item $_.FullName -Recurse -Force -ErrorAction Stop
                }
                catch {
                    # Ignora arquivos em uso
                }
            }
        }
    }
    Write-ColorOutput "✓ Cache do sistema limpo" "Green"
}
catch {
    Write-ColorOutput "⚠ Alguns arquivos de cache não puderam ser removidos (podem estar em uso)" "Yellow"
}

# Finalização
Write-ColorOutput "\n=== LIMPEZA CONCLUÍDA ===" "Cyan"
Write-ColorOutput "Data/Hora de conclusão: $(Get-Date)" "Gray"
Write-ColorOutput "\nRecomendação: Reinicie o computador para liberar completamente os recursos." "Yellow"

# Pausa para visualização (opcional)
Write-ColorOutput "\nPressione qualquer tecla para continuar..." "White"
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")