package odin_obj

import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

_ :: log

// TODO(devon): Refactor tests to support the new version
// TODO(devon): Vertex buffers
// TODO(devon): Reduce triangulation to a generic pattern to allow for more than 4 face elements
// TODO(devon): Support .mtl files

/*
    A scuffed .obj importer in odin. Used this to learn about the file
    format, but releasing it just in case it can be of some use to someone.
    Currently only supports models with faces of 3 to 4 elements.
    Material (.mtl) files are not currently supported

    Keywords:
        Vertex data:
            v 	Geometric vertices
            vt 	Texture vertices
            vn 	Vertex normals
            p 	Parameter space vertices

        Free-form curve/surface attributes:

            deg 	Degree
            bmat 	Basis matrix
            step 	Step size
            cstype 	Curve or surface type

        Elements:

            p 	Point
            l 	Line
            f 	Face
            curv 	Curve
            curv2 	2D curve
            surf 	Surface

        Free-form curve/surface body statements:

            parm 	Parameter values
            trim 	Outer trimming loop
            hole 	Inner trimming loop
            scrv 	Special curve
            sp 	Special point
            end 	End statement

        Connectivity between free-form surfaces:

            con 	Connect

        Grouping:

            g 	Group name
            s 	Smoothing group
            mg 	Merging group
            o 	Object name

        Display/render attributes:

            bevel 	Bevel interpolation
            c_interp 	Color interpolation
            d_interp 	Dissolve interpolation
            lod 	Level of detail
            usemtl 	Material name
            mtllib 	Material library
            shadow_obj 	Shadow casting
            trace_obj 	Ray tracing
            ctech 	Curve approximation technique
            stech 	Surface approximation technique

    Notes:
        - Vertices are stored in counter-clockwise order by default
        - Face format: {vertex index in file}/{texture index in file}/{normal index in file}
    Resources:
        - https://en.wikipedia.org/wiki/Wavefront_.obj_file
        - https://www.fileformat.info/format/wavefrontobj/egff.htm
        - https://www.loc.gov/preservation/digital/formats/fdd/fdd000508.shtml
        - https://paulbourke.net/dataformats/mtl/
        - https://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles
        - https://stackoverflow.com/questions/23349080/opengl-index-buffers-difficulties
*/

Model_Data :: struct {
	vertices_positions: [dynamic][3]f32,
	vertices_normals:   [dynamic][3]f32,
	vertices_uvs:       [dynamic][2]f32,
	indices_positions:  [dynamic]uint,
	indices_normals:    [dynamic]uint,
	indices_uvs:        [dynamic]uint,
}

load_obj :: proc {
	load_obj_from_filepath,
}

load_obj_from_filepath :: proc(
	path: string,
	allocator := context.allocator,
) -> (
	model_data: ^Model_Data,
	ok: bool,
) {
	raw, rok := os.read_entire_file_from_filename(path, context.temp_allocator)
	if !rok {
		ok = false

		return
	}
	defer delete(raw, context.temp_allocator)

	data := string(raw)
	model_data = model_data_init(allocator)

	// Parse
	for line in strings.split_lines_iterator(&data) {
		i := 0
		end_index := strings.index_rune(line, ' ')

		k: string = strings.trim(line[i:end_index], " ")
		v: string = line[end_index + 1:]

		switch k {
		case "#":
		case "o":
		case "v":
			extract_vec3(&model_data.vertices_positions, v)
		case "vn":
			extract_vec3(&model_data.vertices_normals, v)
		case "vt":
			extract_vec2(&model_data.vertices_uvs, v)
		case "s":
		case "f":
			extract_face(model_data, v)
		case "mtllib":
		case "usemtl":
		case "newmtl":
		case "map_Ka":
		case "map_Kd":
		case "map_Ks":
		case "map_Ns":
		case "map_d":
		case "disp":
		case "decl":
		case "bump":
		case "d":
		case "illum":
		case "Ns":
		case "Ni":
		case "Ka":
		case "Kd":
		case "Ks":
		case "Ke":

		case:
		}

	}

	ok = true
	return
}

extract_vec3 :: proc(v: ^[dynamic][3]f32, line: string) {
	x, x_offset := extract_f32(line, 0)
	y, y_offset := extract_f32(line, x_offset)
	z, _ := extract_f32(line, y_offset)

	append(v, [3]f32{x, y, z})
}

extract_vec2 :: proc(v: ^[dynamic][2]f32, line: string) {
	x, x_offset := extract_f32(line, 0)
	y, _ := extract_f32(line, x_offset)

	append(v, [2]f32{x, y})
}

extract_f32 :: proc(
	line: string,
	start_offset: int,
) -> (
	value: f32,
	offset: int,
) {
	end_index, ei_ok := new_element_index(line, start_offset)
	if !ei_ok {return 0.0, 0}

	sub := line[start_offset:end_index]
	if v, ok := strconv.parse_f32(sub); ok {
		return v, end_index + 1
	}

	return 0.0, 0
}

extract_face :: proc(model_data: ^Model_Data, line: string) {
	// NOTE(devon): If one of the elements is 0, that means those indices are not being 
	// used in this model. Reminder that in .obj format, these indices are 1-based.
	// For example the simplest .obj with 3 geometric vertices, 1 face with 3 face elements consisting on only the position indice
	// v 0.0 0.0 0.0
	// v 0.0 1.0 0.0
	// v 1.0 0.0 0.0
	// f 1 2 3
	//
	// Should result in face_elements: {{1, 0, 0} {2, 0, 0} {3, 0 ,0}}
	face_elements: [dynamic][3]uint
	defer delete(face_elements)

	offset := 0
	for {
		end_index, ok := new_element_index(line, offset)
		if !ok {break}

		element: [3]uint
		element_str := line[offset:end_index]
		type_count := strings.count(element_str, "/")
		e_offset := 0
		for i in 0 ..< type_count + 1 {
			fe_end_index := separator_index(element_str, e_offset)
			v, _ := strconv.parse_uint(element_str[e_offset:fe_end_index])
			e_offset = fe_end_index + 1
			element[i] = v
		}

		append(&face_elements, element)
		offset = end_index + 1
	}

	// Determine if triangulation is needed
	triangulate := len(face_elements) > 3
	if triangulate {
		assert(
			len(face_elements) == 4,
			"[odin-obj] Faces with more than 4 elements are not currently supported",
		)

		// TODO(devon): Reduce this to a generic pattern
		indices := [2][3]uint{{0, 1, 2}, {0, 2, 3}}
		for i in indices {
			for j in i {
				append(&model_data.indices_positions, face_elements[j][0])
				append(&model_data.indices_uvs, face_elements[j][1])
				append(&model_data.indices_normals, face_elements[j][2])
			}
		}

	} else {
		indices := [3]uint{0, 1, 2}
		for i in indices {
			append(&model_data.indices_positions, face_elements[i][0])
			append(&model_data.indices_uvs, face_elements[i][1])
			append(&model_data.indices_normals, face_elements[i][2])
		}
	}
}

new_element_index :: proc(
	source: string,
	offset: int,
) -> (
	value: int,
	ok: bool,
) {
	if offset >= len(source) {return -1, false}

	count := 0
	for r in source[offset:] {
		if r == ' ' || r == '\n' || r == '\r' {break}

		count += 1
	}

	return count + offset, true
}

separator_index :: proc(source: string, offset: int) -> int {
	count := 0
	for r in source[offset:] {
		if r == '/' {break}

		count += 1
	}

	return count + offset
}

model_data_init :: proc(allocator := context.allocator) -> ^Model_Data {
	model_data := new(Model_Data, allocator)
	model_data.vertices_positions = make([dynamic][3]f32, 0, allocator)
	model_data.vertices_normals = make([dynamic][3]f32, 0, allocator)
	model_data.vertices_uvs = make([dynamic][2]f32, 0, allocator)
	model_data.indices_positions = make([dynamic]uint, 0, allocator)
	model_data.indices_normals = make([dynamic]uint, 0, allocator)
	model_data.indices_uvs = make([dynamic]uint, 0, allocator)

	return model_data
}

model_data_free :: proc(
	model_data: ^Model_Data,
	allocator := context.allocator,
) {
	if model_data == nil {return}

	defer free(model_data, allocator)
	delete(model_data.vertices_positions)
	delete(model_data.vertices_normals)
	delete(model_data.vertices_uvs)
	delete(model_data.indices_positions)
	delete(model_data.indices_normals)
	delete(model_data.indices_uvs)
}
