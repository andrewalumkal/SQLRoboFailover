$files = Get-ChildItem -Recurse -Filter *.ps1 -Path $PSScriptRoot/Functions

foreach ($file in $files) {
    . $file.FullName
}