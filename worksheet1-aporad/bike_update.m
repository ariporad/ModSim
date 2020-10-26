b_to_c = round(b * 0.05);
c_to_b = round(c * 0.03);
b = b - b_to_c + c_to_b;
c = c - c_to_b + b_to_c;