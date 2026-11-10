param([string]$Java='java',[Parameter(Mandatory=$true)][string]$FFDec)
$ErrorActionPreference='Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
foreach($group in @('loading','gameplay')) {
 New-Item -ItemType Directory -Path "build/ui/$group" -Force | Out-Null
 foreach($file in Get-ChildItem "assets/templates/$group/*.swf") {
  if($group -eq 'gameplay' -and $file.Name -notin @('mainmenu_settingspanel.swf','settingspanel.swf','settingspanel_lrg.swf')){continue}
  & $Java '-Djava.awt.headless=true' -jar $FFDec -importScript $file.FullName "build/ui/$group/$($file.Name)" "src/$group"
  if($LASTEXITCODE -ne 0){throw "UI build failed: $($file.Name)"}
 }
}
