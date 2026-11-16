#!/usr/bin/env python3
"""Support-free + watertight check for STLs (assumes STL is already in print orientation, z=0 on bed).
Layer rule: area of each 0.2 mm slice NOT within previous slice buffered by 0.22 mm must be ~0."""
import sys, numpy as np, trimesh
from shapely.ops import unary_union
LAYER, TOL, BUF = 0.2, 0.22, 1.0  # mm, buffer, mm^2 allowed
def slice_poly(m, z):
    s = m.section(plane_origin=[0,0,z], plane_normal=[0,0,1])
    if s is None: return None
    from shapely.geometry import Polygon
    poly = None
    for line in s.discrete:          # closed loops in world coords
        if len(line) < 4: continue
        pg = Polygon(line[:, :2]).buffer(0)
        poly = pg if poly is None else poly.symmetric_difference(pg)  # even-odd: holes
    return poly
def check(path):
    m = trimesh.load(path)
    ok_w = m.is_watertight
    zmin, zmax = m.bounds[:,2]
    worst, worst_z, prev = 0, 0, None
    for z in np.arange(zmin+LAYER/2, zmax, LAYER):
        cur = slice_poly(m, z)
        if cur is None or cur.is_empty: prev=None; continue
        if prev is not None:
            a = cur.difference(prev.buffer(TOL)).area
            if a > worst: worst, worst_z = a, z
        prev = cur
    print(f"{path}: watertight={ok_w} zmin={zmin:.2f} height={zmax-zmin:.1f} worst_unsupported={worst:.2f}mm2 @z={worst_z:.1f} -> {'OK' if ok_w and worst<=TOL_AREA else 'CHECK'}")
    return ok_w and worst <= TOL_AREA
TOL_AREA = BUF
if __name__ == "__main__":
    sys.exit(0 if all([check(p) for p in sys.argv[1:]]) else 1)
