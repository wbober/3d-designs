// Bike lamp handlebar clamp — two halves, 2x M4x20 + nuts, T-slot for the lamp's T-rail
// PETG, no supports. part="upper"/"lower" exports each half already in print orientation.
// Units: mm. Bar axis = X, lamp slides along Y.

/* [Handlebar] */
bar_d      = 22.2;   // 22.2 / 25.4 / 31.8 / 35
clamp_w    = 18;     // width along the bar
wall       = 4;
split_gap  = 1.5;    // gap between halves so the screws can pull them tight

/* [Screws: M4] */
screw_d    = 4.4;    // clearance hole
head_d     = 8.0;    // counterbore for socket head
nut_af     = 7.2;    // M4 nut across flats + clearance
nut_depth  = 3.5;
ear_h      = 8;      // ear height per half
ear_len    = 5;      // material past the screw centre

/* [T-slot for the lamp's T-rail] */
slot_len   = 30;
slot_open  = 5.5;    // opening between the lips
slot_depth = 2.7;    // calliper: slot bottom to top of lips
lip_h      = 0.8;    // lip thickness (1.0 was too tight on the first print)
slot_w     = 10;     // undercut width
fit        = 0.25;   // clearance, tune after a test print
floor_h    = 1.5;    // material between ring top and the slot bottom

part = "both"; // [upper, lower, both]

$fn = 96;

R  = bar_d/2;
Ro = R + wall;
screw_y   = max(R + 4.5, slot_len/2 + head_d/2 + 0.5);  // keep head counterbores clear of the slot
ear_y     = screw_y + ear_len;
ear_top   = split_gap/2 + ear_h;
slot_z0   = Ro + floor_h;
block_top = slot_z0 + slot_depth + fit;
under_h   = slot_depth - lip_h;

module ears(z0, z1) { translate([-clamp_w/2, -ear_y, z0]) cube([clamp_w, 2*ear_y, z1 - z0]); }
module screw_holes() { for (s = [-1, 1]) translate([0, s*screw_y, -50]) cylinder(d = screw_d, h = 100); }
module bore() { rotate([0, 90, 0]) cylinder(r = R, h = clamp_w + 2, center = true); }
module ring() { rotate([0, 90, 0]) cylinder(r = Ro, h = clamp_w, center = true); }

// prism in the Y-Z plane, extruded across the clamp width
module yz_prism(pts) { rotate([90, 0, 90]) linear_extrude(clamp_w, center = true) polygon(pts); }

module tslot() {
    ow = slot_open + fit;  uw = slot_w + fit;
    translate([-uw/2, -50, slot_z0]) cube([uw, 100, under_h + fit]);
    translate([-ow/2, -50, slot_z0]) cube([ow, 100, 50]);
}

// outer shape shared by both halves (upper as drawn, lower mirrored in Z)
module envelope() {
    intersection() { ring(); translate([-50, -50, split_gap/2]) cube(100); }
    ears(split_gap/2, ear_top);
    translate([-clamp_w/2, -slot_len/2, split_gap/2]) cube([clamp_w, slot_len, block_top - split_gap/2]);
    // 45° gussets between block and ears
    for (m = [0, 1]) mirror([0, m, 0])
        yz_prism([[slot_len/2, ear_top], [ear_y, ear_top], [slot_len/2, ear_top + ear_y - slot_len/2]]);
}

module upper() {
    difference() {
        envelope();
        bore();
        tslot();
        screw_holes();
        for (s = [-1, 1]) translate([0, s*screw_y, ear_top]) cylinder(d = head_d, h = 40);
    }
}

module lower() {
    difference() {
        mirror([0, 0, 1]) envelope();
        bore();
        screw_holes();
        // hex tunnel through the gusset; nut seats nut_depth into the ear.
        // No 30° rotation: a vertex points along X, i.e. up when printed on its side.
        for (s = [-1, 1])
            translate([0, s*screw_y, -ear_top + nut_depth - 50])
                cylinder(d = nut_af/cos(30), h = 50, $fn = 6);
    }
}

if (part == "both") { upper(); lower(); }
// print orientation: upper slot-down; lower ON ITS SIDE (bar axis vertical) so layers follow the arch
if (part == "upper") translate([0, 0, block_top]) rotate([180, 0, 0]) upper();
if (part == "lower") translate([0, 0, clamp_w/2]) rotate([0, 90, 0]) lower();
