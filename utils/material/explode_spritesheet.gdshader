shader_type canvas_item;

uniform vec2 frames;

uniform sampler2D noise_tex_normal;
uniform sampler2D noise_tex;
uniform float progress : hint_range(0.0, 1.0);	
uniform float strength = 1.0;
uniform float min_x = -1.0;
uniform float max_x = 1.0;
uniform float min_y = -1.0;
uniform float max_y = 1.0;

void fragment() {
	// UV for exploded texture
	vec2 tex_size = 1.0 / TEXTURE_PIXEL_SIZE; // Real texture size in pixels
	vec2 frame_size = tex_size/frames;
	vec2 coords = floor(frames * UV);
	vec2 new_uv = 1.0 - ((coords + vec2(1.0, 1.0)) - tex_size * UV / frame_size);
	
	vec2 direction = texture(noise_tex_normal, new_uv).xy; // We're using normal map as direction
	direction.x = fma(direction.x, max_x - min_x, min_x); 
	direction.y = fma(direction.y, max_y - min_y, min_y	); 
	
	direction = direction * strength * progress / frames;
	
	vec2 uv = floor(UV * tex_size) / (tex_size - 1.0); // Pixelate UV to snap pixels
	uv = uv - direction; // Distort UV
	
	vec4 texture_color = texture(TEXTURE, uv);
	
	// Dissolve alpha
	float dissolve = texture(noise_tex, new_uv).x;
	dissolve = step(progress, dissolve);
	texture_color.a *= dissolve;
	
	vec2 region = step(coords/frames, uv) * step(uv, (coords + vec2(1.0, 1.0))/frames);
	texture_color.a *= region.x * region.y;
	COLOR = texture_color;
}