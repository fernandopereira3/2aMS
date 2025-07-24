Add-Type -assembly System.Windows.Forms

$Form = New-Object System.Windows.Forms.Form
$Form.Text = "Powershel da PQP!"
$Label = New-Object System.Windows.Forms.Label
$Label.Text = "Inferno de Windows 10 e cadeia com computador velho da PQP!"
$Label.Location = New-Object System.Drawing.Point(50,50)
$Form.Controls.Add($Label)

# Create a background job for the infinite loop
$job = Start-Job -ScriptBlock {
    while ($true) {
        Write-Host -ForegroundColor DarkRed -BackgroundColor White
        Start-Sleep -Seconds 0.5
    }
}

# Show form and handle cleanup
$Form.Add_Closing({
    # Stop the background job when form closes
    Stop-Job -Job $job
    Remove-Job -Job $job
})

$Form.ShowDialog()