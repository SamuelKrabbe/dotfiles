# backup_moms_pc.ps1
# Must be run as Administrator.

# How to Run the New Script
#     - Save the code as backup_moms_pc.ps1.
#     - Open PowerShell as Administrator.
#     - Navigate to the directory where you saved the file.
#     - Run the script by providing the folder names after the -Folders parameter.

# EXEMPLE
# .\backup_dynamic.ps1 -Folders Documents, Pictures, Videos, Desktop, Music

# --- Script Parameters ---
# This block defines the command-line arguments the script accepts.
param (
    # The -Folders parameter is now mandatory. It accepts one or more strings.
    [Parameter(Mandatory=$true, HelpMessage="Specify one or more folder names from your user profile to back up (e.g., Documents, Pictures).")]
    [string[]]
    $Folders
)

# --- Variables ---
$awsCliUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
$msiPath = Join-Path -Path $env:TEMP -ChildPath "AWSCLIV2.msi"
# Default install location for AWS CLI v2 on Windows
$awsExePath = "$env:ProgramFiles\Amazon\AWSCLIV2\aws.exe"
# Location of the AWS credentials file
$awsCredentialsPath = Join-Path -Path $env:USERPROFILE -ChildPath ".aws\credentials"


# --- Section 1: Install AWS CLI (if not already installed) ---
if (-not (Test-Path -Path $awsExePath)) {
    Write-Host "AWS CLI not found. Starting download and installation..." -ForegroundColor Yellow
    try {
        Write-Host "Downloading AWS CLI from $awsCliUrl..."
        Invoke-WebRequest -Uri $awsCliUrl -OutFile $msiPath -ErrorAction Stop

        Write-Host "Installing AWS CLI... Please wait."
        Start-Process "msiexec.exe" -ArgumentList "/i `"$msiPath`" /quiet /norestart" -Wait
        Write-Host "AWS CLI installation complete." -ForegroundColor Green
    }
    catch {
        Write-Error "An error occurred during download or installation: $($_.Exception.Message)"
        exit 1
    }
    finally {
        if (Test-Path -Path $msiPath) {
            Write-Host "Cleaning up installer file..."
            Remove-Item -Path $msiPath -Force
        }
    }
}
else {
    Write-Host "AWS CLI is already installed."
}


# --- Section 2: Configure AWS CLI (if credentials are not found) ---
if (-not (Test-Path -Path $awsCredentialsPath)) {
    Write-Host "`nAWS credentials not found." -ForegroundColor Yellow
    Write-Host "The script will now run 'aws configure' interactively."
    Write-Host "Please have your AWS Access Key ID and Secret Access Key ready."
    Write-Host "------------------------------------------------------------------"
    
    Start-Process -FilePath $awsExePath -ArgumentList "configure" -NoNewWindow -Wait
    
    Write-Host "------------------------------------------------------------------"
    Write-Host "Configuration complete." -ForegroundColor Green
}
else {
    Write-Host "`nAWS credentials found. Skipping configuration."
}


# --- Section 3: Run Backup ---
Write-Host "`nStarting backup process for the specified folders..."
$Bucket = "moms-windows10-backup-2025-001b"
$Source = $env:USERPROFILE

# The script now loops through the $Folders array provided via the command line.
foreach ($folder in $Folders) {
    $SourcePath = Join-Path -Path $Source -ChildPath $folder

    if (Test-Path -Path $SourcePath -PathType Container) {
        Write-Host "Uploading $folder to s3://$Bucket/$folder ..."
        & $awsExePath s3 sync $SourcePath "s3://$Bucket/$folder"
    }
    else {
        Write-Host "Folder '$SourcePath' not found, skipping." -ForegroundColor Yellow
    }
}

Write-Host "`nBackup finished." -ForegroundColor Green