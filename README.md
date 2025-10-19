# Zandronum — Reproducible Windows x64 build (Visual Studio 2022, CMake, Ninja, vcpkg, FMOD Ex)

This repository documents and automates a reproducible Windows x64 build of the multiplayer Doom engine [Zandronum](https://zandronum.com/) using Visual Studio 2022, CMake + Ninja, and vcpkg. It shows how to integrate the legacy audio library FMOD Ex 4.44.64 SDK (required by Zandronum) and how to prepare runtime DLLs so audio works.

> [!WARNING]
> Important: FMOD Ex is proprietary. Do not add FMOD binaries or SDK files to this repository. Follow the instructions below to obtain and place them locally.

## Prerequisites

- Windows 10 or 11 x64
- Visual Studio 2022 with "Desktop development with C++" workload
- CMake (≥ 3.20 recommended)
- Ninja (on PATH)
- Git
- vcpkg (cloned and bootstrap-built locally)
- Adequate disk space

## Recommended example paths used in commands:

- Project root: `C:\projects\zandronum`
- Build dir: `C:\projects\zandronum\build`
- vcpkg root: `C:\vcpkg`

Adjust paths if you use different locations.

## Quick overview
1. Install prerequisites and bootstrap vcpkg.
2. Install dependencies via vcpkg (sqlite3, fluidsynth, opus, etc.).
3. Obtain FMOD Ex 4.44.64 SDK and place it under build/src/fmod/api (headers, import-libs, bin). Access to the library can be requested on the [qa.fmod.com](https://qa.fmod.com/c/fmodapi/6) discussion board.
4. Configure CMake to use the vcpkg toolchain and point it to the FMOD include/lib paths.
5. Build with Ninja.
6. Copy or expose runtime DLLs (`fmodex64.dll`, `libfluidsynth-3.dll`, `sqlite3.dll`) to the executable directory or add them to PATH.
7. Run `zandronum.exe` and verify audio.

## Step-by-step instructions
1. **Prepare vcpkg and toolchain**
   - `cd C:\`
   - `git clone https://github.com/microsoft/vcpkg.git C:\vcpkg`
   - `cd C:\vcpkg .\bootstrap-vcpkg.bat`
   - `.\vcpkg integrate install`

2. **Install required libraries**
   - `cd C:\vcpkg`
   - `.\vcpkg install sqlite3:x64-windows fluidsynth:x64-windows opus:x64-windows`

3. **Clone Zandronum and create build folder**
   - `cd C:\projects`
   - `git clone https://foss.heptapod.net/zandronum/zandronum.git zandronum-src`
   - `mkdir C:\projects\zandronum\build`

   Note: _The official Zandronum repository is hosted on Heptapod. Heptapod natively uses Mercurial (hg), but it also provides a Git interface. This guide uses git clone for consistency with other tools (vcpkg, GitHub, etc.), but if you prefer Mercurial you can instead run:_

   - `hg clone https://foss.heptapod.net/zandronum/zandronum zandronum-src`

4. **Place FMOD Ex 4.44.64 SDK in the project (manual step)**

   Extract the FMOD Ex 4.44.64 SDK and place its contents under: `C:\projects\zandronum\build\src\fmod\api`

   Expected layout:

   - `inc\` — FMOD headers (e.g. `fmod.h, fmod.hpp`)
   - `lib\x64\` — FMOD import libs (e.g. `fmodex64_vc.lib`)
   - `bin\x64\` — FMOD runtime DLLs (e.g. `fmodex64.dll`)

   Again, do **NOT** commit these files into the repository.

5. **Configure CMake**

   From the build folder, clear CMake cache and configure with vcpkg and FMOD locations:

   - `cd C:\projects\zandronum\build`
   - `rmdir /s /q src\CMakeFiles`
   - `del /q src\CMakeCache.txt`
   - `cmake ..\src -G "Ninja" ^ -DCMAKE_BUILD_TYPE=Release ^ -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake ^ -DFMOD_LOCAL_INC_DIRS=C:/projects/zandronum/build/src/fmod/api/inc ^ -DFMOD_LOCAL_LIB_DIRS=C:/projects/zandronum/build/src/fmod/api/lib/x64 ^ -DFMOD_INCLUDE_DIR=C:/projects/zandronum/build/src/fmod/api/inc ^ -DFMOD_LIBRARY=C:/projects/zandronum/build/src/fmod/api/lib/x64/fmodex64_vc.lib`

   Notes:
   - Project CMake variables may differ; adapt variable names if upstream uses different names.
   - If CMake reports it found FMOD includes and library then the FMOD side is likely correct.

7. **_(Optional)_ Force sqlite3 linking if the linker reports unresolved sqlite symbols**
   - `rmdir /s /q src\CMakeFiles`
   - `del /q src\CMakeCache.txt`
   - `cmake ..\src -G "Ninja" ^ -DCMAKE_BUILD_TYPE=Release ^ -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake ^ -DSQLITE3_INCLUDE_DIR=C:/vcpkg/installed/x64-windows/include ^ -DSQLITE3_LIBRARY=C:/vcpkg/installed/x64-windows/lib/sqlite3.lib ^ -DCMAKE_EXE_LINKER_FLAGS="/LIBPATH:C:/vcpkg/installed/x64-windows/lib C:/vcpkg/installed/x64-windows/lib/sqlite3.lib"`
   This forces sqlite3.lib into the link line when project CMake logic does not add it automatically.

8. **Build**
   - `ninja`

   If you get compile errors about missing FMOD symbols, verify the FMOD headers are the FMOD Ex 4.x headers (not FMOD Studio 2.x).

9. **Make runtime DLLs available**

   You can either set `PATH` in the session where you run the game or copy runtime DLLs next to the executable.

   **Option A:** set `PATH` in the session
   - `set PATH=C:\projects\zandronum\build\src\fmod\api\bin\x64;C:\vcpkg\installed\x64-windows\bin;%PATH%`

   **Option B:** copy runtime DLLs into the exe folder:
   - `where /R . zandronum.exe`
   - `copy C:\projects\zandronum\build\src\fmod\api\bin\x64\fmodex64.dll <EXE_DIR>\ copy C:\vcpkg\installed\x64-windows\bin\libfluidsynth-3.dll <EXE_DIR>\ copy C:\vcpkg\installed\x64-windows\bin\sqlite3.dll <EXE_DIR>\`

9) Run and verify\
Start the executable from the same terminal (so `PATH` applies) or from the folder containing the DLLs and inspect the console log:

  - `cd <EXE_DIR>`
  - `zandronum.exe -logfile console`

Watch console output for FMOD, FluidSynth, MIDI, or sound device messages.

## Troubleshooting
- Missing FMOD symbols at compile time? Ensure you used FMOD Ex 4.x headers (legacy) and the import library for x64.
- Unresolved sqlite3 symbols at link time? Re-run CMake with `-DSQLITE3_LIBRARY` and `-DSQLITE3_INCLUDE_DIR` or use the `CMAKE_EXE_LINKER_FLAGS` override shown above.
- Silent audio at runtime? Ensure `fmodex64.dll` and `libfluidsynth-3.dll` are in `PATH` or copied next to the executable; verify Windows volume mixer is not muting the app.
- MIDI music not playing? Ensure a valid `.sf2` SoundFont is configured for FluidSynth if the project uses FluidSynth for MIDI playback.

## Packaging and licensing notes
- Do not include FMOD binaries in this repository. Provide instructions and a local placement guide instead.
- Do not commit vcpkg installed binaries. Commit only source, scripts and documentation.
- If you used a temporary stub header for FMOD to get a compile, replace it with the real FMOD Ex headers before distributing.

## Files included in this repo
- README.md — this file.
- copy-runtime.bat — helper script to copy runtime DLLs into the exe folder.
- .gitignore — tailored to Visual Studio, CMake, vcpkg and to exclude FMOD SDK binaries.
- CONTRIBUTING.md — contribution and reproduction guidelines.

## Contributions
Pull requests welcome. Do not add proprietary binaries. Reproducibility improvements (CMake presets, checks, scripts) are encouraged. If you want this added upstream to the official Zandronum docs, open an issue on upstream and link this guide.

## License
This guide is licensed under the MIT License. See LICENSE for details.\
