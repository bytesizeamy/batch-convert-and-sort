#let's get functional
function probeData($field, $file, $invChar){
    $metadata = Write-Output (ffprobe -loglevel 0 -show_entries format_tags=$field -of compact=nk=1:p=0 $file)
    $metadata.Split("|") -replace $invChar
 }

#input directory
$inputDir = Get-ChildItem (Read-Host "Enter input directory") -Recurse -Include "*.flac", "*.ape", "*.wav", "*.m4a"
$outputDir = Get-ChildItem (Read-Host "Enter output directory")

foreach($inFile in $inputDir) {
    #metadata and output directory
    $title, $album, $albumArtist = probeData "title,album,album_artist" $inFile "[:\/]","_"
    $track, $disc = probeData "track,disc" $inFile "\s*/.*"

    $outFile = "$disc-{0:D2} $title.m4a" -f [int]$track
    
    #make new directory
    if ((Test-Path -LiteralPath "$outputDir\$albumArtist\$album") -eq 0) {
        New-Item -ItemType dir "$outputDir\$albumArtist\$album"
    } 

    #convert
    ffmpeg -hide_banner -i $inFile -c:v copy -c:a alac "$outputDir\$albumArtist\$album\$outFile"
    #Remove-Item $inFile -WhatIF
}

# notification
$wsh = New-Object -ComObject Wscript.Shell

$wsh.Popup("All done!")
