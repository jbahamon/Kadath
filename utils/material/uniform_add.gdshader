shader_type canvas_item;

uniform vec4 add: source_color = vec4(1, 1, 1, 0);

void fragment(){
  COLOR = texture(TEXTURE, UV) + add;
}