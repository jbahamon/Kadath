shader_type canvas_item;

uniform vec4 add = vec4(1, 1, 1, 0);

void fragment(){
  COLOR = texture(TEXTURE, UV) + 0.25 * vec4(vec3(sin(2.0 * TIME * PI) + 0.25), 0) ;
}