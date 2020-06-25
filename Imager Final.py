# -*- coding: utf-8 -*-
"""
Created on Fri Dec 13 12:26:37 2019

@author: sjung13
"""

# import various libraries necessery to run your Python code
import time   # time related library
import sys    # system related library
ok_loc = 'C:\\Program Files\\Opal Kelly\\FrontPanelUSB\\API\\Python\\3.6\\x64'
sys.path.append(ok_loc)   # add the path of the OK library
import ok     # OpalKelly library
import numpy as np
import matplotlib.pyplot as plt


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

temporal_pix_buf = np.array([])
temporal_mean_buf = np.array([])
temporal_stdev_buf = np.array([])
FPN_mean_buf = np.zeros(488*648)
FPN_stdev_buf = np.array([])

for i in range(1, 20):

    dev.SetWireInValue(0x11, 1) #Input data for Variable 1 using mamoery spacee 0x00
    dev.UpdateWireIns()
    dev.SetWireInValue(0x11, 0) #Input data for Variable 2 using mamoery spacee 0x01
    dev.UpdateWireIns()
    dev.SetWireInValue(0x12, 1) #Input data for Variable 1 using mamoery spacee 0x00
    dev.UpdateWireIns()
    dev.SetWireInValue(0x12, 0) #Input data for Variable 2 using mamoery spacee 0x01
    dev.UpdateWireIns()
    
    buf = bytearray(488*648*4);
    buf_temp = bytearray(488*648);
    
    
    dev.ReadFromBlockPipeOut(0xa0, 64, buf)
    

    
    for j in range(0, 488*648*4, 4):
        buf_temp[int(j/4)] = buf[j];
        FPN_mean_buf[int(j/4)] = FPN_mean_buf[int(j/4)] + buf[j]
    
    temporal_pix = buf_temp[60000]
    temporal_pix_buf = np.append(temporal_pix_buf, temporal_pix)
    
    for q in range(0, 488*648):
        FPN_mean_buf[q] = FPN_mean_buf[q]/100
    


temporal_mean = np.mean(temporal_pix_buf)
temporal_stdev = np.std(temporal_pix_buf)
FPN_stdev = np.std(FPN_mean_buf)
SNR = temporal_mean / temporal_stdev

reshaped_before = np.array(buf_temp).reshape(488,648, order = 'C')

im = plt.imshow(reshaped_before, cmap = 'gray' , vmin = 0 , vmax = 255)
im.set_array(reshaped_before)

print("temporal_mean = " + str(temporal_mean))
print("temporal_stdev = " + str(temporal_stdev))
print("FPN_stdev = " + str(FPN_stdev))
print("SNR = " + str(SNR))
