shader_type canvas_item;
render_mode unshaded;

// --- Base color to replace ---
uniform vec4 original_0: source_color = vec4(1.0, 1.0, 1.0, 1.0);

// --- Matching thresholds ---
uniform float hue_threshold : hint_range(0.0, 0.5, 0.01) = 0.05;
uniform float sat_threshold : hint_range(0.0, 1.0, 0.01) = 0.0;
uniform float val_threshold : hint_range(0.0, 1.0, 0.01) = 0.0;

// --- Rainbow controls ---
uniform float rainbow_speed : hint_range(0.0, 10.0, 0.01) = 1.0;
uniform bool rainbow_animate = false;
uniform float rainbow_band_size : hint_range(0.01, 5.0, 0.01) = 0.25;
uniform float rainbow_alpha : hint_range(0.0, 1.0) = 1.0;
uniform float precision = 0.05;

// --- Outline controls ---
uniform float thickness : hint_range(0.0, 100.0) = 2;
uniform int ring_count : hint_range(1,128) = 4;
uniform float ring_offset : hint_range(0.0, 1.0, 0.01);
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform bool border_clipping_fix = false;
uniform float aspect_ratio : hint_range(0.1, 10.0, 0.01) = 1.0;
uniform bool square_border = false;
uniform vec2 offset;
uniform bool max_or_add = false;

// --- Color utility functions ---
vec3 rgb2hsv(vec3 c) {
    float M = max(c.r, max(c.g, c.b));
    float m = min(c.r, min(c.g, c.b));
    float d = M - m;
    float h = 0.0;
    if (d > 0.00001) {
        if (M == c.r) h = mod((c.g - c.b) / d, 6.0);
        else if (M == c.g) h = (c.b - c.r) / d + 2.0;
        else h = (c.r - c.g) / d + 4.0;
        h /= 6.0;
        if (h < 0.0) h += 1.0;
    }
    float s = (M <= 0.0) ? 0.0 : d / M;
    float v = M;
    return vec3(h, s, v);
}

vec3 hsv2rgb(vec3 c) {
    vec3 K = vec3(1.0, 2.0/3.0, 1.0/3.0);
    vec3 p = abs(fract(c.xxx + K) * 6.0 - 3.0);
    return c.z * mix(vec3(1.0), clamp(p - 1.0, 0.0, 1.0), c.y);
}

// --- Rainbow color generation ---
vec3 rainbow_rgb(vec2 uv) {
    // Multiply by inverse band size → controls how long each hue lasts
    float hue = (uv.x + uv.y) / rainbow_band_size;
    if (rainbow_animate) hue += TIME * rainbow_speed;
    hue = fract(hue);
    return hsv2rgb(vec3(hue, 1.0, 1.0));
}

// --- Matching by hue ---
bool hue_match(vec3 pix_rgb, vec3 target_rgb) {
    vec3 pix_hsv = rgb2hsv(pix_rgb);
    vec3 target_hsv = rgb2hsv(target_rgb);

    if (pix_hsv.y < sat_threshold || pix_hsv.z < val_threshold) return false;

    float dh = abs(pix_hsv.x - target_hsv.x);
    dh = min(dh, 1.0 - dh);
    return dh <= hue_threshold;
}

vec2 square(float i){
	i *= 2.0;
	return (vec2(
		clamp(abs(mod(i,2.0)-1.0),0.25,0.75),
		clamp(abs(mod(i+0.5,2.0)-1.0),0.25,0.75)
		)-0.5)*4.0;
}

vec4 tex(sampler2D sampler, vec2 uv){
	if (uv.x > 0.0 && uv.y > 0.0 && uv.x < 1.0 && uv.y < 1.0)
		return texture(sampler, uv);
	return vec4(0.0);
}

void vertex(){
	if (border_clipping_fix){
		vec2 o = (UV * 2.0 - 1.0);
		VERTEX += o * thickness - offset;
		VERTEX.x *= 1.0 + (aspect_ratio-1.0) * (thickness * TEXTURE_PIXEL_SIZE.x) * 2.0;
	}
}

void fragment(){
	vec2 o = offset / vec2(textureSize(TEXTURE, 0));
	vec2 uv = UV;
	uv -= vec2(0.5);
	if (border_clipping_fix){
		uv.x *= 1.0 + (aspect_ratio-1.0) * thickness * TEXTURE_PIXEL_SIZE.x * 2.0;
		uv *= (1.0 + (thickness * TEXTURE_PIXEL_SIZE * 2.0));
		uv -= o;
	}
	uv += vec2(0.5);
	vec2 size = vec2(thickness) / vec2(textureSize(TEXTURE, 0));

	vec4 sprite_color = tex(TEXTURE, uv);
	float alpha = sprite_color.a;

	if (square_border){
		for(int i=0;i<ring_count;++i){
			float r = float(i) / float(ring_count) + ring_offset;
			alpha = max(alpha,texture(TEXTURE, uv + o + size * square(r) * vec2(aspect_ratio,1.0)).a * outline_color.a);
		}
	}else{
		for(int i=0;i<ring_count;++i){
			float r = float(i) * 3.14159 / float(ring_count) * 2.0 + ring_offset;
			if (max_or_add)
				alpha += tex(TEXTURE, uv + o + vec2(size.x * sin(r) * aspect_ratio, size.y * cos(r))).a * outline_color.a;
			else
				alpha = max(alpha, tex(TEXTURE, uv + o + vec2(size.x * sin(r) * aspect_ratio, size.y * cos(r))).a * outline_color.a);
		}
	}

	vec3 final_rgb = sprite_color.rgb;
	float final_alpha = sprite_color.a;
	if (sprite_color.a > 0.01 && hue_match(sprite_color.rgb, original_0.rgb)) {
		final_rgb = rainbow_rgb(UV);
		final_alpha = rainbow_alpha; // Apply separate alpha to rainbow part
	}

	vec3 mixed = mix(outline_color.rgb, final_rgb, final_alpha);
	COLOR = vec4(mixed, clamp(alpha, 0.0, 1.0));
}
