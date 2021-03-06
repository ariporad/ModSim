function [T, Y, debug] = house_simulate(timespan, max_step, height_aperture, width_aperture, area_floor, thickness_floor, thickness_insulation)
    % The `debug` matrix has one row per call to rate_func, with the
    % columns as specified on Line 107. We initialize it here to avoid
    % performance issues. We'll re-allocate it in rate_fun if we run out
    % of space, or we'll trim it at the end.
    debug_idx = 1;
    debug_max = timespan(2) - timespan(1);
    debug = NaN(debug_max, 7);
    
    %% Location Parameters
    % These are currently set to Olin College
    latitude = 42.2930; % deg
    longitude = -71.2638; % deg
    utc_offset = -5; % hours, EST

    % Calculate other parameters
    width_floor = width_aperture; % stupid now, but possibly more complicated later on
    depth_floor = area_floor / width_floor;
    area_aperture = height_aperture * width_aperture;
    height_house = height_aperture; % stupid now, but possible more complicated later on
    area_wall = (2 * (width_floor + depth_floor) * height_house) - area_aperture;

    %% Material constants
    % Wall is made entirely of insulation urethane foam
    % Floor/thermal mass is entirely made of concrete
    % Aperture is entirely glass

    % Thermal conductivity                  (W / m * K)
    % All values from https://www.engineeringtoolbox.com/thermal-conductivity-d_429.html
    k_insulation = 0.5; % 0.03; % Research
    k_aperture = 0.05; % 1.05 for normal glass, 0.05 for insulating glass

    % Convection heat transfer coefficient  (W / m^2 * K)
    h_air = 10; % 

    % Specific heat                         (J / kg * K)
    c_air = 718; % https://www.ohio.edu/mechanical/thermo/property_tables/air/air_cp_cv.html
    c_floor = 960; % J/(kg * K) engineeringtoolbox.com

    % Emissivity                            (unitless)
    e_floor = 0.85; % engineeringtoolbox.com

    % Densities                             (kg / m^3)
    density_air = 1.225; % kg / m^3
    density_floor = 2400; % kg / m^3

    % Calculate other material constants
    mass_air_internal = area_floor * height_house * density_air; % Calculate
    mass_floor = area_floor * thickness_floor * density_floor; % Calculate

    %% Environment constants
    % T_air_external is a function of time, so calculated in rate_func
    %T_ground = 285; % K
    [T_air_external_0, T_ground_0] = calculate_temp(timespan(1));

    % pveducation.org
    I_insolation = 500; % w / m^2

    %% Calculate thermal resistances
    % Thermal resistance from floor (thermal mass) to air inside
    R_floor_to_air = 1/(h_air * area_floor);

    % Thermal resistance from floor (thermal mass) to ground
    % Here we assume the insulation between floor and the ground is the
    % same thickness as the wall insulation
    R_floor_to_ground = thickness_insulation / (area_floor * k_insulation);
    
    % Thermal resistance from air inside to air outside
    R_air_to_air = 1/(...
        1/(2 * (1/(h_air * (area_wall + area_floor))) + thickness_insulation/((area_wall + area_floor) * k_insulation)) + ... 
        1/(2 * (1/(h_air * area_aperture)) + thickness_insulation/(area_aperture * k_aperture)));
    
    %% Initial State Values
    % Temperature of the internal air starts at the temperature of the external air (which is absurd)
    U_air_internal_0 = T_air_external_0 * mass_air_internal * c_air;
    % Temperature of the floor starts at the temperature of the ground (which is also absurd)
    U_floor_0 = T_ground_0 * mass_floor * c_floor;
    
    %% ode45
    [T, Y_U] = ode45(@rate_func, timespan, [U_air_internal_0, U_floor_0], odeset("MaxStep", max_step));

    %% Rate function
    function rates = rate_func(time, states)
        %% Calculate time-specific environmental constants
        solar_elev = calculate_solar_elev(time, latitude, longitude, utc_offset);
        [T_air_external, T_ground] = calculate_temp(time);
        
        % calculate the projection of the sun through the aperture
        unangled_area_insolation = width_floor * depth_floor;
        area_insolation = max(0, cosd(solar_elev) * sind(solar_elev) * unangled_area_insolation);

        %% Data preprocessing
        U_air_internal = states(1);
        U_floor = states(2);

        T_air_internal = U_air_internal / (mass_air_internal * c_air);
        T_floor = U_floor / (mass_floor * c_floor);

        %% Calculate energy flows
        dUdt_floor_to_air = -(T_air_internal - T_floor) / R_floor_to_air;

        dUdt_floor_to_ground = -(T_ground - T_floor) / R_floor_to_ground;

        dUdt_air_to_air = -(T_air_external - T_air_internal) / R_air_to_air;

        dUdt_insolation = e_floor * I_insolation * area_insolation;
        
        if debug_idx > debug_max
            fprintf("WARNING: re-allocating debug from %1.0f items to %1.0f items.\n", debug_max, debug_max * 2);
            debug = [debug; NaN(7, debug_max)];
            debug_max = debug_max * 2;
        end

        debug(debug_idx, :) = [time, dUdt_floor_to_air, dUdt_floor_to_ground, dUdt_air_to_air, dUdt_insolation, T_air_external, T_ground];
        debug_idx = debug_idx + 1;
        
        %% Calculate final total stock flows
        dUdt_floor = dUdt_insolation - dUdt_floor_to_air - dUdt_floor_to_ground;
        dUdt_air_internal = dUdt_floor_to_air - dUdt_air_to_air;

        rates = [dUdt_air_internal; dUdt_floor];
    end

    all_air_U = Y_U(:, 1);
    all_floor_U = Y_U(:, 2);
    
    Y = [all_air_U / (mass_air_internal * c_air), all_floor_U / (mass_floor * c_floor)];
    
    debug = debug(1:(debug_idx - 1), :); % drop unused rows
end