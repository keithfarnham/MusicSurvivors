shader_type canvas_item;

uniform bool enabled = false;

void fragment() {
	if(enabled) {
	    vec4 color = texture(TEXTURE, UV);
	    COLOR = vec4(1.0 - color.rgb, color.a);
	}
}