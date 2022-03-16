#version 330 compatibility
#extension GL_EXT_gpu_shader4: enable
#extension GL_EXT_geometry_shader4: enable
layout( triangles ) in;
layout( triangle_strip, max_vertices=200 ) out;

uniform int uLevel;
uniform float uQuantize;
uniform bool uRadiusOnly;

in vec3 vNormal[3];

out float gLightIntensity;

const vec3 LIGHTPOS = vec3( -20., -20., 20. );
const float PI = 3.14159265;

vec3 V0, V01, V02;
vec3 N0, N01, N02;

float
Sign( float f )
{
        if( f >= 0. )   return  1.;
        return -1.;
}

float
atan2( float y, float x )
{
        if( x == 0. )
        {
                if( y >= 0. )
                        return  PI/2.;
                else
                        return -PI/2.;
        }
        return atan(y,x);
}

float Quantize( float f ) {
	f *= uQuantize;
	f += .5*Sign(f);		// round-off
	int fi = int( f );
	f = float( fi ) / uQuantize;
	
	return f;
}

vec3 CtoS (vec3 v) {
	float r = length( v );
	float theta = atan2( v.z, v.x );
	float phi   = atan2( v.y, length( v.xz ) );

	return vec3(r, theta, phi);
}

vec3 StoC (vec3 v) {
	vec3 vv;
	vv.y = v.x * sin( v.z );
	float xz = v.x * cos( v.z );
	vv.x = xz * cos( v.y );
	vv.z = xz * sin( v.y );

	return vv; 
}


void ProduceVertex( float s, float t ) {
	vec3 v = V0 + (s*V01) + (t*V02);
    	vec3 n = N0 + (s*N01) + (t*N02);
	vec3 tnorm = normalize(gl_NormalMatrix * n);

	v = CtoS(v);
	if(uRadiusOnly) {
		v.x = Quantize(v.x);
	}
	else {
		v.x = Quantize(v.x);
    		v.y = Quantize(v.y);
    		v.z = Quantize(v.z);

	}
	v = StoC(v);

	vec4 ECposition = gl_ModelViewMatrix * vec4( v, 1. );
	gLightIntensity = abs(dot(normalize(LIGHTPOS -	ECposition.xyz), tnorm));
	gl_Position = gl_ProjectionMatrix * ECposition;
	EmitVertex( );
	
}

void main() {
    	V01 = (gl_PositionIn[1] - gl_PositionIn[0]).xyz;
    	V02 = (gl_PositionIn[2] - gl_PositionIn[0]).xyz;
    	V0  = gl_PositionIn[0].xyz;
    	N01 = vNormal[1] - vNormal[0];
    	N02 = vNormal[2] - vNormal[0];
    	N0 = vNormal[0];	

	int numLayers = 1 << uLevel;
	float dt = 1. / float( numLayers );
	float t_top = 1.;
	
	for(int it = 0; it < numLayers; it++) {
		float t_bot = t_top - dt;
		float smax_top = 1. - t_top;
		float smax_bot = 1. - t_bot;
		int nums = it + 1;
		float ds_top = smax_top / float( nums - 1 );
		float ds_bot = smax_bot / float( nums );
		float s_top = 0.;
		float s_bot = 0.;
		for( int is = 0; is < nums; is++ ) {
			ProduceVertex( s_bot, t_bot );
			ProduceVertex( s_top, t_top );
			s_top += ds_top;
			s_bot += ds_bot;
		}
		ProduceVertex( s_bot, t_bot );
		EndPrimitive( );
		t_top = t_bot;
		t_bot -= dt;	
	}
}