shader_type canvas_item;

uniform sampler2D NOISE_PATTERN;
uniform float progress : hint_range(0.0, 1.0) = 0;

void fragment() {
	// Get size of texture in pixels
	float size_x = float(textureSize(TEXTURE, 0).x);
	float size_y = float(textureSize(TEXTURE, 0).y);
	//
	float threshold = texture(NOISE_PATTERN, UV).x;
	float visible = step(progress, threshold);
	// Draw the pixel, or not depending on if it is visible or not
	COLOR.a = (visible > 0.0)? COLOR.a : 0.0;

}
