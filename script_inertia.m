% inertia_calculator.m
% ------------------------
% Calcola massa, baricentro e inerzia del razzo SENZA motore
% partendo dai dati del razzo completo e del motore.

run('config_inertia.mlx');

%% --- Validazione Input -------------------------------------------------
if isempty(cg_motor)
    cg_motor = [0;0;0];
end
if isempty(cg_total)
    cg_total = [0;0;0];
end
assert(isequal(size(I_total),[3,3]), 'I_total deve essere 3x3');
assert(numel(cg_total)==3 && numel(cg_motor)==3, 'I cg devono essere 3x1');

% Assicuro che siano vettori colonna
cg_total = cg_total(:);
cg_motor = cg_motor(:);

%% --- Decomposizione Massa Motore (Grano e Shell) -----------------------
V_grain = pi * R^2 * h;           % volume del propellente (m^3)
m_grain = rho_grain * V_grain;    % massa del propellente (kg)
m_shell = M_motor - m_grain;      % massa rimanente assegnata all'involucro (kg)

if m_shell < -1e-9
    error('m_grain (%.3g kg) eccede M_motor (%.3g kg). Controlla i dati.', m_grain, M_motor);
end
m_shell = max(m_shell, 0);        % Evita piccoli valori negativi numerici

%% --- Inerzia del Motore rispetto al proprio CG -------------------------
% Inerzia grano (cilindro pieno)
Izz_grain = m_grain * R^2;
Ixx_grain = 0.5 * m_grain * R^2 + (1/12) * m_grain * h^2;
I_grain_c = diag([Ixx_grain, Ixx_grain, Izz_grain]);

% Inerzia shell (cilindro cavo a parete sottile)
Izz_shell = m_shell * R^2;
Ixx_shell = 0.5 * m_shell * R^2 + (1/12) * m_shell * h^2;
I_shell_c = diag([Ixx_shell, Ixx_shell, Izz_shell]);

% Inerzia totale del motore sul proprio CG (OUTPUT RICHIESTO 2)
I_motor_c = I_grain_c + I_shell_c;

%% --- Calcolo Massa e CG del Razzo Nudo ---------------------------------
m_rocket_noMotor = M_total - M_motor;

if m_rocket_noMotor <= 0
    error('La massa del motore (%.3g) è maggiore o uguale a quella totale (%.3g)!', M_motor, M_total);
end

% Formula inversa del baricentro
cg_rocket_noMotor = (M_total * cg_total - M_motor * cg_motor) / m_rocket_noMotor;

%% --- Sottrazione Inerziale (Teorema degli Assi Paralleli) --------------
% Funzione anonima per il termine di Steiner (massa m, vettore distanza d)
par_axis = @(m, d) m * (dot(d,d) * eye(3) - (d * d.'));

% 1. Sposto l'inerzia del motore sul CG totale
d_motor = cg_motor - cg_total;
I_motor_aboutCGtotal = I_motor_c + par_axis(M_motor, d_motor);

% 2. Sottraggo l'inerzia del motore da quella totale (entrambe al CG totale)
I_rocket_aboutCGtotal = I_total - I_motor_aboutCGtotal;

% 3. Riporto l'inerzia del razzo vuoto dal CG totale al SUO vero baricentro
% (OUTPUT RICHIESTO 1)
d_rocket = cg_rocket_noMotor - cg_total;
I_rocket_noMotor = I_rocket_aboutCGtotal - par_axis(m_rocket_noMotor, d_rocket);

%% --- Stampa dei Risultati (I DUE TENSORI RICHIESTI) --------------------
disp('======================================================');
disp('                INERTIA CALCULATOR                    ');
disp('======================================================');

disp('1. TENSORE DI INERZIA DEL RAZZO SENZA MOTORE (riferito al proprio CG):');
disp(I_rocket_noMotor);

disp('2. TENSORE DI INERZIA DEL MOTORE (riferito al proprio CG):');
disp(I_motor_c);

disp('------------------------------------------------------');
fprintf('Massa razzo senza motore : %.6g kg\n', m_rocket_noMotor);
fprintf('Nuovo CG razzo vuoto     : [%.6g; %.6g; %.6g] m\n', cg_rocket_noMotor);
disp('======================================================');

%% --- Salvataggio in Struct ---------------------------------------------
info = struct( ...
    'm_rocket_noMotor',      m_rocket_noMotor, ...
    'cg_rocket_noMotor',     cg_rocket_noMotor, ...
    'I_rocket_noMotor',      I_rocket_noMotor, ...
    'I_motor_c',             I_motor_c ...
);