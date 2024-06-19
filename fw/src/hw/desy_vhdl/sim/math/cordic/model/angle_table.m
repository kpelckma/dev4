
% Matlab/Octave code to generate angle and K tables

data_size = 64;
fraction = data_size -1;

for i = 1:data_size
  v_iteration                  = real(i-1);
  v_angle(i)       = atan(2**(-v_iteration));
  v_angle_table(i) = int64(v_angle(i) * 2^fraction / pi);
  disp(sprintf("%016x %d",v_angle_table(i),v_angle(i)*180/pi))
end

% disp('Angle table in hex:')
% disp(dec2hex(v_angle_table))

for k=1:64
  K(1) = sqrt(2);
  for i=2:k
    gain = sqrt(1+2^(-2*(i-1)));
    K(k) = K(k-1)*gain;
  end
  K1(k) = 1/K(k);
  %
end

Kfixed = int64(K1 * 2^(63));

% disp('K factors in hex for various iterations:')
% disp(dec2hex(Kfixed))

