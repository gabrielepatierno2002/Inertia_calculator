% config_inertia.m
% -------------------------------------------------------------------------
% File di configurazione per script_inertia.m
%
% Inserisci qui i dati del tuo razzo e del motore.
% Tutti i vettori CG sono nella forma [x; y; z] (colonna, in metri).
% Tutti i tensori di inerzia sono matrici 3x3 (in kg*m^2).
% -------------------------------------------------------------------------

%% --- Razzo totale CON motore (dati da OpenRocket o misura) ---------------
% Massa totale razzo + motore [kg]
M_total  = 41;

% Baricentro razzo + motore [m]
cg_total = [0; 0; 0.1];

% Tensore di inerzia totale riferito a cg_total [kg*m^2]
I_total  = diag([25, 25, 0.6]);

%% --- Razzo SENZA motore (CG da OpenRocket o misura) ----------------------
% Baricentro del razzo senza motore [m]
cg_noMotor = [0; 0; 0.15];

%% --- Motore completo (casing + propellente) ------------------------------
% Massa motore completo [kg]
M_motor   = 20;

% Baricentro motore completo [m]
cg_motor  = [0; 0; 0.0];

% Tensore di inerzia del motore completo riferito a cg_motor [kg*m^2]
I_motor_c = diag([0.8, 0.8, 0.05]);

%% --- Solo propellente ----------------------------------------------------
% Massa propellente [kg]
M_propellant  = 15;

% Baricentro propellente [m]
cg_propellant = [0; 0; 0.0];

% Tensore di inerzia del propellente riferito a cg_propellant [kg*m^2]
I_propellant_c = diag([0.5, 0.5, 0.03]);
