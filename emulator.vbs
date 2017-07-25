Option Explicit
Dim wsh
Set wsh = WScript.CreateObject("WScript.Shell")
wsh.Run("""C:\Program Files (x86)\Microsoft Device Emulator\1.0\DeviceEmulator.exe"" ""c:\Program Files (x86)\Windows Mobile 6 SDK\PocketPC\Deviceemulation\0419\PPC_RUS_GSM_SQUARE_VR.BIN"" /cpucore ARMv5 /memsize 256 /s D:\MyCustomEmulator.dess /video 800x530x16 /sharedfolder C:\StorageCard")
Set wsh = Nothing
