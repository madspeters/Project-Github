% Målinger og konstanter
L = 40;         % Længde af aluminiumsstang [mm]
h = 5;         % Højde af aluminiumsstang [mm]
b = 0.5;        % Bredde af aluminiumsstang [mm]
m_sg = 0.020;    % Masse af strain gauge + lod [kg]

E = 68000;      % Elasticitetskoefficient for aluminium [N/mm^2]
GF = 2.15;         % Gainfactor (aflæses i datablad)

% Bestemt i matlab filen carmeasurements.m:
a_cen_lille = 10.0955;      % [m/s^2]
a_cen_stor = 7.7107;        % [m/s^2]

% Bestemmmer kraften, som alu stang påvirkes af(inder sving)
F = a_cen_lille*m_sg;       % [N]

% Bestemmer modstandsmoment og bøjningsmoment
Wx = b*h^2/6;   % Modstandsmoment [mm^3]
Mb = F*L;       % Bøjningsmoment [N/mm]

% Bestemmer spænding
Sigma = Mb/Wx;  % Spænding [N/mm^2]

% Bestemmer relativ forlængelse epsilon 
Epsilon = Sigma / E    % Relativ forlængelse [enhedsløs]

% Den relative forlængelse kan øges markant ved at ændre højden h af
% metalstangen. 

% Nu kan forlængelsen af alu stangen bestemmes:
delta_L = Epsilon * L  % Forlængelse af alu stang [mm]

% Længde af strain gauge aflæses fra datablad
L_sg = 6;              % Længde af strain gauge [mm]

% Bestemmer forlængelse af strain gauge
delta_L_sg = Epsilon * L_sg % Forlængelse af strain gauge [mm]

