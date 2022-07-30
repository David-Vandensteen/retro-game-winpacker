$urlNSIS = "http://azertyvortex.free.fr/download/retro-game-winpacker/nsis-3.08.zip"
#$urlVisualBoyAdvance = "https://github.com/visualboyadvance-m/visualboyadvance-m/releases/download/v2.1.4/visualboyadvance-m-Win-64bit.zip"
$urlVisualBoyAdvance = "http://prdownloads.sourceforge.net/vba/VisualBoyAdvance-1.7.2.zip"
$dest = "build"

function downloadHttp($url, $targetFile){
  Write-Host "downloadHttp : $url $targetFile"
  Import-Module BitsTransfer

  $start_time = Get-Date
  Start-BitsTransfer -Source $url -Destination $targetFile
  Write-Output "Time taken: $((Get-Date).Subtract($start_time).Seconds) second(s)"
}

function main {
  If (-Not(Test-Path -Path $dest)) {
    mkdir $dest
  }
  If (-Not(Test-Path -Path $dest\download)) {
    mkdir "$dest\download"
  }
  If (-Not(Test-Path -Path "$dest\visualboyadvance")) {
    downloadHttp $urlVisualBoyAdvance "$dest\download"
    mkdir "$dest\visualboyadvance"
    Expand-Archive "$dest\download\VisualBoyAdvance-1.7.2.zip" "$dest\visualboyadvance"
  }
  If (-Not(Test-Path -Path "$dest\nsis-3.08")) {
    downloadHttp $urlNSIS "$dest\download\"
    Expand-Archive "$dest\download\nsis-3.08.zip" $dest
  }
}

main
