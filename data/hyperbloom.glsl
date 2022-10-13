// https://www.shadertoy.com/view/wdc3Rn
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
varying vec4 vertTexCoord;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture;

#define PI 3.141592653
#define PI2 2.0*PI
#define EXP2PII(t) vec2(cos(PI2*t), sin(PI2*t))

vec4 colorWheel(in vec2 pos)
{
    float magn = length(pos);
    
    if (magn == 0.0) return vec4(0.0);
    
    float angle = acos(dot(pos, vec2(1.0, 0.0))/magn);
    
    vec3 rgb = clamp(abs(mod(angle*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);

    return vec4(magn * (rgb-0.2), 0.0);
}

void main()
{
    const float speed = 1.0;
    float time = speed * time + 100.0;
    
	// vec2 uv = fragCoord/iResolution.xy;
    vec2 uv=gl_FragCoord.xy/resolution.xy;
    
    // vec4 color = texture(iChannel0, uv);
    vec4 color = texture2D(texture, uv);
    
    vec2 offset = vec2(0.0);
    
    const int m = 64;
    for (int n = 0; n < m; n++)
    {
		vec2 testOffset = 0.015*EXP2PII(float(n) / float(m));
        vec4 testColor = color+texture2D(texture, uv+testOffset);
        
        float l = length(testColor);
        
        offset += l * testOffset;
    }
    
    vec2 warp = vec2(sin(0.7*time+uv.x+4.0), cos(time+uv.y));
    vec2 uvOffset = warp * offset - 0.01*warp;
    vec2 colorPos = 4.0 * warp * offset + 0.02 * EXP2PII(0.02*time);
    
	// fragColor = texture(iChannel0, uv+uvOffset)+colorWheel(colorPos);
    gl_FragColor = texture2D(texture, uv+uvOffset)+colorWheel(colorPos);
}

