$target = "18faz-jen1"
Get-AzureVM -ServiceName $target -Name $target | Add-AzureEndpoint -Name "HttpIn" -Protocol "tcp" -PublicPort 80 -LocalPort 8080 | Update-AzureVM
