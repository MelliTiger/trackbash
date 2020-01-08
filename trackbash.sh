#!/bin/bash
#    Trackbash - mitschreiben von GPS-Daten in ICE der Deutschen Bahn
#    Copyright (C) 2019 Andreas Preissig
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
    
logdatei=$HOME"/"$( date -u +%Y-%m-%d_%H-%M-%S-%Z)".csv"
echo "Skript zum Auslesen der DB API"
echo "--"
echo "Speichere in "$logdatei

# Feste Daten abrufen
status=$(curl -sf https://iceportal.de/api1/rs/status | jq . )
train_type=$(echo "$status" | jq -r '.trainType') # Zugtyp
train_series=$(echo "$status" | jq -r '.series')  # Baureihe
train_train=$(echo "$status" | jq -r '.tzn')     # Triebzugnummer
gps_status=$(echo "$status" | jq -r '.gpsStatus')

throttle=1

while true 
do
   if [ $throttle -eq "1" ]
     then
       train=$(curl -sf https://iceportal.de/api1/rs/tripInfo/trip | jq '.')
       train_number=$(echo "$train" | jq -r '.trip.vzn')
       train_dst_total=$(echo "$train" | jq -r '.trip.totalDistance')
       train_dst_total=$((train_dst_total / 1000))
       train_dst_last=$(echo "$train" | jq -r '.trip.distanceFromLastStop')
       train_dst_last=$((train_dst_last / 1000))
       station=$(curl -sf https://iceportal.de/api1/rs/tripInfo/trip | jq '[.[].stops[]? | select(.info.passed == false)][0]')
       station_name=$(echo "$station" | jq -r '.station.name')
       station_track=$(echo "$station" | jq -r '.track.actual')
       station_arrival=$(echo "$station" | jq -r '.timetable.scheduledArrivalTime')
       station_arrival=$(date --date="@$((station_arrival / 1000))" +%H:%M)
       station_delay=$(echo "$station" | jq -r '.timetable.arrivalDelay')
       if [ -n "$station_delay" ];
         then
           station_delay=$station_delay
         else
           station_delay="pünktlich"
         fi
	throttle=6
     fi
   printf "\033c"
   echo "Zug "$train_type" "$train_number" mit Baureihe "$train_series", Triebzug "$train_train". GPS-Status: "$gps_status
   echo "Gesamte Strecke: "$train_dst_total" km, seit letztem Halt: "$train_dst_last" km"
   echo "Nächster Halt: "$station_name" auf Gleis "$station_track" um "$station_arrival". Aktuelle Verspätung: "$station_delay
   echo "---  Speicherung unter : "$logdatei
   status=$(curl -sf https://iceportal.de/api1/rs/status | jq .  ) 
   gps_latitude=$(echo "$status" | jq -r '.latitude')
   gps_longitude=$(echo "$status" | jq -r '.longitude')
   gps_speed=$(echo "$status" | jq -r '.speed')
   gps_zeit=$(echo "$status" | jq -r '.serverTime')
   gps_status=$(echo "$status" | jq -r '.gpsStatus')
   case "$gps_status" in
     VALID)
        echo $gps_zeit", "$gps_latitude", "$gps_longitude", "$gps_speed >> $logdatei
        ;;
     LAST_KNOWN_POSITION)
        echo "#"$gps_zeit", Kein Empfang, Kein Empfang, "$gps_speed >> $logdatei
        ;;
     *)
        echo "#"$gps_zeit", unklare Rückmeldung!"
        ;;
   esac     
   tail -n $((LINES - 7)) $logdatei | column -t -s,
   throttle=$((throttle-1))
   sleep 5
done
