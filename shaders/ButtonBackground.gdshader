// based on Coastal Landscape shader by bitless - https://www.shadertoy.com/view/fstyD4
// audio visualization/modulation stuff based on https://godotshaders.com/shader/spectrum-analyzer/

shader_type canvas_item;

const int VU_COUNT = 40;
uniform float[VU_COUNT] freq_data;
uniform float zoomValue = 1.0;
uniform vec2 pixelCoords_mod = vec2(0.0);
uniform float alpha_scale = 1.0;

vec4 hue(float v)
{
    return ( .6 + .76 * cos(6.3*(v) + vec4(0,23,21,0) ) );
}

// "Hash without Sine" by Dave_Hoskins.
// https://www.shadertoy.com/view/4djSRW
float hash12(vec2 p)
{
  vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}

vec2 hash22(vec2 p)
{
  vec3 p3 = fract(vec3(p.xyx) * vec3(.1031, .1030, .0973));
    p3 += dot(p3, p3.yzx+33.33);
    return fract((p3.xx+p3.yz)*p3.zy);
}
////////////////////////

vec2 rotate2D (vec2 st, float a){
    return mat2(vec2(cos(a),-sin(a)), vec2(sin(a),cos(a)) )*st;
}

float st(float a, float b, float s) //AA bar
{
    return smoothstep (a-s, a+s, b);
}

float noise( in vec2 p ) //gradient noise
{
    vec2 i = floor( p );
    vec2 f = fract( p );
    
    vec2 u = f*f*(3.-2.*f);

    return mix( mix( dot( hash22( i+vec2(0,0) ), f-vec2(0,0) ), 
                     dot( hash22( i+vec2(1,0) ), f-vec2(1,0) ), u.x),
                mix( dot( hash22( i+vec2(0,1) ), f-vec2(0,1) ), 
                     dot( hash22( i+vec2(1,1) ), f-vec2(1,1) ), u.x), u.y);
}

vec4 color(vec2 screenSize, vec2 normalizedCoords, vec2 uv, float fft)
{
    vec4 o = vec4(0.0);
    vec3 f, c;
    float h, a, l;
    vec4 C;
    
    float smoothness = 3./normalizedCoords.y; //smoothness factor for AA
    vec2 smooth_scale = vec2(0.0, 30.0);
    
    float sh = noise(uv+TIME*.25)*.3; //big noise on the sky

    float cld = noise(-sh*vec2(.5,1)  - vec2(TIME*.2,0)); //cloud density opposite the center of the sun
    cld = 1.- smoothstep(.0,.15,cld)*.5;

    vec2 u = uv * vec2(1,4);
    vec2 id = floor(u);
    float iter = 5.;

    for (float i = 1.; i > -1.; i--) //drawing a wave and its neighbors from above and below
    {
        if (id.y+i < iter)
        {
            vec2 lc = uv;
            lc.y = (lc.y+(sin(uv.x*12.-TIME*3.+id.y+i))*.25-i)*4. + fft; //set the waveform and divide it into four strips
            h = hash12(vec2(id.y+i,floor(lc.y))); //the number of segments in the strip and its horizontal offset

            smooth_scale.x += 6.+h*4.;
            lc.x = uv.x*smooth_scale.x+sh*9.; //divide the strip into segments
            lc.x += sin(TIME * (.5 + h*2.))*.5; //add a cyclic shift of the strips horizontally
            h = .8*smoothstep(5.,.0,abs(floor(lc.x)))*cld+.1; //determine brightness of the sun track 
            f = mix(f,mix(vec3(0,.1,.5),vec3(.35,.35,0),h),st(lc.y,0.,smoothness*smooth_scale.y)); //mix the color of the water and the color of the track for the background of the water 
            lc += noise(lc*vec2(3,.5))*vec2(.1,.6); //add fine noise to the segment

            f = mix(f,                                                                         //mix the background color 
                mix(hue(hash12(floor(lc))*.1+.56).rgb*(1.2+floor(lc.y)*.17),vec3(1,1,0),h)     //and the stroke color
                ,st(lc.y,0.,smoothness*smooth_scale.x)
                *st(abs(fract(lc.x)-.5),.48,smoothness*smooth_scale.x)*st(abs(fract(lc.y)-.5),.3,smoothness*smooth_scale.y)
                );
        }
    }
    
    o = vec4(f,1);
    return o;
}

void fragment()
{
    float fft = freq_data[int(UV.x * float(VU_COUNT))];
    vec2 screenSize = 1.0 / SCREEN_PIXEL_SIZE;
    float zoom = mix(0.3, zoomValue, 0.5 + 0.5 * sin(TIME * 0.05));
    vec2 normalizedCoords = (FRAGCOORD.xy * zoom) + pixelCoords_mod;

	vec4 o = vec4(0.0, 0.1, 0.1, 1.0);
    vec2 buttonSize = vec2(153.0, 28.0);
    o += color(buttonSize, normalizedCoords, UV, fft);
	o.a -= fft * 0.1;
    float edge_fade = 1.0 - max( abs(UV.x - 0.5) * 2.1 + (fft * 0.05), abs(UV.y - 0.5) * 2.5 + (fft * 0.05) );
    o.a = clamp(edge_fade, 0.0, 1.0);
    o.a *= alpha_scale;
	COLOR = o;
}