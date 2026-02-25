% config_inertia.m
% -------------------------------------------------------------------------
% Configurazione input per il calcolo dell'inerzia del razzo SENZA motore
% e dell'inerzia del motore (approssimato come cilindro cavo).
% -------------------------------------------------------------------------

%% --- Dati razzo COMPLETO (con motore) [da OpenRocket] -----------------
M_total  = 12.5;              % [kg] massa totale razzo con motore
cg_total = 1.45;              % [m] baricentro totale (asse Z dal nose tip)
I_total  = diag([2.8, 2.8, 0.12]); % [kg*m^2] tensore inerzia totale @ cg_total (3x3)


%% --- Baricentro (coerenti con il sistema di riferimento) -----------------
cg_noMotor    = 1.40;         % [m] baricentro razzo senza motore (asse Z)


%% --- Motore a secco -------------------------------------------------------
M_motor_dry = 1.8;            % [kg] massa motore a secco (senza propellente)

%% --- Geometria razzo e motore (cilindro cavo) ----------------------------
L_rocket = 1.8;               % [m] lunghezza totale razzo (origine O naso)
R_out  = 0.08;                % [m] raggio esterno motore 
L_motor = 0.35;               % [m] lunghezza motore
% R_in non specificato: assumiamo pareti sottili -> R_in = 0.0 (solido) o lasciarlo vuoto
% Se necessario, impostare R_in = 0.06; % [m] raggio interno

%% --- Propellente (grani cilindrici pieni, semplificati) ------------------
rho_grain = 1800;             % [kg/m^3] densita' propellente
n_grains  = 3;                % [-] numero di grani
r_grain   = 0.038;            % [m] raggio di ciascun grano (circa R_out)
h_grain   = 0.08;             % [m] altezza di ciascun grano
