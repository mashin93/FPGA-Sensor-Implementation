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
direction = 0;
frequency = 499999;
pulse = 100;
pwm = 2;
pulse_count = 100;


#%% 

time.sleep(0.5)
# Define the two variables that will send data to the FPGA
# We will use WireIn instructions to send data to the FPGA
trigger = 1; # variable_1 is initilized to digitla number 50
control = 1; # # variable_2 is initilized to digitla number 14
address1 = int('1010011',2);
address2 = int('1000101',2);
data1 = int('10111011',2);
data2 = int('00001001',2);

dev.SetWireInValue(0x05, trigger) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x06, control) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x07, address1) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x08, address2) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x09, data1) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x10, data2) #Input data for Variable 2 using mamoery spacee 0x01
dev.UpdateWireIns()  # Update the WireIns

time.sleep(0.5)                 

# First recieve data from the FPGA by using UpdateWireOuts
trigger = 1;
control = 0;

dev.SetWireInValue(0x05, trigger) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x06, control) #Input data for Variable 2 using mamoery spacee 0x01
dev.UpdateWireIns()  # Update the WireIns

time.sleep(0.5)                 

# First recieve data from the FPGA by using UpdateWireOuts
dev.UpdateWireOuts()

final1 = dev.GetWireOutValue(0x27)  # Transfer the recived data in result_sum variable
final2 = dev.GetWireOutValue(0x28)

print("data read at register address " + str(address1) + " is " + str(final1))
print("data read at register address " + str(address2) + " is " + str(final2))

#%% 
# We will read data from the FPGA in two different variables
# Since we are using a slow clock on the FPGA to compute the results
# we need to wait for the resutl to be computed
time.sleep(0.5)     

trigger = 1; # variable_1 is initilized to digitla number 50
control = 1; # # variable_2 is initilized to digitla number 14

address1 = int('0101010',2);
address2 = int('0111001',2);
data1 = int('00001010',2);
data2 = int('00000011',2);

dev.SetWireInValue(0x05, trigger) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x06, control) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x07, address1) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x08, address2) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x09, data1) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x10, data2) #Input data for Variable 2 using mamoery spacee 0x01

dev.UpdateWireIns()  # Update the WireIns

time.sleep(0.5)                 

# First recieve data from the FPGA by using UpdateWireOuts
trigger = 1;
control = 0;

dev.SetWireInValue(0x05, trigger) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x06, control) #Input data for Variable 2 using mamoery spacee 0x01
dev.UpdateWireIns()  # Update the WireIns

time.sleep(0.5)                 

# First recieve data from the FPGA by using UpdateWireOuts
dev.UpdateWireOuts()

final1 = dev.GetWireOutValue(0x27)  # Transfer the recived data in result_sum variable
final2 = dev.GetWireOutValue(0x28)

print("data read at register address " + str(address1) + " is " + str(final1))
print("data read at register address " + str(address2) + " is " + str(final2))

time.sleep(0.5)     

trigger = 1; # variable_1 is initilized to digitla number 50
control = 1; # # variable_2 is initilized to digitla number 14

address1 = int('1000100',2);
address2 = int('0111001',2);
data1 = int('00000010',2);
data2 = int('00000011',2);

dev.SetWireInValue(0x05, trigger) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x06, control) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x07, address1) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x08, address2) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x09, data1) #Input data for Variable 2 using mamoery spacee 0x01
dev.SetWireInValue(0x10, data2) #Input data for Variable 2 using mamoery spacee 0x01

dev.UpdateWireIns()  # Update the WireIns

time.sleep(0.5)                 

# First recieve data from the FPGA by using UpdateWireOuts
trigger = 1;
control = 0;

dev.SetWireInValue(0x05, trigger) #Input data for Variable 1 using mamoery spacee 0x00
dev.SetWireInValue(0x06, control) #Input data for Variable 2 using mamoery spacee 0x01
dev.UpdateWireIns()  # Update the WireIns

time.sleep(0.5)                 

# First recieve data from the FPGA by using UpdateWireOuts
dev.UpdateWireOuts()

final1 = dev.GetWireOutValue(0x27)  # Transfer the recived data in result_sum variable
final2 = dev.GetWireOutValue(0x28)

print("data read at register address " + str(address1) + " is " + str(final1))
print("data read at register address " + str(address2) + " is " + str(final2))

time.sleep(0.5)

first_run = 0
buf_temp = bytearray(488*648)
reshaped_before = np.array(buf_temp).reshape(488,648, order = 'C')
fig = plt.figure(figsize=(15,10))
im = plt.imshow(reshaped_before, cmap = 'gray' , vmin = 0 , vmax = 255)

dev.SetWireInValue(0x11, 1) #Input data for Variable 1 using mamoery spacee 0x00
dev.UpdateWireIns()
dev.SetWireInValue(0x11, 0) #Input data for Variable 2 using mamoery spacee 0x01
dev.UpdateWireIns()
dev.SetWireInValue(0x12, 1) #Input data for Variable 1 using mamoery spacee 0x00
dev.UpdateWireIns()
dev.SetWireInValue(0x12, 0) #Input data for Variable 2 using mamoery spacee 0x01
dev.UpdateWireIns()


dev.UpdateWireOuts()


update_flag = 0

buf = bytearray(488*648*4);
buf_temp = bytearray(488*648);
print(dev.ReadFromBlockPipeOut(0xa0, 64, buf))





buf_temp = buf[0::4]
    
reshaped_before = np.array(buf_temp).reshape(488,648, order = 'C')
x_before, y_before = ndimage.measurements.center_of_mass(reshaped_before)

def animate(i):
    global reshaped_before
    global pwm
    global x_before
    global update_flag
    
    print("=============================================================================================\n")
       #print(ndimage.measurements.center_of_mass(reshaped_comp))
    dev.UpdateWireOuts()
    ###################################### Accel
    
    result_sum1 = dev.GetWireOutValue(0x20)
    if(result_sum1 &(1<<(16-1))):
        result_sum1 = result_sum1 - (1<<16)
    result_x = (result_sum1 >> 4) * 0.001
    print("X acceleration 1 " + str((result_x)) + "g") 
       
    result_sum2 = dev.GetWireOutValue(0x21)
    if(result_sum2 &(1<<(16-1))):
        result_sum2 = result_sum2 - (1<<16)
    result_y = (result_sum2 >> 4) * 0.001
    print("Y acceleration 1 " + str((result_y)) + "g") 
    
    result_sum3 = dev.GetWireOutValue(0x22)
    if(result_sum3 &(1<<(16-1))):
        result_sum3 = result_sum3 - (1<<16)
    result_z = (result_sum3 >> 4) * 0.001
    print("Z acceleration 1 " + str((result_z)) + "g") 
    print("")
    
    start_time = time.time() # start time of the loop
    
    
    dev.SetWireInValue(0x11, 1) #Input data for Variable 1 using mamoery spacee 0x00
    dev.UpdateWireIns()
    dev.SetWireInValue(0x11, 0) #Input data for Variable 2 using mamoery spacee 0x01
    dev.UpdateWireIns()
    dev.SetWireInValue(0x12, 1) #Input data for Variable 1 using mamoery spacee 0x00
    dev.UpdateWireIns()
    dev.SetWireInValue(0x12, 0) #Input data for Variable 2 using mamoery spacee 0x01
    dev.UpdateWireIns()
    
    
    dev.UpdateWireOuts()
    
    buf = bytearray(488*648*4);
    buf_temp = bytearray(488*648);
    dev.ReadFromBlockPipeOut(0xa0, 64, buf)
    

    
    buf_temp = buf[0::4]    
    
    dev.UpdateWireOuts()
    ###################################### Accel
    
    result_sum1 = dev.GetWireOutValue(0x20)
    if(result_sum1 &(1<<(16-1))):
        result_sum1 = result_sum1 - (1<<16)
    result_x = (result_sum1 >> 4) * 0.001
    print("X acceleration 2 " + str((result_x)) + "g") 
       
    result_sum2 = dev.GetWireOutValue(0x21)
    if(result_sum2 &(1<<(16-1))):
        result_sum2 = result_sum2 - (1<<16)
    result_y = (result_sum2 >> 4) * 0.001
    print("Y acceleration 2 " + str((result_y)) + "g") 
    
    result_sum3 = dev.GetWireOutValue(0x22)
    if(result_sum3 &(1<<(16-1))):
        result_sum3 = result_sum3 - (1<<16)
    result_z = (result_sum3 >> 4) * 0.001
    print("Z acceleration 2 " + str((result_z)) + "g") 
    print("")
    
    reshaped_after = np.array(buf_temp).reshape(488,648, order = 'C')
    

    
    reshaped_comp = np.subtract(reshaped_after, reshaped_before)
    reshaped_pos = reshaped_comp + 0.0
    reshaped_neg = reshaped_comp + 0.0
    reshaped_pos[reshaped_comp > 4] = 0
    reshaped_neg[reshaped_comp < -4] = 0
    
    x_pos, y_pos = ndimage.measurements.center_of_mass(reshaped_pos)
    x_neg, y_neg = ndimage.measurements.center_of_mass(reshaped_neg)
    

    dev.UpdateWireOuts()
    ###################################### Accel
    
    result_sum1 = dev.GetWireOutValue(0x20)
    if(result_sum1 &(1<<(16-1))):
        result_sum1 = result_sum1 - (1<<16)
    result_x = (result_sum1 >> 4) * 0.001
    print("X acceleration 3 " + str((result_x)) + "g") 
       
    result_sum2 = dev.GetWireOutValue(0x21)
    if(result_sum2 &(1<<(16-1))):
        result_sum2 = result_sum2 - (1<<16)
    result_y = (result_sum2 >> 4) * 0.001
    print("Y acceleration 3 " + str((result_y)) + "g") 
    
    result_sum3 = dev.GetWireOutValue(0x22)
    if(result_sum3 &(1<<(16-1))):
        result_sum3 = result_sum3 - (1<<16)
    result_z = (result_sum3 >> 4) * 0.001
    print("Z acceleration 3 " + str((result_z)) + "g") 
    print("")
    
    if y_pos-y_neg > 50:
        direction = 0
        direction_temp = 0
        pwm = 7
        dev.SetWireInValue(0x01, direction) #Input data for Variable 1 using mamoery spacee 0x00
        dev.SetWireInValue(0x02, frequency) #Input data for Variable 1 using mamoery spacee 0x00
        dev.SetWireInValue(0x04, pwm) #Input data for Variable 1 using mamoery spacee 0x00
        dev.UpdateWireIns()  # Update the WireIns
        
        
        if y_pos-y_neg < -50:
            direction = 0
            pwm = 7
            dev.SetWireInValue(0x01, direction) #Input data for Variable 1 using mamoery spacee 0x00
            dev.SetWireInValue(0x02, frequency) #Input data for Variable 1 using mamoery spacee 0x00
            dev.SetWireInValue(0x04, pwm) #Input data for Variable 1 using mamoery spacee 0x00
            dev.UpdateWireIns()  # Update the WireIns

        
 

# =============================================================================      

        
     
    elif y_pos - y_neg < -50:
        direction = 1
        direction_temp = 1
        pwm = 7
        dev.SetWireInValue(0x01, direction) #Input data for Variable 1 using mamoery spacee 0x00
        dev.SetWireInValue(0x02, frequency) #Input data for Variable 1 using mamoery spacee 0x00
        dev.SetWireInValue(0x04, pwm) #Input data for Variable 1 using mamoery spacee 0x00
        dev.UpdateWireIns()  # Update the WireIns
        
        
        if y_pos-y_neg > 50:
            direction = 1
            pwm = 7
            dev.SetWireInValue(0x01, direction) #Input data for Variable 1 using mamoery spacee 0x00
            dev.SetWireInValue(0x02, frequency) #Input data for Variable 1 using mamoery spacee 0x00
            dev.SetWireInValue(0x04, pwm) #Input data for Variable 1 using mamoery spacee 0x00
            dev.UpdateWireIns()  # Update the WireIns

                        

    else:
        direction_temp = -1
        dev.SetWireInValue(0x04, 0) #Input data for Variable 1 using mamoery spacee 0x00
        dev.UpdateWireIns()  # Update the WireIns
        

    dev.UpdateWireOuts()
    ###################################### Accel
    
    result_sum1 = dev.GetWireOutValue(0x20)
    if(result_sum1 &(1<<(16-1))):
        result_sum1 = result_sum1 - (1<<16)
    result_x = (result_sum1 >> 4) * 0.001
    print("X acceleration 4 " + str((result_x)) + "g") 
       
    result_sum2 = dev.GetWireOutValue(0x21)
    if(result_sum2 &(1<<(16-1))):
        result_sum2 = result_sum2 - (1<<16)
    result_y = (result_sum2 >> 4) * 0.001
    print("Y acceleration 4 " + str((result_y)) + "g") 
    
    result_sum3 = dev.GetWireOutValue(0x22)
    if(result_sum3 &(1<<(16-1))):
        result_sum3 = result_sum3 - (1<<16)
    result_z = (result_sum3 >> 4) * 0.001
    print("Z acceleration 4 " + str((result_z)) + "g") 
    print("")
        
    
    reshaped_before = reshaped_after
    im.set_array(reshaped_before)

    
    dev.UpdateWireOuts()
    ###################################### Accel
    
    result_sum1 = dev.GetWireOutValue(0x20)
    if(result_sum1 &(1<<(16-1))):
        result_sum1 = result_sum1 - (1<<16)
    result_x = (result_sum1 >> 4) * 0.001
    print("X acceleration 5 " + str((result_x)) + "g") 
       
    result_sum2 = dev.GetWireOutValue(0x21)
    if(result_sum2 &(1<<(16-1))):
        result_sum2 = result_sum2 - (1<<16)
    result_y = (result_sum2 >> 4) * 0.001
    print("Y acceleration 5 " + str((result_y)) + "g") 
    
    result_sum3 = dev.GetWireOutValue(0x22)
    if(result_sum3 &(1<<(16-1))):
        result_sum3 = result_sum3 - (1<<16)
    result_z = (result_sum3 >> 4) * 0.001
    print("Z acceleration 5 " + str((result_z)) + "g") 
    print("")
    
    if direction_temp == 0:
        print("Direction: left  " + str(y_pos-y_neg) + " \n")
    elif direction_temp == 1:
        print("Direction: right  "+ str(y_pos-y_neg) +"\n")
    elif direction_temp == -1:
        print("Direction: none  "+ str(y_pos-y_neg) +"\n")
        
    print("FPS: ", 1.0 / (time.time() - start_time)) # FPS = 1 / time to process loop
    print("")
    print("=============================================================================================")
    return [im]

dev.SetWireInValue(0x00, 1) #Input data for Variable 1 using mamoery spacee 0x00
dev.UpdateWireIns()

power_supply.write("APPLy P6V, %0.2f, 0.5" % 4.5)

anim = animation.FuncAnimation(fig, animate, frames = 20, interval = 1000/30)


dev.Close
    
#%%