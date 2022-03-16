#version 330 compatibility

in vec4  vColor;
in float vLightIntensity;
in vec2  vST;

uniform float	uTol;
uniform vec4 	uSquareColor;
uniform float 	uAd;	
uniform float 	uBd; 

void
main( )
{
	float s = vST.s;
	float t = vST.t;
	int numins = int( s / uAd );
	int numint = int( t / uBd );
	float aRadius = uAd/2.;
 	float bRadius = uBd/2.;
	float scenter = float(numins)*uAd + aRadius; 
	float tcenter = float(numint)*uBd + bRadius; 
	gl_FragColor = vColor;		
	float d = pow((s-scenter)/aRadius , 2) + pow((t-tcenter)/bRadius , 2);
	float sStep= smoothstep( 1.-uTol, 1.+uTol, d );
	gl_FragColor = mix( uSquareColor, vColor, sStep );
	gl_FragColor.rgb *= vLightIntensity;	// apply lighting model
}
