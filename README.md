# Trackbash
Ein Bash-Skript um im Portal der ICE der deutschen Bahn:
* die Zugdaten abzurufen,
* diese Daten anzuzeigen 
und 
* die übermittelten Koordinaten in eine Datei zu schreiben.

Beim Schreiben dieses Skripts waren hilfreich:
https://github.com/derhuerst/wifi-on-ice-portal-client

und das Skript "info-wifionice" aus dem Repo 
https://github.com/polybar/polybar-scripts

## Funktionsweise

1. Sinnvollerweise im Zug sitzen und sich mit dem WLAN "WIFIonICE"
verbinden.
1. Das Skript aufrufen. Dabei wird automatisch eine .csv-Datei angelegt, in
der die abgefahrenen Koordinaten abgelegt werden.
1. Die abgerufenen Informationen werden dann angezeigt, zusätzlich die
letzten Zeilen der .csv-Datei angezeigt
1. Die .csv-Datei kann dann mittels gpsbabel in das gewünschte Ausgabeformat
konvertiert werden


![alt text](https://raw.githubusercontent.com/MelliTiger/trackbash/master/trackbash.png)
