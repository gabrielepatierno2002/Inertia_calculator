% script_inertia.m
% -------------------------------------------------------------------------

run('config_inertia.m');

%% --- Validazione input ---------------------------------------------------
requiredVars = {'I_total','M_total','cg_total','cg_noMotor', ...
                'M_motor_dry','L_rocket','R_out','R_in','L_motor'};
for k = 1:numel(requiredVars)
    assert(exist(requiredVars{k}, 'var')==1, 'Variabile mancante: %s', requiredVars{k});
end

if isempty(cg_total),  cg_total = 0; end
if isempty(cg_noMotor), cg_noMotor = 0; end

assert(isequal(size(I_total), [3,3]), 'I_total deve essere 3x3');
assert(isscalar(M_total) && isnumeric(M_total) && M_total > 0, 'M_total deve essere uno scalare > 0');
assert(isscalar(cg_total) && isnumeric(cg_total), 'cg_total deve essere uno scalare (asse Z)');
assert(isscalar(cg_noMotor) && isnumeric(cg_noMotor), 'cg_noMotor deve essere uno scalare (asse Z)');

% Converto in vettori 3x1 lungo Z per i calcoli
cg_total_v   = [0;0;cg_total];
cg_noMotor_v = [0;0;cg_noMotor];

% CG motore assunto = L_rocket - L_motor/2 lungo Z
% (coordinate dal naso: il fondo del motore coincide con il fondo del razzo)
cg_motor = L_rocket - L_motor/2;
cg_motor_v = [0;0;cg_motor];

assert(isscalar(M_motor_dry) && isnumeric(M_motor_dry) && M_motor_dry > 0, ...
    'M_motor_dry deve essere uno scalare > 0');
assert(isscalar(R_out) && R_out > 0, 'R_out deve essere > 0');
assert(isscalar(R_in) && R_in >= 0 && R_in < R_out, 'R_in deve essere >= 0 e < R_out');
assert(isscalar(L_motor) && L_motor > 0, 'L_motor deve essere > 0');
assert(isscalar(L_rocket) && L_rocket > 0, 'L_rocket deve essere > 0');
assert(L_rocket >= L_motor, 'L_rocket deve essere >= L_motor');

% Forzo simmetria numerica (utile se arriva da CAD con piccoli errori)
I_total = 0.5*(I_total + I_total.');
%% -- massa razzo senza motore%%
M_rocket_noMotor = M_total - M_motor_with_prop;
%% --- Massa motore --------------------------------------------------------
M_motor = M_motor_dry;

%% --- Inerzia motore (cilindro cavo) ----------------------------
I_ax = 0.5 * M_motor * ((R_in)^2 + (R_out)^2);
I_tr = (1/12) * M_motor * (3*(R_in^2 + R_out^2) + L_motor^2);
I_motor_c = diag([I_tr, I_tr, I_ax]);


I_ax_full = 0.5 * M_motor_with_prop * R_out^2;
I_tr_full = (1/12) * M_motor_with_prop * (3*R_out^2 + L_motor^2);
I_motor_full = diag([I_tr_full, I_tr_full, I_ax_full]);

%% --- Steiner (assi paralleli) -------------------------------------------
par_axis = @(m, d) m * (dot(d,d) * eye(3) - (d * d.'));

%% --- Calcolo massa e CG del razzo senza motore --------------------------
if M_rocket_noMotor <= 0
    error('M_motor (%.6g) >= M_total (%.6g): impossibile calcolare il razzo senza motore.', M_motor, M_total);
end

cg_rocket_noMotor = cg_noMotor;

%% --- Sottrazione inerziale ----------------------------------------------
% 1) Porta l'inerzia del motore dal suo CG al CG totale
%    (cg_motor = L_rocket - L_motor/2)
% Spiego passo-passo con commenti e variabili intermedie per chiarezza.

% vettore spostamento dal CG totale al CG motore (d = r_motor - r_total)
d_motor = cg_motor_v - cg_total_v;

% I_motor_full è l'inerzia del motore se fosse un cilindro pieno/composto,
% calcolata precedentemente per includere eventualmente la propellente (se definita).
% Qui riportiamo l'inerzia del motore dal suo CG al CG totale usando il teorema di Steiner:
I_motor_aboutCGtotal = I_motor_full + par_axis(M_motor_with_prop, d_motor);

% 2) Sottrazione: dato che I_total è l'inerzia del sistema completo (razzo + motore)
% riferita al cg_total, rimuoviamo il contributo del motore (entrambi riferiti a cg_total)
% per ottenere l'inerzia del razzo senza motore, ma ancora riferita al cg_total.
I_rocket_aboutCGtotal = I_total - I_motor_aboutCGtotal;

% 3) Riporto l'inerzia del razzo vuoto dal CG totale al SUO vero baricentro
d_rocket = cg_total_v - cg_noMotor_v ;
I_rocket_noMotor = I_rocket_aboutCGtotal - par_axis(M_rocket_noMotor, d_rocket);
% Simmetrizza (numerico)
I_rocket_noMotor = 0.5*(I_rocket_noMotor + I_rocket_noMotor.');

%% --- Check: ricostruzione I_total dal razzo senza motore + motore -------
% Verifica che I_rocket_noMotor sia effettivamente riferito a cg_noMotor:
% riportando entrambi i contributi al cg_total e sommando deve tornare I_total.
d_check_rocket = cg_noMotor_v - cg_total_v;
I_rocket_atCGtotal = I_rocket_noMotor + par_axis(M_rocket_noMotor, d_check_rocket);
I_total_reconstructed = I_rocket_atCGtotal + I_motor_aboutCGtotal;
reconstruction_error = norm(I_total_reconstructed - I_total, 'fro') / max(norm(I_total, 'fro'), 1e-30);
if reconstruction_error > 1e-10
    warning(['Check ricostruzione: I_total ricostruito differisce da I_total per %.3g (norma relativa, soglia=1e-10). ' ...
             'Verificare che cg_noMotor e cg_total siano coerenti con I_total di OpenRocket.'], reconstruction_error);
else
    fprintf('Check OK: I_total ricostruito coincide con I_total (errore relativo = %.3g)\n\n', reconstruction_error);
end

%% --- Sanity check --------------------------------------------------------
if any(eig(I_rocket_noMotor) <= 0)
    warning(['I_rocket_noMotor non è definito positivo. ' ...
             'Controlla che I_total sia riferito a cg_total e che cg_motor/cg_total siano coerenti.']);
end

%% --- Stampa risultati------------------------
sep = repmat('=',1,72);
thin = repmat('-',1,72);
titleStr = 'INERTIA CALCULATOR';
fprintf('%s\n', sep);
fprintf('%s\n', centerText(titleStr, length(sep)));
fprintf('%s\n\n', sep);

% Summary numbers (aligned)
lblW = 36;
fmtNum = '%12.6g';

fprintf('%-*s : %s kg\n\n', lblW, 'Motor mass', sprintf(fmtNum, M_motor));

fprintf('%-*s : %s kg\n', lblW, 'Rocket mass without motor', sprintf(fmtNum, M_rocket_noMotor));
fprintf('%-*s : %s m\n\n', lblW, 'Rocket CG without motor (Z)', sprintf(fmtNum, cg_rocket_noMotor));

% Motor inertia (at its CG) — show full matrix with box lines
fprintf('%s\n', thin);
fprintf('%s\n', centerText('Motor inertia tensor (at motor CG) — hollow cylinder', length(thin)));

printMatrixBox(I_motor_c);
fprintf('\n');

% Rocket inertia without motor
fprintf('%s\n', thin);
fprintf('%s\n', centerText('Rocket WITHOUT motor — inertia tensor (at its CG)', length(thin)));

printMatrixBox(I_rocket_noMotor);
fprintf('\n%s\n\n', sep);

%% --- Salvataggio in Struct ----------------------------------------------
info = struct( ...
    'm_rocket_noMotor',   M_rocket_noMotor, ...
    'cg_rocket_noMotor',  cg_rocket_noMotor, ...
    'I_rocket_noMotor',   I_rocket_noMotor, ...
    'M_motor',            M_motor, ...
    'cg_motor',           cg_motor, ...
    'I_motor_c',          I_motor_c, ...
    'M_total',            M_total, ...
    'cg_total',           cg_total, ...
    'I_total',            I_total ...
    );

%---------------------
function s = centerText(str, width)
    if length(str) >= width
        s = str;
    else
        pad = floor((width - length(str))/2);
        s = [repmat(' ',1,pad) str];
    end
end

function printMatrixBox(M)
    % Prints a 3x3 matrix inside an ASCII box without row/column labels.
    assert(isequal(size(M), [3,3]), 'Matrix must be 3x3');
    % field widths
    valW = 14;
    % build horizontal line pieces
    horCell = repmat('-',1,valW+2);
    topLine = ['+' horCell '+' horCell '+' horCell '+'];
    midLine = topLine;
    % print header
    fprintf('%s\n', topLine);
    % rows (no labels)
    for i = 1:3
        for j = 1:3
            if j == 1
                fprintf('|');
            end
            fprintf(' %*.*g |', valW, 6, M(i,j));
        end
        fprintf('\n%s\n', midLine);
    end
end