module logo(){
    color("black"){
        fs="Liberation Sans:style=Italic";
        text("Boli",font=fs,size=40);
        translate([118,0,0]) text("o",font=fs,size=40);
    }
}
module compass(){
    w=4;
    h=12;
    translate([0,0,1]){
        color("black"){
            polygon(points=[[-w,0],[0,h],[w,0],[0,-h],[-w,0]]);
        }
    }
    w1=w-1;
    h1=h-2;
    translate([0,0,2]){
        color("white"){
            polygon(points=[[-w1,0],[0,h1],[w1,0],[0,-h1],[-w1,0]]);
        }
    }
    translate([0,0,3]){
        color("red"){
            polygon(points=[[-w1,0],[0,h1],[0,0],[-w1,0]]);
            polygon(points=[[0,0],[w1,0],[0,-h1],[0,0]]);
        }
    }
}
// A hollow circle
module rmark(x,y,ray){
    translate([x,y,1]){
        color("black") circle(r=ray,$fn=80);
    }
    translate([x,y,2]){
        color("white") circle(r=ray-2,$fn=80);
    }
}
        
// Draw the X of bolixo with circles
module drawx(){
    x=10;
    y=12;
    w=3;
    xtop=x+2;
    color("black"){
        polygon(points=[[-x,-y],[xtop,y],[xtop+w,y],[-x+w,-y]]);
        polygon(points=[[-x+2,y],[x,-y],[x+w,-y],[-x+2+w,y]]);
    }
    rmark(1,0,4);
    rmark(-x+2+1,y,4);
    rmark(x+2+1,y,4);
    rmark(x+1,-y,4);
    rmark(-x+1,-y,4);
}

logo();
translate([133,15,0]) rotate([0,0,-20]) compass();
translate([103,15,0]) drawx();
