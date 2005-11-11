
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

uniform myhvec3 LightColor;
#ifdef USEOFFSETMAPPING
uniform myhalf OffsetMapping_Scale;
uniform myhalf OffsetMapping_Bias;
#endif
#ifdef USESPECULAR
uniform myhalf SpecularPower;
#endif
#ifdef USEFOG
uniform myhalf FogRangeRecip;
#endif
uniform myhalf AmbientScale;
uniform myhalf DiffuseScale;
#ifdef USESPECULAR
uniform myhalf SpecularScale;
#endif

uniform sampler2D Texture_Normal;
uniform sampler2D Texture_Color;
#ifdef USESPECULAR
uniform sampler2D Texture_Gloss;
#endif
#ifdef USECUBEFILTER
uniform samplerCube Texture_Cube;
#endif
#ifdef USEFOG
uniform sampler2D Texture_FogMask;
#endif

varying vec2 TexCoord;
varying myhvec3 CubeVector;
varying vec3 LightVector;
#if defined(USESPECULAR) || defined(USEFOG) || defined(USEOFFSETMAPPING)
varying vec3 EyeVector;
#endif

void main(void)
{
	// attenuation
	//
	// the attenuation is (1-(x*x+y*y+z*z)) which gives a large bright
	// center and sharp falloff at the edge, this is about the most efficient
	// we can get away with as far as providing illumination.
	//
	// pow(1-(x*x+y*y+z*z), 4) is far more realistic but needs large lights to
	// provide significant illumination, large = slow = pain.
	myhalf colorscale = max(1.0 - dot(CubeVector, CubeVector), 0.0);

#ifdef USEFOG
	// apply fog
	colorscale *= texture2D(Texture_FogMask, myhvec2(length(EyeVector)*FogRangeRecip, 0)).x;
#endif

#ifdef USEOFFSETMAPPING
	// this is 3 sample because of ATI Radeon 9500-9800/X300 limits
	myhvec2 OffsetVector = normalize(EyeVector).xy * vec2(-0.333, 0.333);
	myhvec2 TexCoordOffset = TexCoord + OffsetVector * (OffsetMapping_Bias + OffsetMapping_Scale * texture2D(Texture_Normal, TexCoord).w);
	TexCoordOffset += OffsetVector * (OffsetMapping_Bias + OffsetMapping_Scale * texture2D(Texture_Normal, TexCoordOffset).w);
	TexCoordOffset += OffsetVector * (OffsetMapping_Bias + OffsetMapping_Scale * texture2D(Texture_Normal, TexCoordOffset).w);
#define TexCoord TexCoordOffset
#endif

	// get the surface normal
#ifdef SURFACENORMALIZE
	myhvec3 surfacenormal = normalize(myhvec3(texture2D(Texture_Normal, TexCoord)) - 0.5);
#else
	myhvec3 surfacenormal = -1.0 + 2.0 * myhvec3(texture2D(Texture_Normal, TexCoord));
#endif

	// calculate shading
	myhvec3 diffusenormal = myhvec3(normalize(LightVector));
	myhvec3 color = myhvec3(texture2D(Texture_Color, TexCoord)) * (AmbientScale + DiffuseScale * max(dot(surfacenormal, diffusenormal), 0.0));
#ifdef USESPECULAR
	myhvec3 specularnormal = myhvec3(normalize(diffusenormal + myhvec3(normalize(EyeVector))));
	color += myhvec3(texture2D(Texture_Gloss, TexCoord)) * SpecularScale * pow(max(dot(surfacenormal, specularnormal), 0.0), SpecularPower);
#endif

#ifdef USECUBEFILTER
	// apply light cubemap filter
	color *= myhvec3(textureCube(Texture_Cube, CubeVector));
#endif

	// calculate fragment color (apply light color and attenuation/fog scaling)
	gl_FragColor = myhvec4(color * LightColor * colorscale, 1);
}

