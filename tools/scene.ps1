# Runs one sketch of the showcase on its own (for working on it or recording it):
#   tools/scene.ps1 nebula                                   # a 1280x720 window
#   tools/scene.ps1 nebula -Record out/nebula -Frames 420     # saves out/nebula/0001.png ... with a frame-exact clock
#   tools/scene.ps1 hanabi -Offset 3                          # starts the sketch's clock at 3 s
# -Aqua names the compiler (aqua.dll or aqua.exe; default: the AquariusLangTW checkout beside this folder) and -Runtime
# the runtime (default: that checkout's .native-build/install/windows-x64/aquarius.exe).
param(
    [Parameter(Mandatory)][string]$Name,
    [int]$Width = 1280,
    [int]$Height = 720,
    [int]$Density = 0,
    [int]$FrameRate = 60,
    [double]$Offset = 0,
    [string]$Record = '',
    [int]$Frames = 0,
    [string]$Aqua = '',
    [string]$Runtime = ''
)
$ErrorActionPreference = 'Continue'
$root = Split-Path -Parent $PSScriptRoot
$checkout = Join-Path (Split-Path -Parent $root) 'AquariusLangTW'
if (-not $Aqua) { $Aqua = Join-Path $checkout 'compiler/AquariusCli/bin/Release/net8.0/aqua.dll' }
if (-not $Runtime) { $Runtime = Join-Path $checkout '.native-build/install/windows-x64/aquarius.exe' }

$work = Join-Path $root ".aqua/scene-$Name"
New-Item -ItemType Directory -Force (Join-Path $work 'scenes') | Out-Null
Copy-Item -Force (Join-Path $root "scenes/$Name.aqua") (Join-Path $work "scenes/$Name.aqua")
$density = if ($Density -gt 0) { "P.pixelDensity($Density);" } else { '' }
$main = @"
var P = import("Processing");
var scene = import("scenes/$Name.aqua");
var g = 0;
P.run(function() {
    $density
    P.size($Width, $Height, P.P2D, scene.title + " · " + scene.titleZh);
    P.frameRate($FrameRate);
    if (scene.renderer == 3) { g = P.createGraphics(P.width, P.height, P.P3D); } else { g = P.createGraphics(P.width, P.height, P.P2D); }
    g.resize(P.width, P.height, P.pixelWidth, P.pixelHeight);
    g.beginDraw(); scene.setup(g); g.endDraw();
}, function() {
    var t = P.millis() / 1000.0d + $([string]::Format([Globalization.CultureInfo]::InvariantCulture, '{0:0.0##}', $Offset))d;
    g.beginDraw(); scene.draw(g, t); g.endDraw();
    P.image(g, 0, 0, P.width, P.height);
});
"@
[IO.File]::WriteAllText((Join-Path $work 'main.aqua'), $main, [Text.UTF8Encoding]::new($false))
$toml = "manifest_version = 2`n`n[project]`nname = `"scene_$Name`"`nversion = `"1.0.0`"`nentry = `"main.aqua`"`nsources = [`"main.aqua`", `"scenes/$Name.aqua`"]`nplatforms = [`"windows`"]`n`n[dependencies]`n"
[IO.File]::WriteAllText((Join-Path $work 'aqua.toml'), $toml, [Text.UTF8Encoding]::new($false))
$wasm = Join-Path $work 'scene.wasm'
if ($Aqua.EndsWith('.dll')) { & dotnet $Aqua build $work -o $wasm } else { & $Aqua build $work -o $wasm }
if ($LASTEXITCODE -ne 0) { throw "Compiling $Name failed." }
if ($Record) {
    New-Item -ItemType Directory -Force $Record | Out-Null
    $env:AQUARIUS_GRAPHICS_RECORD = Join-Path (Resolve-Path $Record) '####.png'
}
if ($Frames -gt 0) { $env:AQUARIUS_GRAPHICS_FRAMES = "$Frames" }
try { & $Runtime $wasm } finally { Remove-Item Env:AQUARIUS_GRAPHICS_RECORD, Env:AQUARIUS_GRAPHICS_FRAMES -ErrorAction SilentlyContinue }
