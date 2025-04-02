shader_type sky;
render_mode use_half_res_pass;

uniform vec3 sky_color_a = vec3(0.4, 0.0, 1.0);
uniform vec3 sky_color_b = vec3(0.0, 0.4, 1.0);
uniform vec3 cloud_color = vec3(1.0, 1.0, 1.0);
uniform float cloud_speed = 0.01;
uniform sampler2D cloud_noise;

// TODO: see if I can remove the line between tiles

// Simple sky gradient function
vec3 generate_sky(vec3 eyedir) {
    // Create gradient
    float horizon = smoothstep(-0.1, 0.5, eyedir.y);
    return mix(
        sky_color_a,  
        sky_color_b,
        horizon
    );
}

// Genetare clouds based on noise texture
vec4 generate_clouds(vec3 eyedir) {
	// Create UV coordinates based on eyedir, dividing to get a curved effect
    vec2 uv = eyedir.xz / (eyedir.y + 1.0);
    
    // time-based movement
    uv.x += TIME * cloud_speed;
    
    uv = fract(uv); // Combat the tiling effect
    
    // Sample noise texture
    float noise = texture(cloud_noise, uv).r;
    
    // generate clouds
    float clouds = smoothstep(0.3, 0.6, noise);
    
    return vec4(cloud_color, clouds * 0.7);
}

void sky() {
    if (AT_HALF_RES_PASS) {
        vec4 color = generate_clouds(EYEDIR);
        COLOR = color.rgb;
        ALPHA = color.a;
    } else {
        vec3 color = generate_sky(EYEDIR);
        COLOR = color + HALF_RES_COLOR.rgb * HALF_RES_COLOR.a;
    }
}
