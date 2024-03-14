// modular curve 20.90.4.f.1

K := RationalsAsNumberField();
L<a> := NumberField(Polynomial([-1,-1,1]));
R<x,y,z,w> := PolynomialRing(L,4);
eqns := [5*x^2-2*y^2-2*y*z-z^2+y*w+2*z*w,
   2*y^2*z+2*y*z^2-2*y^2*w-3*y*z*w+y*w^2+z*w^2];
C := Curve(Proj(R), eqns);

cusp_orbits := [
  [[0, 0, 0, 1]],
  [[1/2*a, -a, 1/2*a, 1],
  [0, -a, a + 1, 1],
  [-2/5*a + 1/5, 0, 1, 0],
  [-1/2*a, -a, 1/2*a, 1]]
  ];

//auts := Automorphisms(L);
places := [];
for orb in cusp_orbits do
  for c in orb do
    Append(~places, Place(C!c));
  end for;
end for;
