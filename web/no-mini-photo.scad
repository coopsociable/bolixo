// This image is sent when a user has not created his photo or mini-photo
// Just a face with a round mouth, showing surprise

module blackcircle(ray){
    color("black") circle(r=ray,$fn=80);
    translate([0,0,0.1]) color("white") circle(r=ray-3,$fn=80);
}

color("black") resize([100,150]) circle(r=20,$fn=80);
translate([0,0,0.1]) color("white") resize([94,142]) circle(r=20,$fn=80);
//blackcircle(20);

translate([0,0,1]){
    m=25;
    translate([-m,m,0]) blackcircle(10);
    translate([ m,m,0]) blackcircle(10);
    translate([0,-40,0]) blackcircle(15);
}