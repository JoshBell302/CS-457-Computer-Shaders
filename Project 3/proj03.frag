#version 330 compatibility

uniform float uKa, uKd, uKs;
uniform vec4 uColor;
uniform vec4 uSpecularColor;
uniform float uShininess;

in vec3 vNs;
in vec3 vLs;
in vec3 vEs;

void 
main( )
{
  	vec3 Normal = normalize(vNs);
  	vec3 Light = normalize(vLs);
  	vec3 Eye = normalize(vEs);
  	vec4 ambient = uKa * uColor;
  	float d = max( dot(Normal,Light), 0.f );
  	vec4 diffuse = uKd * d * uColor;
  	float s = 0.f;

  	if( dot(Normal,Light) > 0.f )
	{ 
    		vec3 ref = normalize( 2. * Normal * dot(Normal,Light) - Light );
    		s = pow( max( dot(Eye,ref),0.f ), uShininess );
  	}

  	vec4 specular = uKs * s * uSpecularColor;
  	gl_FragColor = vec4( ambient.rgb + diffuse.rgb + specular.rgb, 1.f );
}
