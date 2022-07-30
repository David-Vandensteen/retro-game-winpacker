Param(
  [String] $title,
  [String] $rom,
  [String] $ico
)

$cwd = Resolve-Path -Path "."
$template = "$cwd\script\packer-template.nsi"
$outputFolder = "$cwd\build\$title"
$makensis = "$cwd\build\nsis-3.08\makensis.exe"

function checkParams {
  If (-Not $title) {
    Write-Error "Title is not defined"
    Exit 2
  }
  If (-Not $rom) {
    Write-Error "Rom is not defined"
    Exit 2
  }
  If (-Not(Test-Path -Path $rom)) {
    Write-Error "$rom not found"
    Exit 2
  }
  If ($ico) {
    If (-Not(Test-Path -Path $ico)) {
      Write-Error "$ico not found"
      Exit 2
    }
  }
}

function createPacker {
  $romFileName = Split-Path -Path $rom -Leaf
  Write-Host "create nsis script"
  $content = [System.IO.File]::ReadAllText($template).Replace("/*title*/", $title).Replace("/*rom*/", "$romFileName").Replace("/*rom*/", $romFileName)
  If ($ico) {
    $content = $content.Replace("..\..\ico\default-gba.ico", $ico)
  }
  [System.IO.File]::WriteAllText("$outputFolder\$title.nsi", $content)
}

function pack {
  & $makensis "$outputFolder\$title.nsi"
}

function main {
  checkParams
  If (-Not(Test-Path -Path $outputFolder)) {
    mkdir $outputFolder
  }
  If (-Not(Test-Path -Path $rom)) {
    Write-Error "$rom not found"
    Exit 2
  }
  Copy-Item -Force -Path $rom -Destination $outputFolder
  createPacker
  pack
}

main
Write-Host $title
Write-Host $rom
Write-Host $template
Write-Host $outputFolder
