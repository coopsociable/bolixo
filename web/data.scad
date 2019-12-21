// allviews zip tgz
include </tmp/viewsel/data.h>

module zip(){
    difference(){
        cylinder(r=10,h=20,$fn=80);
        for (f=[1:4]){
            translate([0,0,f*4]) cylinder(r=12,h=1,$fn=80);
        }
    }
}
module tgz(){
}

module main_view(view){
if (view=="zip"){
    zip();
}else if (view=="tgz"){
    tgz();
}
}
