"""Build print-oriented STLs for the bike lamp clamp and check them.
Mirrors scad/bike_lamp_clamp.scad. Needs: pip install manifold3d trimesh matplotlib
Usage: python3 tools/build_stl.py
"""
import manifold3d as m, numpy as np, trimesh, math
C=m.Manifold; CS=m.CrossSection
bar_d=22.2;W=18;wall=4;gap=1.5;sd=4.4;naf=7.2;nd=3.5;eh=8;el=5;cb=8.0
sl=30;so=5.5;sdp=2.7;lh=0.8;sw=10;fit=0.25;fl=1.5
R=bar_d/2;Ro=R+wall;sy=max(R+4.5,sl/2+cb/2+0.5);ey=sy+el;z0=Ro+fl;bt=z0+sdp+fit;uh=sdp-lh;et=gap/2+eh
def box(x0,y0,z0_,x1,y1,z1): return C.cube([x1-x0,y1-y0,z1-z0_]).translate([x0,y0,z0_])
def cylx(r,h): return C.cylinder(h,r,r,128,True).rotate([0,90,0])
def cylz(r,h,n=64): return C.cylinder(h,r,r,n,False)
def prism_yz(pts):  # polygon in (y,z), extruded along x over clamp width
  return C.extrude(CS([pts]),W).rotate([0,90,0]).rotate([90,0,0]).rotate([0,0,0])
def prism(pts):
  # build via explicit transform: extrude along local z, map local(x,y,z)->(z-W/2, x, y)
  e=C.extrude(CS([pts]),W)
  return e.transform([[0,0,1,-W/2],[1,0,0,0],[0,1,0,0]])
ring=cylx(Ro,W); bore=cylx(R,W+2)
holes=sum([cylz(sd/2,100).translate([0,s*sy,-50]) for s in(-1,1)],C())
# truncated teardrop bore for the lower half (point toward -z, flat at R+0.6)
k=R*math.sqrt(2); zt=R+0.6; hw=k-zt
tear=prism([(-R/math.sqrt(2),-R/math.sqrt(2)),(-hw,-zt),(hw,-zt),(R/math.sqrt(2),-R/math.sqrt(2)),(0,0)])
# --- upper half (prints slot-down) ---
u=(ring^box(-50,-50,gap/2,50,50,50))+box(-W/2,-ey,gap/2,W/2,ey,et)+box(-W/2,-sl/2,gap/2,W/2,sl/2,bt)
g=prism([(sl/2,et),(ey,et),(sl/2,et+(ey-sl/2))])  # 45-degree gusset under ear (in print)
u=u+g+g.mirror([0,1,0])
a=so+fit;b=sw+fit
u=u-bore-holes-box(-b/2,-50,z0,b/2,50,z0+uh+fit)-box(-a/2,-50,z0,a/2,50,60)
for s in(-1,1): u=u-cylz(cb/2,40).translate([0,s*sy,et])   # counterbore for screw heads
# --- lower half (prints split-face-down) ---
# lower = mirror of the upper's outer envelope (ring+ears+block+gussets), no slot
env=(ring^box(-50,-50,gap/2,50,50,50))+box(-W/2,-ey,gap/2,W/2,ey,et)+box(-W/2,-sl/2,gap/2,W/2,sl/2,bt)+g+g.mirror([0,1,0])
l=env.mirror([0,0,1])-bore-holes
nr=naf/2/math.cos(math.pi/6)
for s in(-1,1): l=l-cylz(nr,50,6).translate([0,s*sy,-et+nd-50])
def tm(x):
  g=x.to_mesh(); t=trimesh.Trimesh(g.vert_properties[:,:3],g.tri_verts,process=False); return t
U,L=tm(u),tm(l)
flip=trimesh.transformations.rotation_matrix(math.pi,[1,0,0])
Up=U.copy(); Up.apply_transform(flip); Up.apply_translation([0,0,-Up.bounds[0][2]])
Lp=L.copy(); Lp.apply_transform(trimesh.transformations.rotation_matrix(math.pi/2,[0,1,0])); Lp.apply_translation(-Lp.bounds[0]*[0,0,1])
# overhang check: downward faces steeper than 45 deg, not on bed
def oh(M):
  n=M.face_normals; c=M.triangles_center
  bad=(n[:,2]<-0.71)&(c[:,2]>0.05); return M.area_faces[bad].sum()

print(u.status(),l.status());print('watertight',U.is_watertight,L.is_watertight,'overhang mm2 up/low',round(oh(Up),1),round(oh(Lp),1))
import os
root=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..')
os.makedirs(os.path.join(root,'stl'),exist_ok=True);os.makedirs(os.path.join(root,'images'),exist_ok=True)
o=root+'/'
Up.export(o+'stl/clamp_upper.stl'); Lp.export(o+'stl/clamp_lower.stl')
import matplotlib;matplotlib.use('Agg');import matplotlib.pyplot as plt, matplotlib.colors
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
ls=matplotlib.colors.LightSource(45,45)
fig=plt.figure(figsize=(11,5))
for i,(M,t,c) in enumerate([(Up,'Upper — slot on bed','#e8833a'),(Lp,'Lower — mirrored, on its side','#666')]):
  ax=fig.add_subplot(1,2,i+1,projection='3d')
  ax.add_collection3d(Poly3DCollection(M.vertices[M.faces],facecolors=c,shade=True,lightsource=ls))
  xs,ys=np.meshgrid([-32,32],[-32,32]);ax.plot_surface(xs,ys,np.zeros_like(xs),color='#cfe3f5',alpha=.5)
  ax.set_xlim(-30,30);ax.set_ylim(-30,30);ax.set_zlim(0,45);ax.view_init(18,-60);ax.set_axis_off();ax.set_box_aspect([60,60,40]);ax.set_title(t)
plt.tight_layout();plt.savefig(o+'images/print_orientation.png',dpi=110)
