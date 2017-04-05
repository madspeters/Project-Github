
%{
Beregning af gearing 

Dette program omregner motoromdrejninger til hjulomdrejninger ved at
bestemme gearingen.

%}

gear1 = 10;       % Antal af tandhjul
gear2 = 14;       % Antal af tandhjul
gear3 = 9;        % Antal af tandhjul
gear4 = 27;       % Antal af tandhjul

D_hjul = 0.028;      % Diameter af hjul i meter
O_hjul = D_hjul*pi;  % Omkreds af hjul

ratio1 = gear1/gear2;
ratio2 = gear3/gear4;

ratio = ratio1*ratio2

