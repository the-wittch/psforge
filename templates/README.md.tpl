# {{ModuleName}}

{{Description}}

## Requirements

- PowerShell 7+ recommended (Windows PowerShell 5.1 supported for the module itself)
- Network access the first time you run `./build.ps1` (restores Pester, PSScriptAnalyzer, InvokeBuild into `./.modules`)

## Quick start

```powershell
Import-Module ./src/{{ModuleName}}
{{SampleFunction}} -Name 'World'
```

## Project layout

```text
src/{{ModuleName}}/
  Public/     # Exported commands — one function per file
  Private/    # Internal helpers (not exported)
  Classes/    # Optional PowerShell classes
build/        # InvokeBuild tasks
tests/        # Pester 5 unit + integration tests
docs/         # Markdown docs
output/       # Compiled module (generated)
```

## Build

```powershell
./build.ps1              # Clean, analyze, unit test, compile, integration test
./build.ps1 -Task Analyze
./build.ps1 -Task Build
```

The build compiles `Public/` and `Private/` into a single distributable module under `output/{{ModuleName}}/`.

## Add a function

From a machine with [PSForge](https://github.com/the-wittch/psforge) available:

```powershell
Add-PSModuleFunction -Name Get-Something -Path .
Add-PSModuleFunction -Name Get-InternalThing -Path . -Private
```

Or copy an existing Public `.ps1` and matching `tests/Unit/Public/*.Tests.ps1`.

## License

{{License}} — see [LICENSE](LICENSE).
