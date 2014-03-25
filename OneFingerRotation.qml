import QtQuick 1.0

Rectangle{
    id: root
    width: 720
    height: 480
    color: "#000"

    property real m: 1;
    property real modo
    property real modo_time
    property real inercia: 700; //600
    property real inx: rect.x;
    property real iny: rect.y;
    property real r: rect.rotation;
    //friccion
    property real b: 1.2;
    //inicializando
    property real vr: 0
    property real torque: 0
    property real vx: 0
    property real vy: 0
    property real  mxx: 0
    property real  my: 0
    property real  mx0: 0
    property real  my0: 0
    property real  dmx: 0
    property real  dmy: 0
    property real  fx: 0
    property real  fy: 0
    property real  ldx: 0
    property real  ldy: 0
    property real  mlength: 0
    property real  mforce: 0
    property real  addx: 0
    property real  addy: 0
    property real  k: 0
    property real  kx: 0
    property real  ky: 0
    property real newMouseX
    property real newMouseY

    Rectangle{
        id: rect

        property real qAngle
        x: parent.width/2
        y: parent.height/2
        width: 250
        height: 250
        smooth: true

        transform: Translate { y: -rect.height/2; x: -rect.width/2 }

        MouseArea{
            anchors.fill: rect
            onPressed: {
                modo = 1;
                modo_time = 1;
                timer.start()
            }
            onReleased:{
                modo = 2;
                modo_time = 1;
            }
            onMousePositionChanged: {
                var coisa = mapToItem(root,mouseX,mouseY)
                newMouseX = coisa.x
                newMouseY = coisa.y
            }
        }
    }

    Timer{
        id: timer
        interval: 30
        repeat: true
        onTriggered: {
            if (modo == 1) {
                if (modo_time == 1) {
                    modo_time = 0;
                    mxx = newMouseX;
                    my = newMouseY;
                    mx0 = mxx;
                    my0 = my;
                    dmx = mxx-mx0;
                    dmy = my-my0;
                } else {
                    mxx = (newMouseX+mxx)/2;
                    my = (newMouseY+my)/2;
                    dmx = mxx-mx0;
                    dmy = my-my0;
                    mx0 = mxx;
                    my0 = my;
                }
                fx = (dmx-vx)*m;
                fy = (dmy-vy)*m;
                ldx = mxx-inx;
                ldy = my-iny;
                if (fx == 0) {
                    mlength = ldx;
                    mforce = fy;
                    torque = mforce*mlength;
                } else if (fy == 0) {
                    mlength = ldy;
                    mforce = fx;
                    torque = -(mforce)*mlength;
                } else {
                    k = fy/fx;
                    kx = (-(k)*k*ldx+k*ldy)/(-(k)*k-1);
                    ky = k*(kx-ldx)+ldy;
                    mlength = Math.sqrt(kx*kx+ky*ky);
                    mforce = Math.sqrt(fx*fx+fy*fy);
                    if (fx*ky>0) {
                        torque = -(mforce)*mlength;
                    } else {
                        torque = mforce*mlength;
                    }
                }
                vx = dmx;
                vy = dmy;
                inx += vx;
                iny += vy;
                vr = vr-torque/inercia;
                ldx = mxx-inx;
                ldy = my-iny;
                var cos;
                var sin;
                cos = Math.cos(vr/180*Math.PI);
                sin = Math.sin(vr/180*Math.PI);
                addx = ldx*cos+ldy*sin-ldx;
                addy = -(ldx)*sin+ldy*cos-ldy;
                inx += -(addx);
                iny += -(addy);
            } else if (modo == 2) {
                if (modo_time == 1) {
                    modo_time = 0;
                    vx = vx-(addx);
                    vy = vy-(addy);
                }
                torque = 0;
                addx = 0;
                addy = 0;
                inx += vx;
                iny += vy;
                if(Math.round(vx) == 0 && Math.round(vy) == 0){
                    timer.stop()
                }
            }
            r -= vr;
            rect.x = inx;
            rect.y = iny;
            rect.rotation = r;
            vx = vx/b;
            vy = vy/b;
            vr = vr/b;
        }
    }
}
