import time, sys
import board
import adafruit_ccs811
from subprocess import Popen, PIPE
token="vdRsH8PPe8nme153ERpC"
host="localhost"
port="1883"
delaytime = int(sys.argv[1])

def console(cmd):
    p = Popen(cmd, shell=True, stdout=PIPE)
    out, err = p.communicate()
    return out.decode('ascii').strip()

i2c = board.I2C()  # uses board.SCL and board.SDA
ccs811 = adafruit_ccs811.CCS811(i2c)

# Wait for the sensor to be ready
while not ccs811.data_ready:
    pass

while True:
    #print("CO2: {} PPM, TVOC: {} PPB".format(ccs811.eco2, ccs811.tvoc))
    co2=ccs811.eco2
    if(co2 is not None) and (co2>=400) and (co2<5000):
        data='{"Co2":'+str(co2)+'}'
        publish='mosquitto_pub -d -q 1 -h "'+host+'" -p "'+port+'" -t "v1/devices/me/telemetry" -u "'+token+'" -m '+ data
        console(publish)
        time.sleep(delaytime)
    else:
        time.sleep(1)
