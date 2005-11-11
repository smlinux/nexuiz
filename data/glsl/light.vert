
// ambient+diffuse+specular+normalmap+attenuation+cubemap+fog shader
// written by Forest 'LordHavoc' Hale

// use half floats if available for math performance
#ifdef GEFORCEFX
#define myhalf half
#define myhvec2 hvec2
#define myhvec3 hvec3
#define myhvec4 hvec4
#else
#define myhalf float
#define myhvec2 vec2
#define myhvec3 vec3
#define myhvec4 vec4
#endif

uniform vec3 LightPosition;

varying vec2 TexCoord;
varying myhvec3 CubeVector;
varying vec3 LightVector;

#if defined(USESPECULAR) || defined(USEFOG) || defined(USEOFFSETMAPPING)
uniform vec3 EyePosition;
varying vec3 EyeVector;
#endif

// TODO: get rid of tangentt (texcoord2) and use a crossproduct to regenerate it from tangents (texcoord1) and normal (texcoord3)

void main(void)
{
	// copy the surface texcoord
	TexCoord = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);

	// transform vertex position into light attenuation/cubemap space
	// (-1 to +1 across the light box)
	CubeVector = vec3(gl_TextureMatrix[3] * gl_Vertex);

	// transform unnormalized light direction into tangent space
	// (we use unnormalized to ensure that it interpolates correctly and then
	//  normalize it per pixel)
	vec3 lightminusvertex = LightPosition - gl_Vertex.xyz;
	LightVector.x = -dot(lightminusvertex, gl_MultiTexCoord1.xyz);
	LightVector.y = -dot(lightminusvertex, gl_MultiTexCoord2.xyz);
	LightVector.z = -dot(lightminusvertex, gl_MultiTexCoord3.xyz);

#if defined(USESPECULAR) || defined(USEFOG) || defined(USEOFFSETMAPPING)
	// transform unnormalized eye direction into tangent space
	vec3 eyeminusvertex = EyePosition - gl_Vertex.xyz;
	EyeVector.x = -dot(eyeminusvertex, gl_MultiTexCoord1.xyz);
	EyeVector.y = -dot(eyeminusvertex, gl_MultiTexCoord2.xyz);
	EyeVector.z = -dot(eyeminusvertex, gl_MultiTexCoord3.xyz);
#endif

	// transform vertex to camera space, using ftransform to match non-VS
	// rendering
	gl_Position = ftransform();
}

