// Icons for admin account

module gear(){
    color("black"){
        circle(r=10);
        g=12;
        w1=3/2;
        w2=w1-0.4;
        l1=20/2;
        l2=24/2;
        translate([0,0,0]) for (i=[1:g]){
            rotate([0,0,360/g*i]) 
                polygon(points=[[-w1,0],[-w1,l1],[w2,l2],[w1,l1]
                    ,[w1,-l1],[w2,-l2],[-w2,-l2],[-w1,-l1],[-w1,0]]);
            //square([24,3],center=true);
        }
    }
    translate([0,0,1]){
        color("white"){
            circle(r=7);
        }
    }
}

module drawline(x0,y0,angle,len,col,thick){
    t2=thick/2;
    color(col) translate([x0,y0,0]) rotate([0,0,angle]){
        polygon(points=[[0,t2],[len,t2],[len,-t2],[0,-t2],[0,t2]]);
    }
}

module line(x0,y0,x1,y1,col){
    diffy=y1-y0;
    diffx=x1-x0;
    angle=atan2(diffy,diffx);
    len=sqrt(diffx*diffx+diffy*diffy);
    drawline(x0,y0,angle,len,col,1);
}

module stick(x,y,angle,col){
    len=4;
    drawline(x,y,angle,4,col,1);
    endx = x + cos(angle)*(len+1);
    endy = y + sin(angle)*(len+1);
    for (i=[1:6]){
        drawline(endx,endy,i*360/6,1,"yellow",0.15);
    }
}

module juggler(){
    y1=10;
    line(20,0,25,y1,"black");
    line(29,0,25,y1,"black");
    y2=20;
    line(25,y1,24.5,y2,"black");
    translate([24.5,y2+3,0]) color("black") circle(r=3,$fn=40);
    
    // Left arm
    line(24.5,y2-2,20,y2-4,"black");
    line(20.5,y2-4,16,y2-2,"black");
    // Right arm
    line(24.5,y2-2,20,y2-2,"black");
    line(20.5,y2-2,16,y2+1,"black");
    
    stick(18,30,15,"red");
    stick(12,27,225,"red");
    stick(15,35,90,"red");
    stick(12,31,155,"red");
    
}

view="gear";
if (view=="gear"){
    gear();
}else if (view=="juggler"){
    juggler();
}