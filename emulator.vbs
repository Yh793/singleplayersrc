set sh=CreateObject("Wscript.Shell") 
Dim DeviceEmulator
DeviceEmulator = "C:\Program Files (x86)\Microsoft Device Emulator\1.0\DeviceEmulator.exe"
sh.Run "emulator.bat", 0