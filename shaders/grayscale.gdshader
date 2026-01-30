// By Amy Gilhespy.
// I hereby dedicate this shader to the public domain.
// https://creativecommons.org/publicdomain/zero/1.0/


shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float edge_intensity : hint_range(0.0, 1.0, 0.1) = 0.5;

vec3 hsl2rgb(vec3 hsl)
{
	float l = clamp(hsl.z, 0.0, 1.0);
    vec3 rgb = clamp(abs(mod(fract(hsl.x) * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 0.0, 1.0);
    return l + clamp(hsl.y, 0.0, 1.0) * (rgb - 0.5) * (1.0 - abs(2.0 * l - 1.0));
}

vec3 rgb2hsl(in vec3 rgb)
{
	float h = 0.0;
	float s = 0.0;
	float l = 0.0;
	float r = rgb.r;
	float g = rgb.g;
	float b = rgb.b;
	float cMin = min(r, min(g, b));
	float cMax = max(r, max(g, b));
	l = (cMax + cMin) * 0.5;
	if (cMax > cMin) {
		float cDelta = cMax - cMin;
		float invCDelta = 1.0 / cDelta;
		s = l < 0.5 ? cDelta / (cMax + cMin) : cDelta / (2.0 - (cMax + cMin));
		if (r == cMax) {
			h = (g - b) * invCDelta;
		} else if (g == cMax) {
			h = 2.0 + (b - r) * invCDelta;
		} else {
			h = 4.0 + (r - g) * invCDelta;
		}
		if ( h < 0.0) {
			h += 6.0;
		}
		h = h * (1.0 / 6.0);
	}
	return vec3(h, s, l);
}

void fragment() {
	// Get the color behind the ColorRect (or whatever CanvasItem you use):
	vec4 source = texture(SCREEN_TEXTURE, SCREEN_UV);

	// Calculate distance from center (0 at center, 1 at edges):
	vec2 center = vec2(0.5, 0.5);
	float dist = length(SCREEN_UV - center) * 2.0;

	// Calculate darkening amount based on distance and intensity
	float darkening = dist * edge_intensity;

	// Get the color chosen in the ColorRect (also works with Modulate, textures, etc):
	vec4 shift = vec4(COLOR.rgb / texture(TEXTURE, UV).rgb, COLOR.a);

	// Convert and shift the color as HSL (Hue is added, Sat/Lum are multiplied):
	vec3 hsl = rgb2hsl(source.rgb);
	
	// Apply shift to saturation and hue
	hsl.y *= shift.g;
	hsl.x += shift.r;
	
	// Apply darkening to lightness based on distance from center
	hsl.z = max(0.0, hsl.z - darkening);
	
	vec3 rgb = hsl2rgb(hsl);
	
	float alpha = source.a * shift.a;
	COLOR = vec4(rgb, alpha);
}
