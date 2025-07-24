    Add-Type -assembly System.Windows.Forms
    $Form = New-Object System.Windows.Forms.Form
    $Form.Text = "My PowerShell GUI"
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = "Hello from PowerShell!"
    $Label.Location = New-Object System.Drawing.Point(50,50)
    $Form.Controls.Add($Label)
    $Form.ShowDialog()