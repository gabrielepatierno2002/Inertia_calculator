Rocket Inertia Calculator
This MATLAB tool calculates the inertia tensor, mass, and center of gravity (CG) of a rocket without its motor (dry/empty configuration), starting from the full rocket data provided by simulation software like OpenRocket.

It is essential for flight dynamics analysis, allowing you to separate the vehicle's structural dynamics from the variable properties of the propellant and the motor casing.

🚀 How it Works (The Physics)
The calculation is not a simple algebraic subtraction. Since the centers of gravity (CG) of the full rocket, the empty rocket, and the motor are located at different positions along the longitudinal axis (Z), the code rigorously applies the Huygens-Steiner Theorem (Parallel Axis Theorem) through three steps:

Forward Transport: It models the motor (dry + propellant) as a hollow cylinder, calculates its local inertia tensor, and transports it from its own CG to the total CG of the full rocket.

Matrix Subtraction: It subtracts the motor's inertia tensor from the full rocket's tensor (now that both share the same reduction pole).

Backward Transport: It takes the resulting inertia (which is currently referenced to the total CG) and transports it back to the actual CG of the motorless rocket.

Note: The code assumes the Z=0 coordinate coincides with the rocket's nose and that the motor's base is perfectly aligned with the vehicle's base.

📋 Prerequisites and Inputs
The tool requires no additional toolboxes. To work properly, the main script expects to find a file named config_inertia.m in the same directory.

The following physical variables must be defined inside config_inertia.m:

Full Rocket Data (e.g., from OpenRocket):

M_total: Total rocket mass with motor [kg]

cg_total: Total CG position along the Z axis [m]

I_total: 3x3 inertia matrix at the total CG [kg*m^2]

L_rocket: Total vehicle length [m]

cg_noMotor: CG position of the rocket without the motor [m]

Motor and Propellant Data:

M_motor_dry: Dry motor mass (without propellant) [kg]

L_motor: Motor length [m]

R_out: Motor outer radius [m]

R_in: Grain inner radius (optional, default = r_grain) [m]

rho_grain: Propellant density [kg/m^3]

n_grains: Number of propellant grains

r_grain: Grain outer radius [m]

h_grain: Height of a single grain [m]

🛠️ Usage
Clone the repository or download the files.

Open MATLAB and navigate to the folder containing the files.

Fill out config_inertia.m with your vehicle's specific parameters.

Run the main script from the command window:

Matlab run('script_inertia.m')

📊 Output
The script will generate a formatted report in the command window showing the inertia tensors (full motor, dry motor, empty rocket) alongside their respective mass and CG data.
Furthermore, all calculated variables are automatically saved in an info struct in the MATLAB workspace, ready to be passed to other simulation scripts (e.g., 6-DOF flight simulators).
