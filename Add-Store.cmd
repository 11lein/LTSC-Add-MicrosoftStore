@echo off
set "SysPath=%Windir%\System32"
if exist "%Windir%\Sysnative\reg.exe" (set "SysPath=%Windir%\Sysnative")
set "Path=%SysPath%;%Windir%;%SysPath%\Wbem;%SysPath%\WindowsPowerShell\v1.0\"
for /f "tokens=6 delims=[]. " %%G in ('ver') do if %%G lss 16299 goto :version
fsutil dirty query %systemdrive% 1>nul 2>nul || goto :uac
set "arch=x64"
if /i %PROCESSOR_ARCHITECTURE%==x86 (if not defined PROCESSOR_ARCHITEW6432 set "arch=x86")
pushd "%~dp0"
if not exist "*WindowsStore*.appxbundle" goto :nofiles
if not exist "*WindowsStore*.xml" goto :nofiles

for /f %%i in ('dir /b *WindowsStore*.appxbundle 2^>nul') do set "Store=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*1.7*.appx 2^>nul ^| find /i "x64"') do set "FK7X64=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*1.7*.appx 2^>nul ^| find /i "x86"') do set "FK7X86=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*1.7*.appx 2^>nul ^| find /i "x64"') do set "RT7X64=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*1.7*.appx 2^>nul ^| find /i "x86"') do set "RT7X86=%%i"
for /f %%i in ('dir /b *VCLibs*140.00_*.appx 2^>nul ^| find /i "x64"') do set "VCPX64=%%i"
for /f %%i in ('dir /b *VCLibs*140.00_*.appx 2^>nul ^| find /i "x86"') do set "VCPX86=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*2.2*.appx 2^>nul ^| find /i "x64"') do set "FK2X64=%%i"
for /f %%i in ('dir /b *NET.Native.Framework*2.2*.appx 2^>nul ^| find /i "x86"') do set "FK2X86=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*2.2*.appx 2^>nul ^| find /i "x64"') do set "RT2X64=%%i"
for /f %%i in ('dir /b *NET.Native.Runtime*2.2*.appx 2^>nul ^| find /i "x86"') do set "RT2X86=%%i"
for /f %%i in ('dir /b *VCLibs*140.00.UWPDesktop*.appx 2^>nul ^| find /i "x64"') do set "VCDX64=%%i"
for /f %%i in ('dir /b *VCLibs*140.00.UWPDesktop*.appx 2^>nul ^| find /i "x86"') do set "VCDX86=%%i"

if exist "*StorePurchaseApp*.appxbundle" if exist "*StorePurchaseApp*.xml" (
for /f %%i in ('dir /b *StorePurchaseApp*.appxbundle 2^>nul') do set "PurchaseApp=%%i"
)
if exist "*DesktopAppInstaller*.appxbundle" if exist "*DesktopAppInstaller*.xml" (
for /f %%i in ('dir /b *DesktopAppInstaller*.appxbundle 2^>nul') do set "AppInstaller=%%i"
)

if /i %arch%==x64 (
set "DepStore=%FK7X64%,%FK7X86%,%RT7X64%,%RT7X86%,%VCPX64%,%VCPX86%"
set "DepPurchase=%FK7X64%,%FK7X86%,%RT7X64%,%RT7X86%,%VCPX64%,%VCPX86%"
set "DepInstaller=%VCDX64%,%VCDX86%,%VCPX64%,%VCPX86%"
) else (
set "DepStore=%FK7X86%,%RT7X86%,%VCPX86%"
set "DepPurchase=%FK7X86%,%RT7X86%,%VCPX86%"
set "DepInstaller=%VCDX86%,%VCPX86%"
)

for %%i in (%DepStore%) do (
if not exist "%%i" goto :nofiles
)

set "PScommand=PowerShell -NoLogo -NoProfile -NonInteractive -InputFormat None -ExecutionPolicy Bypass"

echo.
echo ============================================================
echo Adding Microsoft Store
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %Store% -DependencyPackagePath %DepStore% -LicensePath Microsoft.WindowsStore_8wekyb3d8bbwe.xml
for %%i in (%DepStore%) do (
%PScommand% Add-AppxPackage -Path %%i
)
%PScommand% Add-AppxPackage -Path %Store%

if defined PurchaseApp (
echo.
echo ============================================================
echo Adding Store Purchase App
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %PurchaseApp% -DependencyPackagePath %DepPurchase% -LicensePath Microsoft.StorePurchaseApp_8wekyb3d8bbwe.xml
%PScommand% Add-AppxPackage -Path %PurchaseApp%
)

if defined AppInstaller (
echo.
echo ============================================================
echo Adding App Installer
echo ============================================================
echo.
1>nul 2>nul %PScommand% Add-AppxProvisionedPackage -Online -PackagePath %AppInstaller% -DependencyPackagePath %DepInstaller% -LicensePath Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.xml
for %%i in (%DepInstaller%) do (
%PScommand% Add-AppxPackage -Path %%i
)
%PScommand% Add-AppxPackage -Path %AppInstaller%
)

:uac
echo.
echo ============================================================
echo Error: Run the script as administrator
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:version
echo.
echo ============================================================
echo Error: This pack is for Windows 10 version 1709 and later
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:nofiles
echo.
echo ============================================================
echo Error: Required files are missing in the current directory
echo ============================================================
echo.
echo.
echo Press any key to Exit
pause >nul
exit

:fin
popd
echo.
echo ============================================================
echo Done
echo ============================================================
echo.
echo Press any Key to Exit.
pause >nul
exit
