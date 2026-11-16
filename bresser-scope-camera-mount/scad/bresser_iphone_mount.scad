// Bresser 20-60x scope -> iPhone 15 Pro in Spigen Mag Armor case (afocal, telephoto lens)
// Part A : short single-piece snug fit on the serrated ring, with a snap rib
// Part B : (1) C-shaped snap ring that hooks over part A from below and turns on friction
//          (2) phone plate: camera-lip seat + window, MagSafe steel-ring pedestal, ledge
//          joined with 2x M3 x 8 self-tapping screws
// Datum: z = 0 at the FRONT FACE OF THE SERRATED RING (stop seat), +z toward the phone.
// Phone data: Apple "iPhone 15 Pro Dimensional Drawings" (rear view, origin = top-left corner).
// Assembly x/y: y up (phone top), viewed from the scope side +x is to the left.

/* [Part selection] */
part = "assembly"; // [assembly, plate, part_a, b_ring, b_plate, test_window]

/* [Eyepiece - measured] */
ring_d          = 42.7; // serrated ring OD
ring_h          = 16;   // serrated ring height
stop_d          = 39.5; // hard band in front of the ring (stop seat)
stop_h          = 6;
lens_from_stop  = 3.5;  // eye lens centre above the ring's front face
cup_od          = 43.5; // soft eyecup max OD (clearance only)
rim_above_lens  = 6;    // reference model only

/* [Optics] */
eye_relief      = 15;   // eye lens -> telephoto entrance pupil (exit pupil of the eyepiece)
tele_pupil      = 3.51; // telephoto pupil behind its cover glass (Apple keep-out cone apex)
lens_below_lip  = 0.3;  // telephoto glass below the case camera lip

/* [Case - measured] */
case_l   = 150.6;  // case outer length
case_w   = 76.7;   // case outer width
case_t   = 11.5;   // phone + case thickness away from the camera
lip_h    = 1.5;    // camera lip above the case back
open_w   = 40.8;   // camera opening, width in portrait
open_h   = 42.3;   // camera opening, height in portrait
lip_wall = 1.5;    // wall thickness of the camera lip (estimate - pedestal keeps clear of it)

/* [Magnet ring (Baseus Halo)] */
mring_od  = 55;
mring_t   = 0.4;
mring_gap = 0.15;  // ring face this much short of the case back (phone always seats on the lip)

/* [Fit and print] */
wall        = 3;
cup_clear   = 0.6;
stop_clear  = 0.6;
ring_clear  = 0.1;   // part A clamp bore clearance (diametral)
rib_h       = 0.45;  // part A crush ribs
n_fingers   = 8;
slit_w      = 1.2;
b_interf    = 0.2;   // snap ring on part A, diametral interference (sets rotation friction)
b_gap       = 120;   // snap ring opening (at the bottom), degrees
b_len       = 16;    // snap ring axial length (wider = resists the phone's prying moment)
b_wall      = 4;     // snap ring wall thickness
b_relief    = 0.3;   // extra bore clearance where the ring passes over part A's flexure fingers
a_gap       = 0.15;  // part A front end to plate back face (plate bears on A if it tips)
snap_h      = 0.8;   // snap rib height on part A
plate_t     = 4;
win_clear   = 0.3;   // window clearance inside the camera lip, per side
ledge_t     = 4;
ledge_depth = 8.5;   // ledge reach under the case edge (beyond the lip height)
port_gap    = 16;    // gap in the ledge for the USB-C plug

/* [Hardware] */
m3_clear = 3.4;
m3_head  = 6.2;
m3_pilot = 2.5;      // M3 self-tapping into the plate

/* [Hidden] */
$fn = 128;
// Apple drawing (rear view coords, mm)
phone_w = 70.6; phone_l = 146.6;
tele  = [32.16, 23.79];
uwide = [14.17, 14.17];
mainc = [14.17, 33.41];
lens_d = 16.20;
msafe = [35.30, 74.98];
open_c = [ (14.17-8.1 + 32.16+8.1)/2, (14.17-8.1 + 33.41+8.1)/2 ]; // opening centred on the lens group
port_x = 35.30;                                                     // USB-C centre
function A(p) = [-(p[0]-tele[0]), -(p[1]-tele[1])];                 // Apple rear coords -> assembly x,y
case_top = tele[1] + (case_l-phone_l)/2;
case_bot = tele[1] - phone_l - (case_l-phone_l)/2;
case_xl  = A([-(case_w-phone_w)/2, 0])[0];
case_xr  = A([phone_w + (case_w-phone_w)/2, 0])[0];

// Axial stations
z_lens = lens_from_stop;
z_P    = z_lens + eye_relief - tele_pupil - lens_below_lip;  // plate front face = camera-lip seat
z_pb   = z_P - plate_t;                                      // plate back face
z_aend = z_pb - a_gap;                                       // part A front end
z_a0   = -ring_h;
z_s1   = z_pb - 0.5;                                         // snap ring front face
z_s0   = z_s1 - b_len;                                       // snap ring back face (print bed)
z_rib  = z_s1 - 4;                                           // snap rib stays on A's solid front zone

r_ring     = ring_d/2;
r_stop     = (stop_d + stop_clear)/2;
r_tube_in  = cup_od/2 + cup_clear;
r_tube_out = max(r_tube_in, r_ring) + wall;
r_bore     = r_ring + ring_clear/2;
slit_top   = ring_h + 1;          // fingers only over the clamp zone; front of A stays solid
r_bi       = r_tube_out - b_interf/2;
r_bo       = r_bi + b_wall;
z_fing     = z_a0 + slit_top + slit_w/2;   // end of part A's flexure slits

assert(z_rib - snap_h - 1 > z_fing, "Snap rib would sit on the flexure fingers");
assert(z_s0 > z_a0 + 1, "Snap ring runs off the rear of part A");
assert(z_aend > stop_h + 2, "Part A too short for the stop zone");
echo(str("Eye lens -> telephoto glass: ", z_P + lens_below_lip - z_lens, " mm; part A height ", z_aend - z_a0, " mm"));
echo("Hardware: 2x M3 x 8 self-tapping (snap ring -> plate); Baseus Halo ring in the pedestal recess");

// ---------------- helpers (no-support geometry) ----------------
module roofed_slot(r0, len_r, w, z_bot, z_top) {
  translate([r0, -w/2, z_bot]) cube([len_r, w, z_top - z_bot]);
  translate([r0, 0, z_top]) rotate([45,0,0]) translate([0,-w/(2*sqrt(2)),-w/(2*sqrt(2))])
    cube([len_r, w/sqrt(2), w/sqrt(2)]);
}
module a_bore(r_clamp) {
  translate([0,0,z_a0-1]) cylinder(r=r_clamp, h=ring_h+1);
  translate([0,0,z_a0-0.01]) cylinder(r1=r_clamp+0.8, r2=r_clamp, h=1.2);
  translate([0,0,-0.01]) cylinder(r1=r_clamp+0.01, r2=r_stop, h=r_clamp-r_stop+0.02);
  cylinder(r=r_stop, h=stop_h+0.01);
  translate([0,0,stop_h]) cylinder(r1=r_stop, r2=r_tube_in, h=r_tube_in-r_stop+0.01);
  translate([0,0,stop_h+r_tube_in-r_stop]) cylinder(r=r_tube_in, h=z_aend);
}
module rrect(w, h, r, t) linear_extrude(t) offset(r) square([w-2*r, h-2*r], center=true);
// snap profile (45 deg flanks): rib on A, matching groove (+0.15) in the snap ring
module snap_rib() rotate_extrude() polygon([
  [r_tube_out-0.01, z_rib-snap_h-0.4], [r_tube_out+snap_h, z_rib-0.4],
  [r_tube_out+snap_h, z_rib+0.4], [r_tube_out-0.01, z_rib+snap_h+0.4]]);
module snap_groove() let(gr = r_tube_out + snap_h + 0.15, d = gr - (r_bi - 1)) rotate_extrude() polygon([
  [r_bi-1, z_rib-0.55-d], [gr, z_rib-0.55], [gr, z_rib+0.55], [r_bi-1, z_rib+0.55+d]]);

// ---------------- Part A ----------------
module part_a() {
  difference() {
    union() {
      difference() {
        translate([0,0,z_a0]) cylinder(r=r_tube_out, h=z_aend-z_a0);
        a_bore(r_bore);
      }
      for (i=[0:2*n_fingers-1]) rotate([0,0,(i+0.5)*180/n_fingers])
        intersection() {
          hull() {
            translate([r_bore+0.6-rib_h, 0, z_a0+3]) cylinder(r=0.6, h=ring_h-3.5, $fn=16);
            translate([r_bore+0.6, 0, z_a0]) cylinder(r=0.6, h=0.1, $fn=16);
          }
          translate([0,0,z_a0]) cylinder(r=r_tube_out, h=ring_h-0.5);
        }
      snap_rib();
    }
    for (i=[0:n_fingers-1]) rotate([0,0,i*360/n_fingers])
      roofed_slot(r_stop-2, r_tube_out-r_stop+3, slit_w, z_a0-1, z_a0+slit_top);
  }
}

// ---------------- Part B (1): snap ring ----------------
cb_depth  = (z_pb - z_s0) - 4.5;          // counterbore so an M3 x 8 bites ~3.5 mm into the plate
screw_pts = [[-4.5, 31], [4.5, 31]];       // same holes as the first plate print
module b_ring() {
  difference() {
    union() {
      rotate([0,0,270+b_gap/2]) rotate_extrude(angle=360-b_gap)
        translate([r_bi, z_s0]) square([r_bo-r_bi, b_len]);
      for (a=[270+b_gap/2, 270-b_gap/2]) rotate([0,0,a]) translate([(r_bi+r_bo)/2, 0, z_s0])
        cylinder(d=r_bo-r_bi, h=b_len, $fn=24);
      // mounting block on top; its front face sits flat on the plate's back face
      translate([-9, r_bi+1, z_s0]) cube([18, r_bo + 6 - (r_bi+1), z_pb - z_s0]);
    }
    translate([0,0,z_s0-1]) cylinder(r=r_bi, h=b_len+2);
    translate([0,0,z_s0-1]) cylinder(r=r_bi+b_relief, h=z_fing + 1 - (z_s0-1));   // relief over the fingers
    translate([0,0,z_fing+1-0.01]) cylinder(r1=r_bi+b_relief, r2=r_bi, h=b_relief+0.01); // 45 deg step
    snap_groove();
    // M3 x 8: counterbore from the back (bed side), 45 deg step, clearance through
    for (p=screw_pts) translate([p[0], p[1], 0]) {
      translate([0,0,z_s0-0.01]) cylinder(d=m3_head, h=cb_depth, $fn=32);
      translate([0,0,z_s0+cb_depth-0.02]) cylinder(d1=m3_head, d2=m3_clear, h=(m3_head-m3_clear)/2, $fn=32);
      translate([0,0,z_s0]) cylinder(d=m3_clear, h=20, $fn=24);
    }
  }
}

// ---------------- Part B (2): phone plate ----------------
ms  = A(msafe);
oc  = A(open_c);
pxl = A([port_x,0])[0];
px0 = -38; px1 = 32; py1 = 36;
py0 = case_bot - 0.3 - ledge_t;
ped_r = mring_od/2 + 2;   // keeps the pedestal clear of the window
module b_plate() {
  difference() {
    union() {
      translate([(px0+px1)/2, (py0+py1)/2, z_pb]) rrect(px1-px0, py1-py0, 6, plate_t);
      // MagSafe pedestal: top of the steel ring ends mring_gap short of the case back
      translate([ms[0], ms[1], z_P-0.01]) cylinder(r=ped_r, h=lip_h - mring_gap + 0.01);
      // ledge under the case bottom edge, with a gap for the USB-C plug
      for (seg=[[px0+6, pxl-port_gap/2], [pxl+port_gap/2, px1-6]])
        translate([seg[0], py0, z_P-0.01]) cube([seg[1]-seg[0], ledge_t, lip_h + ledge_depth]);
    }
    // keep the pedestal clear of the outside of the camera lip
    translate([oc[0], oc[1], z_P]) rrect(open_w + 2*(lip_wall+0.6), open_h + 2*(lip_wall+0.6), 5, 5);
    // window inside the camera lip
    translate([oc[0], oc[1], z_pb-1]) rrect(open_w + 2*win_clear, open_h + 2*win_clear, 4, plate_t+2);
    // steel-ring recess + fingernail notch
    translate([ms[0], ms[1], z_P + lip_h - mring_gap - mring_t]) cylinder(d=mring_od+0.4, h=2);
    translate([ms[0], ms[1], z_P + lip_h - mring_gap - mring_t]) rotate([0,0,-45])
      translate([mring_od/2-2, -3, 0]) cube([6, 6, 2]);
    // blind M3 pilots from the back face (bed side), pointed ends
    for (p=screw_pts) translate([p[0], p[1], z_pb-0.01]) {
      cylinder(d=m3_pilot, h=plate_t-1.2, $fn=24);
      translate([0,0,plate_t-1.2-0.01]) cylinder(d1=m3_pilot, d2=0.1, h=m3_pilot/2, $fn=24);
    }
  }
}

// ---------------- Reference models ----------------
module eyepiece_dummy() color("gray", 0.35) {
  translate([0,0,z_a0-15]) cylinder(d=ring_d, h=ring_h+15);
  cylinder(d=stop_d, h=stop_h);
  translate([0,0,stop_h]) difference() {
    cylinder(d=cup_od, h=z_lens + rim_above_lens - stop_h);
    translate([0,0,-1]) cylinder(d=cup_od-6, h=50);
  }
  translate([0,0,z_lens]) cylinder(d=17, h=0.5);
}
module phone_dummy() {
  color("dimgray", 0.9) translate([(case_xl+case_xr)/2, (case_top+case_bot)/2, z_P+lip_h])
    rrect(abs(case_xr-case_xl), case_top-case_bot, 9, case_t);
  color("black") translate([oc[0], oc[1], z_P]) difference() {         // camera lip
    rrect(open_w+2*lip_wall, open_h+2*lip_wall, 5, lip_h); translate([0,0,-1]) rrect(open_w, open_h, 4, lip_h+2);
  }
  for (p=[uwide, mainc, tele]) color(p==tele ? "orange" : "slategray")
    translate([A(p)[0], A(p)[1], z_P+lens_below_lip]) cylinder(d=lens_d, h=lip_h);
  color("silver") translate([ms[0], ms[1], z_P+lip_h-mring_gap-mring_t]) difference() {
    cylinder(d=mring_od, h=mring_t); translate([0,0,-1]) cylinder(d=mring_od-10, h=2);
  }
}

module place_a()     translate([0,0,-z_a0]) part_a();
module place_ring()  translate([0,0,-z_s0]) b_ring();
module place_plate() translate([0,0,-z_pb]) b_plate();

if (part == "assembly") {
  eyepiece_dummy();
  color("teal") part_a();
  color("mediumpurple") b_ring();
  color("plum") b_plate();
  phone_dummy();
}
else if (part == "part_a")  place_a();
else if (part == "b_ring")  place_ring();
else if (part == "b_plate") place_plate();
else if (part == "test_window") intersection() {
  place_plate();
  translate([oc[0], oc[1], -1]) rrect(open_w + 16, open_h + 16, 6, 20);
}
else if (part == "plate") {
  translate([-105, 0, 0]) place_a();
  translate([-105, -75, 0]) place_ring();
  translate([10, 40, 0]) place_plate();
}
