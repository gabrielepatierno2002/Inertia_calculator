# Inertia Calculator

MATLAB tool to compute:
1. The inertia tensor of the rocket **without motor** (at its own CG)
2. The inertia tensor of the **motor casing only** (at its own CG)

---

## How to download / copy the files

### Option A — Clone the whole repository (recommended)

Open a terminal and run:

```bash
git clone https://github.com/gabrielepatierno2002/Inertia_calculator.git
```

This creates a local folder `Inertia_calculator/` containing all files.

### Option B — Download as ZIP (no Git required)

1. Go to the repository page on GitHub:  
   `https://github.com/gabrielepatierno2002/Inertia_calculator`
2. Click the green **Code** button.
3. Select **Download ZIP**.
4. Extract the ZIP anywhere on your computer.

### Option C — Download a single file

1. Open the file on GitHub (e.g. `config_inertia.m`).
2. Click the **Raw** button to view the plain text.
3. Right-click → **Save as…** (or use `Ctrl+S`) to save it locally.

---

## Files

| File | Purpose |
|---|---|
| `config_inertia.m` | **Edit this file** — fill in your rocket/motor data |
| `script_inertia.m` | Main calculation script — run this in MATLAB |

---

## Usage

1. Open `config_inertia.m` in MATLAB (or any text editor) and replace the example values with your actual data:

   ```matlab
   M_total    = 41;                    % total mass with motor [kg]
   cg_total   = [0; 0; 0.1];          % total CG [m]
   I_total    = diag([25, 25, 0.6]);  % total inertia tensor @ cg_total [kg·m²]

   cg_noMotor = [0; 0; 0.15];         % CG without motor [m]  (from OpenRocket)

   M_motor    = 20;
   cg_motor   = [0; 0; 0.0];
   I_motor_c  = diag([0.8, 0.8, 0.05]);

   M_propellant    = 15;
   cg_propellant   = [0; 0; 0.0];
   I_propellant_c  = diag([0.5, 0.5, 0.03]);
   ```

2. In MATLAB, navigate to the folder containing both files and run:

   ```matlab
   run('script_inertia.m')
   ```

3. The results are printed to the Command Window and stored in the `info` struct.

---

## Input variables reference

| Variable | Description | Unit |
|---|---|---|
| `M_total` | Total mass (rocket + full motor) | kg |
| `cg_total` | CG of rocket + motor (`[x;y;z]`) | m |
| `I_total` | Inertia tensor @ `cg_total` (3×3) | kg·m² |
| `cg_noMotor` | CG of rocket without motor (`[x;y;z]`) | m |
| `M_motor` | Full motor mass (casing + propellant) | kg |
| `cg_motor` | Motor CG (`[x;y;z]`) | m |
| `I_motor_c` | Motor inertia tensor @ `cg_motor` (3×3) | kg·m² |
| `M_propellant` | Propellant mass | kg |
| `cg_propellant` | Propellant CG (`[x;y;z]`) | m |
| `I_propellant_c` | Propellant inertia tensor @ `cg_propellant` (3×3) | kg·m² |
