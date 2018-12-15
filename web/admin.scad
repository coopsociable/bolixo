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

module line(x0,y0,x1,y1,col){
    diffy=y1-y0;
    diffx=x1-x0;
    angle=atan2(diffy,diffx);
    len=sqrt(diffx*diffx+diffy*diffy);
    color(col) translate([x0,y0,0]) rotate([0,0,angle]){
        polygon(points=[[0,0.5],[len,0.5],[len,-0.5],[0,-0.5],[0,0.5]]);
    }
}

module juggler(){
    line(20,0,25,15,"black");
}

view="juggler";
if (view=="gear"){
    gear();
}else if (view=="juggler"){
    juggler();
}