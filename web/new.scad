// Simply an arrow to mean something new entered
module arrow(){
    color("black"){
        l0=-6;
        l1=l0+8;
        l2=l1+4;
        h1=1;
        h2=4;
        polygon (points=[[l0,h1],[l1,h1],[l1,h2],[l2,0],[l1,-h2],[l1,-h1],[l0,-h1]]);
    }
}
view="new";
if (view=="new"){
    arrow();
}
if (view=="modified"){
    rotate([0,0,90]) arrow();
}
if (view=="back"){
    rotate([0,0,180]) arrow();
}