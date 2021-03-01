function [timestamps, positions, velocities] = simulate_launch(timespan, initial_values)
    % Because MATLAB is very very stupid, we need to define these variables
    % in code ````before `load` sets them, otherwise it doesn't work.
    radius_earth = NaN;
    mass_earth = NaN;
    load("constants.mat", "radius_earth", "mass_earth");
    
    [timestamps, D] = ode45(@rate_func, timespan, initial_values, odeset('Events', @event_func, "MaxStep", 10^3));
    positions = D(:, 1:2);
    velocities = D(:, 3:4);

    function [value, is_terminal, direction] = event_func(~, vals)
        [x, y, ~, ~] = matsplit(vals);
        
        [~, radius] = cart2pol(x, y);
        
        value = radius - radius_earth;
         
        direction = 0;
        is_terminal = 1;
    end


    function res = rate_func(~, vals)
        grav_constant = 6.67 * 10^(-11);

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
end



