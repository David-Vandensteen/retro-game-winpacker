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
  # Numéro de l'utilisateur (0-3) pour le contrôleur
  $dwUserIndex = 0

  $state = New-Object XInputWrapper+XINPUT_STATE
  $result = [XInputWrapper]::XInputGetState($dwUserIndex, [ref] $state)

  if ($result -eq 0) {
    Write-Host "Controleur connecte."
    Write-Host "Buttons: $($state.wButtons)"
    Write-Host "Left Trigger: $($state.bLeftTrigger)"
    Write-Host "Right Trigger: $($state.bRightTrigger)"
    Write-Host "Left Thumb X: $($state.sThumbLX)"
    Write-Host "Left Thumb Y: $($state.sThumbLY)"
    Write-Host "Right Thumb X: $($state.sThumbRX)"
    Write-Host "Right Thumb Y: $($state.sThumbRY)"
    sleep 1
    Debug
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
  $dwUserIndex = $ControllerIndex
  $currentState = New-Object XInputWrapper+XINPUT_STATE
  [XInputWrapper]::XInputGetState($dwUserIndex, [ref]$currentState)

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

function Get-ConnectedIndexController {
  $dwUserIndex = 0

  $state = New-Object XInputWrapper+XINPUT_STATE
  $result = [XInputWrapper]::XInputGetState($dwUserIndex, [ref] $state)

  if ($result -eq 0) {
    return $dwUserIndex
  } else {
    throw "controller is not connected"
  }
}

function Main {
  $controllerIndex = Get-ConnectedIndexController
  Write-Host "controller index $controllerIndex is connected"

  $previousState = New-Object XInputWrapper+XINPUT_STATE
  $control = Get-Control -ControllerIndex $controllerIndex

  Write-Host "control"
  $control
}

Main
#Debug


#Joy0_Up=288
#Joy0_Start=391

