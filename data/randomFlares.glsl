#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER


varying vec4 vertTexCoord;
uniform sampler2D texture;
uniform float time;
uniform vec2 resolution;
uniform vec2 pixels;
uniform float rollRate;
uniform float rollAmount;

uniform vec2 rbias =vec2(0,0);
uniform vec2 gbias=vec2(-0.1,0);
uniform vec2 bbias=vec2(0,0);
uniform vec2 rmult=vec2(0.9,1);
uniform vec2 gmult = vec2(1,1);
uniform vec2 bmult =vec2(1,1);

#define r(x)fract(1e4*sin((x)*541.17))// rand, signed rand   in 1, 2, 3D.
#define sr2(x)(r(vec2(x,x+.1))*2.-1.)
#define sr3(x)(r(vec4(x,x+.1,x+.2,0))*2.-1.)

float flare(vec2 U)// rotating hexagon
{
    vec2 A=sin(vec2(0,1.57)+time + U.x);
    U=abs(U*mat2(A,-A.y,A.x))*mat2(2,0,1,1.7);
    return.2/max(U.x,U.y);// glowing-spiky approx of step(max,.2)
    
}



void main()
{
    // U is gl_FragCoord // O is gl_FragColor
    vec2 R=resolution.xy;
    vec2 myFragCoord=(gl_FragCoord.xy+gl_FragCoord.xy-R)/R.y;
    gl_FragColor-=gl_FragColor+.3;
    vec2 p=vertTexCoord.st;
    vec3 col = texture2D(texture, p).rgb; // takes color from puxel
    // gl_FragColor = vec4(col, 1.0); // sets fragment color to pixel color (1.0 seems to do nothing.)
    // gl_FragColor=gl_FragColor*.1;

    for(float i=0.;i<99.;i++){
        vec2 randXY = myFragCoord-sr2(i)*R/R.y;
        gl_FragColor+=flare(randXY) // rotating flare at random location
        *r(i+.1)// random scale
        *(1.+sin(time+r(i+.3)*6.))*.1 // time pulse
        *(1.+.1*sr3(i));// random color - correlated
    }
}

