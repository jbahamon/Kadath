shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D NOISE_PATTERN;
uniform float progress : hint_range(0.0, 1.0) = 0;

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 1.0);
	float threshold = texture(NOISE_PATTERN, UV).x;
	float visible = step(progress, threshold);
	// Draw the pixel, or not depending on if it is visible or not
	COLOR = c;
	COLOR.a = (visible > 0.0)? c.a : 0.0;

}
