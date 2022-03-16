#version 330 compatibility

in vec4  vColor;
in vec3 	vMCposition;
in float 	vLightIntensity;
in vec2  	vST;

uniform float	uTol;
uniform vec4 	uSquareColor;

uniform sampler2D Noise2;

uniform float Timer;
float Time = Timer > 0.5 ? 1. - Timer : Timer;

void
main( )
{
	float uNoiseFreq = 5.9189;
	float uNoiseAmp = 0.2012;
	float uAd = 0.0010;
	float uBd = 0.0010;
	vec4 nv = texture( Noise2, uNoiseFreq * Time * vST );
	float n = nv.r + nv.g + nv.b + nv.a;
	n = ( n - 2. );
	n *= uNoiseAmp*Time;

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
	float scale = newDistance / oldDistance;
	ds *= scale;
	ds /= aRadius;
	dt *= scale;
	dt /= bRadius;
	
	float d = pow(ds,2) + pow(dt,2);

	float sStep= smoothstep( 1.-uTol, 1.+uTol, d );

	gl_FragColor = mix( vec4(.12*Time, .46*Time, .9, 1.), vec4(.89, .5*Time, .5*Time, 1.), sStep );
	gl_FragColor.rgb *= vLightIntensity;	
}

