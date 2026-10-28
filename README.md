# AquariusLang Processing Showcase · 星泉 Processing 展示

Thirteen animated sketches written in AquariusLang (星泉) with its built-in Processing module (`Processing` / `繪圖`),
each a fresh take on a kind of sketch that is popular on [OpenProcessing](https://openprocessing.org/): flow fields,
tunnels, networks, fireworks, fractals, particle clocks and more. None of them copies an existing sketch; the themes
are the starting point, the code, motion and palettes are new.

十三個以星泉內建 Processing 模組寫成的動態草稿，題材取自 OpenProcessing 上受歡迎的類型（流場、隧道、網絡、煙火、碎形、粒子時鐘
等），程式、動態與配色皆為全新創作。

| # | Sketch · 草稿 | What it shows · 展示內容 |
| --- | --- | --- |
| 1 | Nebula Currents · 星雲流場 | thousands of particles in a Perlin flow field with a drifting vortex, additive trails (`noise`, `blendMode(ADD)`, HSB) |
| 2 | Neon Wormhole · 霓虹蟲洞 | P3D rings flying through a winding tunnel, glow with `hint(DISABLE_DEPTH_TEST)` |
| 3 | Constellation Web · 星座網絡 | 160 drifting nodes, proximity links, signals hopping between them; the mouse gathers them |
| 4 | Hanabi Night · 夏夜花火 | rockets and four kinds of bursts from a 4,000-spark pool with gravity, drag and flicker |
| 5 | Orbit Sphere · 環繞星球 | 900 lit boxes on a Fibonacci sphere, travelling waves, orbiting point lights |
| 6 | Truchet Weave · 特魯謝編織 | quarter-circle tiles ("10 PRINT" with arcs) flipping in eased waves |
| 7 | Night Sakura · 夜櫻 | a recursive cherry tree in the wind, written with 繁體中文 keywords and Processing's Chinese names |
| 8 | Julia Bloom · 朱利亞綻放 | a Julia set per pixel in a WGSL fragment shader (`createShader`, uniforms) |
| 9 | Particle Clock · 粒子時鐘 | the time from `hour()`, `minute()`, `second()` in dot-matrix digits of sprung particles |
| 10 | Abyssal Drifters · 深海漂流者 | follow-the-leader chains swimming along noise paths |
| 11 | Harmonograph · 諧波繪圖儀 | four damped pendulums drawing decaying rosettes |
| 12 | Ridgelines · 山脊光譜 | a P3D noise terrain as hidden-line ridges rolling toward you (`QUAD_STRIP`) |
| 13 | Divide · 分割構成 | recursive subdivision with sliding splits and pattern tiles (`clip`, `arc(PIE)`) |

[INSPIRATIONS.md](INSPIRATIONS.md) lists the OpenProcessing sketches behind each one, with links, and how each differs.

## Run · 執行

The sketches use Processing features added in AquariusLang after 0.1.5 (blend modes, `hint()`, `nf()`, `hour()`, ...),
so build the compiler and runtime from a checkout of AquariusLangTW that has them, next to this folder:

```powershell
cd ../AquariusLangTW
dotnet build compiler/AquariusCli -c Release
scripts/build-runtime.ps1 -Targets windows-x64
cd ../AquariusLangTW_ProcessingShowcase
dotnet ../AquariusLangTW/compiler/AquariusCli/bin/Release/net8.0/aqua.dll build . -o dist/showcase.wasm
../AquariusLangTW/.native-build/install/windows-x64/aquarius.exe dist/showcase.wasm
```

With an `aqua` that has them on PATH: `aqua run .` (or `aqua build . --target web -o dist/web` for the browser).

**← →** switch sketches · **Space** pauses autoplay (14 s per sketch) · **R** restarts the sketch · **S** saves a PNG ·
**Esc** quits. Some sketches respond to the mouse (Constellation Web, Abyssal Drifters).

## One sketch at a time · 單獨執行

`tools/scene.ps1 <name>` runs one sketch from `scenes/` in its own window. With `-Record folder -Frames N` it saves
every frame as a PNG through the runtime's `AQUARIUS_GRAPHICS_RECORD`, whose clock advances exactly one frame per
frame, so recordings play back smoothly however long each frame took to save:

```powershell
tools/scene.ps1 julia
tools/scene.ps1 hanabi -Record out/hanabi -Frames 360 -Width 1280 -Height 720 -Density 2
```

## How a sketch is written · 草稿結構

Each `scenes/<name>.aqua` is a module with `title`, `titleZh`, `idea`, `renderer` (2 for P2D, 3 for P3D), `setup(g)`
and `draw(g, t)`; `g` is the offscreen canvas (`PGraphics`) it draws on and `t` the seconds since it started. Physics
runs in fixed 1/60 s steps (`int(t * 60)`), so a sketch looks the same at any frame rate. `main.aqua` shows the canvas
and the caption.
