#version 330 compatibility
uniform float uLightX, uLightY, uLightZ;
out vec3 vNs;
out vec3 vLs;
out vec3 vEs;
uniform float uA;
uniform float uK;

uniform sampler3D Noise3;
uniform float uNoiseFreq;
uniform float uNoiseAmp;

vec3 eyeLightPosition = vec3( uLightX, uLightY, uLightZ );

// From Resource Page START ------------------------------------
float 
Sinc( float r, float k )
{
	if( r*k == 0. )
		return 1.;
	return sin(r*k) / (r*k);
}

float 
DerivSinc( float r, float k )
{
	if( r*k == 0. )
		return 0;
	return ( r*k*cos(r*k) - sin(r*k) ) / ( r*k*r*k );
}

vec3 
RotateNormal( float angx, float angy, vec3 n )
{
  	float cx = cos( angx );
  	float sx = sin( angx );
  	float cy = cos( angy );
  	float sy = sin( angy );
  
	// rotate about x:
  	float yp =  n.y*cx - n.z*sx;    // y'
  	n.z =  n.y*sx + n.z*cx;    	// z'
  	n.y =  yp;
  	// n.x =  n.x;
  
	// rotate about y:
  	float xp =  n.x*cy + n.z*sy;    // x'
  	n.z = -n.x*sy + n.z*cy;    	// z'
  	n.x =  xp;
  	// n.y =  n.y;

  	return normalize( n );
}

void 
main( ) {
  	vec4 newVertex = gl_Vertex;
  	vec3 vMC = gl_Vertex.xyz;
  	float r = sqrt( newVertex.x*newVertex.x + 	newVertex.y*newVertex.y );
  	newVertex.z = uA * Sinc( r, uK );

  	float dzdr = uA * DerivSinc( r, uK );
  	float drdx = newVertex.x / r;
  	float drdy = newVertex.y / r;
  	float dzdx = dzdr * drdx;
  	float dzdy = dzdr * drdy;

  	vec3 Tx = vec3(1., 0., dzdx );
  	vec3 Ty = vec3(0., 1., dzdy );

  	vec4 nvx = texture( Noise3, uNoiseFreq*vMC );
  	float angx = nvx.r + nvx.g + nvx.b + nvx.a  -  2.;	// -1. to +1.
  	angx *= uNoiseAmp;

  	vec4 nvy = texture( Noise3, uNoiseFreq*vec3(vMC.xy,vMC.z+0.5) );
  	float angy = nvy.r + nvy.g + nvy.b + nvy.a  -  2.;	// -1. to +1.
  	angy *= uNoiseAmp;

// From Resource Page END --------------------------------------

  	vec3 newNormal = RotateNormal(angx, angy, cross(Tx, Ty));
  	vec4 ECposition = gl_ModelViewMatrix * gl_Vertex;
  	vNs = normalize( gl_NormalMatrix * newNormal ); // surface normal vector
  	vLs = eyeLightPosition - ECposition.xyz; // vector from the point
  	vEs = vec3( 0., 0., 0. ) - ECposition.xyz; // vector from the point
  	gl_Position = gl_ModelViewProjectionMatrix * newVertex;
}
