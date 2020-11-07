%%
% This is V2 of coffee_cool.m
%
function [time, T] = coffee_cooler()
    T_0            =   370; % K
    T_env_0        =   290; % K
    cup_d          =  0.08; % m, outer diamaeter
    cup_h          =  0.10; % m
    cup_thickness  = 0.007; % m
    cup_cond       =   1.5; % W / (m * K)
    coffee_c       =  4186; % J / (kg * K)
    coffee_density =  1000; % kg/m^3
    
    cup_r = cup_d / 2; % m
    
    coffee_heat_transfer =  10;
    air_heat_transfer    = 100;
    
    
    convection_area = pi * (cup_r ^ 2); % m^2
    
    cup_area = 2 * pi * cup_r * cup_h;
    
    coffee_volume = pi * (cup_r ^ 2) * cup_h;
    
    coffee_mass = coffee_volume * coffee_density;
    
    % U = m * c * dT
    % dU = dQ = -(conductivity * area / thickness) * dt;
    
    U_0 = temperatureToEnergy(T_0, coffee_mass, coffee_c);
    
    [time_sec, U] = ode45(@coffee_cooler_step, [0, 30 * 60], [U_0]);
    
    function dU = coffee_cooler_step(~, U)
        temp = energyToTemperature(U, coffee_mass, coffee_c) - T_env_0;
        
        dU_cond = ((cup_cond * cup_area) / cup_thickness) * temp;
        
        R_conv = (1 / (air_heat_transfer * convection_area)) + (1 / (coffee_heat_transfer * convection_area));
        
        dU_conv = (1 / R_conv) * temp;
        
        dU = -dU_cond - dU_conv;
    end

    T = energyToTemperature(U, coffee_mass, coffee_c);
    time = time_sec / 60;
end

