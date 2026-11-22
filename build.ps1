# Sestaví repozitář Kodi KODI-SPER (pro GitHub).
#   .\build.ps1 -User <github-uživatel> [-Branch main]
# Výstup (vše v této složce, nahrát na GitHub celé):
#   addons.xml, addons.xml.md5, zips\<id>\<id>-<verze>.zip, repository.kodisper-<verze>.zip (ke stažení)
# Postup aktualizace: zvednout verzi v addon.xml doplňku → spustit build.ps1 → nahrát změněné soubory na GitHub.
param(
    [Parameter(Mandatory = $true)][string]$User,
    [string]$Branch = 'main',
    [string]$Repo = 'KODI-SPER'
)
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression, System.IO.Compression.FileSystem
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$base = "https://raw.githubusercontent.com/$User/$Repo/$Branch"

# doplňky, které repozitář nabízí (zdrojové složky)
$sources = @(
    (Join-Path $here 'src\repository.kodisper'),
    (Join-Path (Split-Path -Parent $here) 'plugin.video.webshare.hledani')
)

# adresa repozitáře do addon.xml repozitáře
$repoXml = Join-Path $here 'src\repository.kodisper\addon.xml'
$x = [IO.File]::ReadAllText($repoXml, [Text.Encoding]::UTF8)
$x = [regex]::Replace($x, 'https://raw\.githubusercontent\.com/[^<]*?/(addons\.xml\.md5|addons\.xml|zips/)', { param($m) "$base/" + $m.Groups[1].Value })
[IO.File]::WriteAllText($repoXml, $x, (New-Object Text.UTF8Encoding $false))

function New-AddonZip($srcDir, $zipPath) {
    $id = Split-Path -Leaf $srcDir
    if (Test-Path $zipPath) { Remove-Item $zipPath }
    $z = [IO.Compression.ZipFile]::Open($zipPath, 'Create')
    try {
        Get-ChildItem $srcDir -Recurse -File | Where-Object { $_.FullName -notmatch '__pycache__|\.pyc$' } | ForEach-Object {
            $rel = $id + '/' + $_.FullName.Substring($srcDir.Length + 1).Replace('\', '/')
            [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($z, $_.FullName, $rel)
        }
    } finally { $z.Dispose() }
}

$entries = @()
$zips = Join-Path $here 'zips'
New-Item -ItemType Directory -Force $zips | Out-Null
foreach ($src in $sources) {
    $id = Split-Path -Leaf $src
    [xml]$ax = [IO.File]::ReadAllText((Join-Path $src 'addon.xml'), [Text.Encoding]::UTF8)
    $ver = $ax.addon.version
    $dir = Join-Path $zips $id
    if (Test-Path $dir) { Remove-Item -Recurse -Force $dir }      # jen aktuální verze
    New-Item -ItemType Directory -Force $dir | Out-Null
    New-AddonZip $src (Join-Path $dir "$id-$ver.zip")
    foreach ($asset in @($ax.addon.extension | Where-Object { $_.point -eq 'xbmc.addon.metadata' } | ForEach-Object { $_.assets.icon; $_.assets.fanart })) {
        if ($asset -and (Test-Path (Join-Path $src $asset))) { Copy-Item (Join-Path $src $asset) $dir }
    }
    $raw = [IO.File]::ReadAllText((Join-Path $src 'addon.xml'), [Text.Encoding]::UTF8)
    $raw = [regex]::Replace($raw, '^\s*<\?xml[^>]*\?>\s*', '')
    $entries += $raw.Trim()
    "{0,-32} {1}" -f $id, $ver
    if ($id -eq 'repository.kodisper') {
        Get-ChildItem $here -Filter 'repository.kodisper-*.zip' | Remove-Item
        Copy-Item (Join-Path $dir "$id-$ver.zip") (Join-Path $here "$id-$ver.zip")
        $idx = Join-Path $here 'index.html'      # stránka pro „Přidat zdroj“ v Kodi (GitHub Pages)
        $h = [IO.File]::ReadAllText($idx, [Text.Encoding]::UTF8) -replace 'repository\.kodisper-[\d.]+\.zip', "$id-$ver.zip"
        [IO.File]::WriteAllText($idx, $h, (New-Object Text.UTF8Encoding $false))
    }
}

$addonsXml = "<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>`n<addons>`n" + ($entries -join "`n") + "`n</addons>`n"
$utf8 = New-Object Text.UTF8Encoding $false
[IO.File]::WriteAllText((Join-Path $here 'addons.xml'), $addonsXml, $utf8)
$md5 = [Security.Cryptography.MD5]::Create()
$hash = ($md5.ComputeHash($utf8.GetBytes($addonsXml)) | ForEach-Object { $_.ToString('x2') }) -join ''
[IO.File]::WriteAllText((Join-Path $here 'addons.xml.md5'), $hash, $utf8)
"addons.xml.md5 = $hash"
"Adresa repozitáře: $base/"
