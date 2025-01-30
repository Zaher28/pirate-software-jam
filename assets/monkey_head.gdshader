shader_type spatial;

void vertex() {
	VERTEX.y += sin(TIME * 2.0) * 0.25;
}

void fragment() {
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
