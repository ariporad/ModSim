function [T, D, debug] = model()
    g = 9.8; % m/s/s

    m_rod = 1; % kg
    m_disk = 1; % kg

    r_ring = 0.1;
    % NB: The disk is zero-thickness

    z_disk_start = 0.5;
    h_rod = 1;

    k_elastic = 50; % N/m

    F_push = -1; % N

    debug = zeros(10000, 5);
    debug_idx = 1;
    
    [T, D] = ode45(@phase23, [0, 15], [0, z_disk_start, 0, 0]);

    % This would be the model for phase 1, but I realized that it didn't
    % actually make much sense to model it so this code is unused
    function [dzdt_rod, dzdt_disk, dvdt_rod, dvdt_disk] = phase1(~, data)
        [~, ~, v_rod, v_disk] = matsplit(data);

        % It has been decided that 100% of the downwards force on the ring goes is absobed by the elastic.
        % This results in the elastic stretching, which (combined with gravity) causes the ring to move
        % downward. However, the movement of the ring and the unbalanced forces causing that to happen
        % are outside of the scope of this model.

        %% Disk
        F_grav_disk = m_disk * g;
        F_push_disk = F_push;
        % F_idk represents the upwards force excerted by the rubber tubing on
        % the ring when energy is being stored. It's called F_idk because I'm
        % not really sure what that force ought to be called (is it the normal
        % force? All of the energy goes into the tubing).
        % To be clear, this force is consistently called `F_idk` throughout the
        % model. It's the name of a specific force, not a generic catch-all.
        F_idk_disk = -1 * (F_grav_disk + F_push_disk);
        F_net_disk = sum([F_grav_disk, F_push_disk, F_idk_disk]);

        dzdt_disk = v_disk;
        dvdt_disk = F_net_disk / m_disk;

        %% Rod
        F_idk_rod = -F_idk_disk;
        F_grav_rod = m_rod * g;
        F_norm_rod = -1 * (F_idk_rod + F_grav_rod);
        F_net_rod = sum([F_idk_rod, F_grav_rod, F_norm_rod]);

        dzdt_rod = v_rod;
        dvdt_rod = F_net_rod / m_rod;
    end

    % This would be a standalone phase2 rate function, but I successfully
    % integrated it into phase23.
    function [dzdt_rod, dzdt_disk, dvdt_rod, dvdt_disk] = phase2(~, data)
        [z_rod, z_disk, v_rod, v_disk] = matsplit(data);

        F_grav_disk = m_disk * g;
        F_elas_disk = k_elastic * abs(z_rod - z_disk);
        F_net_disk = sum([F_grav_disk, F_elas_disk]);

        dzdt_disk = v_disk;
        dvdt_disk = F_net_disk / m_disk;

        F_grav_rod = m_rod * g;
        F_norm_rod = -F_grav_rod;
        F_net_rod = sum([F_grav_rod, F_norm_rod]);

        dzdt_rod = v_rod;
        dvdt_rod = F_net_rod / m_rod;
    end

    function rates = phase23(t, data)
        [z_rod, z_disk, v_rod, v_disk] = matsplit(data);

        %% Calculate Spring Force
        % Thank you to the solutions for help figuring this out (especially
        % the diagonals).
        d_elastic = sqrt(r_ring^2 + (z_disk-(z_rod + h_rod))^2);
        F_elastic = k_elastic * d_elastic * ((z_disk - (z_rod + h_rod)) / d_elastic);
        
        dzdt_disk = v_disk;
        dvdt_disk = (-F_elastic / m_disk) - g;

        dzdt_rod = v_rod;
        dvdt_rod = (F_elastic / m_rod) - g;
        
        %% Phase 2
        % This is kind of hacky, but we just decree that it's impossible
        % for the rod to go into the table
        if z_rod <= 0 && dvdt_rod < 0
            dvdt_rod = 0;
        end
        
        debug(debug_idx, :) = [t, d_elastic, F_elastic, dvdt_rod, dvdt_disk];
        debug_idx = debug_idx + 1;
        
        rates = [dzdt_rod; dzdt_disk; dvdt_rod; dvdt_disk];
    end
    
    debug = debug(1:(debug_idx - 1), :);
end