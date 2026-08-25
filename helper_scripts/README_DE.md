# MAC-Adresse und Hostname ändern

`change_mac_addr.sh` richtet eine eindeutige Netzwerkidentität für eine OpenOrangeStorm-Installation ein.

Das Skript:

- erzeugt eine zufällige Geräte-ID
- setzt den Hostnamen auf `openorangestorm-xxxxxx`
- weist der Ethernet-Schnittstelle eine dauerhafte, lokal verwaltete MAC-Adresse zu
- weist WLAN eine passende dauerhafte MAC-Adresse zu, wenn eine WLAN-Verbindung verfügbar ist
- macht Hostname, Ethernet-MAC und WLAN-MAC leicht zuzuordnen, weil dieselbe Geräte-ID verwendet wird

## Direkt von GitHub ausführen

Das Skript benötigt Root-Rechte. Du kannst es mit `wget` herunterladen und direkt an `bash` übergeben:

```bash
wget -qO- https://raw.githubusercontent.com/metexon/OpenOrangeStorm/refs/heads/main/helper_scripts/change_mac_addr.sh | sudo bash
```

Das Skript zeigt die erzeugte Konfiguration an und fragt nach einer Bestätigung, bevor Änderungen angewendet werden.

Nachdem die Konfiguration geschrieben wurde, starte den Drucker neu.

## Herunterladen und manuell ausführen

Alternativ kannst du das Skript zuerst herunterladen:

```bash
wget https://raw.githubusercontent.com/metexon/OpenOrangeStorm/refs/heads/main/helper_scripts/change_mac_addr.sh
```

Mache es ausführbar:

```bash
chmod +x change_mac_addr.sh
```

Führe es dann mit `sudo` aus:

```bash
sudo ./change_mac_addr.sh
```

## Hostnamen manuell ändern

Wenn du nur den Hostnamen ändern möchtest, kannst du das ohne das MAC-Adress-Skript tun.

Ersetze `mein-drucker-name` durch den Namen deiner Wahl:

```bash
sudo hostnamectl set-hostname mein-drucker-name
```

Hostnamen sollten nur Buchstaben, Zahlen und Bindestriche enthalten. Vermeide Leerzeichen und Sonderzeichen.

Starte den Drucker danach neu:

```bash
sudo reboot
```

## Warum ist das nötig?

Wenn mehrere OpenOrangeStorm-Systeme aus demselben System-Image erstellt werden, können sie dieselbe Netzwerkidentität haben. Dadurch können sich mehrere Drucker im selben Netzwerk gegenseitig stören oder unter derselben Adresse erscheinen.

Wenn du dieses Skript einmal auf jedem Drucker ausführst, erhält jede Maschine eigene dauerhafte MAC-Adressen und einen eigenen Hostnamen.
