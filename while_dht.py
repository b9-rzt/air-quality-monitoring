import time
import board
import sys
import adafruit_dht
from subprocess import Popen, PIPE

# Token for authentication in Thingsboard
token="vdRsH8PPe8nme153ERpC"

#Thingsboard Ip
host="localhost"

# Thingsboard MQTT Port
port="1883"

# Intervall of sending sensor data in minutes 
delaytime = int(sys.argv[1])*60

# Function to run commands in the commandshell on linux
def console(cmd):
    p = Popen(cmd, shell=True, stdout=PIPE)
    out, err = p.communicate()
    return out.decode('ascii').strip()
 
# Initial the dht device, with data pin connected to:
# dhtDevice = adafruit_dht.DHT22(board.D4)
dhtDevice = adafruit_dht.DHT11(board.D4, use_pulseio=False)
 
while True:
    try:
        # Print the values to the serial port
        temperature_c = dhtDevice.temperature
        humidity = dhtDevice.humidity

        # put sensor data in a json format
        data='{"Temperature":'+str(temperature_c)+',"Humidity":'+str(humidity)+'}'
        
        # send the data via mqtt to thingsboard
        publish='mosquitto_pub -d -q 1 -h "'+host+'" -p "'+port+'" -t "v1/devices/me/telemetry" -u "'+token+'" -m '+ data
        console(publish)

    except RuntimeError as error:
        # Errors happen fairly often, DHT's are hard to read, just keep going
        print(error.args[0])
        time.sleep(2.0)
        continue
    except Exception as error:
        dhtDevice.exit()
        raise error
 
    time.sleep(delaytime)