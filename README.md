
## To install, run Add-Store.cmd as Administrator  
If you do not want App Installer / Purchase App / delete each one appxbundle before running to install. However, if you plan on installing games or any app with in-purchase options, you should include everything.  
If the store still will not function, reboot. If still not working, open the command prompt as the administrator and run the following command, then reboot once more.  
```PowerShell -ExecutionPolicy Unrestricted -Command "& {$manifest = (Get-AppxPackage Microsoft.WindowsStore).InstallLocation + '\AppxManifest.xml' ; Add-AppxPackage -DisableDevelopmentMode -Register $manifest}"```    
## Addition troubleshooting    
>Right click start  
Select Run  
Type in: WSReset.exe  
This will clear the cache if needed.  