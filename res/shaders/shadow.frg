varying vec2 v_texCoord;

vec4 composite(vec4 over, vec4 under){
	return over + (1.0 - over.a)*under;
}

void main() {
	vec4 c = texture2D(CC_Texture0, v_texCoord);
	
	vec2 shadowOffset = vec2(15.0 / 1951.0, -15.0/2048.0);
	float shadowMask = texture2D(CC_Texture0, v_texCoord + shadowOffset).a;
	
	const float shadowOpacity = 0.5;
	vec4 shadowColor = vec4(vec3(0.0), shadowMask*shadowOpacity);
	
	gl_FragColor = composite(c, shadowColor);
}