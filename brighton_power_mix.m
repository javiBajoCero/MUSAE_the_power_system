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

investment_per_capita=2000;%€ updated from 1000 to 2000

total_investment=investment_per_capita*population;%€



%% solar ()
cost_per_solar_panel_550w=600;          % [€]
efficiency_inverter=0.96;               % [%]
efficiency_panel=0.197;                 % [%]
area_singlesolarpanel=2.8;              % [m^2]

Power_single_solar_panel_KW = 0.001*efficiency_panel*efficiency_inverter*area_singlesolarpanel.*solar.optimiced_moving_solar_ALLSKY_SFC_SW_DWN_Wh_m_2_;

number_of_solar_panels=0.8e6;
cost_of_solar=number_of_solar_panels*cost_per_solar_panel_550w;
total_solar_power=Power_single_solar_panel_KW*number_of_solar_panels;



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

number_of_wind_turbines=600;
cost_of_wind=number_of_wind_turbines*cost_per_wind_turbine_5Mw;
total_wind_power=Power_single_wind_turbine_KW*number_of_wind_turbines;

%% flow of the river constant hydro already existing
number_of_damms_per_km2= 1/10000;                           %damm/km^2
total_number_of_damms=floor(number_of_damms_per_km2*area);  %we round down , we cannot have a fraction of a damm
hydro_power_per_km2=20;                                     %KW/km^2
total_hydro_power=hydro_power_per_km2*area;                 %KW

hydro_already_existing_generation = demand;
hydro_already_existing_generation.kWhPerCapita = [];
column = total_hydro_power .* ones(height(hydro_already_existing_generation),1);
hydro_already_existing_generation.Kw = column;

%% nuclear already existing
nuclear_per_capita=0.15;                          %KW/capita
total_nuclear_power=nuclear_per_capita*population;%Kw

nuclear_already_existing_generation = demand;
nuclear_already_existing_generation.kWhPerCapita = [];
column = total_nuclear_power .* ones(height(nuclear_already_existing_generation),1);
nuclear_already_existing_generation.Kw = column;


%nuclear extra
cost_per_nuclear_SMR100Mw=500e6;                 %€
power_per_SMR_plant=100e3;                      %KW
number_of_SMR_plant=50;                            %plants

nuclear_small_generators = demand;
nuclear_small_generators.kWhPerCapita = [];
column = power_per_SMR_plant*number_of_SMR_plant .* ones(height(nuclear_small_generators),1);
nuclear_small_generators.Kw = column;
cost_nuclear=cost_per_nuclear_SMR100Mw*number_of_SMR_plant;



total_generation=nuclear_small_generators.Kw;%%total_solar_power+hydro_already_existing_generation.Kw+ nuclear_small_generators.Kw + nuclear_already_existing_generation.Kw;
total_cost=cost_of_solar+cost_nuclear+cost_of_wind;
available_money=total_investment-total_cost





subplot(3,1,1);
%demand
plot(demand.hour,demand.kWhPerCapita*population);
hold on;
cumulativeplot_kw=hydro_already_existing_generation.Kw;
plot(nuclear_already_existing_generation.hour,cumulativeplot_kw);

cumulativeplot_kw=cumulativeplot_kw+nuclear_already_existing_generation.Kw;
plot(nuclear_already_existing_generation.hour,cumulativeplot_kw);

cumulativeplot_kw=cumulativeplot_kw+nuclear_small_generators.Kw;
plot(nuclear_already_existing_generation.hour,cumulativeplot_kw);

cumulativeplot_kw=cumulativeplot_kw+total_solar_power;
plot(nuclear_already_existing_generation.hour,cumulativeplot_kw);

cumulativeplot_kw=cumulativeplot_kw+total_wind_power;
plot(nuclear_already_existing_generation.hour,cumulativeplot_kw);

xlabel('Hour of the year');
ylabel('Total KW');
title('Total Demand in KW in one year');%name the plot
xticks(0:24*7:8784); %grid per week
legend('demand','hydro river','preexisting nuclear','nuclear SMR reactors','solar panels','windturbines');
grid on;



subplot(3,1,2);
title('difference between demand and generation');%name the plot
plot(nuclear_already_existing_generation.hour,demand.kWhPerCapita*population-cumulativeplot_kw);
xlabel('Hour of the year');
ylabel('Total KW');
xticks(0:24*7:8784); %grid per week
grid on;

%pie chart with the cost
subplot(3,1,3);
pie([cost_of_solar cost_nuclear cost_of_wind available_money],{'solar','nuclear','wind','€'});

%average production of each source for each €
avg_power_solar=mean(total_solar_power);
how_many_KWperEuro_solar=avg_power_solar/cost_of_solar;%[kw/€]

avg_power_wind=mean(total_wind_power);
how_many_KWperEuro_wind=avg_power_wind/cost_of_wind;%[kw/€]

avg_power_nuclear=mean(nuclear_small_generators.Kw);
how_many_KWperEuro_nuclear=avg_power_nuclear/cost_nuclear;%[kw/€]