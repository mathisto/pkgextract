# pkgextract

Fast, command-line **PS4 PKG extractor** for Windows. One self-contained `.exe`, no .NET install needed.
It is a patched build of [maxton/LibOrbisPkg](https://github.com/maxton/LibOrbisPkg) (`PkgTool`).

> **Scope: PS4 only.** This tool reads PS4 (Orbis) PKG files. It does **not** support PS5 (Prospero) PKGs, and nothing here has been tested against them.

## Quick start

```powershell
# extract everything to a folder
PkgTool.exe pkg_extract "Game.pkg" "C:\out\Game"
```

Game files land under `<output>\uroot` (`eboot.bin`, `sce_module\`, data archives...).
Add `--verbose` to print each file as it is written. Progress prints every ~256 MiB.

Other commands:

| Command | What it does |
|---|---|
| `pkg_listentries <pkg>` | List the PKG's metadata entries (index, name, size) |
| `pkg_extractentry <pkg> <index> <out>` | Extract one metadata entry (`param.sfo`, icon, trophy, ...) |
| `pkg_validate <pkg>` | Validate PKG hashes |
| `pfs_extract <pfs.dat> <out>` | Extract a raw PFS image |
| `pkg_build`, `pfs_buildinner/outer`, `pkg_makegp4` | Build tools from upstream (unchanged) |

Run `PkgTool.exe` with no arguments for the full verb list.

### Metadata (sce_sys)
`pkg_extract` writes the game filesystem. The PKG's own metadata entries (`param.sfo`, `icon0.png`, trophy `.trp`, ...) are separate; list them and pull what you need:

```powershell
PkgTool.exe pkg_listentries Game.pkg
PkgTool.exe pkg_extractentry Game.pkg 11 C:\out\Game\param.sfo
```

### Tuning (environment variables)
| Variable | Effect |
|---|---|
| `PKG_THREADS=n` | Cap parallel files (default: all logical cores) |
| `PKG_GENTLE=1` | Background priority, 2 threads, so a desktop stays responsive |
| `PKG_ONLY=text` | Extract only files whose path contains `text` |

## What is different from upstream
1. **PFSC fix.** On .NET 6+, one `DeflateStream.Read` can return a partial sector, which silently corrupted most compressed files. The reader now loops until the block is full.
2. **Parallel by default**, with periodic working-set trimming so huge memory-mapped PKGs do not bloat RAM.
3. Retargeted to **net8.0**; builds as a **single-file, self-contained** `win-x64` executable.
4. `PKG_GENTLE`, `PKG_THREADS`, `PKG_ONLY` knobs.

Measured example: a 13.5 GB retail PKG (Shadow of the Colossus) extracts in about 2 minutes on a 12-core desktop with NVMe storage.

## Build

Requires the [.NET 8 SDK](https://dotnet.microsoft.com/download).

```powershell
./build.ps1          # produces dist/PkgTool.exe
```

or directly:

```powershell
dotnet publish PkgTool.Core/PkgTool.Core.csproj -c Release -r win-x64 --self-contained `
  -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o dist
```

## Limits
- PS4 only (see above). Retail PKGs from some sources use a passcode/keys; `pkg_extract` accepts `--passcode`, `--xts_tweak`, `--xts_data` as upstream does.
- Only extract PKGs of software you own.
- Verify results: check that extracted archives open and that `eboot.bin` starts with the SELF magic `4F 15 3D 1D`.

## License
LGPL-3.0, inherited from LibOrbisPkg (see `LICENSE.txt`). Upstream docs: `UPSTREAM-README.md`.
