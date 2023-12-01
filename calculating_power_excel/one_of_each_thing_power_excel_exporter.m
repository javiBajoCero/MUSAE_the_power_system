clear all;
close all;

%% data is from 2020

demand = readtable('demand_data.dat');
solar  = readtable('solar_irradiation_and_angle_data.csv');
wind   = readtable('Wind speed 140m.csv');
wind_cp   = readtable('Cp turbine de gamesa 5Mw.xlsx');

latitude='050d81E';
longitude='000d13W';
population=14.691e6;%persons
area= 19161; %km^2
hours_in_the_year=size(demand);hours_in_the_year=hours_in_the_year(1);

investment_per_capita=2000;%€ updated from 1000 to 2000

total_investment=investment_per_capita*population;%€

writematrix(demand.kWhPerCapita.*population,'results/Power_total_demand_KW.xlsx','Sheet',1);

%% solar ()
cost_per_solar_panel_550w=600;          % [€]
efficiency_inverter=0.96;               % [%]
efficiency_panel=0.197;                 % [%]
area_singlesolarpanel=2.8;              % [m^2]

Power_single_solar_panel_KW = 0.001*efficiency_panel*efficiency_inverter*area_singlesolarpanel.*solar.optimiced_moving_solar_ALLSKY_SFC_SW_DWN_Wh_m_2_;

writematrix(Power_single_solar_panel_KW,'results/Power_single_solar_panel_KW.xlsx','Sheet',1);

%% wind (Gamesa G132-5.0MW)
% https://en.wind-turbine-models.com/turbines/768-gamesa-g132-5.0mw
cost_per_wind_turbine_5Mw=6.5e6;        %€
turbine_diameter=132;% [m]
turbine_area=pi*(turbine_diameter^2)/4;
%%roughness_length_Zo=0.0002; %[m] for roughness class 0, open sea
rho=1.20; % taken from our wind power assigment offshore turbines

Power_single_wind_turbine_KW=0.001*0.5*rho*turbine_area*wind.cutIn_outWindSpeedsApplied.^3;% [Kw]

% applying CP factor
for i=1:1:length(Power_single_wind_turbine_KW)
    wind_speed=int32(wind.cutIn_outWindSpeedsApplied(i));
    if(wind_speed>0)
        cp(i)=wind_cp.Cp__uno_(wind_speed);
    else
        cp(i)=0;
    end
end
cp=cp';
Power_single_wind_turbine_KW=Power_single_wind_turbine_KW.*cp;

writematrix(Power_single_wind_turbine_KW,'results/Power_single_wind_turbine_KW.xlsx','Sheet',1);

%% flow of the river constant hydro already existing
number_of_damms_per_km2= 1/10000;                           %damm/km^2
total_number_of_damms=floor(number_of_damms_per_km2*area);  %we round down , we cannot have a fraction of a damm
hydro_power_per_km2=20;                                     %KW/km^2
flow_of_the_river_power=hydro_power_per_km2*area;           %KW

Power_total_flow_of_the_river_KW= ones([hours_in_the_year,1]).*flow_of_the_river_power ;

writematrix(Power_total_flow_of_the_river_KW,'results/Power_total_flow_of_the_river_KW.xlsx','Sheet',1);

%% nuclear already existing (no cost)
nuclear_per_capita=0.15;                                        %KW/capita
already_existing_nuclear_power=nuclear_per_capita*population;   %Kw

Power_already_existing_nuclear_KW= ones([hours_in_the_year,1]).*already_existing_nuclear_power ;

writematrix(Power_already_existing_nuclear_KW,'results/Power_already_existing_nuclear_KW.xlsx','Sheet',1);

%% nuclear small SMR generators
cost_per_nuclear_SMR100Mw=500e6;                        %€
nuclear_power_per_SMR_plant=100e3;                      %KW

Power_single_SMR_nuclear_plant_KW= ones([hours_in_the_year,1]).*nuclear_power_per_SMR_plant ;

writematrix(Power_single_SMR_nuclear_plant_KW,'results/Power_single_SMR_nuclear_plant_KW.xlsx','Sheet',1);


