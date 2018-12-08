// Icons for admin account

module gear(){
    color("black"){
        circle(r=10);
        g=8;
        translate([0,0,0]) for (i=[1:g]){
            rotate([0,0,360/g*i]) square([24,3],center=true);
        }
    }
    translate([0,0,1]){
        color("white"){
            circle(r=7);
        }
    }
}
view="gear";
if (view=="gear"){
    gear();
}