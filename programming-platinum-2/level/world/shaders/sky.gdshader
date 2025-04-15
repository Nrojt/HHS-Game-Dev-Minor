shader_type sky;
render_mode use_half_res_pass;

uniform vec3 sky_color_a : source_color = vec3(0.4, 0.0, 1.0);
uniform vec3 sky_color_b : source_color = vec3(0.0, 0.4, 1.0); 
uniform vec3 cloud_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float cloud_min = 0.3;
uniform float cloud_max = 0.8;
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

// Generate clouds based on noise texture
vec4 generate_clouds(vec3 eyedir) {
	// Create UV coordinates based on eyedir, dividing to get a curved effect
    // eyedir.x = horizontal, eyedir.z = depth
    vec2 uv = eyedir.xz / (eyedir.y + 1.0);

    // time-based movement (along the Z-axis/depth)
    // Modify uv.y  for front-to-back movement
    uv.y -= TIME * cloud_speed;

    uv = fract(uv); // Combat the tiling effect

    // Sample noise texture
    float noise = texture(cloud_noise, uv).r;

    // generate clouds
    float clouds = smoothstep(cloud_min, cloud_max, noise);

    return vec4(cloud_color, clouds * 0.7); // Making the clouds semi transparent
}

void sky() {
    // Render clouds at half resolution for performance
    if (AT_HALF_RES_PASS) {
        vec4 color = generate_clouds(EYEDIR);
        COLOR = color.rgb;
        ALPHA = color.a;
    }
    // Render the base sky and composite the half-resolution clouds on top
    else {
        vec3 color = generate_sky(EYEDIR);
        // Blend the base sky color with the pre-calculated cloud color (HALF_RES_COLOR)
        COLOR = color + HALF_RES_COLOR.rgb * HALF_RES_COLOR.a;
        ALPHA = 1.0;
    }
}
