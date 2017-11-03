function GetInputs() {
    $file = Read-Host "Enter path to file with project names, e.g. 'Chatham.Web', seperated by newlines"
    $dotNetTargetVersion = Read-Host "Enter version to upgrade to"
    return $file, $dotNetTargetVersion
}

function GetProjectFileNames($file) {
    $text = Get-Content $file | Out-String
    return @($text.split([System.Environment]::NewLine)) | Where-Object { $_ -ne "" } | Foreach-Object{ $_ + '.csproj' }
}

function GetPathsToProjectFiles($projectNames){
    $trunkPath = Read-Host "Enter local code repo path"
    $projectPaths = @()

    foreach($name in $projectNames){
        Write-Host "Getting path for $name"
        $path = Get-ChildItem -Path $trunkPath -recurse -Depth 4 -filter $name -File | ForEach-Object { $_.FullName } | Select-Object -First 1
        $projectPaths += $path
    }

    return $projectPaths
}

function UpgradeProjects($projectPaths) {
    foreach($path in $projectPaths){
        $projectFile = Get-Content $path | Out-String
        Write-Host "Updating $path"
        $projectFile -replace '<TargetFrameworkVersion>v\d+\.*\d*\.*\d*<\/TargetFrameworkVersion>', "<TargetFrameworkVersion>v$dotNetTargetVersion</TargetFrameworkVersion>" | Set-Content -Path $path   
    }
    Write-Host 'Update complete!'
    Read-Host 'Hit any key to close.'
}

#MAIN

$file, $dotNetTargetVersion = GetInputs
$fileNames = GetProjectFileNames($file)
$projectPaths = GetPathsToProjectFiles($fileNames)
UpgradeProjects($projectPaths)
