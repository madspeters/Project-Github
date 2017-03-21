% Størrelser i meter
d = 0.0261;             % Hjuldiameter (m)
h = 0.0578;             % Højde af bil (Bagenden, når affjedringen er i bund)
L = 0.148;              % Længde af bil (m)
b = 0.061;              % Bredde af bil (m)

m = 0.1168;             % Vægt af bil (kg)

d_lille = 0.506;          % diameter af lille (m)
r_lille = d_lille/2;       % radius af lille (m)

d_stor = 0.6625;            % stor diameter (m)
r_stor = d_stor/2;         % stor radius (m)

g = 9.82;                  % tyngdeacceleration (m/s^2)
theta = deg2rad(85);       % vinkel(rad), hvor bilen falder ned
F_down = 0.103*g;            % downforce calculator: http://www.scalextric-car.co.uk/Parts/Magnetraction/Magnet_Downforce_Calculator.htm
F_t = m*g;                 % Tyngdekraft
F_ty = F_t * cos(theta);   % Tyngdekraft y-komposant
F_tx = F_t * sin(theta);   % Tyngdekraft x-komposant

syms my

F_n = F_ty + F_down;       % Normalkraft
F_gnid = my * F_n;         % Gnidningskraft

my = solve(F_gnid==F_tx,my); % Gnidningskoefficient

% Bestemmer maks hastighed i lille og stort sving
syms v
F_cenlille = (m*v^2)/r_lille;    % Centripetalkraft lille radius
F_censtor = (m*v^2)/r_stor;    % Centripetalkraft lille radius
F_gnid = m*g*my;


v_maxlille = solve(F_cenlille == F_gnid,v);
v_maxstor = solve(F_censtor == F_gnid,v);

kphlille = double(3.6*v_maxlille(2));       % Positiv max-hastighed
kphstor = double(3.6*v_maxstor(2));         % Positiv max-hastighed

% Bestemmer acceleration i inder og yder sving til beregning af strain
% gauge. Ved denne beregninger antager vi at vi ikke kan se forskel på
% inder og ydersving, og at max hastigheden i indersvinget også benyttes
% til at bestmeme accelerationen i ydersvinget

a_cen_lille = double(v_maxlille(2)^2/r_lille)      % Max acceleration i indersving
a_cen_stor = double(v_maxlille(2)^2/r_stor)        % Acceleration med max hastighed i indersving





