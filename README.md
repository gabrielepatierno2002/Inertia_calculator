# Inertia Calculator — GUI App

This MATLAB GUI application calculates the **inertia tensor, mass, and center of gravity (CG)** of a rocket **without its motor** (dry/empty airframe configuration), starting from the full rocket data provided by simulation software like [OpenRocket](https://openrocket.info/).

Everything — inputs, calculation, and results — is handled inside a single interactive graphical interface. There is no need to edit any configuration file or run scripts manually.

---

## 📂 Repository Contents

| File | Description |
|---|---|
| `GUI_inertia_calculator` | **Main app file** — contains the complete GUI class `InertiaCalculatorApp` |
| `README.md` | This documentation |

---

## How It Works

Since the centers of gravity (CG) of the full rocket, the empty rocket, and the motor are located at different positions along the longitudinal axis (Z), the app applies the **Huygens-Steiner Theorem** (Parallel Axis Theorem) through three steps:

1. **Forward Transport:** It models the motor as a **hollow cylinder**, calculates its local inertia tensor, and transports it from its own CG to the total CG of the full rocket.

2. **Matrix Subtraction:** It subtracts the motor's inertia tensor from the full rocket's tensor (now that both share the same reduction pole).

3. **Backward Transport:** It takes the resulting inertia (which is currently referenced to the total CG) and transports it back to the actual CG of the motorless rocket.

> **Note:** The app assumes `Z = 0` coincides with the rocket's **nose tip** and that the motor's base is flush with the vehicle's base.

---

## 📋 Prerequisites

- MATLAB (R2019b or later recommended, for App Designer / `uifigure` support)
- Your rocket's physical data, typically from [OpenRocket](https://openrocket.info/) or a similar simulation tool

---

## 🛠️ Step-by-Step Usage Guide

### Step 1 — Clone or Download

```bash
git clone https://github.com/gabrielepatierno2002/Inertia_calculator.git
```

Or download the ZIP from the GitHub page and extract it.

### Step 2 — Open MATLAB and Launch the App

In the MATLAB Command Window, navigate to the folder containing `GUI_inertia_calculator`, then either:

- Press **F5** with the file open in the MATLAB Editor, **or**
- Type in the Command Window:

```matlab
InertiaCalculatorApp
```

Both `InertiaCalculatorApp` and `InertiaCalculatorApp()` work — MATLAB will instantiate the class and display the window.

### Step 3 — Enter Your Parameters

The **Configuration** panel on the left contains all input fields, pre-filled with default example values. Replace them with your rocket's actual data:

#### Section A — Full Rocket Data (from OpenRocket / CAD)

| Field | Description | Unit |
|---|---|---|
| `L_rocket` | Total rocket length (nose tip = Z origin) | m |
| `M_total` | Total rocket mass **with motor loaded** | kg |
| `cg_total` | CG of the full rocket along Z (from nose tip) | m |
| `Ixx` | Transverse moment of inertia (X-axis) at `cg_total` | kg·m² |
| `Iyy` | Transverse moment of inertia (Y-axis) at `cg_total` | kg·m² |
| `Izz` | Axial moment of inertia (Z-axis) at `cg_total` | kg·m² |

> The app uses only the three diagonal components `Ixx`, `Iyy`, `Izz`; off-diagonal inertia terms are assumed to be zero.

#### Section B — Motorless Rocket CG

| Field | Description | Unit |
|---|---|---|
| `cg_noMotor` | CG of the rocket **without motor**, along Z (from nose tip) | m |

#### Section C — Motor (Hollow Cylinder)

| Field | Description | Unit |
|---|---|---|
| `M_motor_dry` | Motor casing mass (dry, without propellant) | kg |
| `M_motor_with_prop` | Motor mass with propellant loaded | kg |
| `R_out` | Motor outer radius | m |
| `R_in` | Motor inner radius | m |
| `L_motor` | Motor length | m |

### Step 4 — Calculate

Click the **Calculate** button. The **Results** panel on the right will display a formatted report:

```
========================================================
                  INERTIA CALCULATOR
========================================================

Motor casing mass                : 3.456 kg

Rocket mass w/o motor            : 14.777 kg
Rocket CG w/o motor (Z)          : 1.38 m

--------------------------------------------------------
        Motor inertia tensor (at motor CG)
                  hollow cylinder
+----------------+----------------+----------------+
|       0.731505 |              0 |              0 |
+----------------+----------------+----------------+
|              0 |       0.731505 |              0 |
+----------------+----------------+----------------+
|              0 |              0 |    0.000196    |
+----------------+----------------+----------------+

--------------------------------------------------------
          Rocket WITHOUT motor
       inertia tensor (at its CG)
+----------------+----------------+----------------+
|        ...     |              0 |              0 |
+----------------+----------------+----------------+
| ...
========================================================

✓  Reconstruction check OK  (relative error = ...)
```

### Step 5 — Reset (Optional)

Click **Reset to defaults** to restore all fields to the built-in example values and clear the output area.

---

## ⚙️ Key Assumptions & Conventions

| Assumption | Details |
|---|---|
| **Coordinate origin** | `Z = 0` is at the rocket's **nose tip**; Z increases toward the tail |
| **Motor position** | The motor's base is flush with the rocket's base; motor CG is computed as `L_rocket − L_motor / 2` |
| **Motor geometry** | The motor is modeled as a **hollow cylinder** with outer radius `R_out` and inner radius `R_in` |
| **Axial symmetry** | The rocket is assumed axially symmetric (`Ixx = Iyy`) |
| **Inertia tensor** | The diagonal tensor `diag([Ixx, Iyy, Izz])` is used; off-diagonal terms are assumed zero |

---

## ❗ Troubleshooting

| Warning / Error | Cause | Fix |
|---|---|---|
| `⚠ Validation error: M_total must be > 0` | A required field has an invalid value | Enter a positive value for the flagged field |
| `⚠ M_motor_dry must be < M_total` | Motor casing mass exceeds total rocket mass | Check `M_motor_dry` and `M_total` |
| `⚠ M_motor_with_prop must be < M_total` | Motor mass with propellant exceeds total rocket mass | Check `M_motor_with_prop` and `M_total` |
| `⚠ R_in must be >= 0 and < R_out` | Inner radius is out of range | Ensure `0 ≤ R_in < R_out` |
| `⚠ L_rocket must be >= L_motor` | Motor is longer than the rocket | Check `L_motor` and `L_rocket` |
| `⚠ I_rocket_noMotor is not positive-definite` | Resulting inertia tensor has non-positive eigenvalues | Verify that `I_total` is referenced to `cg_total` and that all CG positions are consistent |
| `⚠ Reconstruction check: relative error > 1e-10` | Computed result may be inaccurate | Verify that `cg_noMotor` and `cg_total` are consistent with `I_total` |

---

## 🔄 Typical Workflow with OpenRocket

1. **Design** your rocket in OpenRocket and run a simulation.
2. From the component analysis, note `M_total`, `cg_total`, `L_rocket`, and the diagonal moments of inertia (`Ixx`, `Iyy`, `Izz`).
3. **Remove the motor** in OpenRocket to obtain `cg_noMotor`.
4. From your **motor's datasheet**, fill in `M_motor_dry`, `M_motor_with_prop`, `L_motor`, `R_out`, and `R_in`.
5. **Launch the app** and click **Calculate** → the airframe's inertia properties are displayed instantly.

---

## 📄 License

**All rights reserved.**

This code is the exclusive property of the development team. Any reproduction, distribution, modification, or use of this code — in whole or in part — without explicit prior written consent from the team is strictly forbidden.

If you wish to use this code for your own projects, you **must** request permission first by contacting the repository owner.
