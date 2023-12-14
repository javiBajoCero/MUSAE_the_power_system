import pandas as pd
import numpy as np
import matplotlib.pyplot as plt


#from excels to numpy arrays

Power_total_demand_KW             = pd.read_excel('Power_total_demand_KW.xlsx').to_numpy()

Power_already_existing_nuclear_KW = pd.read_excel('Power_already_existing_nuclear_KW.xlsx').to_numpy()
Power_total_flow_of_the_river_KW  = pd.read_excel('Power_total_flow_of_the_river_KW.xlsx').to_numpy()

Power_single_solar_panel_KW       = pd.read_excel('Power_single_solar_panel_KW.xlsx').to_numpy()
Power_single_wind_turbine_KW      = pd.read_excel('Power_single_wind_turbine_KW.xlsx').to_numpy()
Power_single_SMR_nuclear_plant_KW = pd.read_excel('Power_single_SMR_nuclear_plant_KW.xlsx').to_numpy()

#debugging
print (Power_already_existing_nuclear_KW.size)
print (Power_total_flow_of_the_river_KW.size)
print (Power_single_solar_panel_KW.size)
print (Power_single_wind_turbine_KW.size)
print (Power_single_SMR_nuclear_plant_KW.size)

figure=plt.figure()

figure.add_subplot(10,1,1).title.set_text('Power_already_existing_nuclear_KW')
plt.plot(Power_already_existing_nuclear_KW)

figure.add_subplot(10,1,3).title.set_text('Power_total_flow_of_the_river_KW')
plt.plot(Power_total_flow_of_the_river_KW) 

figure.add_subplot(10,1,5).title.set_text('Power_single_solar_panel_KW')
plt.plot(Power_single_solar_panel_KW) 

figure.add_subplot(10,1,7).title.set_text('Power_single_wind_turbine_KW')
plt.plot(Power_single_wind_turbine_KW) 

figure.add_subplot(10,1,9).title.set_text('Power_single_SMR_nuclear_plant_KW')
plt.plot(Power_single_SMR_nuclear_plant_KW) 
