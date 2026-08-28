# Abyssal Descent
Run on `forge 47.4.10`

Join the [Discord](https://discord.gg/S43xbbHAe2) for more information  

> **Note:**  
> This project is still in development, read [Known Issues](KNOWN-ISSUES.md)

PR's and Issues welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md)

## Building
**Dependencies:** raku, JDK 17

```bash
git clone --recursive https://github.com/abyssal-descent/abyssal-descent
cd abyssal-descent
zef install JSON::Fast
raku build.raku
```

**Install Raku (Windows):**
```powershell
. {iwr -useb https://rakubrew.org/install-on-powershell.ps1 } | iex
New-Item -Path (Split-Path $PROFILE) -ItemType "Directory" -Force
Add-Content -Force -Path $PROFILE -Value '. "C:\rakubrew\bin\rakubrew.exe" init PowerShell | Out-String | Invoke-Expression'
rakubrew install
```

**Install Raku (Linux)**
```bash
curl https://rakubrew.org/install-on-perl.sh | sh
rakubrew install
```
