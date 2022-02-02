# raspi-monitoring

Beide Skripte müssen mit einem zusätzlichen Argument gestartet werden --> dem Intervall in dem das Skript die Daten senden soll

Außerdem beinhalten sie eine While schleife somit nur einmal starten am besten über crontab mit @reboot

Beispielsweise:
  python3 while_co2.py 5
