function [T, Y] = house_simulate(t_0, t_f, Y0)
    %% Parameters (here for now)
    area_aperture = 0; % Total aerture area;
    area_floor = 0; % Total house floor area
    dimension1_floor = 0; % One dimension for the floor/house; Other one is derived by dividing area
    thickness_floor = 0; % Thickness of thermal mass floor slab
    thickness_insulation = 0; % Thickness of wall/all? insulation
    height_house = 0; % Height of house

    % Calculate other parameters
    dimension2_floor = area_floor / dimension1_floor;
    area_wall = (2 * (dimension1_floor + dimension2_floor) * height_house) - ...
        area_aperture;

    %% Material constants
    % Wall is made entirely of insulation urethane foam
    % Floor/thermal mass is entirely made of concrete
    % Aperture is entirely glass

    % Thermal conductivity                  (W / m * K)
    % All values from https://www.engineeringtoolbox.com/thermal-conductivity-d_429.html
    k_floor = 1; % 1.0 - 1.8 for heavy concrete
    k_insulation = 0.03; % Research
    k_aperture = 0.05; % 1.05 for normal glass, 0.05 for insulating glass

    % Convection heat transfer coefficient  (W / m^2 * K)
    h_air = 10; % 

    % Specific heat                         (J / kg * K)
    c_air = 0.718; % https://www.ohio.edu/mechanical/thermo/property_tables/air/air_cp_cv.html
    c_floor = 0.96 / 1000; % kJ/(kg k) converted to Joules, engineeringtoolbox.com

    % Emissivity                            (unitless)
    e_floor = 0.85; % engineeringtoolbox.com

    % Densities                             (kg / m^3)
    density_air = 1.225; % kg / m^3
    density_floor = 2400; % kg / m^3

    % Calculate other material constants
    mass_air_internal = area_floor * height_house * density_air; % Calculate
    mass_floor = area_floor * thickness_floor * density_floor; % Calculate

    %% Environment constants
    % These might be parameters based on location/time?
    T_air_external = 291; % K
    T_ground = 285; % K

    I_insolation = 0; % Research

    % Calculate other environmental constants
    area_insolation = 1234; % Call area angle calculator

    %% Calculate thermal resistances
    % Thermal resistance from floor (thermal mass) to air inside
    R_floor_to_air = 1/(h_air * area_floor);

    % Thermal resistance from floor (thermal mass) to ground
    R_floor_to_ground = thickness_floor / (area_floor * k_floor);

    % Thermal resistance from air inside to air outside
    R_air_to_air = 1/(...
        1/(2 * (1/(h_air * area_wall)) + thickness_insulation/(area_wall * k_insulation)) + ... 
        1/(2 * (1/(h_air * area_aperture)) + thickness_insulation/(area_aperture * k_aperture)));

    %% ode45 wrapper
    v_timespan = [t_0 t_f];

    [T, Y] = ode45(@rate_func, v_timespan, Y0);

    %% Rate function
        function rates = rate_func(states)
            %% Data preprocessing
            U_air_internal = states(1);
            U_floor = states(2);

            T_air_internal = U_air_internal / (mass_air_internal * c_air);
            T_floor = U_floor / (mass_floor * c_floor);

            %% Calculate energy flows
            dUdt_floor_to_air = (T_air_internal - T_floor) / R_floor_to_air;

            dUdt_floor_to_ground = (T_ground - T_floor) / R_floor_to_ground;

            dUdt_air_to_air = (T_air_external - T_air_internal) / R_air_to_air;

            dUdt_insolation = e_floor * I_insolation * area_insolation;

            %% Calculate final total stock flows
            dUdt_floor = dUdt_insolation - dUdt_floor_to_air - dUdt_floor_to_ground;
            dUdt_air_internal = dUdt_floor_to_air - dUdt_air_to_air;

            rates = [dUdt_air_internal; dUdt_floor];
        end
end