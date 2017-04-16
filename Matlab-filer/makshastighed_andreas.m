% I det ?jeblik bilen v?lter, er der ikke noget v?gt p? det ene hjul. Det
% andet hjul bliver et omdrejningspunkt, hvor summen af alle momenter er
% lig nul ved v_maks.

% Tyngdeacceleration
g = 9.82;

% Radius af sving
r = 0.20;

% Massen af bilen
m = 0.2;

% H?jden fra banen til massemidtpunktet
h = 0.05;

% Bredden af bilen (hjul til hjul)
b = 0.08;

% Summen af momenter er lig nul.
% F_c er centrifugalkraften
% 0 = -F_c*h + m*g*(b/2)
% 0 = -((m*v^2)/r)*h+(m*g*b)/2
% m g?r ud med hinanden
% (v^2*h)/r = (g*b)/2
% v^2 = (g*b*r)/(2*h)
v = sqrt((g*b*r)/(2*h))