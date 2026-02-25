% script_inertia.m
% -------------------------------------------------------------------------
% Calcola:
%   1) Inerzia del razzo SENZA motore (sul proprio CG)
%   2) Inerzia del SOLO CASING del motore (sul proprio CG)
%
% Input richiesti:
%   - (M_total, cg_total, I_total)     razzo completo CON motore;
%                                       I_total riferito a cg_total (OpenRocket)
%   - cg_noMotor                        CG del razzo SENZA motore (OpenRocket)
%   - (M_motor, cg_motor, I_motor_c)   motore completo (casing + propellente);
%                                       I_motor_c riferito a cg_motor
%   - (M_propellant, cg_propellant,
%      I_propellant_c)                  solo propellente;
%                                       I_propellant_c riferito a cg_propellant
% -------------------------------------------------------------------------

run('config_inertia.m');

%% --- Validazione input ---------------------------------------------------
requiredVars = {'I_total','M_total','cg_total','cg_noMotor', ...
                'I_motor_c','M_motor','cg_motor', ...
                'M_propellant','cg_propellant','I_propellant_c'};
for k = 1:numel(requiredVars)
    assert(exist(requiredVars{k}, 'var')==1, 'Variabile mancante: %s', requiredVars{k});
end

if isempty(cg_total),      cg_total      = [0;0;0]; end
if isempty(cg_noMotor),    cg_noMotor    = [0;0;0]; end
if isempty(cg_motor),      cg_motor      = [0;0;0]; end
if isempty(cg_propellant), cg_propellant = [0;0;0]; end

assert(isequal(size(I_total),        [3,3]), 'I_total deve essere 3x3');
assert(isequal(size(I_motor_c),      [3,3]), 'I_motor_c deve essere 3x3');
assert(isequal(size(I_propellant_c), [3,3]), 'I_propellant_c deve essere 3x3');
assert(isscalar(M_total)      && isnumeric(M_total)      && M_total > 0,      'M_total deve essere uno scalare > 0');
assert(isscalar(M_motor)      && isnumeric(M_motor)      && M_motor > 0,      'M_motor deve essere uno scalare > 0');
assert(isscalar(M_propellant) && isnumeric(M_propellant) && M_propellant > 0, 'M_propellant deve essere uno scalare > 0');

cg_total      = cg_total(:);
cg_noMotor    = cg_noMotor(:);
cg_motor      = cg_motor(:);
cg_propellant = cg_propellant(:);
assert(numel(cg_total)==3 && numel(cg_noMotor)==3 && numel(cg_motor)==3 && numel(cg_propellant)==3, ...
       'cg_total, cg_noMotor, cg_motor e cg_propellant devono avere 3 elementi');

% Forzo simmetria numerica (utile se arriva da CAD con piccoli errori)
I_total        = 0.5*(I_total        + I_total.');
I_motor_c      = 0.5*(I_motor_c      + I_motor_c.');
I_propellant_c = 0.5*(I_propellant_c + I_propellant_c.');

%% --- Steiner (assi paralleli) -------------------------------------------
par_axis = @(m, d) m * (dot(d,d) * eye(3) - (d * d.'));

%% --- Calcolo massa del razzo senza motore --------------------------------
m_rocket_noMotor = M_total - M_motor;
if m_rocket_noMotor <= 0
    error('M_motor (%.6g) >= M_total (%.6g): impossibile calcolare il razzo senza motore.', M_motor, M_total);
end

%% --- Inerzia razzo senza motore (al suo CG, fornito come input) ---------
% 1) Porta l'inerzia del motore dal suo CG al CG totale
d_motor = cg_motor - cg_total;
I_motor_aboutCGtotal = I_motor_c + par_axis(M_motor, d_motor);

% 2) Sottraggo l'inerzia del motore da quella totale (entrambe al CG totale)
I_rocket_aboutCGtotal = I_total - I_motor_aboutCGtotal;

% 3) Riporto l'inerzia del razzo vuoto dal CG totale al suo CG (fornito)
d_rocket = cg_noMotor - cg_total;
I_rocket_noMotor = I_rocket_aboutCGtotal - par_axis(m_rocket_noMotor, d_rocket);

% Simmetrizza (numerico)
I_rocket_noMotor = 0.5*(I_rocket_noMotor + I_rocket_noMotor.');

%% --- Inerzia solo casing del motore (al suo CG) -------------------------
M_casing  = M_motor - M_propellant;
if M_casing <= 0
    error('M_propellant (%.6g) >= M_motor (%.6g): impossibile calcolare il casing.', M_propellant, M_motor);
end

cg_casing = (M_motor * cg_motor - M_propellant * cg_propellant) / M_casing;

% 1) Porta l'inerzia del propellente dal suo CG al CG del motore
d_prop = cg_propellant - cg_motor;
I_propellant_aboutCGmotor = I_propellant_c + par_axis(M_propellant, d_prop);

% 2) Sottraggo l'inerzia del propellente da quella del motore (entrambe al CG motore)
I_casing_aboutCGmotor = I_motor_c - I_propellant_aboutCGmotor;

% 3) Riporto l'inerzia del casing dal CG motore al suo vero CG
d_casing = cg_casing - cg_motor;
I_casing = I_casing_aboutCGmotor - par_axis(M_casing, d_casing);

% Simmetrizza (numerico)
I_casing = 0.5*(I_casing + I_casing.');

%% --- Sanity check --------------------------------------------------------
if any(eig(I_rocket_noMotor) <= 0)
    warning(['I_rocket_noMotor non è definito positivo. ' ...
             'Controlla che I_total sia riferito a cg_total e che i CG siano coerenti.']);
end
if any(eig(I_casing) <= 0)
    warning(['I_casing non è definito positivo. ' ...
             'Controlla che I_motor_c e I_propellant_c siano coerenti.']);
end

%% --- Stampa risultati ----------------------------------------------------
disp('======================================================');
disp('                INERTIA CALCULATOR                    ');
disp('======================================================');

disp('1) TENSORE DI INERZIA DEL RAZZO SENZA MOTORE (sul proprio CG):');
disp(I_rocket_noMotor);

disp('2) TENSORE DI INERZIA DEL SOLO CASING DEL MOTORE (sul proprio CG):');
disp(I_casing);

disp('------------------------------------------------------');
fprintf('Massa razzo senza motore : %.6g kg\n', m_rocket_noMotor);
fprintf('CG razzo senza motore    : [%.6g; %.6g; %.6g] m\n', cg_noMotor);
fprintf('Massa casing motore      : %.6g kg\n', M_casing);
fprintf('CG casing motore         : [%.6g; %.6g; %.6g] m\n', cg_casing);
disp('======================================================');

%% --- Salvataggio in Struct ----------------------------------------------
info = struct( ...
    'm_rocket_noMotor',   m_rocket_noMotor, ...
    'cg_rocket_noMotor',  cg_noMotor, ...
    'I_rocket_noMotor',   I_rocket_noMotor, ...
    'M_casing',           M_casing, ...
    'cg_casing',          cg_casing, ...
    'I_casing',           I_casing, ...
    'M_motor',            M_motor, ...
    'cg_motor',           cg_motor, ...
    'I_motor_c',          I_motor_c, ...
    'M_propellant',       M_propellant, ...
    'cg_propellant',      cg_propellant, ...
    'I_propellant_c',     I_propellant_c, ...
    'M_total',            M_total, ...
    'cg_total',           cg_total, ...
    'I_total',            I_total ...
);