% M�linger og konstanter
L = 40;         % L�ngde af aluminiumsstang [mm]
h = 10;         % H�jde af aluminiumsstang [mm]
b = 0.5;        % Bredde af aluminiumsstang [mm]
m_sg = 0.020;    % Masse af strain gauge + lod [kg]

E = 210000;      % Elasticitetskoefficient for fjederst�l [N/mm^2]
GF = 2.15;         % Gainfactor (afl�ses i datablad)

% Bestemt i matlab filen carmeasurements.m:
a_cen_lille = 18.9983;      % [m/s^2]
a_cen_stor = 14.5104;        % [m/s^2]

% Bestemmmer kraften, som alu stang p�virkes af(inder sving)
F = a_cen_lille*m_sg;       % [N]

% Bestemmer modstandsmoment og b�jningsmoment
Wx = b^2*h/6;   % Modstandsmoment [mm^3] % Bem�rk at h�jde og bredde byttes rundt p� grund af retningen af kraften
Mb = F*L;       % B�jningsmoment [Nmm]b

% Bestemmer sp�nding
Sigma = Mb/Wx;  % Sp�nding [N/mm^2]

% Bestemmer relativ forl�ngelse epsilon 
Epsilon = Sigma / E    % Relativ forl�ngelse [enhedsl�s]

% Den relative forl�ngelse kan �ges markant ved at �ndre h�jden h af
% metalstangen. 

% Nu kan forl�ngelsen af alu stangen bestemmes:
delta_L = Epsilon * L  % Forl�ngelse af alu stang [mm]

% L�ngde af strain gauge afl�ses fra datablad
L_sg = 6;              % L�ngde af strain gauge [mm]

% Bestemmer forl�ngelse af strain gauge
delta_L_sg = Epsilon * L_sg % Forl�ngelse af strain gauge [mm]


% Bestemmer �ndring i modstand
DeltaR = GF * Epsilon * 120