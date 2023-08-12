# TODO : waiting max value for analog control

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public class XInputWrapper {
    [StructLayout(LayoutKind.Sequential)]
    public struct XINPUT_STATE {
        public uint dwPacketNumber;
        public short wButtons;
        public byte bLeftTrigger;
        public byte bRightTrigger;
        public short sThumbLX;
        public short sThumbLY;
        public short sThumbRX;
        public short sThumbRY;
    }

    [DllImport("xinput1_4.dll")]
    public static extern uint XInputGetState(uint dwUserIndex, ref XINPUT_STATE pState);
}
'@

function Debug {
  Param([Parameter(Mandatory=$true)][int] $ControllerIndex)

  $dwUserIndex = $ControllerIndex
  $state = New-Object XInputWrapper+XINPUT_STATE
  $result = [XInputWrapper]::XInputGetState($dwUserIndex, [ref] $state)

  if ($result -eq 0) {
    Write-Host "Controleur connecte."
    Write-Host "wButtons: $($state.wButtons)"
    Write-Host "bLeftTrigger: $($state.bLeftTrigger)"
    Write-Host "bRightTrigger: $($state.bRightTrigger)"
    Write-Host "sThumbLX: $($state.sThumbLX)"
    Write-Host "sThumbLY: $($state.sThumbLY)"
    Write-Host "sThumbRX: $($state.sThumbRX)"
    Write-Host "sThumbRY: $($state.sThumbRY)"
    sleep 1
    Debug -ControllerIndex $ControllerIndex
  } else {
    Write-Host "Le controleur n est pas connecte."
  }
}

function Get-Control {
  Param(
    [Parameter(Mandatory=$true)][int] $ControllerIndex,
    [int] $Delay = 100
  )

  $change = @{}
  $dwUserIndex = $ControWllerIndex
  $currentState = New-Object XInputWrapper+XINPUT_STATE


  $previousState = $currentState
  [XInputWrapper]::XInputGetState($dwUserIndex, [ref]$currentState)

  #if (($currentState.bLeftTrigger -ne -3356) -and ($currentState.))
  if ($currentState -ne $previousState) {
    if ($currentState.wButtons -ne $previousState.wButtons) {
      $change["wButtons"] = $currentState.wButtons
      return $change
    }

    if ($currentState.bLeftTrigger -ne $previousState.bLeftTrigger) {
      $change["bLeftTrigger"] = $currentState.bLeftTrigger
      return $change
    }

    if ($currentState.bRightTrigger -ne $previousState.bRightTrigger) {
      $change["bRightTrigger"] = $currentState.bRightTrigger
      return $change
    }

    if ($currentState.sThumbLX -ne $previousState.sThumbLX) {
      $change["sThumbLX"] = $currentState.sThumbLX
      return $change
    }

    if ($currentState.sThumbLY -ne $previousState.sThumbLY) {
      $change["sThumbLY"] = $currentState.sThumbLY
      return $change
    }

    if ($currentState.sThumbRX -ne $previousState.sThumbRX) {
      $change["sThumbRX"] = $currentState.sThumbRX
      return $change
    }

    if ($currentState.sThumbRY -ne $previousState.sThumbRY) {
      $change["sThumbRY"] = $currentState.sThumbRY
      return $change
    }

    $previousState = $currentState
  }

  Start-Sleep -Milliseconds $Delay
  Get-Control -ControllerIndex $ControllerIndex
}

function Test-Controller {
  Param([Parameter(Mandatory=$true)][int] $ControllerIndex)
  $dwUserIndex = $ControllerIndex

  $state = New-Object XInputWrapper+XINPUT_STATE
  $result = [XInputWrapper]::XInputGetState($dwUserIndex, [ref] $state)

  if ($result -eq 0) {
    return $true
  } else {
    return $false
  }
}

function Get-FirstConnectedIndexController {
  Param(
    [int]$MaxIndex = 3,
    [int]$Delay = 100
  )

  $index = 0
  #$connected = $false

  while ($true) {
    if ($(Test-Controller -ControllerIndex $index)) {
      return $index
    }
    if ($index -lt $MaxIndex) {
      $index += 1
    } else {
      $index = 0
    }
    Start-Sleep -Milliseconds $Delay
  }



  # $dwUserIndex = 0

  # $state = New-Object XInputWrapper+XINPUT_STATE
  # $result = [XInputWrapper]::XInputGetState($dwUserIndex, [ref] $state)

  # if ($result -eq 0) {
  #   return $true
  # } else {
  #   return $false
  # }
}

function Main {
  Write-Host "trying to find a connected controller..."
  $controllerIndex = Get-FirstConnectedIndexController

  Write-Host "controller was found at index $controllerIndex"
  Write-Host ""
  Write-Host "please wait ..."
  Debug -ControllerIndex $controllerIndex

  Write-Host "waiting a controller change"
  $control = Get-Control -ControllerIndex $controllerIndex

  Write-Host "control"
  $control
}

Main

# Init value
# wButtons: 0
# bLeftTrigger: 0
# bRightTrigger: 0
# sThumbLX: -3356
# sThumbLY: -1869
# sThumbRX: -3255
# sThumbRY: -848

#Joy0_Up=288
#Joy0_Start=391

