# spruce support for the Anbernic RG351P

spruce's side of the dArkMoss `rg351p` unit. One set of files, two uses:

- **A pull request to spruceOS**: `0001-Add-the-Anbernic-RG351P.patch`, or
  `make.sh spruce <checkout>` against a newer spruceOS.
- **An overlay** for a spruce card that does not carry the RG351P yet:
  `make.sh overlay <out.zip>`.

## Layout

```
files/        the new spruce files, at their paths on the card / in spruceOS
  spruce/scripts/platform/darkmoss/RG351P.cfg, RG351P.sh   platform
  spruce/scripts/platform/darkmoss/RG351P-patch.sh         overlay only
  App/PyUI/main-ui/devices/darkmoss/rg351p.py, json/rg351p-system.json
  RetroArch/platform/retroarch-RG351P.cfg.bak
  RetroArch/.retroarch/autoconfig/udev/OpenSimHardware OSH PB Controller.cfg
  Emu/NDS/config/drastic-RG351P.cfg(.bak)
  spruce/flags/first_boot_RG351P.lock
make.sh       builds the PR change or the overlay zip from files/
0001-Add-the-Anbernic-RG351P.patch   the PR, on spruceOS Development 6ca7c2f
test_mapping.py   checks rg351p.py's key mapping against a spruceOS PyUI tree
```

The shared spruce files only need "RG351P" next to "V10" (six one-line
edits: `helperFunctions.sh` device name `ANBERNIC_RG351P`, PyUI `launch.sh`
and `device_factory.py`, `drastic_functions.sh`, and the app launchers).
`RG351P-patch.sh` is the single definition of those edits:

- `make.sh spruce` runs it against a spruceOS checkout, so the PR carries the
  edits as plain source changes, and leaves the patcher and its hook out.
- On a card, `RG351P.cfg` runs it once per boot (the block between the
  `overlay only` markers), editing that card's own spruce files in place. It
  works across spruce versions, and the edits come back after a spruce
  update.

Once spruceOS merges the RG351P, the overlay is no longer needed: the
patcher sees RG351P already named in every file and does nothing.

## Sending the PR

In a clone of your spruceOS fork, on a branch from `Development`:

```sh
git am /path/to/0001-Add-the-Anbernic-RG351P.patch
```

If Development has moved on and the patch no longer applies, regenerate it:

```sh
/path/to/make.sh spruce .        # fails, naming the file, if a V10 anchor moved
git add -A && git commit
```

Adding another dArkMoss unit the same way: copy files/ with the new name,
and change `RG351P`/`rg351p` and the anchors in the patcher.

## Installing the overlay

1. Extract spruce onto the card's **SPRUCEOS** drive.
2. Extract the overlay zip into the same drive and replace all.
3. Boot. `Saves/spruce/rg351p-patch.log` lists the shared files it edited.

Not yet run on hardware.
