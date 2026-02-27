% config_inertia.m
% -------------------------------------------------------------------------
% Configurazione input per il calcolo dell'inerzia.
% -------------------------------------------------------------------------

%% --- Dati razzo COMPLETO (con motore) [da OpenRocket/CAD] -----------------
L_rocket = 2.63;                         % [m] lunghezza totale razzo (origine O naso)
M_total  = 23.05;                        % [kg] massa totale razzo con motore
cg_total = 1.70;                         % [m] baricentro totale (asse Z dal nose tip)
I_total  = diag([10.84, 10.84, 0.066]);  % [kg*m^2] tensore inerzia totale @ cg_total (3x3)

%% --- Baricentro razzo SENZA motore -----------------
cg_noMotor    = 1.38;                    % [m] baricentro razzo senza motore (asse Z)


%% --- Motore (cilindro cavo) ----------------------------------------------
M_motor_dry = 3.456;                     % [kg] massa casing motore
M_motor_with_prop = 8.273;               % [kg] massa motore casing+prop
R_out       = 0.098;                     % [m] raggio esterno motore
R_in        = 0.096;                     % [m] raggio interno motore (cilindro cavo)
L_motor     = 0.702;                     % [m] lunghezza motore

