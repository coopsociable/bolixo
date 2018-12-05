// A hollow circle
module rmark(x,y,ray){
    translate([x,y,1]){
        color("black") circle(r=ray,$fn=80);
    }
    translate([x,y,2]){
        color("white") circle(r=ray-1,$fn=80);
    }
}

module line(x0,y0,x1,y1,col="black"){
    rmark(x0,y0,2);
    rmark(x1,y1,2);
    color(col) polygon(points=[[x0,y0],[x1,y1],[x1+1,y1+1],[x0+1,y0+1],[x0,y0]]);
}
line(0,0,0,255,"red");
line(0,255,255,255,"red");
line(0,0,255,0,"red");
line(255,0,255,255,"red");
