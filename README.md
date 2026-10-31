# 99EMU™

### Texas Instruments TI-99/4A Computer Emulator

**An independent, clean-room emulation project.**

99EMU is an original emulator for the Texas Instruments TI-99/4A home computer, developed with an emphasis on hardware fidelity, documented behavior, and reproducible testing.

The project implements the TMS9900 processor and associated console hardware using original technical documentation and independently developed source code.

**Project established:** October 2026  
**Project creator:** reed-rosa  
**Status:** Public Windows binary preview (v0.01); source code remains private

### Windows installation (v0.01)

99EMU v0.01 is a Windows binary preview. The source code is not publicly released.

1. Download [Install-99EMU.ps1](Install-99EMU.ps1) from this repository. Open the link, select **Raw**, and save the file as `Install-99EMU.ps1` on the drive where you want to install (for example, `D:\AATMP\Install-99EMU.ps1`).
2. Open **Windows PowerShell** and change to the directory where you saved it:

   ```powershell
   Set-Location D:\AATMP
   ```

3. If Windows blocks the downloaded script because it is not digitally signed, review the script and unblock **that file only**:

   ```powershell
   Unblock-File .\Install-99EMU.ps1
   ```

4. Run the installer:

   ```powershell
   .\Install-99EMU.ps1
   ```

5. The installer creates `D:\99EMU` (using the drive of your current PowerShell directory), downloads `99emu.exe`, `SDL3.dll`, and `Get-ROMs.ps1`, and creates the `roms`, `roms\parsec`, and `roms\speech` directories. It asks before overwriting files in an existing installation.
6. When prompted, choose whether to download the required third-party ROM, cartridge, and speech archives from WHTech, or provide a folder containing files you already have permission to use. **The emulator does not include TI firmware or cartridge ROMs.** Downloading is optional; follow the applicable rights and permissions.
7. Once the required files are present, run:

   ```powershell
   D:\99EMU\99emu.exe
   ```

Replace `D:` with your selected drive letter. If any files are missing, rerun `D:\99EMU\Get-ROMs.ps1` to retry the ROM setup.

**Notes:** Internet access is required for downloads. The ROM downloader is an early preview and has not been validated against every archive layout; review any missing-file messages. You do **not** need Git or administrator rights for installation on a writable drive.

### Project principles

- Original, independently developed emulator implementation.
- Hardware behavior based on published technical specifications.
- Extensive automated testing and reproducible results.
- Historical firmware studied separately from the hardware implementation.
- No original TI firmware distributed with the emulator.

### Copyright and project name

Copyright © 2026 reed-rosa. All rights reserved.

99EMU™ is the project name used by its creator. No trademark registration is claimed.

Texas Instruments and TI-99/4A are referenced solely to identify the historical computer being emulated. This is an independent project and is not affiliated with Texas Instruments.

**Source code:** Private, not publicly released.  
**Public distribution:** Windows binary preview v0.01 is available in this repository.
