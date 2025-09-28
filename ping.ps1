Set-ExecutionPolicy -ExecutionPolicy Bypass

$base = Read-Host "Insira a base EX: 192.186. "

for ($i=1; $i -le 254; $i++){
    $ip = $base + $i
    Write-Host "Testando $ip"
    Test-Connection -ComputerName $ip -Count 1 -Quiet
}
# 192.168.64.1