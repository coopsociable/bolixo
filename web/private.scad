ray=10;
color("red") circle(ray);
translate([0,0,1]) color("white") circle(ray-2);
off=cos(45)*(ray-1);
//translate([-off,-off,2]) 
translate([0,0,2]) rotate([0,0,45]) color("red") square([2,2*ray-2],center=true);
