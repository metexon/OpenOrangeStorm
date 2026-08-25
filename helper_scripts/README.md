# Change MAC Address and Hostname

`change_mac_addr.sh` configures a unique network identity for an OpenOrangeStorm installation.

The script:

- Generates a random device ID
- Sets the hostname to `openorangestorm-xxxxxx`
- Assigns a persistent, locally administered MAC address to the Ethernet interface
- Assigns a corresponding persistent MAC address to Wi-Fi, if a Wi-Fi connection is available
- Keeps the hostname, Ethernet MAC, and Wi-Fi MAC easy to associate by using the same device ID

## Run directly from GitHub

The script requires root privileges. You can download it with `wget` and pipe it directly to `bash`:

```bash
wget -qO- https://raw.githubusercontent.com/metexon/OpenOrangeStorm/refs/heads/main/helper_scripts/change_mac_addr.sh | sudo bash
```

The script will show the generated configuration and ask for confirmation before applying any changes.

After the configuration has been written, reboot the printer.

## Download and run manually

Alternatively, download the script first:

```bash
wget https://raw.githubusercontent.com/metexon/OpenOrangeStorm/refs/heads/main/helper_scripts/change_mac_addr.sh
```

Make it executable:

```bash
chmod +x change_mac_addr.sh
```

Then run it with `sudo`:

```bash
sudo ./change_mac_addr.sh
```

## Change the hostname manually

If you only want to change the hostname, you can do that without running the MAC address script.

Replace `my-printer-name` with the name of your choice:

```bash
sudo hostnamectl set-hostname my-printer-name
```

Hostnames should use only letters, numbers, and hyphens. Avoid spaces and special characters.

Then reboot the printer:

```bash
sudo reboot
```

## Why is this needed?

When multiple OpenOrangeStorm systems are created from the same system image, they may end up with conflicting network identities. This can cause multiple printers on the same network to interfere with each other or appear under the same address.

Running this script once on each printer gives every machine its own persistent MAC addresses and hostname.
