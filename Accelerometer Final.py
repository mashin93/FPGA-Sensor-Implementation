# -*- coding: utf-8 -*-
"""
Created on Thu Dec 12 13:16:21 2019

@author: sjung13
"""

# -*- coding: utf-8 -*-

#%%
# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.animation as animation
from scipy import ndimage
import visa

#%% 
# Define FrontPanel device variable, open USB communication and
# load the bit file in the FPGA
dev = ok.okCFrontPanel()  # define a device for FrontPanel communication
SerialStatus=dev.OpenBySerial("")      # open USB communicaiton with the OK board
ConfigStatus=dev.ConfigureFPGA("Lab10.runs\impl_1\Lab10.bit"); # Configure the FPGA with this bit file

# Check if FrontPanel is initialized correctly and if the bit file is loaded.
# Otherwise terminate the program
print("----------------------------------------------------")
if SerialStatus == 0:
    print ("FrontPanel host interface was successfully initialized.")
else:    
    print ("FrontPanel host interface not detected. The error code number is:" + str(int(SerialStatus)))
    print("Exiting the program.")
    sys.exit ()

if ConfigStatus == 0:
    print ("Your bit file is successfully loaded in the FPGA.")
else:
    print ("Your bit file did not load. The error code number is:" + str(int(ConfigStatus)))
    print ("Exiting the progam.")
    sys.exit ()
print("----------------------------------------------------")
print("----------------------------------------------------")

#%%
# This section of the code cycles through all USB connected devices to the computer.
# The code figures out the USB port number for each instrument.
# The port number for each instrument is stored in a variable named â€œinstrument_idâ€
# If the instrument is turned off or if you are trying to connect to the 
# keyboard or mouse, you will get a message that you cannot connect on that port.
device_manager = visa.ResourceManager()
devices = device_manager.list_resources()
number_of_device = len(devices)

power_supply_id = -1;
waveform_generator_id = -1;
digital_multimeter_id = -1;
oscilloscope_id = -1;

# assumes only the DC power supply is connected
for i in range (0, number_of_device):

# check that it is actually the power supply
    try:
        device_temp = device_manager.open_resource(devices[i])
        print("Instrument connect on USB port number [" + str(i) + "] is " + device_temp.query("*IDN?"))
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.2-6.0-2.0\r\n'):
            power_supply_id = i        
        if (device_temp.query("*IDN?") == 'HEWLETT-PACKARD,E3631A,0,3.0-6.0-2.0\r\n'):
            power_supply_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,33511B,MY52301259,3.03-1.19-2.00-52-00\n'):
            waveform_generator_id = i
        if (device_temp.query("*IDN?") == 'Agilent Technologies,34461A,MY53207926,A.01.10-02.25-01.10-00.35-01-01\n'):
            digital_multimeter_id = i 
        if (device_temp.query("*IDN?") == 'Keysight Technologies,34461A,MY53212931,A.02.08-02.37-02.08-00.49-01-01\n'):
            digital_multimeter_id = i            
        if (device_temp.query("*IDN?") == 'KEYSIGHT TECHNOLOGIES,MSO-X 3024T,MY54440281,07.10.2017042905\n'):
            oscilloscope_id = i                        
        device_temp.close()
    except:
        print("Instrument on USB port number [" + str(i) + "] cannot be connected. The instrument might be powered of or you are trying to connect to a mouse or keyboard.\n")
    

#%%
# Open the USB communication port with the power supply.
# The power supply is connected on USB port number power_supply_id.
# If the power supply ss not connected or turned off, the program will exit.
# Otherwise, the power_supply variable is the handler to the power supply
    
if (power_supply_id == -1):
    print("Power supply instrument is not powered on or connected to the PC.")    
else:
    print("Power supply is connected to the PC.")
    power_supply = device_manager.open_resource(devices[power_supply_id]) 
    
    output_voltage = np.arange(3, 5.5, .5)
    measured_voltage = np.array([]) # create an empty list to hold our values
    measured_current = np.array([]) # create an empty list to hold our values

    print(power_supply.write("OUTPUT ON")) # power supply output is turned on




#%% 
# Define the two variables that will send data to the FPGA
# We will use WireIn instructions to send data to the FPGA
time.sleep(0.5)

trigger = 1; # variable_1 is initilized to digitla number 50
direction = 1;
frequency = 499999;

pwm = 1
dev.SetWireInValue(0x00, trigger) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x01, direction) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x02, frequency) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x04, pwm) #Input data for Variable 1 using mamoery spacee 0x00
dev.UpdateWireIns()  # Update the WireIns



x_accel_mean = np.zeros(0)
y_accel_mean = np.zeros(0)
z_accel_mean = np.zeros(0)

x_accel_stdev = np.zeros(0)
y_accel_stdev = np.zeros(0)
z_accel_stdev = np.zeros(0)

      
for v in output_voltage:
    
    power_supply.write("APPLy P6V, %0.2f, 0.5" % v)
    
    x_accel = np.zeros(0)
    y_accel = np.zeros(0)
    z_accel = np.zeros(0)
    
    for i in range(50):
    
        start_time = time.time() # start time of the loop
        
        time.sleep(.007)
        
        dev.UpdateWireOuts()
        
        result_sum1 = dev.GetWireOutValue(0x20)
        if(result_sum1 &(1<<(16-1))):
            result_sum1 = result_sum1 - (1<<16)
        result_x = (result_sum1 >> 4) * 0.001
        print("X acceleration " + str((result_x)) + "g") 
           
        result_sum2 = dev.GetWireOutValue(0x21)
        if(result_sum2 &(1<<(16-1))):
            result_sum2 = result_sum2 - (1<<16)
        result_y = (result_sum2 >> 4) * 0.001
        print("Y acceleration " + str((result_y)) + "g") 
        
        result_sum3 = dev.GetWireOutValue(0x22)
        if(result_sum3 &(1<<(16-1))):
            result_sum3 = result_sum3 - (1<<16)
        result_z = (result_sum3 >> 4) * 0.001
        print("Z acceleration " + str((result_z)) + "g") 
        print("")
    
        x_accel = np.append(x_accel, result_x)
        y_accel = np.append(y_accel, result_y)
        z_accel = np.append(z_accel, result_z)
        
        print("Data read per second: ", 1.0 / (time.time() - start_time)) # FPS = 1 / time to process loop
        
    x_accel_mean_temp = np.mean(x_accel)
    y_accel_mean_temp = np.mean(y_accel)
    z_accel_mean_temp = np.mean(z_accel)
    
    x_accel_stdev_temp = np.std(x_accel)
    y_accel_stdev_temp = np.std(y_accel)
    z_accel_stdev_temp = np.std(z_accel)
    
    x_accel_stdev = np.append(x_accel_stdev, x_accel_stdev_temp)
    y_accel_stdev = np.append(y_accel_stdev, y_accel_stdev_temp)
    z_accel_stdev = np.append(z_accel_stdev, z_accel_stdev_temp)
    
    x_accel_mean = np.append(x_accel_mean, x_accel_mean_temp)
    y_accel_mean = np.append(y_accel_mean, y_accel_mean_temp)
    z_accel_mean = np.append(z_accel_mean, z_accel_mean_temp)
    
dev.SetWireInValue(0x04, 0) #Input data for Variable 1 using mamoery spacee 0x00
dev.UpdateWireIns()  # Update the WireIns

voltage = [3.0, 3.5, 4.0, 4.5, 5.0]

plt.figure()
plt.plot(voltage, x_accel_mean)
plt.title("Measured Voltage vs. Mean Accel(x)")
plt.xlabel("Applied Volts [V]")
plt.ylabel("Mean Accel(x) [G]")
plt.draw()

plt.figure()
plt.plot(voltage, y_accel_mean)
plt.title("Measured Voltage vs. Mean Accel(y)")
plt.xlabel("Applied Volts [V]")
plt.ylabel("Mean Accel(y [G])")
plt.draw()

plt.figure()
plt.plot(voltage, z_accel_mean)
plt.title("Measured Voltage vs. Mean Accel(z)")
plt.xlabel("Applied Volts [V]")
plt.ylabel("Mean Accel(z) [G]")
plt.draw()

plt.figure()
plt.plot(voltage, x_accel_stdev)
plt.title("Measured Voltage vs. Stdev Accel(x)")
plt.xlabel("Applied Volts [V]")
plt.ylabel("Stdev Accel(x) [G]")
plt.draw()

plt.figure()
plt.plot(voltage, y_accel_stdev)
plt.title("Measured Voltage vs. Stdev Accel(y)")
plt.xlabel("Applied Volts [V]")
plt.ylabel("Stdev Accel(y) [G]")
plt.draw()

plt.figure()
plt.plot(voltage, z_accel_stdev)
plt.title("Measured Voltage vs. Stdev Accel(z)")
plt.xlabel("Applied Volts [V]")
plt.ylabel("Stdev Accel(z) [G]")
plt.draw()



dev.Close
    
#%%