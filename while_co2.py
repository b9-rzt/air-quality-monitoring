import time, sys
import board
import adafruit_ccs811
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

time.sleep(1200) # Sensor benötigt ca.20min um zu starten und werte ausgeben zu können

i2c = board.I2C()  # uses board.SCL and board.SDA
ccs811 = adafruit_ccs811.CCS811(i2c)

# Wait for the sensor to be ready
while not ccs811.data_ready:
    pass

while True:
    #print("CO2: {} PPM, TVOC: {} PPB".format(ccs811.eco2, ccs811.tvoc))
    co2=ccs811.eco2
    if(co2 is not None) and (co2>=400) and (co2<5000): # if co2 is between 400 and 5000 else the value is wrong
        data='{"Co2":'+str(co2)+'}' # put sensor data in a json format
        # send the data via mqtt to thingsboard
        publish='mosquitto_pub -d -q 1 -h "'+host+'" -p "'+port+'" -t "v1/devices/me/telemetry" -u "'+token+'" -m '+ data 
        console(publish)
        time.sleep(delaytime)
    else:
        time.sleep(1)
