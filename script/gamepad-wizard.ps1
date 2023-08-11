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
}

#Main
Debug


#Joy0_Up=288
#Joy0_Start=391

