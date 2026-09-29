# PSForge

[![CI](https://github.com/the-wittch/psforge/actions/workflows/ci.yml/badge.svg)](https://github.com/the-wittch/psforge/actions/workflows/ci.yml)

Scaffold production-ready PowerShell modules. Clone and run — no Gallery required.

## Install

```powershell
git clone https://github.com/the-wittch/psforge.git
cd psforge
./bootstrap.ps1
```

Persist for new sessions:

```powershell
./bootstrap.ps1 -Install
```

## Usage

```powershell
New-PSModule -Name MyTools -Path ~/Projects -Author 'Alex' -Description 'Ops helpers'
Add-PSModuleFunction -Name Get-ServerInfo -Path ~/Projects/MyTools
Add-PSModuleFunction -Name Get-InternalToken -Path ~/Projects/MyTools -Private
Remove-PSModuleFunction -Name Get-ServerInfo -Path ~/Projects/MyTools
Update-PSModuleVersion -Path ~/Projects/MyTools -Minor
```

Generated layout:

```text
MyTools/
├── src/MyTools/          # Public/, Private/, Classes/, manifest
├── build/                # InvokeBuild tasks
├── tests/                # Pester unit + integration
├── docs/
├── .github/workflows/ci.yml
├── build.ps1
├── requirements.psd1
└── PSScriptAnalyzerSettings.psd1
```

Build the generated module:

```powershell
cd ~/Projects/MyTools
./build.ps1
```

Restores Pester, PSScriptAnalyzer, and InvokeBuild into `./.modules`, then analyze → unit test → compile → integration test.

## License

MIT — see [LICENSE](LICENSE).
