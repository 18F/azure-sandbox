

if ( -Not (Test-Path I:\psmodules) ) {
  mkdir I:\psmodules
}
Start-Process -FilePath "robocopy.exe" `
   -ArgumentList `
   '"C:\Program Files\WindowsPowerShell\Modules" I:\psmodules /e /purge /xf' `
   -NoNewWindow -Wait


#$sqi = "i:\SQLServer2014SP2"
#mkdir $sqi
#Start-Process -FilePath "robocopy.exe" `
#   -ArgumentList "F:/ $sqi /e /purge /xf" -NoNewWindow -Wait
