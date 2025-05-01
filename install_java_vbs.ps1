# PowerShell script to install Java 8 and VBS components
# Run this script with administrative privileges

# Set execution policy to allow script execution
Set-ExecutionPolicy Bypass -Scope Process -Force

# Create a directory for downloads
$downloadPath = "C:\Temp\JavaInstall"
New-Item -ItemType Directory -Force -Path $downloadPath

# Download Java 8 JRE
$jreUrl = "https://javadl.oracle.com/webapps/download/AutoDL?BundleId=244068_89d678f2be164786b292527658ca1605"
$jreInstaller = "$downloadPath\jre-8u281-windows-x64.exe"
Invoke-WebRequest -Uri $jreUrl -OutFile $jreInstaller

# Download Java 8 JDK
$jdkUrl = "https://download.oracle.com/otn/java/jdk/8u281-b09/89d678f2be164786b292527658ca1605/jdk-8u281-windows-x64.exe"
$jdkInstaller = "$downloadPath\jdk-8u281-windows-x64.exe"
Invoke-WebRequest -Uri $jdkUrl -OutFile $jdkInstaller

# Install Java 8 JRE (Silent installation)
Start-Process -FilePath $jreInstaller -ArgumentList "/s" -Wait

# Install Java 8 JDK (Silent installation)
Start-Process -FilePath $jdkInstaller -ArgumentList "/s" -Wait

# Enable .NET Framework 3.5 and 4.8
Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All
# .NET Framework 4.8 is typically pre-installed on Windows 10, but we'll check and install if needed
$dotNet48Path = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
if (!(Test-Path $dotNet48Path) -or (Get-ItemProperty $dotNet48Path).Release -lt 528040) {
    Write-Host "Installing .NET Framework 4.8..."
    $dotNet48Url = "https://go.microsoft.com/fwlink/?LinkId=2085155"
    $dotNet48Installer = "$downloadPath\ndp48-web.exe"
    Invoke-WebRequest -Uri $dotNet48Url -OutFile $dotNet48Installer
    Start-Process -FilePath $dotNet48Installer -ArgumentList "/q /norestart" -Wait
}

# Set JAVA_HOME environment variable
$javaHome = "C:\Program Files\Java\jdk1.8.0_281"
[Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")

# Add Java to PATH
$path = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = "$javaHome\bin;" + $path
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

Write-Host "Installation completed successfully!"

# Cleanup
Remove-Item -Path $downloadPath -Recurse -Force
