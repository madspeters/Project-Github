 L_alu = 0.000;          % [m]
h_alu = 0.005;          % [m]
b_alu = 0.0005;         % [m]
p_alu = 2700;           % [kg/m^3]
V_alu = L_alu*h_alu*b_alu;          % [m^3]

m_alu = p_alu*V_alu     % [kg]

L_jern = 0.01;          % [m]
h_jern = 0.01;          % [m]
b_jern = 0.01;         % [m]
p_jern = 7860;           % [kg/m^3]
V_jern = L_jern*h_jern*b_jern;          % [m^3]

m_jern = p_jern*V_jern     % [kg]

m_samlet = m_alu + m_jern

