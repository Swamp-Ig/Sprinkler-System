# KiCad Project Template

A ready-to-use KiCad project scaffold with Git configuration and VS Code tasks for [KiCad 10.0](https://www.kicad.org/).

## Quick Start

### 1. Create your KiCad project here

Open KiCad, choose **File → New Project**, and point it at this folder.
KiCad will create `<project-name>.kicad_pro`, `<project-name>.kicad_sch`, and `<project-name>.kicad_pcb`.

### 2. Open the folder in VS Code

```
File → Open Folder → select this folder
```

Install the recommended extensions when prompted (TOML support, Git Graph, GitLens).

### 3. Run KiCad CLI tasks

Use **Terminal → Run Task** (or `Ctrl+Shift+P` → *Tasks: Run Task*) to access:

| Task | Description |
|------|-------------|
| KiCad: Run ERC | Electrical Rule Check → `docs/erc-report.txt` |
| KiCad: Run DRC | Design Rule Check → `docs/drc-report.txt` |
| KiCad: Export Schematic PDF | → `docs/schematic.pdf` |
| KiCad: Export PCB PDF | → `docs/pcb.pdf` |
| KiCad: Export Gerbers | → `manufacturing/gerbers/` |
| KiCad: Export Drill Files | → `manufacturing/drill/` |
| KiCad: Export Pick-and-Place (POS) | → `manufacturing/pos/` |
| KiCad: Export BOM (CSV) | → `manufacturing/bom/bom.csv` |
| KiCad: Export STEP (3D Model) | → `docs/board.step` |
| KiCad: Export Netlist | → `manufacturing/netlist.net` |
| **KiCad: Full Fabrication Export** | Runs all of the above in sequence |

Each task will prompt you for the path to your `.kicad_pcb` or `.kicad_sch` file.
The default is `${workspaceFolder}\my-project.kicad_pcb` — update `.vscode/tasks.json` with your actual project name for a smoother workflow.

## Configuring the KiCad CLI Path

If you use a different KiCad version, edit `kicad.cliPath` in `.vscode/settings.json`:

```jsonc
"kicad.cliPath": "C:\\Program Files\\KiCad\\10.0\\bin\\kicad-cli.exe"
```

Installed versions found on this machine: `8.0`, `9.0`, `10.0`

## Project Structure

```
kicad-template/
├── *.kicad_pro          ← KiCad project file (TOML)       [created by KiCad]
├── *.kicad_sch          ← Root schematic sheet             [created by KiCad]
├── *.kicad_pcb          ← PCB layout                       [created by KiCad]
├── sheets/              ← Hierarchical schematic sub-sheets
├── footprints/          ← Custom footprint library (.kicad_mod)
├── symbols/             ← Custom symbol library (.kicad_sym)
├── 3d_models/           ← Custom 3D component models (.step, .wrl)
├── manufacturing/
│   ├── gerbers/         ← Gerber files for PCB fabrication
│   ├── drill/           ← Excellon drill files
│   ├── pos/             ← Pick-and-place / centroid files
│   └── bom/             ← Bill of materials exports
├── docs/                ← Schematic/PCB PDFs, DRC/ERC reports
├── .gitignore           ← Ignores *.kicad_prl, backups, lock files
├── .gitattributes       ← Marks KiCad files as text (LF), 3D models as binary
└── .vscode/
    ├── settings.json    ← File associations, Explorer filters, CLI path
    ├── tasks.json       ← KiCad CLI export/check tasks
    └── extensions.json  ← Recommended VS Code extensions
```

## Git Notes

- **`.kicad_prl`** is gitignored — it stores per-machine UI state (zoom, pan, open windows)
- **`.kicad_sch`, `.kicad_pcb`, `.kicad_pro`** are tracked as UTF-8 text with LF endings
- **`*-backups/`** folders created by KiCad are gitignored
- Manufacturing outputs (Gerbers, PDFs) are tracked by default so reviewers can access fab files without running KiCad. Comment them out in `.gitignore` if you prefer not to track them.

## KiCad CLI Reference

```powershell
# Check installed version
& "C:\Program Files\KiCad\10.0\bin\kicad-cli.exe" version

# List available subcommands
& "C:\Program Files\KiCad\10.0\bin\kicad-cli.exe" --help

# Export Gerbers manually
& "C:\Program Files\KiCad\10.0\bin\kicad-cli.exe" pcb export gerbers `
    --output .\manufacturing\gerbers\ .\my-project.kicad_pcb
```

Full CLI documentation: <https://docs.kicad.org/10.0/en/cli/cli.html>
