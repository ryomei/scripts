# Window sizing
$size=New-Object System.Management.Automation.Host.Size(120, 30)
$host.ui.rawui.WindowSize=$size

# Loading configuration file
try {
    $content = ( Get-Content .\config.pson -ErrorAction Stop | Out-String )
} catch {
    Write-Output 'Error file not found: could not find ".\config.pson". Be sure it`s present on the same folder as this script.'
    Write-Host -NoNewLine 'press any key to exit...'
    $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
    exit 1
}
$config = ( Invoke-Expression $content )
$message = $config['messages']

# Initializing global variables
Write-Output $message['sourceDirname']
Write-Output $('default --> {0}' -f $config['sourceDirname'])
$SOURCE_DIRPATH = Read-Host -Prompt $message['chooseSourceDirname']
if ([string]::IsNullOrWhiteSpace($SOURCE_DIRPATH)) {
    $SOURCE_DIRPATH = $config['sourceDirname']
}
$DESTINATION_DIRPATH = '{0}\{1}' -f (Get-Location).tostring(), $config['destinationDirname']
$DESTINATION_ZIP_FILEPATH = '{0}.zip' -f $DESTINATION_DIRPATH


# Main functions
function CopyFiles {
    param (
        [Parameter(Mandatory=$True)] $sourceDir, 
        [Parameter(Mandatory=$True)] $filename,
        [Parameter(Mandatory=$True)] $destinationDir
    )

    $from = "$sourceDir\$filename"
    $to = '{0}\{1}' -f $destinationDir, $filename
    Write-Output ('{0}: {1}' -f $message['copying'], $from)
    Copy-Item -Path $from -Destination $to -Recurse
}

function GenerateZip {
    $shell = new-object -comobject "WScript.Shell"
    $choice = $shell.popup($message['generateZipQuestion'], 0, $message['generateZipPopupTitle'], 4+32)
    if ($choice -eq 6) {
        $compress = @{
            Path = $DESTINATION_DIRPATH
            CompressionLevel = "Optimal"
            DestinationPath = $DESTINATION_ZIP_FILEPATH
            }
            Compress-Archive @compress
            return $message['zipCreatedAt'] -f $DESTINATION_ZIP_FILEPATH
    } else {
        return $message['zipNotCreated']
    }
}

# Remove destination folder and zip file if exists
Remove-Item $DESTINATION_DIRPATH -Recurse -ErrorAction Ignore
Remove-Item $DESTINATION_ZIP_FILEPATH -Recurse -ErrorAction Ignore
# Copy files
foreach ($file in $config['filesAndDirectories']) {
    CopyFiles -sourceDir $SOURCE_DIRPATH -filename $file -destinationDir $DESTINATION_DIRPATH
}
# Ask whether the user wants a zip file or not
$zipMessageOutput = GenerateZip
# Script output
Write-Host $message['processCompleted'];
Write-Host $($message['filesCopiedTo'] -f $DESTINATION_DIRPATH)
Write-Output $zipMessageOutput
# Just a halt so user can see the script output before leaving
Write-Host -NoNewLine $message['pressAnyKey']
$Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
