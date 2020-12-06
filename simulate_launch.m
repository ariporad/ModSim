function [timestamps, positions, velocities] = simulate_launch(timespan, initial_values)
    [timestamps, D] = ode45(@rate_func, timespan, initial_values, odeset('Events', @event_func));
    positions = D(:, 1:2);
    velocities = D(:, 3:4);
end

function [value, is_terminal, direction] = event_func(~, vals)
    [x, y, ~, ~] = matsplit(vals);
    
    value = max(abs([x, y])) - 50;
    direction = -1;
    is_terminal = 1;
end

function res = rate_func(~, vals)
    [x, y, vx, vy] = matsplit(vals);
    
    dxdt = vx;
    dydt = vy;
    
    v_vector = [x y];
    
    direction = v_vector / norm(v_vector);
    
    a_vector = -9.8 * direction; % TODO: -9.8 needs to change
    
    res = [dxdt; dydt; a_vector'];
end
