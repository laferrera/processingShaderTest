#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

varying vec4 vertColor;
varying vec4 vertTexCoord;
uniform float time;

#define r(x)fract(1e4*sin((x)*541.17))// rand, signed rand   in 1, 2, 3D.
#define sr2(x)(r(vec2(x,x+.1))*2.-1.)
#define sr3(x)(r(vec4(x,x+.1,x+.2,0))*2.-1.)

float flare2(vec2 U)// rotating hexagon
{
    vec2 A=sin(vec2(0,1.57)+time);
    U=abs(U*mat2(A,-A.y,A.x))*mat2(2,0,1,1.7);
    return.2/max(U.x,U.y);// glowing-spiky approx of step(max,.2)
}

void main() {
    vec4 curColor=texture2D(texture,vertTexCoord.st)*vertColor;    
    gl_FragColor = curColor;

    vec2 thisXY=vertTexCoord.st;
    gl_FragColor=flare2(thisXY)
    *(.1*sr3(thisXY.x)) // random color - correlated
    *1.;


}