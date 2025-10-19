# zandronum-windows-build-guide
Step-by-step instructions for building Zandronum on Windows x64 using Visual Studio, CMake, Ninja, vcpkg, and FMOD Ex.

This repository documents and automates a reproducible Windows x64 build of Zandronum using Visual Studio 2022, CMake + Ninja, and vcpkg. It shows how to integrate the legacy FMOD Ex 4.44.64 SDK (required by Zandronum) and how to prepare runtime DLLs so audio works.

Important: FMOD Ex is proprietary. Do not add FMOD binaries or SDK files to this repository. Follow the instructions below to obtain and place them locally.

---

## Prerequisites

- Windows 10 or 11 x64 +- Visual Studio 2022 with "Desktop development with C++" workload +- CMake (>= 3.20 recommended) +- Ninja (on PATH) +- Git +- vcpkg (cloned and bootstrap-built locally) +- Adequate disk space

Recommended example paths used in commands: +- Project root: C:\projects\zandronum +- Build dir: C:\projects\zandronum\build +- vcpkg root: C:\vcpkg

Adjust commands if you use different paths.

---

## Quick overview

1. Install prerequisites and bootstrap vcpkg. +2. Install dependencies via vcpkg (sqlite3, fluidsynth, opus, etc.). +3. Obtain FMOD Ex 4.44.64 SDK and place it under build/src/fmod/api (headers, import-libs, bin). +4. Configure CMake to use the vcpkg toolchain and point it to the FMOD include/lib paths. +5. Build with Ninja. +6. Copy or expose runtime DLLs (fmodex64.dll, libfluidsynth-3.dll, sqlite3.dll) to the executable directory or add them to PATH. +7. Run zandronum.exe and verify audio.

---

## Step-by-step (copy/paste into an x64 Developer Command Prompt)

### 1) Prepare vcpkg and toolchain +cmd +cd C:\ +git clone https://github.com/microsoft/vcpkg.git C:\vcpkg +cd C:\vcpkg +.\bootstrap-vcpkg.bat +.\vcpkg integrate install +

### 2) Install required libraries +cmd +cd C:\vcpkg +.\vcpkg install sqlite3:x64-windows fluidsynth:x64-windows opus:x64-windows +

### 3) Clone Zandronum and create build folder +cmd +cd C:\projects +git clone https://github.com/Zandronum/Zandronum.git zandronum-src +mkdir C:\projects\zandronum\build +

### 4) Place FMOD Ex 4.44.64 SDK in the project (manual) +- Extract the FMOD Ex 4.44.64 SDK and put its contents under:

C:\projects\zandronum\build\src\fmod\api\inc (headers: fmod.h, fmod.hpp, etc.)

C:\projects\zandronum\build\src\fmod\api\lib\x64 (import libs: e.g. fmodex64_vc.lib)

C:\projects\zandronum\build\src\fmod\api\bin\x64 (runtime DLLs: e.g. fmodex64.dll)

Do NOT commit these files into the repository.

### 5) Configure CMake (from build folder) +```cmd +cd C:\projects\zandronum\build

rmdir /s /q src\CMakeFiles +del /q src\CMakeCache.txt

cmake ..\src -G "Ninja" ^

-DCMAKE_BUILD_TYPE=Release ^

-DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake ^

-DFMOD_LOCAL_INC_DIRS=C:/projects/zandronum/build/src/fmod/api/inc ^

-DFMOD_LOCAL_LIB_DIRS=C:/projects/zandronum/build/src/fmod/api/lib/x64 ^

-DFMOD_INCLUDE_DIR=C:/projects/zandronum/build/src/fmod/api/inc ^

-DFMOD_LIBRARY=C:/projects/zandronum/build/src/fmod/api/lib/x64/fmodex64_vc.lib +```

If you get unresolved sqlite3 symbols, reconfigure with explicit sqlite variables (see next).

### 6) Force sqlite3 link (only if linker complains) +```cmd +rmdir /s /q src\CMakeFiles +del /q src\CMakeCache.txt

cmake ..\src -G "Ninja" ^

-DCMAKE_BUILD_TYPE=Release ^

-DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake ^

-DSQLITE3_INCLUDE_DIR=C:/vcpkg/installed/x64-windows/include ^

-DSQLITE3_LIBRARY=C:/vcpkg/installed/x64-windows/lib/sqlite3.lib ^

-DCMAKE_EXE_LINKER_FLAGS="/LIBPATH:C:/vcpkg/installed/x64-windows/lib C:/vcpkg/installed/x64-windows/lib/sqlite3.lib" +```

### 7) Build +cmd +ninja +

### 8) Make runtime DLLs available +- Option A: set PATH in your session before running the game: +cmd +set PATH=C:\projects\zandronum\build\src\fmod\api\bin\x64;C:\vcpkg\installed\x64-windows\bin;%PATH% + +- Option B: copy runtime DLLs into the executable folder: +cmd +where /R . zandronum.exe +copy C:\projects\zandronum\build\src\fmod\api\bin\x64\fmodex64.dll <EXE_DIR>\ +copy C:\vcpkg\installed\x64-windows\bin\libfluidsynth-3.dll <EXE_DIR>\ +copy C:\vcpkg\installed\x64-windows\bin\sqlite3.dll <EXE_DIR>\ +

### 9) Run with console log +cmd +cd <EXE_DIR> +zandronum.exe -logfile console +

Check console for FMOD / FluidSynth / midi / sound device messages.

---

## Troubleshooting highlights

- Missing FMOD symbols at compile → verify you used FMOD Ex 4.x headers (not FMOD 2.x). +- Unresolved sqlite3 at link → pass SQLITE3_LIBRARY and SQLITE3_INCLUDE_DIR, or use CMAKE_EXE_LINKER_FLAGS to force link. +- Silent audio at runtime → ensure fmodex64.dll and libfluidsynth-3.dll are on PATH or next to the exe; ensure SoundFont (.sf2) is configured for FluidSynth if MIDI is expected. +- If you temporarily created a stub header for FMOD, replace it with the real headers before distribution.

---

## Packaging / licensing notes

- Do not include FMOD binaries in the public repo. Provide instructions so users obtain and place FMOD locally. +- Do not commit vcpkg binary artifacts. Commit only source, scripts, and documentation.

---

If you want helper scripts, presets, or a CONTRIBUTING doc, see the repo files included in this patch.
