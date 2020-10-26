b_to_c_frac_sweep = 0.01:0.01:0.07;
Cs = zeros(size(b_to_c_frac_sweep, 2), iterations);
Bs = zeros(size(b_to_c_frac_sweep, 2), iterations);

sweep_i = 1;
for b_to_c_frac=b_to_c_frac_sweep
    bike_loop;
    Bs(sweep_i,:) = B;
    Cs(sweep_i,:) = C;
    sweep_i = sweep_i + 1;
end