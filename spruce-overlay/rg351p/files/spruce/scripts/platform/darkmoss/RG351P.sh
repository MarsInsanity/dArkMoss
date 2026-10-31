#!/bin/sh
# Anbernic RG351P device functions. Everything the base OS decides is in
# dArkMossCommon.sh; this file holds what is particular to this unit. Board,
# codec and memory behave as on the V10 (V10.sh), the pad and the motor do not.

. "/mnt/SDCARD/spruce/scripts/platform/darkmoss/dArkMossCommon.sh"

# The rk817 codec switches to the jack itself, as on the V10.
apply_playback_path() {
    :
}

set_event_arg_for_idlemon() {
    EVENT_ARG="-e $EVENT_PATH_READ_INPUTS_SPRUCE"
}

# Volume is the hardware wheel, after the codec. spruce keeps the codec at
# full and stores full, whatever level it is asked for: the setting is hidden
# in PyUI (rg351p.py's supports_volume) and nothing here steps it. The one
# exception is a temporary mute that is not saved (sleep_helper.sh mutes with
# "set_volume 0 false" so waking to shut down is silent, then restores).
set_volume() {
    if [ "$1" = "0" ] && [ "${2:-true}" = "false" ]; then
        amixer -q sset -M "${VOLUME_CONTROL:-Master}" 0% 2>/dev/null
        log_message "$PLATFORM: codec muted (temporary)"
        return 0
    fi
    amixer -q sset -M "${VOLUME_CONTROL:-Master}" 100% 2>/dev/null
    bt_headset_volume 20
    apply_playback_path
    if [ "${2:-true}" = "true" ]; then
        save_volume_to_config_file 20 2>/dev/null
    fi
}

volume_up() {
    :
}

volume_down() {
    :
}

# A real stick and a hat d-pad: nothing to swap.
swap_dpad_analog_toggle() {
    :
}

treat_dpad_as_analog() {
    :
}

treat_dpad_as_dpad() {
    :
}

device_get_charging_status() {
    if grep -qs "^1$" /sys/class/power_supply/ac/online /sys/class/power_supply/usb/online; then
        if [ "$(cat "$BATTERY/capacity" 2>/dev/null)" = "100" ]; then
            echo "Full"
        else
            echo "Charging"
        fi
    else
        echo "Discharging"
    fi
}

# As the V10: memory clock changes make the sound crackle, so pin it.
set_dram_governor() {
    [ -n "$DRAM_DEVFREQ_DIR" ] && [ -d "$DRAM_DEVFREQ_DIR" ] || return 0
    _top=$(tr ' ' '\n' < "$DRAM_DEVFREQ_DIR/available_frequencies" 2>/dev/null | grep -v '^$' | sort -n | tail -1)
    [ -n "$_top" ] || return 0
    echo userspace > "$DRAM_DEVFREQ_DIR/governor" 2>/dev/null
    echo "$_top" > "$DRAM_DEVFREQ_DIR/userspace/set_freq" 2>/dev/null
    echo "$_top" > "$DRAM_DEVFREQ_DIR/min_freq" 2>/dev/null
}

# The motor hangs off pwm0 (GPIO0_B7). It is not a force-feedback device on
# the pad, so darkmoss_vibrate's rumble tool has nothing to talk to. Drive the
# PWM directly and always leave it disabled, so it can never stay on.
RG351P_PWM_PERIOD=1000000
_rg351p_pwm() {
    _chip="${RG351P_PWM_CHIP:-/sys/class/pwm/pwmchip0}"
    [ -d "$_chip" ] || return 1
    [ -d "$_chip/pwm0" ] || echo 0 > "$_chip/export" 2>/dev/null
    [ -d "$_chip/pwm0" ] || return 1
    echo "$_chip/pwm0"
}

vibrate() {
    duration=""
    intensity="$(get_config_value '.menuOptions."System Settings".rumbleIntensity.selected' "Medium")"
    while [ $# -gt 0 ]; do
        case "$1" in
        --intensity) shift; intensity="$1" ;;
        [0-9]*) duration="$1" ;;
        esac
        shift
    done

    case "$intensity" in
        "Off")    return 0 ;;
        "Weak")   duty=$((RG351P_PWM_PERIOD * 6 / 10)); tier_duration=200 ;;
        "Strong") duty=$RG351P_PWM_PERIOD;              tier_duration=450 ;;
        *)        duty=$((RG351P_PWM_PERIOD * 8 / 10)); tier_duration=300 ;;
    esac
    [ -n "$duration" ] || duration="$tier_duration"

    _pwm="$(_rg351p_pwm)" || return 0
    # period before duty_cycle: the kernel refuses a duty longer than the period.
    echo "$RG351P_PWM_PERIOD" > "$_pwm/period" 2>/dev/null
    echo "$duty" > "$_pwm/duty_cycle" 2>/dev/null
    echo 1 > "$_pwm/enable" 2>/dev/null
    sleep "$(awk -v ms="$duration" 'BEGIN { printf "%.3f", ms / 1000 }')"
    echo 0 > "$_pwm/duty_cycle" 2>/dev/null
    echo 0 > "$_pwm/enable" 2>/dev/null
}

# udev numbering of this pad: select 7, B 1, R2 11.
set_default_ra_hotkeys() {
    RA_FILE="/mnt/SDCARD/Saves/ra-configs/retroarch-$PLATFORM.cfg"

    log_message "Resetting RetroArch hotkeys to Spruce defaults."

    update_ra_config_file_with_new_setting "$RA_FILE" \
        "input_enable_hotkey_btn = \"7\"" \
        "input_exit_emulator_btn = \"1\"" \
        "input_fps_toggle_btn = \"2\"" \
        "input_load_state_btn = \"4\"" \
        "input_save_state_btn = \"5\"" \
        "input_menu_toggle = \"f1\"" \
        "input_menu_toggle_btn = \"3\"" \
        "input_quit_gamepad_combo = \"0\"" \
        "input_toggle_fast_forward_btn = \"11\"" \
        "input_screenshot_btn = \"nul\"" \
        "input_shader_toggle_btn = \"nul\"" \
        "input_state_slot_decrease_btn = \"nul\"" \
        "input_state_slot_increase_btn = \"nul\"" \
        "input_toggle_slowmotion_btn = \"nul\""
}
