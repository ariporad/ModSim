function [timestamps, positions, velocities] = simulate_launch(timespan, initial_values)
    [timestamps, D] = ode45(@rate_func, timespan, initial_values, odeset('Events', @event_func));
    positions = D(:, 1:2);
    velocities = D(:, 3:4);
end

function [value, is_terminal, direction] = event_func(~, vals)
    [x, y, ~, ~] = matsplit(vals);
    
    value = sqrt(x^2 + y^2) - 6371071;
%     value = max(abs([x, y])) - 50;
    direction = 0;
    is_terminal = 1;
end


function res = rate_func(~, vals)
    grav_constant = 6.67 * 10^(-11);
    mass_earth = 5.97 * 10^24; % kg

    [x, y, vx, vy] = matsplit(vals);
    
    dxdt = vx;
    dydt = vy;
    
    r_vector = [x y];
    r_distance = norm(r_vector);
    
    direction = r_vector / r_distance;
    
    a_gravity = -1 * grav_constant * mass_earth / (r_distance ^ 2);
    
    a_vector = a_gravity * direction;
    
    res = [dxdt; dydt; a_vector'];
end
