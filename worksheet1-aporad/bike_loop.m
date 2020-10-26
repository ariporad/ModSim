iterations = 30; % days
b = 100;
c = 100;
B = zeros(1, iterations);
C = zeros(1, iterations);
for i=1:iterations
    bike_update2;
    B(i) = b;
    C(i) = c;
end