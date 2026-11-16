// Bresser 20-60x scope -> Raspberry Pi Camera Module 3 afocal mount
// Part A: single-piece snug fit (flexure fingers, crush ribs, stop seat)
// Part B: rotating camera carrier, locked by an M3 bolt + printed thumb knob in a groove on part A
// Pi bracket: C-clip on part A keyed to part B, with a tray for a Raspberry Pi Zero W
// Datum: z = 0 at the FRONT FACE OF THE SERRATED RING (the stop seat), +z toward the camera.
// Camera data: Raspberry Pi "camera-module-3-standard-mechanical-drawing.pdf"

/* [Part selection] */
part = "assembly"; // [assembly, plate, part_a, part_b, knob, pi_bracket, shims]

/* [Eyepiece - measured] */
ring_d          = 42.7; // serrated ring OD
ring_h          = 16;   // serrated ring height (axial)
stop_d          = 39.5; // hard band in front of the ring (stop seat)
stop_h          = 6;    // height of that hard band
lens_from_stop  = 3.5;  // eye lens centre above the ring's front face (verify, see echo)
cup_od          = 43.5; // max OD of soft eyecup (clearance only)
rim_above_lens  = 6;    // eyecup rim above the eye lens (reference model only)

/* [Optics] */
eye_relief  = 15;   // eye lens -> camera lens tip (aim for the exit pupil)

/* [Fit and print] */
wall         = 3;
rot_clear    = 0.15; // radial clearance of the rotary joint (part B on part A)
cup_clear    = 0.6;  // radial clearance over the eyecup
stop_clear   = 0.6;  // diametral clearance of the stop bore on the hard band
journal_len  = 10;
groove_depth = 1.2;
groove_w     = 4.6;  // wide enough for an M3 tip at the groove bottom
back_wall    = 2.5;

/* [Pi Zero bracket] */
clip_w = 24; // clip ring width on part A

/* [Snug fit] */
ring_clear   = 0.1;  // diametral clearance of the clamp bore itself
rib_h        = 0.45; // crush-rib height into the bore (sets the grip)
n_fingers    = 8;    // flexure fingers
slit_w       = 1.2;
finger_extra = 4;    // slits run past the stop zone by this much (longer = softer)

/* [Hardware] */
m3_clear  = 3.4;
m3_nut_af = 5.6;  // nut across flats + clearance
m3_nut_t  = 2.7;
m3_head_d = 6.2;
m2_pilot  = 1.8;  // M2 self-tapping into camera standoffs
cam_screw_len = 10; // camera screw length (M2 x 10 from a standard set)
shim_t    = [0.5, 1, 2];
ribbon_w      = 16.8; // 15-pin camera ribbon is 16 mm wide
ribbon_slot_h  = 1.4;  // slot height (ribbon is 0.3 mm thick, 0.6 folded)
ribbon_off     = 2;    // slot starts this far below the PCB bottom edge

/* [Thumb knob] */
knob_d      = 14;
knob_h      = 8;
knob_pocket = "round"; // [round, hex]  round = M3 socket head (ISO 4762) + glue, hex = hex head (DIN 933)

/* [Pi Zero bracket] */
clip_interf = 0.3;   // diametral interference of the clip on part A
clip_gap    = 120;   // opening of the C-clip, degrees
plate_gap   = 2.9;   // tray plate to part B clearance
plate_t     = 3;
plate_w     = 44;
pi_standoff = 3;
pi_pilot    = 2.2;   // M2.6 self-tapping (Pi holes are 2.75)
pi_margin   = 2;     // clip front face to Pi connector edge
tongue_len  = 5;     // part B boss tongue length into the clip's lock notch
stoprib_w   = 2;     // stop rib on part A behind the clip
stoprib_h   = 1.5;

/* [Hidden] */
$fn = 128;
// Raspberry Pi Zero W v1.1 (official mechanical drawing): 65 x 30, M2.5 holes 3.5 from edges
pi_l = 65; pi_w = 30; pi_t = 1.4;
pi_holes = [[3.5,3.5],[61.5,3.5],[3.5,26.5],[61.5,26.5]];
// Camera Module 3 (lens-centred coordinates: lens axis at x=0,y=0)
pcb_w = 25; pcb_h = 23.862; pcb_t = 1.12;
lens_y_from_bottom = 14.4;
tip_from_pcb  = 6.98;
housing       = 10.8;
back_comp     = 3.2;
holes = [[-10.5, 14.5-14.4], [10.5, 14.5-14.4], [-10.5, 2-14.4], [10.5, 2-14.4]];
pcb_y0 = -lens_y_from_bottom;
standoff_d = 4.5;
standoff_h = max(back_comp + 1.3, cam_screw_len - pcb_t + 1 - back_wall); // deep enough for the camera screws

// Derived axial stations
z_lens      = lens_from_stop;
z_tip       = z_lens + eye_relief;
z_pcb_front = z_tip + tip_from_pcb;
z_pcb_back  = z_pcb_front + pcb_t;
z_bw        = z_pcb_back + standoff_h;      // inner face of B back wall
z_aend      = z_pcb_front - 1.5;            // front end of part A
z_j0        = z_aend - journal_len;
z_groove    = z_aend - journal_len/2;
z_a0        = -ring_h;                      // rear end of A = rear edge of the ring

r_ring     = ring_d/2;
r_stop     = (stop_d + stop_clear)/2;
r_tube_in  = cup_od/2 + cup_clear;
r_tube_out = max(r_tube_in, r_ring) + wall;
r_sleeve   = r_tube_out + rot_clear;
r_b_out    = r_sleeve + wall;
r_chamber  = r_tube_in;

assert(r_stop < r_ring, "Stop band must be smaller than the serrated ring");
assert(r_chamber > 20, "Chamber too small for the camera PCB");
assert(z_j0 > stop_h, "Eye relief too short: journal overlaps the stop zone");
echo(str("Expected depth from part A top rim to eye lens centre: ", z_aend - z_lens, " mm"));
echo(str("Part A height: ", z_aend - z_a0, " mm"));

// ---------------- Print helpers (no-support geometry) ----------------
module groove_cut(r_out, zc) rotate_extrude($fn=$fn) polygon([
  [r_out - groove_depth, zc - groove_w/2], [r_out + 1, zc - groove_w/2],
  [r_out + 1, zc + groove_w/2 + 1], [r_out - groove_depth, zc + groove_w/2 - groove_depth]]);
module roofed_slot(r0, len_r, w, z_bot, z_top) {
  translate([r0, -w/2, z_bot]) cube([len_r, w, z_top - z_bot]);
  translate([r0, 0, z_top]) rotate([45,0,0]) translate([0,-w/(2*sqrt(2)),-w/(2*sqrt(2))])
    cube([len_r, w/sqrt(2), w/sqrt(2)]);
}
module teardrop2d(d) { circle(d=d, $fn=24); rotate(45) square(d/2); }

// Inner bore of part A (shared): clamp zone, 45 deg stop cone, stop bore, eyecup clearance.
// Every step is a 45 deg cone so nothing overhangs with the rear end on the bed.
module a_bore(r_clamp) {
  translate([0,0,z_a0-1]) cylinder(r=r_clamp, h=ring_h+1);
  translate([0,0,z_a0-0.01]) cylinder(r1=r_clamp+0.8, r2=r_clamp, h=1.2);   // lead-in
  translate([0,0,-0.01]) cylinder(r1=r_clamp+0.01, r2=r_stop, h=r_clamp-r_stop+0.02); // stop seat
  cylinder(r=r_stop, h=stop_h+0.01);
  translate([0,0,stop_h]) cylinder(r1=r_stop, r2=r_tube_in, h=r_tube_in-r_stop+0.01);
  translate([0,0,stop_h+r_tube_in-r_stop]) cylinder(r=r_tube_in, h=z_aend);
}

// ---------------- Part B ----------------
boss_top = r_b_out + 5;
module b_body() {
  difference() {
    union() {
      translate([0,0,z_j0]) cylinder(r=r_b_out, h=z_bw + back_wall - z_j0);
      // thumbscrew boss (+y): grows from the back wall (bed) and runs past B's front edge
      // as a key tongue that sits in the Pi clip's lock notch
      translate([-5, r_b_out-2, z_j0 - tongue_len])
        cube([10, boss_top - r_b_out + 2, z_bw + back_wall - z_j0 + tongue_len]);
      for (h=holes) translate([h[0], h[1], z_pcb_back]) cylinder(d=standoff_d, h=standoff_h + 0.01, $fn=32);
    }
    translate([0,0,z_j0-1]) cylinder(r=r_sleeve, h=z_aend + rot_clear - z_j0 + 1);
    translate([0,0,z_j0]) difference() {
      cylinder(r=r_chamber, h=z_bw - z_j0);
      for (h=holes) translate([h[0], h[1], z_pcb_back - z_j0]) cylinder(d=standoff_d, h=standoff_h + 1, $fn=32);
    }
    // ribbon slot through back wall (narrow, to keep stray light out)
    translate([-ribbon_w/2, pcb_y0 - ribbon_off - ribbon_slot_h, z_bw - 1]) cube([ribbon_w, ribbon_slot_h, back_wall + 2]);
    // thumbscrew hole (teardrop points up when printed) + captive nut slot, open at the tongue end
    translate([0, r_sleeve-1, z_groove]) rotate([-90,0,0]) linear_extrude(12) teardrop2d(m3_clear);
    translate([-m3_nut_af/2, r_b_out + 1, z_j0 - tongue_len - 1])
      cube([m3_nut_af, m3_nut_t, z_groove - z_j0 + tongue_len + 1 + m3_nut_af/2]);
    // blind camera pilot holes, 0.6 mm skin on the outside of the back wall
    for (h=holes) translate([h[0], h[1], z_pcb_back - 1])
      cylinder(d=m2_pilot, h=1 + standoff_h + back_wall - 0.6, $fn=16);
  }
}

module shims() {
  for (i=[0:len(shim_t)-1], j=[0:3]) translate([i*7, j*7, 0]) difference() {
    cylinder(d=standoff_d, h=shim_t[i], $fn=32);
    translate([0,0,-1]) cylinder(d=2.4, h=5, $fn=16);
  }
}

// ---------------- Reference models ----------------
module camera_dummy() {
  color("green") translate([-pcb_w/2, pcb_y0, z_pcb_front]) cube([pcb_w, pcb_h, pcb_t]);
  color("dimgray") translate([-housing/2, -housing/2, z_pcb_front - 3.875]) cube([housing, housing, 3.875]);
  color("black") translate([0,0,z_tip]) cylinder(d=5.75, h=tip_from_pcb - 3.875);
}
module eyepiece_dummy() {
  color("gray", 0.35) {
    translate([0,0,z_a0-15]) cylinder(d=ring_d, h=ring_h+15);           // ring + body
    cylinder(d=stop_d, h=stop_h);                                       // hard band
    translate([0,0,stop_h]) difference() {                              // soft eyecup
      cylinder(d=cup_od, h=z_lens + rim_above_lens - stop_h);
      translate([0,0,-1]) cylinder(d=cup_od-6, h=50);
    }
    translate([0,0,z_lens]) cylinder(d=17, h=0.5);                      // eye lens
  }
}
module place_b_for_print() translate([0,0,z_bw + back_wall]) mirror([0,0,1]) b_body();

// ---------------- Thumb knob (cap over the M3 head) ----------------
head_h = knob_pocket=="hex" ? 2.2 : 3.2;
head_r = knob_pocket=="hex" ? 5.6/2/cos(30) : 5.7/2;
groove_bottom = r_tube_out - groove_depth;
screw_need = boss_top - groove_bottom + 0.4;       // head clears the boss by >= 0.4 mm when locked
screw_len  = [for (L=[6,8,10,12,16,20]) if (L >= screw_need) L][0];
knob_gap   = screw_len - (boss_top - groove_bottom);
echo(str("Thumbscrew: M3 x ", screw_len, " ", knob_pocket=="hex" ? "hex head (DIN 933)" : "socket head (ISO 4762)",
         " + M3 nut; knob sits ", knob_gap, " mm above the boss when locked"));
module knob() {
  difference() {
    union() {
      cylinder(d=knob_d-1.6, h=knob_h, $fn=64);
      for (a=[0:20:359]) rotate([0,0,a]) translate([knob_d/2-0.8,0,0]) cylinder(d=1.6, h=knob_h, $fn=12);
    }
    // head pocket opens on the bed face; 45 deg conical roof so nothing overhangs
    translate([0,0,-0.01]) cylinder(r=head_r, h=head_h, $fn=knob_pocket=="hex" ? 6 : 32);
    translate([0,0,head_h-0.02]) cylinder(r1=head_r, r2=0.1, h=head_r, $fn=knob_pocket=="hex" ? 6 : 32);
    translate([0,0,knob_h-0.6]) cylinder(r1=knob_d/2-1.4, r2=knob_d/2+0.2, h=1.61, $fn=64); // top chamfer
  }
}
assert(knob_h >= head_h + head_r + 1, "knob_h too small for the head pocket");

// ---------------- Pi Zero bracket (clip ring + tray, one piece) ----------------
// The tray points back toward the scope. Printed with the clip's FRONT face on the bed.
clip_r_in  = r_tube_out - clip_interf/2;
clip_r_out = r_b_out + 1.5;
z_c1       = z_j0 - 0.3;               // clip front face (print bed), just short of part B
z_c0       = z_c1 - clip_w;            // clip rear face, held by the stop rib on part A
d_p        = r_b_out + plate_gap;      // tray plate inner face distance below the axis
pi_z1      = z_c1 - pi_margin;         // Pi camera-connector edge (faces part B)
pi_z0      = pi_z1 - pi_l;
plate_len  = pi_margin + pi_l + 1;
y_pi       = -(d_p + plate_t + pi_standoff);   // Pi board back face
assert(z_c0 - stoprib_w - stoprib_h >= z_a0, "Clip and stop rib run off the rear of part A: reduce clip_w");
echo(str("Ribbon: about ", round(2*(z_bw + back_wall - pi_z1) + (-pcb_y0 - y_pi) + 25),
         " mm needed (15-pin to 22-pin Pi Zero cable)"));
echo(str("Board screws: camera 4x M2 x ", cam_screw_len, ", Pi Zero 4x M2.6 x 6 (self-tapping, pan/round head)"));

// Stop rib on part A, behind the clip; 45 deg underside (part A prints rear end down)
module stop_rib() rotate_extrude($fn=$fn) polygon([
  [r_tube_out-0.01, z_c0 - 0.2 - stoprib_w - stoprib_h], [r_tube_out + stoprib_h, z_c0 - 0.2 - stoprib_w],
  [r_tube_out + stoprib_h, z_c0 - 0.2], [r_tube_out-0.01, z_c0 - 0.2]]);

// Standoff growing out of the vertical plate along -y. Print "down" is +z here, so the
// teardrop point and the 45 deg corbel root face +z; the pilot hole's point faces -z.
module boss_y(len, d) mirror([0,0,1]) hull() {
  rotate([90,0,0]) linear_extrude(len) circle(d=d, $fn=32);
  rotate([90,0,0]) linear_extrude(0.01) translate([0,-len]) rotate(180) teardrop2d(d);
}
module hole_y(len, d) mirror([0,0,1]) rotate([90,0,0]) linear_extrude(len) teardrop2d(d);
module slot_y(x, z0, z1, w) translate([x, 0, 0]) rotate([90,0,0]) linear_extrude(200, center=true)
  polygon([[-w/2,z1],[w/2,z1],[w/2,z0],[0,z0-w/2],[-w/2,z0]]);   // pointed end toward -z (print up)

module pi_bracket() {
  difference() {
    union() {
      // C-clip, gap centred on +x
      rotate([0,0,clip_gap/2]) rotate_extrude(angle=360-clip_gap)
        translate([clip_r_in, z_c0]) square([clip_r_out-clip_r_in, clip_w]);
      for (a=[clip_gap/2, -clip_gap/2]) rotate([0,0,a]) translate([(clip_r_in+clip_r_out)/2, 0, z_c0])
        cylinder(d=clip_r_out-clip_r_in, h=clip_w, $fn=24);
      // web to tray plate
      translate([-12, -d_p-0.01, z_c0]) cube([24, d_p - clip_r_in - 1.5, clip_w]);
      // tray plate, reaching back toward the scope (vertical when printed)
      translate([-plate_w/2, -d_p-plate_t, z_c1 - plate_len]) cube([plate_w, plate_t, plate_len]);
      // Pi standoffs (roots trimmed at the bed)
      for (h=pi_holes) intersection() {
        translate([h[1]-pi_w/2, -d_p-plate_t+0.01, pi_z0+h[0]]) boss_y(pi_standoff+0.01, 5.5);
        translate([-100,-100,z_c1-200]) cube([200,200,200]);
      }
    }
    translate([0,0,z_c0-1]) cylinder(r=clip_r_in, h=clip_w+2);
    // lock notch for part B's boss tongue, open at the front face, pointed 45 deg roof
    translate([0, 0, z_c1 + 1]) rotate([-90,0,0]) linear_extrude(clip_r_out + 2)
      polygon([[-5.25, 0], [5.25, 0], [5.25, tongue_len + 1.5], [0, tongue_len + 1.5 + 5.25], [-5.25, tongue_len + 1.5]]);
    // blind pilot holes, 0.5 mm skin left on the plate's inner face
    for (h=pi_holes) translate([h[1]-pi_w/2, -d_p-0.5, pi_z0+h[0]]) hole_y(pi_standoff+plate_t+1, pi_pilot);
    // tie slots for USB lead (-x side) and ribbon fold (+x side)
    for (sx=[-1,1], zz=[pi_z1-33, pi_z1-49]) slot_y(sx*19, zz, zz+5, 3);
  }
}
module place_bracket_for_print() translate([0,0,z_c1]) mirror([0,0,1]) pi_bracket();
module pi_dummy() {
  color("darkgreen") translate([-pi_w/2, y_pi - pi_t, pi_z0]) cube([pi_w, pi_t, pi_l]);
  color("silver") translate([-8.5, y_pi - pi_t - 1.2, pi_z1 - 5]) cube([17, 1.2, 5]); // camera connector
}

// ---------------- Part A: single-piece snug fit ----------------
r_bore     = r_ring + ring_clear/2;
finger_len = ring_h + stop_h + finger_extra;
module part_a() {
  difference() {
    union() {
      difference() {
        translate([0,0,z_a0]) cylinder(r=r_tube_out, h=z_aend-z_a0);
        a_bore(r_bore);
      }
      // crush ribs over the ring height, two per finger, tapered entry from the bed
      for (i=[0:2*n_fingers-1]) rotate([0,0,(i+0.5)*180/n_fingers])
        intersection() {
          hull() {
            translate([r_bore+0.6-rib_h, 0, z_a0+3]) cylinder(r=0.6, h=ring_h-3.5, $fn=16);
            translate([r_bore+0.6, 0, z_a0]) cylinder(r=0.6, h=0.1, $fn=16);
          }
          translate([0,0,z_a0]) cylinder(r=r_tube_out, h=ring_h-0.5);
        }
      stop_rib();
    }
    // flexure slits through clamp and stop zones, 45 deg roofs
    for (i=[0:n_fingers-1]) rotate([0,0,i*360/n_fingers])
      roofed_slot(r_stop-2, r_tube_out-r_stop+stoprib_h+4, slit_w, z_a0-1, z_a0+finger_len);
    groove_cut(r_tube_out, z_groove + groove_depth/2);
  }
}
module place_a_for_print() translate([0,0,-z_a0]) part_a();

if (part == "assembly") {
  eyepiece_dummy();
  color("teal") part_a();
  color("mediumpurple") b_body();
  camera_dummy();
  color("coral") pi_bracket();
  pi_dummy();
  color("orange") translate([0, boss_top + knob_gap, z_groove]) rotate([-90,0,0]) knob();
}
else if (part == "part_a") place_a_for_print();
else if (part == "part_b") place_b_for_print();
else if (part == "shims")  shims();
else if (part == "knob")   knob();
else if (part == "pi_bracket") place_bracket_for_print();
else if (part == "plate") {
  translate([-75, 40, 0]) place_a_for_print();
  translate([-10, 40, 0]) place_b_for_print();
  translate([ 60, 70, 0]) place_bracket_for_print();
  translate([ 40,-30, 0]) knob();
  translate([-40,-40, 0]) shims();
}
