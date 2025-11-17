shader_type canvas_item;

uniform int color_count = 1;

uniform vec4 from_colors[8];
uniform vec4 to_colors[8];

uniform float tolerance : hint_range(0.0, 1.0) = 0.05;

void fragment() {
    vec4 c = texture(TEXTURE, UV);

    for (int i = 0; i < color_count; i++) {
        // Compare difference in RGB
        float diff = distance(c.rgb, from_colors[i].rgb);

        if (diff <= tolerance) {
            // Replace with target color, keep original alpha
            c.rgb = to_colors[i].rgb;
        }
    }

    COLOR = c;
}
