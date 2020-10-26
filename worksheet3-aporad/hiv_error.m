function res = hiv_error(~, args)
    gamma = 1.36;
    mu = 0.0036;
    tau = 0.2;
    beta = 0.00027; % per virion
    rho = 0.1;
    alpha = 0.036;
    sigma = 2;
    delta = 0.33;
    pi = 100;
    
    V = args(1);
    E = args(2);
    L = args(3);
    R = args(4);

    dR = (gamma * tau) - (mu * R) - (beta * R * V);
    dL = (rho * beta * R * V) - (mu * L) - (alpha * L);
    dE = ((1 - rho) * beta * R * V) + (alpha * L) - (delta * E);
    dV = (pi * E) - (sigma * V);
    
    res = [dV; dE; dL; dR];
end
