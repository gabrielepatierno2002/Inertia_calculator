% config_inertia.m
% -------------------------------------------------------------------------
% Configurazione input per il calcolo dell'inerzia del razzo SENZA motore
% e dell'inerzia del motore (approssimato come cilindro cavo).
% -------------------------------------------------------------------------

%% --- Dati razzo COMPLETO (con motore) [da OpenRocket/CAD] -----------------
M_total  = 0;                 % [kg] massa totale razzo con motore
cg_total = 0;                 % [m]  baricentro totale (asse Z)
I_total  = eye(3);            % [kg*m^2] tensore inerzia totale @ cg_total (3x3)

%% --- Baricentri (coerenti con il sistema di riferimento) -----------------
cg_noMotor    = 0;            % [m]  baricentro razzo senza motore (asse Z)
% cg_motor e cg_motor_dry NON sono input: si assumono entrambi = L_motor/2

%% --- Motore a secco -------------------------------------------------------
M_motor_dry = 0;              % [kg] massa motore a secco (senza propellente)

%% --- Geometria esterna motore (cilindro cavo) ----------------------------
R_out  = 0;                   % [m] raggio esterno motore
L_motor = 0;                  % [m] altezza/lunghezza motore
% R_in = 0;                   % [m] raggio interno (opzionale). Se non impostato -> R_in = r_grain

%% --- Propellente (grani cilindrici pieni, semplificati) ------------------
rho_grain = 0;                % [kg/m^3] densita' propellente
n_grains  = 0;                % [-] numero di grani
r_grain   = 0;                % [m] raggio di ciascun grano
h_grain   = 0;                % [m] altezza di ciascun grano
