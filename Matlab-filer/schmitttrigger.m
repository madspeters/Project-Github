R1 = 32;
R2 = 32;
R3 = 2;
Vcc = 5;

R123 = (1/R1+1/R2+1/R3)^-1;

V1 = R123/R2*Vcc + R123/R3*Vcc;
V2 = R123/R2*Vcc - R123/R3*Vcc;
