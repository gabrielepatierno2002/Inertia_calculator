% script_inertia.m
% -------------------------------------------------------------------------
% Calcola massa, baricentro e inerzia del razzo SENZA motore
% partendo da:
%   - (M_total, cg_total, I_total) del razzo completo CON motore
%     con I_total riferito a cg_total (OpenRocket)
%   - (M_motor, cg_motor, I_motor_c) del motore
%     con I_motor_c riferito a cg_motor
% -------------------------------------------------------------------------

run('config_inertia.mlx');

%% --- Validazione input ---------------------------------------------------
requiredVars = {'I_total','M_total','cg_total','I_motor_c','M_motor','cg_motor'};
for k = 1:numel(requiredVars)
    assert(exist(requiredVars{k}, 'var')==1, 'Variabile mancante: %s', requiredVars{k});
end

if isempty(cg_total), cg_total = [0;0;0]; end
if isempty(cg_motor), cg_motor = [0;0;0]; end

assert(isequal(size(I_total),   [3,3]), 'I_total deve essere 3x3');
assert(isequal(size(I_motor_c), [3,3]), 'I_motor_c deve essere 3x3');
assert(isscalar(M_total) && isnumeric(M_total) && M_total > 0, 'M_total deve essere uno scalare > 0');
assert(isscalar(M_motor) && isnumeric(M_motor) && M_motor > 0, 'M_motor deve essere uno scalare > 0');

cg_total = cg_total(:);
cg_motor = cg_motor(:);
assert(numel(cg_total)==3 && numel(cg_motor)==3, 'cg_total e cg_motor devono avere 3 elementi');

% Forzo simmetria numerica (utile se arriva da CAD con piccoli errori)
I_total   = 0.5*(I_total   + I_total.');
I_motor_c = 0.5*(I_motor_c + I_motor_c.');

%% --- Steiner (assi paralleli) -------------------------------------------
par_axis = @(m, d) m * (dot(d,d) * eye(3) - (d * d.'));

%% --- Calcolo massa e CG del razzo senza motore --------------------------
m_rocket_noMotor = M_total - M_motor;
if m_rocket_noMotor <= 0
    error('M_motor (%.6g) >= M_total (%.6g): impossibile calcolare il razzo senza motore.', M_motor, M_total);
end

cg_rocket_noMotor = (M_total * cg_total - M_motor * cg_motor) / m_rocket_noMotor;

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

disp('1) TENSORE DI INERZIA DEL RAZZO SENZA MOTORE (sul proprio CG):');
disp(I_rocket_noMotor);

disp('2) TENSORE DI INERZIA DEL MOTORE (sul proprio CG) [INPUT]:');
disp(I_motor_c);

disp('------------------------------------------------------');
fprintf('Massa razzo senza motore : %.6g kg\n', m_rocket_noMotor);
fprintf('CG razzo senza motore    : [%.6g; %.6g; %.6g] m\n', cg_rocket_noMotor);
disp('======================================================');

%% --- Salvataggio in Struct ----------------------------------------------
info = struct( ...
    'm_rocket_noMotor',   m_rocket_noMotor, ...
    'cg_rocket_noMotor',  cg_rocket_noMotor, ...
    'I_rocket_noMotor',   I_rocket_noMotor, ...
    'M_motor',            M_motor, ...
    'cg_motor',           cg_motor, ...
    'I_motor_c',          I_motor_c, ...
    'M_total',            M_total, ...
    'cg_total',           cg_total, ...
    'I_total',            I_total ...
);