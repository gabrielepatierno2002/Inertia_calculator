% script_inertia.m
% -------------------------------------------------------------------------
% Calcola massa, baricentro e inerzia del razzo SENZA motore
% partendo da:
%   - (M_total, cg_total, I_total) del razzo completo CON motore
%     con I_total riferito a cg_total (OpenRocket)
%   - Dati del motore e del propellente (semplificati)
% -------------------------------------------------------------------------

run('config_inertia.m');

%% --- Validazione input ---------------------------------------------------
requiredVars = {'I_total','M_total','cg_total','cg_motor', ...
                'cg_noMotor','M_motor_dry','cg_motor_dry','R_out','L_motor', ...
                'rho_grain','n_grains','r_grain','h_grain'};
for k = 1:numel(requiredVars)
    assert(exist(requiredVars{k}, 'var')==1, 'Variabile mancante: %s', requiredVars{k});
end

if isempty(cg_total), cg_total = [0;0;0]; end
if isempty(cg_motor), cg_motor = [0;0;0]; end

assert(isequal(size(I_total), [3,3]), 'I_total deve essere 3x3');
assert(isscalar(M_total) && isnumeric(M_total) && M_total > 0, 'M_total deve essere uno scalare > 0');

cg_total = cg_total(:);
cg_motor = cg_motor(:);
assert(numel(cg_total)==3 && numel(cg_motor)==3, 'cg_total e cg_motor devono avere 3 elementi');

if isempty(cg_noMotor),   cg_noMotor   = [0;0;0]; end
if isempty(cg_motor_dry), cg_motor_dry = [0;0;0]; end
cg_noMotor   = cg_noMotor(:);
cg_motor_dry = cg_motor_dry(:);
assert(numel(cg_noMotor)==3 && numel(cg_motor_dry)==3, ...
    'cg_noMotor e cg_motor_dry devono avere 3 elementi');
assert(isscalar(M_motor_dry) && isnumeric(M_motor_dry) && M_motor_dry > 0, ...
    'M_motor_dry deve essere uno scalare > 0');
assert(isscalar(R_out) && R_out > 0, 'R_out deve essere > 0');
assert(isscalar(L_motor) && L_motor > 0, 'L_motor deve essere > 0');
assert(isscalar(rho_grain) && rho_grain > 0, 'rho_grain deve essere > 0');
assert(isscalar(n_grains) && n_grains > 0, 'n_grains deve essere > 0');
assert(isscalar(r_grain) && r_grain > 0, 'r_grain deve essere > 0');
assert(isscalar(h_grain) && h_grain > 0, 'h_grain deve essere > 0');

% R_in opzionale: se non definito, uso il raggio del grano
if ~exist('R_in', 'var') || isempty(R_in)
    R_in = r_grain;
end
assert(isscalar(R_in) && R_in >= 0, 'R_in deve essere >= 0');
assert(R_out > R_in, 'R_out deve essere > R_in');

% Forzo simmetria numerica (utile se arriva da CAD con piccoli errori)
I_total = 0.5*(I_total + I_total.');

%% --- Propellente (massa) -------------------------------------------------
V_grain = pi * r_grain^2 * h_grain; % volume grano (cilindro pieno)
M_prop = rho_grain * n_grains * V_grain;

%% --- Massa motore completo ----------------------------------------------
M_motor = M_motor_dry + M_prop;

%% --- Inerzia motore (cilindro cavo, Z = asse) ----------------------------
I_ax_full = 0.5 * M_motor * (R_out^2 + R_in^2);
I_tr_full = (1/12) * M_motor * (3*(R_out^2 + R_in^2) + L_motor^2);
I_motor_c = diag([I_tr_full, I_tr_full, I_ax_full]);

%% --- Inerzia motore a secco (stessa geometria) ---------------------------
I_ax_dry = 0.5  * M_motor_dry * (R_out^2 + R_in^2);
I_tr_dry = (1/12) * M_motor_dry * (3*(R_out^2 + R_in^2) + L_motor^2);
I_motor_dry_c = diag([I_tr_dry, I_tr_dry, I_ax_dry]);

%% --- Steiner (assi paralleli) -------------------------------------------
par_axis = @(m, d) m * (dot(d,d) * eye(3) - (d * d.'));

%% --- Calcolo massa e CG del razzo senza motore --------------------------
m_rocket_noMotor = M_total - M_motor;
if m_rocket_noMotor <= 0
    error('M_motor (%.6g) >= M_total (%.6g): impossibile calcolare il razzo senza motore.', M_motor, M_total);
end

if M_motor_dry >= M_motor
    warning('M_motor_dry (%.6g) >= M_motor (%.6g): la massa a secco dovrebbe essere < massa totale.', M_motor_dry, M_motor);
end

cg_rocket_noMotor = cg_noMotor;

%% --- Sottrazione inerziale ----------------------------------------------
% 1) Porta l'inerzia del motore dal suo CG al CG totale
d_motor = cg_motor - cg_total;
I_motor_aboutCGtotal = I_motor_c + par_axis(M_motor, d_motor);

% 2) Sottraggo l'inerzia del motore da quella totale (entrambe al CG totale)
I_rocket_aboutCGtotal = I_total - I_motor_aboutCGtotal;

% 3) Riporto l'inerzia del razzo vuoto dal CG totale al SUO vero baricentro
d_rocket = cg_rocket_noMotor - cg_total;
I_rocket_noMotor = I_rocket_aboutCGtotal - par_axis(m_rocket_noMotor, d_rocket);

% Simmetrizza (numerico)
I_rocket_noMotor = 0.5*(I_rocket_noMotor + I_rocket_noMotor.');

%% --- Sanity check --------------------------------------------------------
if any(eig(I_rocket_noMotor) <= 0)
    warning(['I_rocket_noMotor non è definito positivo. ' ...
             'Controlla che I_total sia riferito a cg_total e che cg_motor/cg_total siano coerenti.']);
end

%% --- Stampa risultati ----------------------------------------------------
disp('======================================================');
disp('                INERTIA CALCULATOR                    ');
disp('======================================================');

fprintf('Propellant mass             : %.6g kg\n', M_prop);

fprintf('Motor total mass            : %.6g kg\n', M_motor);
disp('Motor total inertia tensor (at its own CG) [hollow cylinder]:');
disp(I_motor_c);

fprintf('Motor dry mass              : %.6g kg\n', M_motor_dry);
disp('Motor dry inertia tensor (at its own CG) [hollow cylinder]:');
disp(I_motor_dry_c);

fprintf('Rocket mass without motor   : %.6g kg\n', m_rocket_noMotor);
fprintf('Rocket CG without motor     : [%.6g; %.6g; %.6g] m\n', cg_rocket_noMotor);
disp('Inertia tensor of rocket WITHOUT motor (at its own CG):');
disp(I_rocket_noMotor);

disp('======================================================');

%% --- Salvataggio in Struct ----------------------------------------------
info = struct( ...
    'm_rocket_noMotor',   m_rocket_noMotor, ...
    'cg_rocket_noMotor',  cg_rocket_noMotor, ...
    'I_rocket_noMotor',   I_rocket_noMotor, ...
    'M_motor',            M_motor, ...
    'cg_motor',           cg_motor, ...
    'I_motor_c',          I_motor_c, ...
    'M_motor_dry',        M_motor_dry, ...
    'cg_motor_dry',       cg_motor_dry, ...
    'I_motor_dry_c',      I_motor_dry_c, ...
    'M_total',            M_total, ...
    'cg_total',           cg_total, ...
    'I_total',            I_total, ...
    'M_prop',             M_prop ...
    );