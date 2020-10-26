b_to_c = round(b * b_to_c_frac);
c_to_b = round(c * c_to_b_frac);
b = b - b_to_c + c_to_b;
c = c - c_to_b + b_to_c;