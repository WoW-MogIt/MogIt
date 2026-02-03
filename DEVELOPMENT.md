# MogIt Development Setup

## Cloning the Repository

When cloning MogIt from GitHub, the `Libs/` folder will be empty because libraries are listed in `.gitignore`. They are normally fetched automatically during CurseForge packaging via `pkgmeta.yaml` externals.

For local development, you must manually download the libraries.

## Required Libraries

MogIt depends on the following libraries:

| Library | Source |
|---------|--------|
| LibStub | https://github.com/WoWUIDev/Ace3 |
| CallbackHandler-1.0 | https://github.com/WoWUIDev/Ace3 |
| AceGUI-3.0 | https://github.com/WoWUIDev/Ace3 |
| AceConfig-3.0 | https://github.com/WoWUIDev/Ace3 |
| AceDB-3.0 | https://github.com/WoWUIDev/Ace3 |
| AceDBOptions-3.0 | https://github.com/WoWUIDev/Ace3 |
| LibDataBroker-1.1 | https://github.com/tekkub/libdatabroker-1-1 |
| LibDBIcon-1.0 | https://github.com/Wrath-AddOns/LibDBIcon-1.0 |
| Libra | https://github.com/Lombra/Libra |
| LibItemInfo-1.0 | https://github.com/Lombra/LibItemInfo-1.0 |

## Quick Setup Script

Run these commands from the `MogIt/Libs/` directory:

```bash
# Clone Ace3 and extract needed libraries
git clone https://github.com/WoWUIDev/Ace3.git Ace3-temp
cp -r Ace3-temp/LibStub .
cp -r Ace3-temp/CallbackHandler-1.0 .
cp -r Ace3-temp/AceGUI-3.0 .
cp -r Ace3-temp/AceConfig-3.0 .
cp -r Ace3-temp/AceDB-3.0 .
cp -r Ace3-temp/AceDBOptions-3.0 .
rm -rf Ace3-temp

# Clone other libraries
git clone https://github.com/tekkub/libdatabroker-1-1.git LibDataBroker-1.1

git clone https://github.com/Wrath-AddOns/LibDBIcon-1.0.git LibDBIcon-temp
mv LibDBIcon-temp/LibDBIcon-1.0/LibDBIcon-1.0.lua LibDBIcon-temp/
rmdir LibDBIcon-temp/LibDBIcon-1.0
mv LibDBIcon-temp LibDBIcon-1.0

git clone https://github.com/Lombra/Libra.git

git clone https://github.com/Lombra/LibItemInfo-1.0.git LibItemInfo-temp
mv LibItemInfo-temp/LibItemInfo-1.0 .
rm -rf LibItemInfo-temp
```

## Alternative: Copy from Packaged Release

Download the latest MogIt release from [CurseForge](https://www.curseforge.com/wow/addons/mogit) and copy the `Libs/` folder to your cloned repository.

## Creating a Symlink for Testing

To test in WoW without copying files, create a symlink from your project to the AddOns folder.

**Windows (Run as Administrator in PowerShell):**
```powershell
cmd /c mklink /D "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\MogIt" "C:\Projects\MogIt"
```

**Linux/macOS:**
```bash
ln -s /path/to/MogIt "/path/to/WoW/_retail_/Interface/AddOns/MogIt"
```

## Verifying Library Installation

After setup, your `Libs/` folder should contain:
```
Libs/
├── AceConfig-3.0/
├── AceDB-3.0/
├── AceDBOptions-3.0/
├── AceGUI-3.0/
├── CallbackHandler-1.0/
├── Embeds.xml
├── LibDataBroker-1.1/
├── LibDBIcon-1.0/
├── LibItemInfo-1.0/
├── Libra/
└── LibStub/
```

## Troubleshooting

**"Cannot find a library instance of X"** - The library is missing or not in the correct location. Check that all folders exist and match the paths in `Libs/Embeds.xml`.

**"attempt to index field 'db' (a nil value)"** - This usually means AceDB-3.0 failed to load. Ensure all Ace libraries are present.
