import time
import board
import sys
import adafruit_dht
from subprocess import Popen, PIPE
token="vdRsH8PPe8nme153ERpC"
host="localhost"
port="1883"
delaytime = sys.argv[1]

def console(cmd):
    p = Popen(cmd, shell=True, stdout=PIPE)
    out, err = p.communicate()
    return out.decode('ascii').strip()
 
# Initial the dht device, with data pin connected to:
# dhtDevice = adafruit_dht.DHT22(board.D4)
 
# you can pass DHT22 use_pulseio=False if you wouldn't like to use pulseio.
# This may be necessary on a Linux single board computer like the Raspberry Pi,
# but it will not work in CircuitPython.
dhtDevice = adafruit_dht.DHT11(board.D4, use_pulseio=False)
 
while True:
    try:
        # Print the values to the serial port
        temperature_c = dhtDevice.temperature
        temperature_f = temperature_c * (9 / 5) + 32
        humidity = dhtDevice.humidity
        data='{"Temperature":'+str(temperature_c)+',"Humidity":'+str(humidity)+'}'

        publish='mosquitto_pub -d -q 1 -h "'+host+'" -p "'+port+'" -t "v1/devices/me/telemetry" -u "'+token+'" -m '+ data
        console(publish)
        print(
            "Temp: {:.1f} F / {:.1f} C    Humidity: {}% ".format(
                temperature_f, temperature_c, humidity
            )
        )
    except RuntimeError as error:
        # Errors happen fairly often, DHT's are hard to read, just keep going
        print(error.args[0])
        time.sleep(2.0)
        continue
    except Exception as error:
        dhtDevice.exit()
        raise error
 
    time.sleep(delaytime)