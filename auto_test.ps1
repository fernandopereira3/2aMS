Clear-Host
$base = "10.14"

# Criar arquivo de log com timestamp
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = ".\ping_completo_$timestamp.log"

# Adicionar cabeçalho ao arquivo de log
"Teste de conexão completo iniciado em $(Get-Date)" | Out-File -FilePath $logFile
"IP - Status - Hostname" | Out-File -FilePath $logFile -Append
"----------------------------------------" | Out-File -FilePath $logFile -Append

for ($i=1; $i -le 254; $i++) {
    for ($j=1; $j -le 254; $j++) {
        $ip = "$base.$i.$j"
        
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
            
            
            "$ip - Conectado - Host: $hostName" | Out-File -FilePath $logFile -Append
        } else {
            "$ip - Desconectado" | Out-File -FilePath $logFile -Append
        }
    }
}
Write-Host "`nTeste completo finalizado. Resultados salvos em $logFile" -ForegroundColor Cyan