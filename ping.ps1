Set-ExecutionPolicy -ExecutionPolicy Bypass

$base = Read-Host "Insira a base EX: 192.186. "

for ($i=1; $i -le 254; $i++){
    $ip = $base + $i
    Write-Host "Testando $ip" -NoNewline
    if (Test-Connection -ComputerName $ip -Count 1 -Quiet) {
        Write-Host " - Conectado"
    } else {
        Write-Host " - Não Conectado"
    }
}
# 192.168.64.1