package odin_obj

import "core:log"
import "core:os"
import "core:strconv"
import "core:strings"

_ :: log

// TODO(devon): Cache 1m vertices
// TODO(devon): Do manual triangtulation

/*
    A scuffed .obj importer in odin. Used this to learn about the file
    format, but releasing it just in case it can be of some use to someone.

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
        - https://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles
        - https://stackoverflow.com/questions/23349080/opengl-index-buffers-difficulties
*/

// Vertex :: struct {
// 	positions: [3]f32,
// 	normals:   [3]f32,
// 	uvs:       [2]f32,
// }

Mesh :: struct {
	vertices_positions: [dynamic][3]f32,
	vertices_normals:   [dynamic][3]f32,
	vertices_uvs:       [dynamic][2]f32,
	indices_positions:  [dynamic]uint,
	indices_normals:    [dynamic]uint,
	indices_uvs:        [dynamic]uint,
}

Obj_Keyword :: enum {
	None,
	Comment,
	Geometric_Vertex,
	Texture_Vertex,
	Vertex_Normal,
	Face,
	Object_Name,
	Group_Name,
	Smoothing_Group,
	Material_Library,
	Material_Name,
}

Obj_Parser :: struct {
	cursor: uint,
	data:   string,
}

Obj_Property_Desc :: struct {
	key:   Obj_Keyword,
	value: string,
}

load_obj :: proc {
	load_obj_from_filepath,
}

load_obj_from_filepath :: proc(
	path: string,
	allocator := context.allocator,
) -> (
	mesh: ^Mesh,
	ok: bool,
) {
	raw, rok := os.read_entire_file_from_filename(path, allocator)
	if !rok {
		ok = false

		return
	}
	defer delete(raw)

	data := string(raw)
	descs: [dynamic]Obj_Property_Desc = make(
		[dynamic]Obj_Property_Desc,
		0,
		allocator,
	)
	defer delete(descs)

	// Parse
	for line in strings.split_lines_iterator(&data) {
		if len(line) == 0 {continue}
		desc := extract_property_desc(line)

		if desc.key != .None {
			append(&descs, desc)
		}

	}

	// Sort
	mesh = mesh_init(allocator)

	for desc in descs {
		#partial switch desc.key {
		case .Geometric_Vertex:
			{
				extract_vec3(&mesh.vertices_positions, desc.value)
			}
		case .Vertex_Normal:
			{
				extract_vec3(&mesh.vertices_normals, desc.value)
			}
		case .Texture_Vertex:
			{
				extract_vec2(&mesh.vertices_uvs, desc.value)
			}
		case .Face:
			{
				extract_face(mesh, desc.value)
			}
		case:
		}
	}

	ok = true
	return
}

extract_property_desc :: proc(line: string) -> Obj_Property_Desc {
	start_index := 0
	end_index := strings.index_rune(line, ' ')

	if end_index == -1 {return Obj_Property_Desc{.None, ""}}
	k: string = strings.trim(line[start_index:end_index], " ")
	v: string = line[end_index + 1:]
	key: Obj_Keyword

	switch k {
	case "#":
		key = .Comment
	case "o":
		key = .Object_Name
	case "v":
		key = .Geometric_Vertex
	case "vn":
		key = .Vertex_Normal
	case "vt":
		key = .Texture_Vertex
	case "s":
		key = .Smoothing_Group
	case "f":
		key = .Face
	case "mtllib":
		key = .Material_Library
	case "usemtl":
		key = .Material_Name
	case:
		key = .None
	}

	return Obj_Property_Desc{key = key, value = v}
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
	count := 0
	for r in line[start_offset:] {
		if r == ' ' || r == '\n' || r == '\r' {break}

		count += 1
	}

	sub := line[start_offset:start_offset + count]
	if v, ok := strconv.parse_f32(sub); ok {
		return v, start_offset + count + 1
	}

	return 0.0, 0
}

extract_face :: proc(mesh: ^Mesh, line: string) {

}

mesh_init :: proc(allocator := context.allocator) -> ^Mesh {
	mesh := new(Mesh, allocator)
	mesh.vertices_positions = make([dynamic][3]f32, 0, allocator)
	mesh.vertices_normals = make([dynamic][3]f32, 0, allocator)
	mesh.vertices_uvs = make([dynamic][2]f32, 0, allocator)
	mesh.indices_positions = make([dynamic]uint, 0, allocator)
	mesh.indices_normals = make([dynamic]uint, 0, allocator)
	mesh.indices_uvs = make([dynamic]uint, 0, allocator)

	return mesh
}

mesh_free :: proc(mesh: ^Mesh, allocator := context.allocator) {
	if mesh == nil {return}

	defer free(mesh, allocator)
	delete(mesh.vertices_positions)
	delete(mesh.vertices_normals)
	delete(mesh.vertices_uvs)
	delete(mesh.indices_positions)
	delete(mesh.indices_normals)
	delete(mesh.indices_uvs)
}
