#version 330 compatibility

uniform sampler3D Noise3;
uniform float uNoiseAmp;
uniform float uNoiseFreq;
uniform float uBiasx, uBiasy, uBiasz;
uniform float uLightX, uLightY, uLightZ;

out vec3 vNs;
out vec3 vLs;
out vec3 vEs;
out vec3 vMC;
uniform float uDelta;

vec3 DELTAX = vec3( uDelta, 0., 0. );
vec3 DELTAY = vec3( 0., uDelta, 0. );

float 
Height( vec3 mc )
{
	vec3 newmc = vec3( mc.x+uBiasx, mc.y+uBiasy, mc.z );
	vec4 nv = texture( Noise3, uNoiseFreq * newmc );
	float n = nv.r + nv.g + nv.b + nv.a;
	n = n - 2.;
	n = n + uBiasz;
	n *= uNoiseAmp;
	return n;
}

void 
main( )
{
	float h00 = Height( gl_Vertex.xyz );
	float hp0 = Height( gl_Vertex.xyz + DELTAX );
	float hm0 = Height( gl_Vertex.xyz - DELTAX );
	float h0p = Height( gl_Vertex.xyz + DELTAY );
	float h0m = Height( gl_Vertex.xyz - DELTAY );
	
	float dzdx = hp0 - hm0;
	vec3 xtangent = vec3( 1., 0., dzdx );
	float dzdy = h0p - h0m;
	vec3 ytangent = vec3( 0., 1., dzdy );
	//vNs = normalize( gl_NormalMatrix * cross( xtangent, ytangent ) );
	vNs = normalize( cross( xtangent, ytangent ) );

	vec3 new = gl_Vertex.xyz;
	new.z += h00; // displace the point
	if( new.z < 0. )
		new.z = 0.;
	vMC = new;

	vec4 ECposition = gl_ModelViewMatrix * vec4( new, 1. );
	vec3 eyeLightPosition = vec3( uLightX, uLightY, uLightZ );

	vLs = normalize( eyeLightPosition - ECposition.xyz );
	vEs = normalize( vec3( 0., 0., 0. ) - ECposition.xyz );

	gl_Position = gl_ModelViewProjectionMatrix * vec4( new, 1. );
}