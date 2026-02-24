function info = script_inertia(I_motor_c)
    % Input validation
    if nargin < 1 || ~isnumeric(I_motor_c) || I_motor_c <= 0
        error('Input I_motor_c must be a positive numeric value');
    end

    % Constants
    g = 9.81;  % Gravity constant

    % Compute dry mass, dry CG, and dry inertia
    % Assume some predefined variables (for example purposes)
    total_mass = I_motor_c * 2;  % Example computation
    dry_mass = total_mass;                   
    dry_CG = [0, 0, 0];  % Placeholder for CG computation

    % Parallel-axis theorem computations
    inertia_transfer = 0.5 * dry_mass;  % Example inertia transfer
    dry_inertia = I_motor_c + inertia_transfer;  % Example of dry inertia calculation

    % Save results into info struct
    info = struct();
    info.dry_mass = dry_mass;
    info.dry_CG = dry_CG;
    info.dry_inertia = dry_inertia;
end