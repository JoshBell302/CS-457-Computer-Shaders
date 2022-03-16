#version 330 compatibility

in vec4  vColor;
in vec3 	vMCposition;
in float 	vLightIntensity;
in vec2  	vST;

uniform float	uTol;
uniform vec4 	uSquareColor;
uniform float	uNoiseFreq;
uniform float	uNoiseAmp;
uniform float 	uAd;	
uniform float 	uBd;

uniform sampler2D Noise2;

const float PI = 3.14159265;

uniform float Timer;
float Time = sin(2.*PI*Timer/2.);

void
main( )
{
	Time = Time + 0.2;
	vec4 nv = texture( Noise2, uNoiseFreq * Time * vST );
	float n = nv.r + nv.g + nv.b + nv.a;
	n = ( n - 2. );
	n *= uNoiseAmp;

	float s = vST.s;
	float t = vST.t;
	int numins = int( s / uAd );
	int numint = int( t / uBd );
	float aRadius = uAd/2.;
 	float bRadius = uBd/2.;
	float scenter = float(numins)*uAd + aRadius; 
	float tcenter = float(numint)*uBd + bRadius; 

	float ds = s - scenter;
	float dt = t - tcenter;
	float oldDistance = sqrt(pow(ds,2) + pow(dt,2));
	float newDistance = oldDistance + n;
	float scale = (newDistance / oldDistance);
	ds *= scale;
	ds /= aRadius;
	dt *= scale;
	dt /= bRadius;
	 
	float d = pow(ds,2) + pow(dt,2);

	float sStep= smoothstep( 1.-uTol, 1.+uTol, d );

	gl_FragColor = mix( vec4(uSquareColor.r*Time, uSquareColor.g*Time, uSquareColor.b+Time, 1.),  vec4(vColor.r+Time, vColor.g+Time, vColor.b+Time, 1.), sStep );
	gl_FragColor.rgb *= vLightIntensity;	
}

