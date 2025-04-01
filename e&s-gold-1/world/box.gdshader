shader_type spatial;
uniform vec3 color_a = vec3(1.0, 0.0, 0.0);
uniform	vec3 color_b = vec3(0.0, 1.0, 0.0);

void vertex() {
	float wave = cos(TIME * 2.0 + VERTEX.x * 4.0) * 0.2;
    VERTEX.y += wave;
}

void fragment() {
	
	// TODO improve shader
	float pattern = smoothstep(
        abs(sin(TIME * 0.8)), 
        abs(cos(TIME * 0.6)), 
        abs(tan(TIME * 0.4))
    );
	
	vec3 mix_colour = mix(color_a, color_b, pattern);
	ALBEDO = mix_colour;
    METALLIC = pattern * 0.5;
}
