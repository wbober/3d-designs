// Kärcher WD3 (DN35) -> G3/4 male BSPP adapter
// For draining a garden sprinkler line with a wet/dry vacuum.
// Screws INTO the female G3/4 fitting (with its own flat gasket) on the pipe after the tap.
// The vacuum's wand/hose-handle end (Ø35 male) slides into the socket like any WD accessory.
//
// Requires BOSL2: https://github.com/BelfrySCAD/BOSL2
// Print: PETG, thread end DOWN on the bed, 5+ walls, 0.15 mm layers, no supports.

include <BOSL2/std.scad>
include <BOSL2/threading.scad>

/* [Part] */
part = "adapter";          // [adapter, coupon]

/* [Vacuum side - Kärcher DN35] */
kaercher_od      = 35.3;   // measured OD of the wand / hose-handle tip
socket_clear_top = 0.25;   // diametral clearance at the socket mouth
socket_clear_bot = -0.15;  // at the bottom (negative = interference -> wedge fit)
socket_depth     = 40;
socket_wall      = 3;

/* [Pipe side - G3/4 BSPP male] */
g_major      = 26.441;     // G3/4 nominal major diameter
g_pitch      = 25.4 / 14;  // 1.814 mm, 14 TPI
thread_clear = 0.30;       // diametral reduction for FDM fit
thread_len   = 16;         // keep LONGER than the female thread depth so the end face reaches the gasket
bore         = 18;         // through-bore; leaves a flat end face that compresses the gasket

/* [Grip collar] */
collar_d = 46;
collar_h = 10;
ribs     = 12;

$fn = 120;

thread_d   = g_major - thread_clear;
socket_od  = kaercher_od + 2 * socket_wall;
cone_h     = (kaercher_od - bore) / 2;   // 45° inner transition

// Whitworth 55° profile, in units of pitch (BOSL2 generic profile).
// Thread depth h = 0.6403 P; small flats approximate the rounded crest/root.
wh = 0.6403;
wf = 0.0833;
whit_profile = [
    [-0.5,      -wh], [-0.5 + wf, -wh],
    [-wf,        0 ], [ wf,        0 ],
    [ 0.5 - wf, -wh], [ 0.5,      -wh]
];

module g34_thread(len) {
    generic_threaded_rod(d = thread_d, l = len, pitch = g_pitch,
                         profile = whit_profile, bevel1 = 0.6, bevel2 = false,
                         blunt_start = true, anchor = BOTTOM);
}

module collar() {
    // 45° underside so it prints without supports above the thread
    difference() {
        union() {
            cyl(d1 = thread_d - 1, d2 = collar_d, h = (collar_d - thread_d + 1) / 2, anchor = BOTTOM);
            up((collar_d - thread_d + 1) / 2)
                cyl(d = collar_d, h = collar_h, chamfer2 = 1, anchor = BOTTOM);
        }
        // grip flutes
        for (a = [0 : 360 / ribs : 359])
            zrot(a) right(collar_d / 2 + 1.2)
                up((collar_d - thread_d + 1) / 2)
                    cyl(d = 5, h = collar_h + 2, anchor = BOTTOM);
    }
}

module adapter() {
    z_collar = thread_len;
    collar_total = (collar_d - thread_d + 1) / 2 + collar_h;
    z_cone   = z_collar + collar_total;
    z_socket = z_cone + cone_h;
    total_h  = z_socket + socket_depth;

    difference() {
        union() {
            g34_thread(thread_len + 0.5);
            up(z_collar) collar();
            up(z_cone - 0.01)
                cyl(d = socket_od, h = total_h - z_cone, anchor = BOTTOM);
        }
        // through-bore
        down(1) cyl(d = bore, h = z_cone + 2, anchor = BOTTOM);
        // 45° inner transition bore -> socket
        up(z_cone) cyl(d1 = bore, d2 = kaercher_od, h = cone_h + 0.01, anchor = BOTTOM);
        // tapered friction socket
        up(z_socket)
            cyl(d1 = kaercher_od + socket_clear_bot, d2 = kaercher_od + socket_clear_top,
                h = socket_depth + 0.01, anchor = BOTTOM);
        // lead-in chamfer at the mouth
        up(total_h - 1.5)
            cyl(d1 = kaercher_od + socket_clear_top, d2 = kaercher_od + 2.5, h = 1.51, anchor = BOTTOM);
    }
}

// Quick fit test: 8 mm of thread + a 10 mm socket ring, ~20 min print
module coupon() {
    difference() {
        g34_thread(8);
        down(1) cyl(d = bore, h = 10, anchor = BOTTOM);
    }
    right(45) difference() {
        cyl(d = socket_od, h = 10, anchor = BOTTOM);
        down(0.01) cyl(d1 = kaercher_od + socket_clear_bot, d2 = kaercher_od + socket_clear_top,
                       h = 10.02, anchor = BOTTOM);
    }
}

if (part == "adapter") adapter();
else coupon();
