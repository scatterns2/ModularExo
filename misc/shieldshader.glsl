#define pi 3.141592653589793238462643383279

float lineDist(vec2 pt1, vec2 pt2, vec2 testPt) {
	vec2 lineDir = pt2 - pt1;
	vec2 perpDir = vec2(lineDir.y, -lineDir.x);
	vec2 dirToPt1 = pt1 - testPt;
	return abs(dot(normalize(perpDir), dirToPt1));
}

float lineSegmentDist(vec2 a, vec2 b, vec2 p) {
	vec2 c = p-a;
	vec2 v = normalize(b-a);
	float d = length(b-a);
	float t = dot(v, c);
	if(t < 0.0) return length(c);
	if(t > d) return length(p-b);
	v *= t;
	return length(v-c);
}

bool pointInHexagon(vec2 c, float d, vec2 p) {
	vec2 dp = abs(p-c)/d;
    float a = 0.25 * sqrt(3.0);
    return (dp.y <= a) && (a*dp.x + 0.25*dp.y <= 0.5*a);
}

void main(void)
{
	float scale = 0.74;
	float size = 10.0;
	float rad = 36.0;
	
	vec2 p = gl_FragCoord.xy-iResolution.xy/2.0;
	vec3 col = vec3(0.0, 0.0, 0.0);
	bool bc = false;
	
	float ratio = sin(pi/3.0);
	p.x = mod(p.x, rad*4.0*ratio);
	p.y = mod(p.y, rad*2.0);
	float dist = 9999.0;
	//dist = max(dist, 1.0/lineSegmentDist(vec2(0.0, 0.0), vec2(rad*4.0*ratio, 0.0), p));
	//dist = max(dist, 1.0/lineSegmentDist(vec2(rad*4.0*ratio, 0.0), vec2(rad*4.0*ratio, rad*2.0), p));
	//dist = max(dist, 1.0/lineSegmentDist(vec2(rad*4.0*ratio, rad*2.0), vec2(0.0, rad*2.0), p));
	//dist = max(dist, 1.0/lineSegmentDist(vec2(0.0, rad*2.0), vec2(0.0, 0.0), p));
	p += vec2(-rad/ratio, 0);
	for(int hexI = 0; hexI < 7; hexI++) {
		vec2 o = (p-(
				hexI == 1 ? vec2( rad*2.0*ratio, -rad/1.0)
			:	hexI == 2 ? vec2( rad*2.0*ratio,  rad/1.0)
			:	hexI == 3 ? vec2(-rad*2.0*ratio, -rad/1.0)
			:	hexI == 4 ? vec2(-rad*2.0*ratio,  rad/1.0)
			:	hexI == 5 ? vec2( 0            , -rad*2.0)
			:	hexI == 6 ? vec2( 0            ,  rad*2.0)
			:   vec2(0, 0)
		));
		vec2 p_mr = vec2(cos( 0.0*pi/3.0), sin( 0.0*pi/3.0))*rad/ratio*scale;
		vec2 p_tr = vec2(cos( 1.0*pi/3.0), sin( 1.0*pi/3.0))*rad/ratio*scale;
		vec2 p_tl = vec2(cos( 2.0*pi/3.0), sin( 2.0*pi/3.0))*rad/ratio*scale;
		vec2 p_ml = vec2(cos( 3.0*pi/3.0), sin( 3.0*pi/3.0))*rad/ratio*scale;
		vec2 p_bl = vec2(cos( 4.0*pi/3.0), sin( 4.0*pi/3.0))*rad/ratio*scale;
		vec2 p_br = vec2(cos( 5.0*pi/3.0), sin( 5.0*pi/3.0))*rad/ratio*scale;
		
		dist = min(dist, lineSegmentDist(p_mr, p_tr, o));
		dist = min(dist, lineSegmentDist(p_tr, p_tl, o));
		dist = min(dist, lineSegmentDist(p_tl, p_ml, o));
		dist = min(dist, lineSegmentDist(p_ml, p_bl, o));
		dist = min(dist, lineSegmentDist(p_bl, p_br, o));
		dist = min(dist, lineSegmentDist(p_br, p_mr, o));
	}
	
	//dist = max(dist, 1.0/lineSegmentDist(vec2(0.0, 0.0), vec2(0, rad), p));
	
	float val = min(1.0, 1.0-dist/size);
	/*if(pointInHexagon(vec2(0, 0), rad*2.0, p)) {
		val *= 2.0;
	}*/
	val = clamp(val, 0.0, 1.0);
	col = vec3(0.05, 0.14, 1.0)*val;
	
	gl_FragColor = mix(vec4(col, 1), texture2D(iChannel1, p/iResolution.xy), 1.0-val);
}
