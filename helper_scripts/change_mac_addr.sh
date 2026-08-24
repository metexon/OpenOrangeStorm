#!/usr/bin/env bash

# sets a unique mac addr and hostname
# useful if you have more than one openorangestorm machine
# (otherwise they have same mac and hostname)

set -euo pipefail

# Must be run as root / with sudo
if [[ "${EUID}" -ne 0 ]]; then
    echo "Error: This script must be run with sudo."
    echo
    echo "Please run it again with:"
    echo "  sudo $0"
    exit 1
fi

# Check required commands
for CMD in nmcli hostnamectl od tr; do
    if ! command -v "$CMD" >/dev/null 2>&1; then
        echo "Error: Required command '$CMD' was not found."
        exit 1
    fi
done

ETH_INTERFACE="eth0"
WIFI_INTERFACE="wlan0"

echo "OpenOrangeStorm Network Setup"
echo "============================="
echo
echo "This script will:"
echo "  - generate a unique device ID"
echo "  - assign a persistent Ethernet MAC address"
echo "  - assign a persistent Wi-Fi MAC address if Wi-Fi is available"
echo "  - set the hostname to openorangestorm-xxxxxx"
echo
echo "A reboot will be required afterwards."
echo

read -r -p "Generate and apply new network identities? [y/N]: " ANSWER

case "${ANSWER,,}" in
    y|yes)
        ;;
    *)
        echo
        echo "No changes were made."
        exit 0
        ;;
esac

# Generate a random 3-byte device ID.
# Example: a473c2
DEVICE_ID="$(od -An -N3 -tx1 /dev/urandom | tr -d ' \n')"

B1="${DEVICE_ID:0:2}"
B2="${DEVICE_ID:2:2}"
B3="${DEVICE_ID:4:2}"

NEW_HOSTNAME="openorangestorm-${DEVICE_ID}"

# Locally administered unicast MAC addresses.
#
# Ethernet:
#   02:10:00:xx:xx:xx
#
# Wi-Fi:
#   02:20:00:xx:xx:xx
#
# The last three bytes match the hostname suffix.
NEW_ETH_MAC="02:10:00:${B1}:${B2}:${B3}"
NEW_WIFI_MAC="02:20:00:${B1}:${B2}:${B3}"

echo
echo "Generated configuration:"
echo "  Hostname:     $NEW_HOSTNAME"
echo "  Ethernet MAC: $NEW_ETH_MAC"
echo "  Wi-Fi MAC:    $NEW_WIFI_MAC"
echo

#
# Ethernet
#

if nmcli device show "$ETH_INTERFACE" >/dev/null 2>&1; then
    ETH_CONNECTION="$(nmcli -g GENERAL.CONNECTION device show "$ETH_INTERFACE")"

    if [[ -n "$ETH_CONNECTION" && "$ETH_CONNECTION" != "--" ]]; then
        echo "Configuring Ethernet connection:"
        echo "  $ETH_CONNECTION"

        nmcli connection modify "$ETH_CONNECTION" \
            802-3-ethernet.cloned-mac-address "$NEW_ETH_MAC"

        echo "Ethernet MAC address configured."
    else
        echo "Warning: '$ETH_INTERFACE' exists but has no active NetworkManager connection."
        echo "Ethernet MAC address was not changed."
    fi
else
    echo "Warning: Ethernet interface '$ETH_INTERFACE' was not found."
fi

echo

#
# Wi-Fi
#

if nmcli device show "$WIFI_INTERFACE" >/dev/null 2>&1; then
    WIFI_CONNECTION="$(nmcli -g GENERAL.CONNECTION device show "$WIFI_INTERFACE")"mete

    if [[ -n "$WIFI_CONNECTION" && "$WIFI_CONNECTION" != "--" ]]; then
        echo "Configuring active Wi-Fi connection:"
        echo "  $WIFI_CONNECTION"

        nmcli connection modify "$WIFI_CONNECTION" \
            802-11-wireless.cloned-mac-address "$NEW_WIFI_MAC"

        echo "Wi-Fi MAC address configured."
    else
        echo "Wi-Fi interface '$WIFI_INTERFACE' exists, but no Wi-Fi connection is currently active."
        echo

        mapfile -t WIFI_CONNECTIONS < <(
            nmcli -t -f NAME,TYPE connection show |
            awk -F: '$2 == "802-11-wireless" {print $1}'
        )

        if [[ "${#WIFI_CONNECTIONS[@]}" -gt 0 ]]; then
            echo "Applying the Wi-Fi MAC address to stored Wi-Fi connection(s):"

            for WIFI_CONNECTION in "${WIFI_CONNECTIONS[@]}"; do
                echo "  $WIFI_CONNECTION"

                nmcli connection modify "$WIFI_CONNECTION" \
                    802-11-wireless.cloned-mac-address "$NEW_WIFI_MAC"
            done

            echo "Wi-Fi MAC address configured."
        else
            echo "No stored Wi-Fi connections were found."
            echo "Wi-Fi MAC address was not changed."
        fi
    fi
else
    echo "Wi-Fi interface '$WIFI_INTERFACE' was not found."
fi

echo

#
# Hostname
#

hostnamectl set-hostname "$NEW_HOSTNAME"

echo "Hostname configured."
echo
echo "========================================"
echo "Configuration saved successfully"
echo "========================================"
echo
echo "Hostname:     $NEW_HOSTNAME"
echo "Ethernet MAC: $NEW_ETH_MAC"

if nmcli device show "$WIFI_INTERFACE" >/dev/null 2>&1; then
    echo "Wi-Fi MAC:    $NEW_WIFI_MAC"
fi

echo
echo "The new network configuration will become active after a reboot."
echo
echo "Please reboot the printer using:"
echo
echo "  sudo reboot"
echo

exit 0