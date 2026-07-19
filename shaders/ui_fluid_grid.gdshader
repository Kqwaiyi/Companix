shader_type canvas_item;

uniform float grid_size : hint_range(1.0, 100.0) = 6.0;
uniform float line_thickness : hint_range(0.001, 0.5) = 0.01;
uniform vec4 grid_color : source_color = vec4(1.0, 1.0, 1.0, 0.15); // White, low opacity
uniform float wave_strength : hint_range(0.0, 0.1) = 0.02;
uniform vec2 parallax_offset = vec2(0.0);

// Pseudo-random noise
vec2 random2(vec2 st){
    st = vec2( dot(st,vec2(127.1,311.7)),
              dot(st,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(st)*43758.5453123);
}

// 2D Noise
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);
    vec2 u = f*f*(3.0-2.0*f);
    return mix( mix( dot( random2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( random2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( random2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( random2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y);
}

float fbm(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
	vec2 base_uv = UV + parallax_offset;
	
	// Create a slow, wavy displacement field
	vec2 wave_disp = vec2(
		fbm(base_uv * 2.0 + TIME * 0.1),
		fbm(base_uv * 2.0 - TIME * 0.1 + vec2(100.0))
	) * 2.0 - 1.0;
	
	// Apply displacement
	vec2 final_uv = base_uv + (wave_disp * wave_strength);
	
	// Draw the grid
	vec2 grid_uv = fract(final_uv * grid_size);
	
	float blend = 0.01;
	float line_x = smoothstep(line_thickness + blend, line_thickness, grid_uv.x) + smoothstep(1.0 - line_thickness - blend, 1.0 - line_thickness, grid_uv.x);
	float line_y = smoothstep(line_thickness + blend, line_thickness, grid_uv.y) + smoothstep(1.0 - line_thickness - blend, 1.0 - line_thickness, grid_uv.y);
	float grid = clamp(line_x + line_y, 0.0, 1.0);
	
	COLOR = grid_color;
	COLOR.a *= grid; 
}
