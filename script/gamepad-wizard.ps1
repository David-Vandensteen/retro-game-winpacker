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

function Watch-Controler {
  Param(
    [Parameter(Mandatory=$true)][int] $ControlerIndex
    # TODO StopAndReturnTrigger
  )
  $dwUserIndex = $ControlerIndex
  $currentState = New-Object XInputWrapper+XINPUT_STATE
  [XInputWrapper]::XInputGetState($dwUserIndex, [ref]$currentState)

  if ($currentState -ne $previousState) {
    Write-Host "Controller event detected!"

    if ($currentState.wButtons -ne $previousState.wButtons) { Write-Host "Buttons: $($currentState.wButtons)" }

    if ($currentState.bLeftTrigger -ne $previousState.bLeftTrigger) { Write-Host "Left Trigger: $($currentState.bLeftTrigger)" }
    if ($currentState.bRightTrigger -ne $previousState.bRightTrigger) { Write-Host "Right Trigger: $($currentState.bRightTrigger)" }

    if ($currentState.sThumbLX -ne $previousState.sThumbLX) { Write-Host "Left Thumb X: $($currentState.sThumbLX)" }
    if ($currentState.sThumbLY -ne $previousState.sThumbLY) { Write-Host "Left Thumb Y: $($currentState.sThumbLY)" }

    if ($currentState.sThumbRX -ne $previousState.sThumbRX) { Write-Host "Right Thumb X: $($currentState.sThumbRX)" }
    if ($currentState.sThumbRY -ne $previousState.sThumbRY) { Write-Host "Right Thumb Y: $($currentState.sThumbRY)" }

    $previousState = $currentState
  }

  Start-Sleep -Milliseconds 100
  Watch-Controler -ControlerIndex $ControlerIndex
}


function Get-ConnectedIndexControler {
  $dwUserIndex = 0

  $state = New-Object XInputWrapper+XINPUT_STATE
  $result = [XInputWrapper]::XInputGetState($dwUserIndex, [ref] $state)

  if ($result -eq 0) {
    return $dwUserIndex
  } else {
    throw "controler is not connected"
  }
}

function Main {
  $controlerIndex = Get-ConnectedIndexControler
  Write-Host "controler index $controlerIndex is connected"

  $previousState = New-Object XInputWrapper+XINPUT_STATE
  #MonitorControllerEvents
  Watch-Controler -ControlerIndex $controlerIndex
}

Main
#Debug


#Joy0_Up=288
#Joy0_Start=391

