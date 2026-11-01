
## Anbernic RG351P: how to install

The RG351P has one SD slot, so dArkMoss and spruce share the same card. A card bigger than about 12 GB is needed: dArkMoss keeps 11 GB, spruce gets the rest.

1. **Download** both image parts below (`dArkMoss_RG351P_..._img.7z.001` and `.002`) into the same folder, and `spruce-RG351P-overlay.zip`.
2. **Unpack** with [7-Zip](https://www.7-zip.org/download.html): right-click the `.001` file and choose *Extract Here*. You get one `.img` file.
3. **Flash** the `.img` to your SD card with [balenaEtcher](https://etcher.balena.io/) or Raspberry Pi Imager. This erases the card. If Windows asks to format the disk afterwards, click *Cancel*.
4. **First boot:** put the card in the RG351P and turn it on. It sets up the card and makes a **SPRUCEOS** partition (a few minutes), then shows *spruce card not found* and turns off. That is expected.
5. **Copy spruce:** put the card back in your computer and open the **SPRUCEOS** drive.
   - Extract the newest spruce `.7z` into it (a [release](https://github.com/spruceUI/spruceOS/releases) or a [nightly](https://github.com/spruceUI/spruceOSNightlies/releases)).
   - Then extract `spruce-RG351P-overlay.zip` into the same drive and replace the files. It adds the RG351P to spruce versions that do not include it yet; on one that does, it changes nothing. On a Mac, Finder's *Replace* deletes whole folders: use Terminal, `ditto -x -k --norsrc spruce-RG351P-overlay.zip /Volumes/SPRUCEOS`, then `dot_clean -m /Volumes/SPRUCEOS`.
6. **Turn the RG351P on.** The first start unpacks spruce's apps and themes, which takes a few minutes once.

**Controls:** there is no menu button. In the menus, **SELECT + START** opens the menu. In games, a tap on the stick opens the emulator menu and holding it opens the Game Switcher; SELECT is the RetroArch hotkey: SELECT+B exit, SELECT+R1 save, SELECT+L1 load, SELECT+Y RetroArch menu.

**Volume** is the hardware wheel only; spruce keeps its own volume at full.

**Reporting problems:** logs are on the SPRUCEOS drive in `Saves/spruce/` (`spruce.log`, `darkmoss_debug.log`, `rg351p-input.txt`, and `retroarch.log` with *Settings → Emulator Settings → Verbose emulator logging* on). If a game you cannot leave resumes at every boot, delete `spruce/flags/save_active.lock` on SPRUCEOS.
