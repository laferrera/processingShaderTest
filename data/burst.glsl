#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
varying vec4 vertTexCoord;
uniform float time;
float lastRand;
uniform vec2 resolution;
uniform sampler2D texture;
const float PI = 3.1415925358;

float safety_sin( in float x ) { 
    return sin( mod( x, PI ) ); 
}

// float rand( vec2 p ) { return fract( safety_sin( dot(p, vec2( 12.9898, 78.233 ) ) ) * 43758.5453 + time * .35 ); }
float rand(vec2 p){
    // return fract(safety_sin(dot(p,vec2(12.9898,78.233)))*43758.5453+time*.15);
    float outFloat;
    outFloat=dot(p,vec2(12.9898,78.233));
    outFloat=safety_sin(outFloat)*43758.5453+time*.15;
    outFloat=fract(outFloat);
    return outFloat;
}

float noise( vec2 x )
{
	vec2 i = floor(x);
	vec2 f = fract(x);
	vec4 h;
	// Smooth Interpolation
	f = f * f * ( f * -2.0 + 3.0 );
	// Four corners in 2D of a tile
	h.x = rand( i + vec2( 0., 0. ) );
	h.y = rand( i + vec2( 1., 0. ) );
	h.z = rand( i + vec2( 0., 1. ) );
	h.w = rand( i + vec2( 1., 1. ) );
	// Mix 4 corners percentages
	return mix( mix( h.x, h.y, f.x ), mix( h.z, h.w, f.x ), f.y );
}


float star_burst( vec2 p )
{
	float k0 = 2.0; // how many rays noise0 + noise1 coeff - orig 2.0
	float k1 = 1.0; // length2 power coeff(how long the rays are?) - orig 1.0
	float k2 = .5 +0.1*sin(.03*time);; // length2 power coeff (how long the rays are?)  - orig 0.5
	float k3 = 12.0 + 3*sin(.13*time); // n1 coeff (212 is A LOT of rays)- orig 12.0
	float k4 = 20.0 + 2*sin(.33*time);; // end noise power coeff (how MANY rays? small means more)- orig 12.0
    float k5 = 2.0; // end noise power coeff(big makes center big and blurry) - orig 2.0
    float k6 = 5.2;  // end noise power coeff (big makes center big and blurry)- orig 5.2
    float k7 = 18.0;  // end noise clamp coeff (how strong center bright, lower is more powerful)- orig 4.0
    float k8 = 6.2;  // end noise power coeff (how STRONG rays)- orig 6.2 

	
	float l  = length( p );
    float l2 = pow( l * k1, k2 );
	float n0 = noise( vec2( atan(  p.y,  p.x ) * k0, l2 ) * k3 );
	float n1 = noise( vec2( atan( -p.y, -p.x ) * k0, l2 ) * k3 );
	float n  = pow( max( n0, n1 ), k4 ) * pow( clamp( 1.0 - l * k5, 0.0, 1.0 ), k6 );
	n += pow( clamp( 1.0 - ( l * k7 - 0.1 ), 0.0, 1.0 ), k8 ); //this adds center star
	return n;
}


float star_burst2(vec2 p)
{
    float k0=0.2;// how many rays noise0 + noise1 coeff - orig 2.0
    float k1=2.;// length2 power coeff(how long the rays are?) - orig 1.0
    float k2=.5+.1*sin(.06*time);;// length2 power coeff (how long the rays are?)  - orig 0.5
    float k3=12.+3*sin(.32*time);// n1 coeff (212 is A LOT of rays)- orig 12.0
    float k4=20.+2*sin(.22*time);;// end noise power coeff (how MANY rays? small means more)- orig 12.0
    float k5=2.;// end noise power coeff(big makes center big and blurry) - orig 2.0
    float k6=5.2;// end noise power coeff (big makes center big and blurry)- orig 5.2
    float k7=24.;// end noise clamp coeff (how strong center bright, lower is more powerful)- orig 4.0
    float k8=6.2;// end noise power coeff (how STRONG rays)- orig 6.2
    
    float l=length(p);
    float l2=pow(l*k1,k2);
    float n0=noise(vec2(atan(p.y,p.x)*k0,l2)*k3);
    float n1=noise(vec2(atan(-p.y,-p.x)*k0,l2)*k3);
    float n=pow(max(n0,n1),k4)*pow(clamp(1.-l*k5,0.,1.),k6);
    n+=pow(clamp(1.-(l*k7-.1),0.,1.),k8);
    return n;
}


void main()
{
    
    // Normalized pixel coordinates (from 0 to 1)
    // vec2 R=resolution.xy;
    // vec2 p = gl_FragCoord.xy / min( R.x, R.y );
    vec2 p=vertTexCoord.st;
    
    p -= 0.5; // center 
    p *= 0.5; // bigger
    
	float r = star_burst( p * 1.1 );
	float g = star_burst( p );
	float b = star_burst( p * 0.9 );

    // Output to screen
    // vec3 col=pow(vec3(r,g,b),vec3(1./2.2));    // no sin pulsing
    vec3 col = pow( vec3( r, g, b ), vec3( 1.0 / (sin(time)*2 + 4.2) ) );
    gl_FragColor = .8*vec4( col, 1. );    
    
    // another pass if we want to...

    // // gl_FragColor-=gl_FragColor+.3;

    r=star_burst2(p*1.1);
    g=star_burst2(p);
    b=star_burst2(p*.9);

    // Output to screen
    // vec3 col=pow(vec3(r,g,b),vec3(1./2.2));
    col=pow(vec3(r,g,b),vec3(1./(sin(.8*time)*2+4.2)));
    gl_FragColor+=0.3*vec4(col,1.);


}