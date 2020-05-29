/*	PART G
*	Moving lighting calculations from vertex to fragment shader
*	Requires new varying variables
*	Position variable needs to be a 4D vector to allow multiplication with ModelView matrix
*/

varying vec4 position;
varying vec3 normal;

/*	
*	vec4 color cannot be varying as compiler returns read-only error on assignment
*/

vec4 color;

varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

uniform sampler2D texture;

/*	PART G
*	Moving lighting calculations from vertex to fragment shader
*/

uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct;
uniform mat4 ModelView;


uniform float texScale; // Part B - Texture Scaling

uniform float Shininess;

/*	Part H
*	Variables for light manipulation
*/
uniform vec4 LightPosition;
uniform vec3 LightColor;
uniform float LightBrightness;
//

/*	Part I
*	Duplicate variables for SECOND light object
*/
uniform vec4 LightPosition2;
uniform vec3 LightColor2;
uniform float LightBrightness2;
//

void main()
{


    // Transform vertex position into eye coordinates
    vec3 pos = (ModelView * position).xyz;


    // The vector to the light from the vertex    
    vec3 Lvec = LightPosition.xyz - pos;

/*	Part I
*	Duplicate variables for SECOND light object
*/
    vec3 Lvec2 = LightPosition2.xyz;
//

    // Unit direction vectors for Blinn-Phong shading calculation
    vec3 L = normalize( Lvec );   // Direction to the light source
    vec3 E = normalize( -pos );   // Direction to the eye/camera
    vec3 H = normalize( L + E );  // Halfway vector

/*	Part I
*	Duplicate variables for SECOND light object
*/
	vec3 L2 = normalize( Lvec2 );   // Direction to the light source
    vec3 H2 = normalize( L2 + E );  // Halfway vector
//

    // Transform vertex normal into eye coordinates (assumes scaling
    // is uniform across dimensions)
    vec3 N = normalize( (ModelView*vec4(normal, 0.0)).xyz );

    // Compute terms in the illumination equation
    vec3 ambient = (LightColor * LightBrightness) * AmbientProduct;
    vec3 ambient2 = (LightColor2 * LightBrightness2) * AmbientProduct; // Part I

    float Kd = max( dot(L, N), 0.0 );
    float Kd2 = max( dot(L2, N), 0.0); // Part I

    vec3 diffuse = (LightColor * LightBrightness) * Kd*DiffuseProduct;
    vec3 diffuse2 = (LightColor2 * LightBrightness2) * Kd2*DiffuseProduct; // Part I

    float Ks = pow( max(dot(N, H), 0.0), Shininess );
    float Ks2 = pow( max(dot(N, H2), 0.0), Shininess );	// Part I
    
    vec3 specular = LightBrightness * Ks * SpecularProduct;
    vec3 specular2 = LightBrightness2 * Ks2 * SpecularProduct;	// Part I
    
    if (dot(L, N) < 0.0 ) {
	specular = vec3(0.0, 0.0, 0.0);
    } 
    if (dot(L2, N) < 0.0 ) {
	specular2 = vec3(0.0, 0.0, 0.0);	// Part I
    } 


    // globalAmbient is independent of distance from the light source
    vec3 globalAmbient = vec3(0.1, 0.1, 0.1);
    color.a = 1.0;


	/*	Part F
	*	Light reduction with distance
	*/
	
	float lightDist = 0.01 + length(Lvec);

	color.rgb = globalAmbient + ((ambient + diffuse) / lightDist) + (ambient2 + diffuse2);
	color.a = 1.0;
	
	/*
	*
	*/

    gl_FragColor = color * texture2D( texture, texCoord * 2.0 * texScale) + vec4(specular/lightDist + specular2, 1.0);

}

