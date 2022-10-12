#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
varying vec4 vertTexCoord;
uniform float time;
float lastRand;

uniform float burst0Fade;
uniform float burst0Fract;
uniform float burst1Fade;
uniform float burst1Fract;
uniform float burst2Fade;
uniform float burst2Fract;
uniform float burst3Fade;
uniform float burst3Fract;


uniform vec2 resolution;
uniform sampler2D texture;
const float PI = 3.1415925358;

float safety_sin( in float x ) { 
    return sin( mod( x, PI ) ); 
}

// float rand( vec2 p ) { return fract( safety_sin( dot(p, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 + time * .35 ); }
// float rand(vec2 p){
//     // return fract(safety_sin(dot(p,vec2(12.9898,78.233)))*43758.5453+time*.15);
//     float outFloat;
//     outFloat=dot(p,vec2(12.9898,78.233));
//     outFloat=safety_sin(outFloat)*43758.5453+time*.15;
//     outFloat=fract(outFloat);
//     return outFloat;
// }
float rand(vec2 p, float fractInput){
    // return fract(safety_sin(dot(p,vec2(12.9898,78.233)))*43758.5453+time*.15);
    float outFloat;
    outFloat=dot(p,vec2(12.9898,78.233));
    outFloat=safety_sin(outFloat)*43758.5453+fractInput;
    outFloat=fract(outFloat);
    return outFloat;
}



float noise( vec2 x , float fractInput)
{
	vec2 i = floor(x);
	vec2 f = fract(x);
	vec4 h;
	// Smooth Interpolation
	f = f * f * ( f * -2.0 + 3.0 );
	// Four corners in 2D of a tile
	h.x = rand( i + vec2( 0., 0. ), fractInput );
	h.y = rand( i + vec2( 1., 0. ), fractInput );
	h.z = rand( i + vec2( 0., 1. ), fractInput );
	h.w = rand( i + vec2( 1., 1. ), fractInput );
	// Mix 4 corners percentages
	return mix( mix( h.x, h.y, f.x ), mix( h.z, h.w, f.x ), f.y );
}


float star_burst( vec2 p , float fractInput, float lfoTime)
{
	float k0 = 2.0; // how many rays noise0 + noise1 coeff - orig 2.0
	float k1 = 1.0; // length2 power coeff(how long the rays are?) - orig 1.0
	float k2 = .5   + lfoTime + 0.1*sin(.03+lfoTime*time);; // length2 power coeff (how long the rays are?)  - orig 0.5
	float k3 = 12.0 + lfoTime + 3*sin(.13+lfoTime*time); // n1 coeff (212 is A LOT of rays)- orig 12.0
	float k4 = 36.0 + lfoTime + 2*sin(.33+lfoTime*time);; // end noise power coeff (how MANY rays? small means more)- orig 12.0
    float k5 = 2.0; // end noise power coeff(big makes center big and blurry) - orig 2.0
    float k6 = 5.2;  // end noise power coeff (big makes center big and blurry)- orig 5.2
    float k7 = 18.0;  // end noise clamp coeff (how strong center bright, lower is more powerful)- orig 4.0
    float k8 = 6.2;  // end noise power coeff (how STRONG rays)- orig 6.2 

	
	float l  = length( p );
    float l2 = pow( l * k1, k2 );
	float n0 = noise( vec2( atan(  p.y,  p.x ) * k0, l2 ) * k3, fractInput );
	float n1 = noise( vec2( atan( -p.y, -p.x ) * k0, l2 ) * k3, fractInput );
	float n  = pow( max( n0, n1 ), k4 ) * pow( clamp( 1.0 - l * k5, 0.0, 1.0 ), k6 );
	// n += pow( clamp( 1.0 - ( l * k7 - 0.1 ), 0.0, 1.0 ), k8 ); //this adds center star
	return n;
}


float star_burst2(vec2 p)
{
    float k0=0.2;// how many rays noise0 + noise1 coeff - orig 2.0
    float k1=1.;// length2 power coeff(how long the rays are?) - orig 1.0
    float k2=.5+.1*sin(.06*time);;// length2 power coeff (how long the rays are?)  - orig 0.5
    float k3=12.+3*sin(.32*time);// n1 coeff (212 is A LOT of rays)- orig 12.0
    float k4=20.+2*sin(.22*time);;// end noise power coeff (how MANY rays? small means more)- orig 12.0
    float k5=2.;// end noise power coeff(big makes center big and blurry) - orig 2.0
    float k6=5.2;// end noise power coeff (big makes center big and blurry)- orig 5.2
    float k7=18.;// end noise clamp coeff (how strong center bright, lower is more powerful)- orig 4.0
    float k8=6.2;// end noise power coeff (how STRONG rays)- orig 6.2
    
    float l=length(p);
    float l2=pow(l*k1,k2);
	float n0 = noise( vec2( atan(  p.y,  p.x ) * k0, l2 ) * k3, 2 );
	float n1 = noise( vec2( atan( -p.y, -p.x ) * k0, l2 ) * k3, 2 );
    float n=pow(max(n0,n1),k4)*pow(clamp(1.-l*k5,0.,1.),k6);
    n+=pow(clamp(1.-(l*k7-.1),0.,1.),k8);
    return n;
}

vec4 renderStarburst(float index, vec2 point, float myFract, float myFade){
    point -= 0.5; // center 
    point *= 0.5; // bigger
    float lfoTime = index * .1; 
	float r = star_burst(point * 1.1 , myFract,lfoTime);
	float g = star_burst(point ,myFract,lfoTime);
	float b = star_burst(point * 0.9 , myFract,lfoTime);


    vec3 col = pow( vec3( r, g, b ), vec3( 1.0 / (sin(index * time) + 4.2) ) );
    vec4 v4col = myFade*vec4( col, 1. );
    return v4col;
}

void main()
{
    
    // Normalized pixel coordinates (from 0 to 1)
    // vec2 R=resolution.xy;
    // vec2 p = gl_FragCoord.xy / min( R.x, R.y );
    vec2 p=vertTexCoord.st;

    gl_FragColor = renderStarburst(4, p,burst0Fract, burst0Fade);
    gl_FragColor += renderStarburst(1, p,burst1Fract, burst1Fade);
    gl_FragColor += renderStarburst(2, p,burst2Fract, burst2Fade);
    gl_FragColor += renderStarburst(3, p,burst3Fract, burst3Fade);
    




    // another pass if we want to...

    // // gl_FragColor-=gl_FragColor+.3;
    p -= 0.5; // center 
    p *= 0.5; // bigger
    float r=star_burst2(p*1.1);
    float g=star_burst2(p);
    float b=star_burst2(p*.9);

    // Output to screen
    // vec3 col=pow(vec3(r,g,b),vec3(1./2.2));
    vec3 col=pow(vec3(r,g,b),vec3(1./(sin(.8*time)*2+8.2)));
    gl_FragColor+=0.2*vec4(col,1.);


}