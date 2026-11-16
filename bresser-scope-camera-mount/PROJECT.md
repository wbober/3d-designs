# PROJECT.md – handoff for a new session

Owner: Wojciech (prints on Bambu A1, PLA for first prototypes). Working style: **present a plan before changing files**; concise answers; use visual aids/diagrams; keep the Pi version intact when working on the iPhone version.

## 1. Goal
Mount a camera on a **Bresser 20-60x spotting scope** eyepiece:
- **Part A** – fixed to the eyepiece (snug fit on the serrated ring).
- **Part B** – camera carrier that **rotates** relative to Part A (to set camera angle after zooming), lockable.
- Everything must **print without supports** (hard rule).

## 2. Datum and measured eyepiece data
z = 0 at the **front face of the serrated ring** (stop seat); +z toward camera/phone.
- Serrated ring: OD **42.7 mm**, height **16 mm** (user-corrected from 11).
- Hard band above ring: OD **39.5 mm**, height **~6 mm** (used as stop bore, Ø39.5+0.6).
- Soft rubber eyecup: max OD assumed 43.5 – never clamp it.
- Eye lens centre: **3.5 mm above ring front face** (rim-to-lens measured 25.5 mm after subtracting 1 mm ruler); expected Part A rim-to-lens depth ≈ 20.5 mm. Lens Ø17.
- **eye_relief = 15 mm is an ESTIMATE** (distance eye lens → camera entrance pupil). Measure: paper held behind eyepiece, find where the exit-pupil disc is smallest, at 20x and 60x. Adjust `eye_relief`.

## 3. Part A (snug, single piece)
8 flexure fingers (slits with 45° roofs), crush ribs (`rib_h` 0.45), 45° stop-seat cone, stop bore over the hard band, lead-in chamfer. Tightness tuned from print feedback (made tighter once). Parameters: `ring_d, ring_h, stop_d, stop_h, ring_clear, rib_h, n_fingers, slit_w, finger_extra`. Printed fit: user mounted it successfully.

## 4. Pi version (`bresser_picam3_mount.scad`)
- Part B: rotating cup on Part A, M3 thumbscrew lock (M3×10 socket head + nut; printed knob with round or hex pocket), groove 1.2 deep × 4.6 wide.
- Snap-on **Pi bracket/tray** (clip width 24, interference 0.3, gap 120°) goes over Part A below Part B; tongue keys to Part B; stop ribs on outside of fingers keep it from sliding away; tray points **toward the scope**.
- Standoffs: 45° **corbels** with roots clipped at the bed, blind pilot holes with skin (no supports).
- Camera Module 3: 25×23.862 mm, holes ±10.5 (Ø2.2), lens 14.4 mm from bottom edge, 4× M2×10 self-tapping. Pi Zero W v1.1: 65×30, M2.5 holes 58×23 → 4× M2.6×6 self-tapping. Cable: Pi Zero 15-to-22-pin, ≥150 mm (route ≈126 mm).
- Taller camera standoffs shift the lens distance – `eye_relief` accounts for it (check echo output).

## 5. iPhone version (`bresser_iphone_mount.scad`)
- iPhone 15 Pro + Spigen Mag Armor, **telephoto lens** (fills frame better than main; 33° cone, entrance pupil ≈3.51 mm behind cover glass), **portrait** (weight hangs below the axis; lens ~3 mm off CoM line).
- Apple drawing coords (rear view, top-left origin): telephoto (32.16, 23.79), MagSafe centre (35.30, 74.98), phone 70.6×146.6×8.25. Helper `A(p)` maps these to assembly coords (telephoto at origin).
- Case: total thickness phone+case 11.5, camera opening 40.8 w × 42.3 h, lip ~1.5 tall, glass ~0.3 below lip.
- **Part A (short)**, **B ring** (friction snap ring, 16 mm wide, 4 mm wall – widened after the first one was too weak), **B plate** (MagSafe plate with round pedestal; steel ring Ø55×0.4 mm stuck in recess – Baseus Halo, dims assumed). Ring and plate are separate so each prints face-down without supports. Fasteners: 2× M3×8 self-tapping (ring → plate).
- `test_window` is a quick fit test of the camera opening.

## 6. Support-free rules used
45° max overhang; teardrop holes; roofed slots; 45° corbels; blind pilot holes with skin; counterbores with 45° step. Verified by `tools/check_printable.py`: for each 0.2 mm layer, area outside the previous layer buffered 0.22 mm must be ≤1 mm² and mesh watertight. Last run: all STLs OK except the two clamshell halves (expected).

## 7. Hardware
520-piece self-tapping set (M2/M2.3/M2.6/M3; 6,8,10,12,14 mm) covers everything; M3 nut + M3×10 socket head for the Pi knob.

## 8. Open items / unverified
1. `eye_relief` measurement (both versions).
2. `lip_wall` (1.5 est.), Baseus ring size, case back thickness.
3. iPhone wider snap ring (v2) not yet confirmed by user to hold weight.
4. Friction params (`rib_h`, `b_interf`, `clip_interf`) need print tuning.
5. Camera choice: Camera Module 3 chosen; Arducam OV5647 5MP AF was considered but not pursued.

## 9. Design history (dead ends)
- Clamshell Part A → moved to its own file; snug single piece preferred.
- Angle serration removed. lens_from_stop 8.5 → 3.5 after measurements.
- Overhang check was too lenient (missed perpendicular standoff tips) → corbels + layer check.
- Printed bracket via 3-lens/wide lens rejected for iPhone; telephoto chosen.

## 10. Sources (not copied)
- Camera Module 3: https://datasheets.raspberrypi.com/camera/camera-module-3-standard-mechanical-drawing.pdf
- Pi Zero W: https://datasheets.raspberrypi.com/rpizero/raspberry-pi-zero-w-mechanical-drawing.pdf
- iPhone 15 Pro: https://developer.apple.com/download/files/accessories/dimensional-drawings/iphone-15-pro.pdf

## 11. Notes
Pi .scad files were generated from a Python template (not kept); edit the .scad files directly – Part B and bracket code are duplicated in both Pi files, keep them in sync.
