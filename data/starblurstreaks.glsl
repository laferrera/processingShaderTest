// streaks
// https://www.shadertoy.com/view/NlyfDW


// glow
// https://www.shadertoy.com/view/NlyfDW

#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
varying vec4 vertTexCoord;
uniform float time;
uniform vec2 resolution;
uniform sampler2D texture;

void main() {

    // vec2 uv = fragCoord / iResolution.xy;
    vec2 uv=gl_FragCoord.xy/resolution.xy;
    gl_FragColor = texture2D(texture, uv);
    
	const float range = 0.2; // Length of glow streaks
	const float steps = 0.002; // Texture samples
	const float threshold = 0.0; // Color key threshold (0-1)
	
	for (float i = -range; i < range; i += steps) {
	
		float falloff = 1.0 - abs(i / range);
	
		vec4 blur = texture2D(texture, uv + i);
		if (blur.r + blur.g + blur.b > threshold * 3.0) {
			gl_FragColor = max(gl_FragColor, blur * falloff);
		}
		
		blur = texture2D(texture, uv + vec2(i, -i));
		if (blur.r + blur.g + blur.b > threshold * 3.0) {
			gl_FragColor = max(gl_FragColor, blur * falloff);
		}
	}
}