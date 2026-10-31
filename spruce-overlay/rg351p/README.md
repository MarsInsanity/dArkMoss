# spruce overlay for the Anbernic RG351P

spruce's files for the RG351P (dArkMoss `rg351p` unit), for spruce versions
that do not include it yet. Unpack spruce first, then copy this folder's
contents (everything except this README) onto the **SPRUCEOS** drive and
replace all.

Built on spruceOS `Development` at 6ca7c2f. The changed shared files below are
whole copies of that revision, so use a spruce nightly from the same week or
later; on an older spruce they would replace newer files with older ones.

New:

- `spruce/scripts/platform/darkmoss/RG351P.cfg`, `RG351P.sh`: the platform.
  Display, CPU and audio as the V10 (same panel, SoC and codec). The pad is
  the RG351P's internal USB controller, "OpenSimHardware OSH PB Controller",
  with a hat d-pad; codes from ArkOS's RG351P EmulationStation config. The
  rumble motor is on pwm0, so `vibrate` drives the PWM.
- `App/PyUI/main-ui/devices/darkmoss/rg351p.py`, `json/rg351p-system.json`:
  the PyUI device. No menu button: SELECT+START (or the stick click) opens
  the menu.
- `RetroArch/platform/retroarch-RG351P.cfg.bak`,
  `RetroArch/.retroarch/autoconfig/udev/OpenSimHardware OSH PB Controller.cfg`
- `Emu/NDS/config/drastic-RG351P.cfg` (+ `.bak`)
- `spruce/flags/first_boot_RG351P.lock`

Changed (RG351P added next to V10):

- `spruce/scripts/helperFunctions.sh` (device name `ANBERNIC_RG351P`)
- `App/PyUI/launch.sh`, `App/PyUI/main-ui/devices/device_factory.py`
- `spruce/scripts/emu/lib/drastic_functions.sh`
- `App/-FirmwareUpdate-/firmwareUpdate.sh`, `App/AccentColor/launch.sh`,
  `App/FileManagement/launch.sh`, `App/Gallery/launch.sh`,
  `App/PixelReader/launch.sh`

Not verified on hardware yet.
