shader_type canvas_item;
render_mode blend_add;

uniform vec3 tint_color : source_color = vec3(1.0, 0.0, 0.0);
uniform float intensity : hint_range(0, 1) = 0.5;
uniform float progress : hint_range(0.0, 1.0) = 0;

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 438.5453);
}

void fragment() {
	// Get size of texture in pixels
	float size_x = float(textureSize(TEXTURE, 0).x);
	float size_y = float(textureSize(TEXTURE, 0).y);
	//
	vec4 pixelColor = texture(TEXTURE, UV);
	// Create a new "UV" which remaps every UV value to a snapped pixel value
	vec2 UVr = vec2(floor(UV.x*size_x)/size_x, floor(UV.y*size_y)/size_y);
	// Determine whether pixel should be visible or not
	float visible = step(progress, random(UVr));
	// Draw the pixel, or not depending on if it is visible or not
	float avg = ((pixelColor.r + pixelColor.g + pixelColor.b) / 3.0  * 2.0);

    vec4 front = vec4(vec3(avg), min(visible, pixelColor.a/2.0)) ;
	COLOR = mix(front, vec4(tint_color, front.a), intensity);

}
