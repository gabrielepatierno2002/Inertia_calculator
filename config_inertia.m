% config_inertia.m
% -------------------------------------------------------------------------
% File di configurazione per script_inertia.m
% Inserire qui tutti i dati di input.
% -------------------------------------------------------------------------

% --- Razzo completo CON motore (da OpenRocket) ---
M_total  = ;          % [kg]  massa totale del razzo con motore
cg_total = [; ; ];    % [m]   baricentro del razzo con motore (vettore colonna 3x1)
I_total  = [...       % [kg*m^2] tensore di inerzia al CG totale (matrice 3x3)
             , , ; ...
             , , ; ...
             , , ];

% --- Motore (massa totale e inerzia) ---
M_motor   = ;         % [kg]  massa totale del motore (propellente + casing)
cg_motor  = [; ; ];   % [m]   baricentro del motore (vettore colonna 3x1)
I_motor_c = [...      % [kg*m^2] tensore di inerzia del motore al proprio CG (matrice 3x3)
              , , ; ...
              , , ; ...
              , , ];

% --- CG del razzo senza motore ---
cg_noMotor = [; ; ];  % [m]   baricentro del razzo senza motore (vettore colonna 3x1)

% --- Massa secca e geometria del motore (solo casing, cilindro cavo) ---
M_motor_dry  = ;      % [kg]  massa secca del motore (solo casing)
cg_motor_dry = [; ; ];% [m]   baricentro del motore secco (vettore colonna 3x1)
R_out        = ;      % [m]   raggio esterno del casing del motore
R_in         = ;      % [m]   raggio interno del casing del motore
L_motor      = ;      % [m]   lunghezza del casing del motore
