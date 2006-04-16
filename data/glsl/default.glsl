// ambient+diffuse+specular+normalmap+attenuation+cubemap+fog shader
// written by Forest 'LordHavoc' Hale

// common definitions between vertex shader and fragment shader:

#ifdef __GLSL_CG_DATA_TYPES
#define myhalf half
#define myhvec2 hvec2
#define myhvec3 hvec3
#else
#define myhalf float
#define myhvec2 vec2
#define myhvec3 vec3
#endif


varying vec2 TexCoord;
varying vec2 TexCoordLightmap;

varying myhvec3 CubeVector;
varying vec3 LightVector;
varying vec3 EyeVector;
#ifdef USEFOG
varying vec3 EyeVectorModelSpace;
#endif

varying myhvec3 VectorS; // direction of S texcoord (sometimes crudely called tangent)
varying myhvec3 VectorT; // direction of T texcoord (sometimes crudely called binormal)
varying myhvec3 VectorR; // direction of R texcoord (surface normal)




// vertex shader specific:
#ifdef VERTEX_SHADER

uniform vec3 LightPosition;
uniform vec3 EyePosition;
uniform myhvec3 LightDir;

// TODO: get rid of tangentt (texcoord2) and use a crossproduct to regenerate it from tangents (texcoord1) and normal (texcoord3)

void main(void)
{
	gl_FrontColor = gl_Color;
	// copy the surface texcoord
	TexCoord = vec2(gl_TextureMatrix[0] * gl_MultiTexCoord0);
#if !defined(MODE_LIGHTSOURCE) && !defined(MODE_LIGHTDIRECTION)
	TexCoordLightmap = vec2(gl_MultiTexCoord4);
#endif

#ifdef MODE_LIGHTSOURCE
	// transform vertex position into light attenuation/cubemap space
	// (-1 to +1 across the light box)
	CubeVector = vec3(gl_TextureMatrix[3] * gl_Vertex);

	// transform unnormalized light direction into tangent space
	// (we use unnormalized to ensure that it interpolates correctly and then
	//  normalize it per pixel)
	vec3 lightminusvertex = LightPosition - gl_Vertex.xyz;
	LightVector.x = dot(lightminusvertex, gl_MultiTexCoord1.xyz);
	LightVector.y = dot(lightminusvertex, gl_MultiTexCoord2.xyz);
	LightVector.z = dot(lightminusvertex, gl_MultiTexCoord3.xyz);
#endif

#ifdef MODE_LIGHTDIRECTION
	LightVector.x = dot(LightDir, gl_MultiTexCoord1.xyz);
	LightVector.y = dot(LightDir, gl_MultiTexCoord2.xyz);
	LightVector.z = dot(LightDir, gl_MultiTexCoord3.xyz);
#endif

	// transform unnormalized eye direction into tangent space
#ifndef USEFOG
	vec3 EyeVectorModelSpace;
#endif
	EyeVectorModelSpace = EyePosition - gl_Vertex.xyz;
	EyeVector.x = dot(EyeVectorModelSpace, gl_MultiTexCoord1.xyz);
	EyeVector.y = dot(EyeVectorModelSpace, gl_MultiTexCoord2.xyz);
	EyeVector.z = dot(EyeVectorModelSpace, gl_MultiTexCoord3.xyz);

#ifdef MODE_LIGHTDIRECTIONMAP_MODELSPACE
	VectorS = gl_MultiTexCoord1.xyz;
	VectorT = gl_MultiTexCoord2.xyz;
	VectorR = gl_MultiTexCoord3.xyz;
#endif

	// transform vertex to camera space, using ftransform to match non-VS
	// rendering
	gl_Position = ftransform();
}

#endif // VERTEX_SHADER




// fragment shader specific:
#ifdef FRAGMENT_SHADER

uniform sampler2D Texture_Normal;
uniform sampler2D Texture_Color;
uniform sampler2D Texture_Gloss;
uniform samplerCube Texture_Cube;
uniform sampler2D Texture_FogMask;
uniform sampler2D Texture_Pants;
uniform sampler2D Texture_Shirt;
uniform sampler2D Texture_Lightmap;
uniform sampler2D Texture_Deluxemap;
uniform sampler2D Texture_Glow;

uniform myhvec3 LightColor;
uniform myhvec3 AmbientColor;
uniform myhvec3 DiffuseColor;
uniform myhvec3 SpecularColor;
uniform myhvec3 Color_Pants;
uniform myhvec3 Color_Shirt;
uniform myhvec3 FogColor;

uniform myhalf OffsetMapping_Scale;
uniform myhalf OffsetMapping_Bias;
uniform myhalf FogRangeRecip;

uniform myhalf AmbientScale;
uniform myhalf DiffuseScale;
uniform myhalf SpecularScale;
uniform myhalf SpecularPower;

void main(void)
{
	// apply offsetmapping
#ifdef USEOFFSETMAPPING
	myhvec2 TexCoordOffset = myhvec2(TexCoord);
#define TexCoord TexCoordOffset

	myhvec3 eyedir = myhvec3(normalize(EyeVector));

#ifdef USEOFFSETMAPPING_RELIEFMAPPING
	myhalf depthbias = 1.0 - eyedir.z; // should this be a -?
	depthbias = 1.0 - depthbias * depthbias;

	// 14 sample relief mapping: linear search and then binary search
	myhvec3 OffsetVector = myhvec3(EyeVector.xy * (1.0 / EyeVector.z) * depthbias * OffsetMapping_Scale * myhvec2(-0.1, 0.1), -0.1);
	vec3 RT = vec3(TexCoord - OffsetVector.xy * 10.0, 1.0) + OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;OffsetVector *= 0.5;RT -= OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;OffsetVector *= 0.5;RT -= OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;OffsetVector *= 0.5;RT -= OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;OffsetVector *= 0.5;RT -= OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;OffsetVector *= 0.5;RT -= OffsetVector;
	if (RT.z > texture2D(Texture_Normal, RT.xy).a) RT += OffsetVector;OffsetVector *= 0.5;RT -= OffsetVector;
	TexCoord = RT.xy;
#else

	// parallax mapping as described in the paper
	// "Parallax Mapping with Offset Limiting: A Per-Pixel Approximation of Uneven Surfaces" by Terry Welsh
	// The paper provides code in the ARB fragment program assembly language
	// I translated it to GLSL but may have done something wrong - SavageX
	myhalf height = texture2D(Texture_Normal, TexCoord).a;
	height = (height * myhalf(OffsetMapping_Scale)) + myhalf(-0.02); // scale and bias
	TexCoordOffset += myhalf(height) * myhvec2(eyedir.x, -1.0 * eyedir.y);
	
#endif
#endif

	// combine the diffuse textures (base, pants, shirt)
	vec4 color = vec4(texture2D(Texture_Color, TexCoord));
#ifdef USECOLORMAPPING
	color.rgb += myhvec3(texture2D(Texture_Pants, TexCoord)) * Color_Pants + myhvec3(texture2D(Texture_Shirt, TexCoord)) * Color_Shirt;
#endif




#ifdef MODE_LIGHTSOURCE
	// light source

	// get the surface normal and light normal
	myhvec3 surfacenormal = normalize(myhvec3(texture2D(Texture_Normal, TexCoord)) - 0.5);
	myhvec3 diffusenormal = myhvec3(normalize(LightVector));

	// calculate directional shading
	color.rgb *= (AmbientScale + DiffuseScale * max(dot(surfacenormal, diffusenormal), 0.0));
#ifdef USESPECULAR
	myhvec3 specularnormal = myhvec3(normalize(diffusenormal + myhvec3(normalize(EyeVector))));
	color.rgb += myhvec3(texture2D(Texture_Gloss, TexCoord)) * SpecularScale * pow(max(dot(surfacenormal, specularnormal), 0.0), SpecularPower);
#endif

#ifdef USECUBEFILTER
	// apply light cubemap filter
	//color.rgb *= normalize(CubeVector) * 0.5 + 0.5;//vec3(textureCube(Texture_Cube, CubeVector));
	color.rgb *= myhvec3(textureCube(Texture_Cube, CubeVector));
#endif

	// apply light color
	color.rgb *= LightColor;

	// apply attenuation
	//
	// the attenuation is (1-(x*x+y*y+z*z)) which gives a large bright
	// center and sharp falloff at the edge, this is about the most efficient
	// we can get away with as far as providing illumination.
	//
	// pow(1-(x*x+y*y+z*z), 4) is far more realistic but needs large lights to
	// provide significant illumination, large = slow = pain.
	color.rgb *= max(1.0 - dot(CubeVector, CubeVector), 0.0);




#elif defined(MODE_LIGHTDIRECTION)
	// directional model lighting

	// get the surface normal and light normal
	myhvec3 surfacenormal = normalize(myhvec3(texture2D(Texture_Normal, TexCoord)) - 0.5);
	myhvec3 diffusenormal = myhvec3(normalize(LightVector));

	// calculate directional shading
	color.rgb *= AmbientColor + DiffuseColor * max(dot(surfacenormal, diffusenormal), 0.0);
#ifdef USESPECULAR
	myhvec3 specularnormal = myhvec3(normalize(diffusenormal + myhvec3(normalize(EyeVector))));
	color.rgb += myhvec3(texture2D(Texture_Gloss, TexCoord)) * SpecularColor * pow(max(dot(surfacenormal, specularnormal), 0.0), SpecularPower);
#endif




#elif defined(MODE_LIGHTDIRECTIONMAP_MODELSPACE) || defined(MODE_LIGHTDIRECTIONMAP_TANGENTSPACE)
	// deluxemap lightmapping using light vectors in modelspace (evil q3map2)

	// get the surface normal and light normal
	myhvec3 surfacenormal = normalize(myhvec3(texture2D(Texture_Normal, TexCoord)) - 0.5);
	
	#ifdef MODE_LIGHTDIRECTIONMAP_MODELSPACE
	myhvec3 diffusenormal_modelspace = myhvec3(texture2D(Texture_Deluxemap, TexCoordLightmap)) - 0.5;
	myhvec3 diffusenormal = normalize(myhvec3(dot(diffusenormal_modelspace, VectorS), dot(diffusenormal_modelspace, VectorT), dot(diffusenormal_modelspace, VectorR)));
	#else 
	myhvec3 diffusenormal = normalize(myhvec3(texture2D(Texture_Deluxemap, TexCoordLightmap)) - 0.5);
	#endif
	// calculate directional shading
	myhvec3 tempcolor = color.rgb * (DiffuseScale * max(dot(surfacenormal, diffusenormal), 0.0));
#ifdef USESPECULAR
	myhvec3 specularnormal = myhvec3(normalize(diffusenormal + myhvec3(normalize(EyeVector))));
	tempcolor += myhvec3(texture2D(Texture_Gloss, TexCoord)) * SpecularScale * pow(max(dot(surfacenormal, specularnormal), 0.0), SpecularPower);
#endif

	// apply lightmap color
	color.rgb = tempcolor * myhvec3(texture2D(Texture_Lightmap, TexCoordLightmap)) + color.rgb * myhvec3(AmbientScale);


#else // MODE none (lightmap)
	// apply lightmap color
	color.rgb *= myhvec3(texture2D(Texture_Lightmap, TexCoordLightmap)) * DiffuseScale + myhvec3(AmbientScale);
#endif // MODE

	color *= gl_Color;

#ifdef USEGLOW
	color.rgb += myhvec3(texture2D(Texture_Glow, TexCoord));
#endif

#ifdef USEFOG
	// apply fog
	myhalf fog = texture2D(Texture_FogMask, myhvec2(length(EyeVectorModelSpace)*FogRangeRecip, 0.0)).x;
	color.rgb = color.rgb * fog + FogColor * (1.0 - fog);
#endif

	gl_FragColor = color;
}

#endif // FRAGMENT_SHADER
