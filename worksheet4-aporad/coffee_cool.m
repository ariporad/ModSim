function [time, T] = coffee_cool()
    T_0            =   370; % K
    T_env_0        =   290; % K
    cup_d          =  0.08; % m, outer diamaeter
    cup_h          =  0.10; % m
    cup_thickness  = 0.007; % m
    cup_cond       =   1.5; % W / (m * K)
    coffee_c       =  4186; % J / (kg * K)
    coffee_density =  1000; % kg/m^3
    
    cup_r = cup_d / 2;
    cup_area = 2 * pi * cup_r * cup_h;
    
    coffee_volume = pi * (cup_r ^ 2) * cup_h;
    
    coffee_mass = coffee_volume * coffee_density;
    
    % U = m * c * dT
    % dU = dQ = -(conductivity * area / thickness) * dt;
    
    U_0 = temperatureToEnergy(T_0 - T_env_0, coffee_mass, coffee_c);
    
    [time_sec, U] = ode45(@coffee_cool_step, [0, 30 * 60], [U_0]);
    
    function dU = coffee_cool_step(~, U)
        dU = -((cup_cond * cup_area) / cup_thickness) * energyToTemperature(U, coffee_mass, coffee_c);
    end

    T = energyToTemperature(U, coffee_mass, coffee_c) + T_env_0;
    time = time_sec / 60;
end

