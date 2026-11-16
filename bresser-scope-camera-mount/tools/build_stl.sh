#!/usr/bin/env bash
# Regenerate all STLs from the OpenSCAD sources (needs openscad; xvfb-run if headless).
set -e; cd "$(dirname "$0")/.."
OS="openscad"; command -v xvfb-run >/dev/null && OS="xvfb-run -a openscad"
r(){ $OS -o "stl/$1.stl" -D "part=\"$2\"" "scad/$3.scad"; }
P=bresser_picam3_mount; C=bresser_picam3_mount_clamshell; I=bresser_iphone_mount
r part_a_snug part_a $P; r part_b part_b $P; r knob knob $P; r pi_bracket pi_bracket $P; r shims shims $P
r clamshell_part_a_upper part_a_upper $C; r clamshell_part_a_lower part_a_lower $C; r clamshell_pi_bracket pi_bracket $C
r iphone_part_a part_a $I; r iphone_b_ring b_ring $I; r iphone_b_plate b_plate $I; r iphone_test_window test_window $I
