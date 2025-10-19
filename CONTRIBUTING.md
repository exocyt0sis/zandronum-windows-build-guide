# Contributing and reproducing the Windows x64 build

Thank you for wanting to reproduce or contribute to this build workflow. This document explains key steps to reproduce the build locally and how to add improvements.

## Repro steps (summary)
1. Install prerequisites (Visual Studio 2022 C++ workload, CMake, Ninja, Git).  
2. Clone and bootstrap vcpkg locally.  
3. Install vcpkg packages: `sqlite3`, `fluidsynth`, `opus`.  
4. Obtain FMOD Ex 4.44.64 SDK (legacy) and place it under `build/src/fmod/api` (do not commit these files).  
5. Configure CMake using the vcpkg toolchain and FMOD variables shown in README.md.  
6. Build with `ninja`.  
7. Copy runtime DLLs into the executable folder or add their bin folders to PATH.

## Getting FMOD Ex 4.44.64
FMOD Ex 4.x is legacy and proprietary. Obtain it from FMOD’s official download area (an account may be required) or an authorized archive, or obtain permission to use it by asking on the [qa.fmod.com](https://qa.fmod.com/c/fmodapi/6) message board. Place the extracted SDK contents under `build/src/fmod/api` with the layout:
- `inc\` (headers)  
- `lib\x64\` (import libs)  
- `bin\x64\` (runtime DLLs)

## Packaging guidance
- Never commit FMOD SDK binaries to the repo; again, they contain proprietary code. Provide a clear local placement guide.  
- Do not commit vcpkg installed binaries.

## Automations & scripts
- Use `copy-runtime.bat` to copy runtime DLLs into the exe folder after building.

## Troubleshooting
- Missing FMOD symbols? Ensure FMOD Ex 4.x headers are used (not FMOD 2.x).  
- Linker complains about sqlite3? Re-run CMake with `-DSQLITE3_LIBRARY` and `-DSQLITE3_INCLUDE_DIR` or use the linker flags example in README.md.  
- Silent audio? Ensure `fmodex64.dll` and `libfluidsynth-3.dll` are on PATH or copied next to the exe and that a SoundFont (.sf2) is present/configured.

## Pull requests
- Pull requests must not introduce proprietary binaries.  
- Changes that improve reproducibility (scripts, presets, checks) are encouraged.
