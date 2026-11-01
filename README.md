# <p align="center">Welcome to dArkOS</p>

### <p align="center">Debian based version of the ArkOS operating system for select RK3326 and RK3566 based portable gaming devices.</p>

[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/donate?hosted_button_id=RC72LJ4SSERSU)

The overarching goals of dArkOS is as follows:
1. Highly customizable 
1. Performance
1. Online Updates (Won't require SD card reflashing unless there are major structural changes like file system changes.)
1. Enthusiats focused

This is intended to continue the work from [ArkOS](https://github.com/christianhaitian/arkos/wiki) but in a way that allows others to easily fork and modify the OS to their own taste.  If there's a feature not currently available that you want, you can fork this and add it yourself.
Don't feel like building the OS from scratch or don't have the resources to do so?  Ok, just download one of the available prebuilt images and make changes right in the OS.  Since this OS is based on the latest stable version of Debian, you have
access to over 64,000 packages you can install via the Debian Advanced Package Tool (APT).  Want to build the latest testing or bleeding edge release of Debian? See the notes below on how to accomplish this.

**Building instructions:**
   - Suggested Environment - Ubuntu or related variants, version 24.04 or newer.  Windows Subsystem for Linux (WSL) is not supported and will not work due to no support for chroot. \
     Because chroot is used in this process, heavy use of sudo is made.  To reduce the possibility of priviledge issues, \
     it's best to be able to execute sudo without needing a password.  This can be done using one of the 2 methods below.
      - Method 1: - Open a Terminal window and type `sudo visudo` \
                    In the bottom of the file, add the following line: `$USER ALL=(ALL) NOPASSWD: ALL` \
                    Where $USER is your username on your system. Save and close the sudoers file (if you haven't changed your \
                    default terminal editor (you'll know if you have), press Ctl + x to exit nano and it'll prompt you to save).
      - Method 2: - Clone this git repo then run `./FreeSudo.sh`.  If there were no errors, it should've completed this change for you. \
                    You can verify this by checking if a `/etc/sudoers.d/$USER` file exists and contains `$USER ALL=(ALL) NOPASSWD: ALL` in it.
     
Now you should be able to just run make <device_name> to build for a supported device.  Example: `make rg353m`

**Notes**
- To build on a different release of Debian, change the DEBIAN_CODE_NAME export in the Makefile or add DEBIAN_CODE_NAME=<release> as a variable to `make`.  Other debian code names can be found at https://www.debian.org/releases/
- By default, this will build with both a 64bit and 32bit userspace.  This is primarily to support some 32bit ports available through PortMaster.  There are also some 32bit retroarch emulators available but the performance seems to be similar to the 64bit retroarch emulators at this point.
 - To build without 32bit support, change the BUILD_ARMHF export in the Makefile to n or add BUILD_ARMHF=n as a variable to `make`.
- For RK3566, you can add Kodi to your build.  Just change the BUILD_KODI export in the Makefile to y or add BUILD_KODI=y as a variavble to `make`.  Kodi is also available as a prepackaged build in the extra_packages/rk3566 subfolder.  Just copy it to your tools folder and launch from Options/Tools in the start menu.
 - Be aware that building Kodi will add a significant amount of time to your build.  Could be double or triple the build time.
- Initial build time on an Intel I7-8700 65w unit with a 512GB NVME SSD and 32GB of DDR4 memory is a little over 19 hours.  Subsequent builds are about 3 hours thanks to ccache.

# Credits and Thanks
[ChatGPT](https://chatgpt.com/) for guidance on how to build a Debian image \
Jetup13 for many themes \
dani7959 for the replica theme \
pix33l for the pixui theme \
TheGreatCrippler for testing and feedback \
kloptops for testing and feedback \
Fraxinus88 for testing and feedback \
ImCoKeMaN for testing and feedback \
[PortMaster](https://portmaster.games/) team for support in figuring out PM interface issues



test webhook.... again......again!

## dArkMoss

dArkMoss is spruceUI's fork of dArkOS: a Debian base OS on TF1 that hands off to
[spruce](https://github.com/spruceUI/spruceOS) on TF2. The emulator and
EmulationStation builds are stripped from the unit build scripts because spruce
provides all of that from its own card; what is left is debootstrap, the kernel
and image assembly.

Units:

| unit | device | Makefile target | script |
|---|---|---|---|
| rgb30 | Powkiddy RGB30 | `make rgb30` | `build_rgb30.sh` |
| miniloong | Miniloong Pocket 1 | `make miniloong` | `build_miniloong.sh` |
| a10mini | A10 Mini (RK3326) | `make a10mini` | `build_a10mini.sh` |
| g350 | G350 (RK3326) | `make g350` | `build_g350.sh` |
| v10 | Powkiddy V10 (RK3326) | `make v10` | `build_v10.sh` |
| xumini | MagicX XU Mini M (RK3326) | `make xumini` | `build_xumini.sh` |
| r36sclone | R36S clone, G80CA-MB board (RK3326) | `make r36sclone` | `build_r36sclone.sh` |

Images are built on GitHub Actions, not locally. Under Actions:

- **build-all** takes a version (`v1.2.3`) and optionally a list of units
  (blank = every unit in `.github/units.txt`), builds them in parallel and
  publishes them as the `beta-<branch>` prerelease. A beta never becomes the
  latest release, so spruce devices and the installer do not see it.
- **create-latest-release** turns a beta into a draft release tagged with its
  version. It refuses a beta that is missing any unit. Publish the draft by
  hand from the Releases page.

Images ship as `dArkMoss_<UNIT>_<suite>_<date>.img.7z.001`
and `.002` because a single volume is over GitHub's asset limit; the parts are
a plain byte split, so `cat` them (or let 7z read `.001`) to extract.

Beside each image the build also produces `dArkMoss_<UNIT>_<version>.dmupd`, an
update payload spruce's Firmware Update app downloads and applies in place: the
boot partition files, every rootfs file the dArkMoss build added or changed
(chosen by the dpkg database, see `build_update.sh`) and the U-Boot
resource partition (dtb, charging animation, power-on logo), with the applier
`scripts/spruce/dmupd-apply.sh` inside. A release carries a `SHA256SUMS` over
all of its assets, which the app checks the download against. The app only
reads the latest release, so betas are never offered as updates.

Adding a unit that dArkOS already supports: copy `build_rgb30.sh` (rk3566) or
`build_g350.sh` (rk3326) to `build_<unit>.sh` and change `UNIT`. On rk3566 add
`logos/unrotated/dArkMoss<unit>.png` (the kernel boot logo); rk3326 units share
`logos/unrotated/dArkMoss.bmp` (the U-Boot logo on the boot partition). Give it
a name in the `HW_DEVICE` and `SPRUCE_PLATFORM` cases in
`setup_spruce_handoff.sh` and in `build_update.sh`, and add the unit to
`.github/units.txt`. Everything else in the pipeline already keys on `UNIT`.

### R36S clone (r36sclone)

For the R36S clones on the G80CA-MB board (V1.2/V1.3 on the silkscreen), not
the genuine R36S. spruce has no R36S platform and will not get one, so the
image runs spruce's own G350 profile: same SoC, panel size, sticks, joypad
driver and button codes. Nothing on the spruce card changes.

- Kernel: `patches/r36sclone/kernel/series`, applied to christianhaitian's
  rg351 like the Mini M's: the board's two dts, one per panel, and
  lcdyk0517's odroidgo3-joypad, which reads the clone's
  `amux-channel-mapping`. Both from lcdyk0517/arkos.bsp.4.4 (arkos4clone's
  "R36S Clone Type2"); the patches list what was changed.
- U-Boot: `patches/r36sclone/uboot`, the G80CA U-Boot dtb dArkOSRE-R36 ships as
  tested, as source, with both panels for the panel-ID check. U-Boot reads this
  board as an RG351V, so it is loaded as `uboot.dtb` (the `uboot-dtb` opt-in).
- Panels: G80CA units have "Panel 8" (ST7703) or "Panel 9" (NV3051D family).
  U-Boot starts on Panel 8 and switches when the screen answers with Panel 9's
  ID; boot.ini loads the kernel dtb for whichever it ended on. The IDs are the
  ones the G350's panels of the same families answer and have not been read on
  a G80CA, so BOOT also carries `uboot-panel9.dtb`, the same dtb starting on
  Panel 9, and `R36S-PANEL.txt` says how to swap it in.
- Updates: spruce's Firmware Update looks up the G350's payload, which would
  leave the clone dark, so the image stamps `OS_VERSION="999.0.0"` (spruce then
  never offers one) and the real version as `DARKMOSS_VERSION`. Its own payload
  is `dArkMoss_R36SCLONE_<version>.dmupd`: renamed
  `dArkMoss_G350_<version>.dmupd` at the root of the spruce card, Firmware
  Update installs it. The applier checks `DARKMOSS_UNIT`, so it refuses a
  payload built for another unit.
- USB: the clone's only USB data port is the OTG controller, so the image
  leaves wired adbd off and the port stays a host for a WiFi dongle.
  `extras/spruce/App/USBMode` is a spruce app that switches it: copy the
  folder to `App/` on the spruce card, and its menu entry turns adbd at boot
  on (wired adb) or off (WiFi dongle). The boot line carries
  `usbcore.autosuspend=-1`: with autosuspend on, a dongle plugged in after
  boot is not detected.
- Headphones: `hpjackd` sets the rk817 Playback Path to HP while the jack
  switch is on and SPK while it is off. The dts reads the detect pin active
  high, as on the unit this branch is for (dArkOSRE's 20250422 dtb; its
  20250423 dtb and arkos4clone have it active low). On a board that reads it
  the other way, `/boot/headphones-invert` flips it; `R36S-PANEL.txt` says so.
