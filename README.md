# Intro

This MATLAB tool calculates the **inertia tensor, mass, and center of gravity (CG)** of a rocket **without its motor** (dry/empty airframe configuration), starting from the full rocket data provided by simulation software like [OpenRocket](https://openrocket.info/).

---

## 📂 Repository Contents

| File | Description |
|---|---|
| `InertiaCalculatorApp.m` | **GUI app** — interactive graphical interface for entering parameters and viewing results |
| `config_inertia.m` | **Configuration file** — define all your rocket & motor parameters here (script-based workflow) |
| `script_inertia.m` | **Main script** — reads the config, runs the calculations, prints results |
| `README.md` | This documentation |

---

## How It Works 

Since the centers of gravity (CG) of the full rocket, the empty rocket, and the motor are located at different positions along the longitudinal axis (Z), the code applies the **Huygens-Steiner Theorem** (Parallel Axis Theorem) through three steps:

1. **Forward Transport:** It models the motor as a **solid cylinder**, calculates its local inertia tensor, and transports it from its own CG to the total CG of the full rocket.

2. **Matrix Subtraction:** It subtracts the motor's inertia tensor from the full rocket's tensor (now that both share the same reduction pole).

3. **Backward Transport:** It takes the resulting inertia (which is currently referenced to the total CG) and transports it back to the actual CG of the motorless rocket.

> **Note:** The code assumes `Z = 0` coincides with the rocket's **nose tip** and that the motor's base is perfectly aligned with the vehicle's base.

---

## 📋 Prerequisites
- Your rocket's physical data, typically from [OpenRocket](https://openrocket.info/) or a similar simulation tool

---

## 🖥️ GUI App (Recommended)

The easiest way to use the calculator is through the interactive graphical app.

### Launch the App

In the MATLAB Command Window, navigate to the repository folder and type:

```matlab
InertiaCalculatorApp
```

The app window opens with two panels:

| Panel | Description |
|---|---|
| **Configuration** (left) | Editable input fields for every parameter, pre-filled with the example values from `config_inertia.m` |
| **Results** (right) | Formatted output showing masses, CG positions, and inertia tensors — updated each time you press **Calculate** |

### App Buttons

| Button | Action |
|---|---|
| **Calculate** | Reads all fields, validates the inputs, runs the inertia calculation, and displays the results |
| **Reset to defaults** | Restores all input fields to the built-in example values |

> **Requirements:** MATLAB R2019b or later (uses `uifigure` / App Designer runtime).

---

## 🛠️ Step-by-Step Usage Guide (Script-based workflow)

### Step 1 — Clone or Download

```bash
git clone https://github.com/gabrielepatierno2002/Inertia_calculator.git
```

Or download the ZIP from the GitHub page and extract it.

### Step 2 — Configure Your Parameters

Open `config_inertia.m` in the MATLAB editor. Replace the example values with your rocket's actual numbers. The file is organized into clearly labelled sections:

#### Section A — Full Rocket Data (from OpenRocket)

| Variable | Description | Unit | Example |
|---|---|---|---|
| `M_total` | Total rocket mass **with motor loaded** | kg | `12.5` |
| `cg_total` | CG position of the full rocket along the Z axis (from **nose tip**) | m | `1.45` |
| `I_total` | 3×3 inertia tensor at `cg_total` | kg·m² | `diag([2.8, 2.8, 0.12])` |

> For `I_total`, use `diag([Ixx, Iyy, Izz])` for a diagonal tensor, or provide the full 3×3 matrix if off-diagonal terms are non-zero.

#### Section B — Motorless Rocket CG

| Variable | Description | Unit | Example |
|---|---|---|---|
| `cg_noMotor` | CG position of the rocket **without motor**, along Z (from nose tip) | m | `1.40` |

#### Section C — Motor (Solid Cylinder)

| Variable | Description | Unit | Example |
|---|---|---|---|
| `M_motor_dry` | Motor mass | kg | `1.8` |
| `R_out` | Motor outer radius | m | `0.08` |
| `L_motor` | Motor length | m | `0.35` |

#### Section D — Geometry

| Variable | Description | Unit | Example |
|---|---|---|---|
| `L_rocket` | Total rocket length (nose tip = Z origin) | m | `1.8` |

### Step 3 — Run the Script

In the MATLAB Command Window, make sure your current directory contains both `config_inertia.m` and `script_inertia.m`, then type:

```matlab
run('script_inertia.m')
```

### Step 4 — Read the Output

The script prints a formatted report directly in the Command Window:

```
========================================================================
                         INERTIA CALCULATOR
========================================================================

Motor mass                           :          1.8 kg

Rocket mass without motor            :         10.7 kg
Rocket CG without motor (Z)          :          1.4 m

------------------------------------------------------------------------
       Motor inertia tensor (at motor CG) — solid cylinder
+----------------+----------------+----------------+
|    0.0156363   |              0 |              0 |
+----------------+----------------+----------------+
|              0 |    0.0156363   |              0 |
+----------------+----------------+----------------+
|              0 |              0 |   0.00576      |
+----------------+----------------+----------------+

  ... (empty rocket tensor follows)
========================================================================
```

### Step 5 — Use the Results Programmatically

All computed quantities are stored in a MATLAB **`info` struct** that remains in the workspace after the script finishes:

```matlab
% --- Airframe (rocket without motor) ---
info.m_rocket_noMotor    % Airframe mass [kg]
info.cg_rocket_noMotor   % Airframe CG position [m]
info.I_rocket_noMotor    % 3x3 inertia tensor at the airframe CG [kg·m²]

% --- Motor ---
info.M_motor             % Motor mass [kg]
info.cg_motor            % Motor CG position [m]
info.I_motor_c           % Motor inertia tensor at its CG [kg·m²]

% --- Full Rocket ---
info.M_total             % Total rocket mass [kg]
info.cg_total            % Total rocket CG [m]
info.I_total             % Total rocket inertia tensor [kg·m²]
```

You can pass this struct directly to a flight simulator:

```matlab
sim_data.airframe = info;
run('my_6dof_simulator.m');
```

---

## ⚙️ Key Assumptions & Conventions

| Assumption | Details |
|---|---|
| **Coordinate origin** | `Z = 0` is at the rocket's **nose tip**; Z increases toward the tail |
| **Motor position** | The motor's base is flush with the rocket's base; motor CG is computed as `L_rocket − L_motor / 2` |
| **Motor geometry** | The motor is modelled as a **solid cylinder** with outer radius `R_out` |
| **Axial symmetry** | The rocket is assumed axially symmetric (X and Y transverse axes are equivalent) |

---

## ❗ Troubleshooting

| Error / Warning | Cause | Fix |
|---|---|---|
| `Variabile mancante: <name>` | A required variable is missing from `config_inertia.m` | Add the missing variable to the config file |
| `I_total deve essere 3x3` | The inertia tensor is not a 3×3 matrix | Ensure `I_total` is defined as a 3×3 matrix, e.g. `diag([Ixx, Iyy, Izz])` |
| `M_motor >= M_total` | The motor mass exceeds the total rocket mass | Check `M_motor_dry` — it must be less than `M_total` |
| `I_rocket_noMotor non è definito positivo` | The resulting inertia tensor has non-positive eigenvalues | Verify that `I_total` is referenced to `cg_total` and that all CG positions are consistent |

---

## 🔄 Typical Workflow with OpenRocket

1. **Design** your rocket in OpenRocket and run a simulation.
2. From the component analysis, note `M_total`, `cg_total`, and the moments of inertia → build `I_total`.
3. **Remove the motor** in OpenRocket to obtain `cg_noMotor`.
4. From your **motor's datasheet**, fill in `M_motor_dry`, `L_motor`, and `R_out`.
5. **Run** `script_inertia.m` → you now have the airframe's inertia properties, ready for your flight dynamics code.

---
## 📄 License

**All rights reserved.**

This code is the exclusive property of the development team. Any reproduction, distribution, modification, or use of this code — in whole or in part — without explicit prior written consent from the team is strictly forbidden.

If you wish to use this code for your own projects, you **must** request permission first by contacting the repository owner.
