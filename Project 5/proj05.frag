#version 330 compatibility
#define PI 3.1415926538

uniform float uPower;
uniform float uRtheta;
uniform float uBlend;
uniform float uContrast;
uniform sampler2D TexUnitA;
uniform sampler2D TexUnitB;

in vec2 vST;

const vec4 BLACK = vec4( 0., 0., 0., 1. );

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


void
main()
{
// Fisheye
vec2 st = vST - vec2(0.5,0.5);
float r = length(st);
float rPrime = pow(2*r, uPower);

// Whirl
float theta = atan2(st.t, st.s);
float thetaPrime = theta - uRtheta * r;

// Restoring
st = rPrime * vec2( cos (thetaPrime), sin (thetaPrime));
st += 1;
st *= 0.5;


// if s or t wander outside the range [0.,1.], paint the pixel black
if( st.t <= 0 || st.s <= 0)
	gl_FragColor = BLACK;
else
	if(  st.t >= 1 || st.s >= 1 )
		gl_FragColor = BLACK;
	else
	{
		vec3 slowpoke = texture(TexUnitA, st).rgb;
		vec3 slowbro = texture(TexUnitB, st).rgb;
		vec3 blend = mix( slowpoke, slowbro, uBlend);
		vec3 iOut = (1-uContrast)*vec3(0.5, 0.5, 0.5) + uContrast*blend;
		gl_FragColor = vec4( iOut, 1. );
	}
}