package odin_obj

import "core:log"
import "core:os"
import "core:strings"

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
*/

Vertex :: struct {
	positions: [3]f32,
	normals:   [3]f32,
	texcoords: [2]f32,
}

Mesh :: struct {
	vertices: [dynamic]Vertex,
	indices:  [dynamic]uint,
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


	// Parse
	for line in strings.split_lines_iterator(&data) {
		if len(line) == 0 {continue}
		keyword := extract_keyword(line)

		log.info(keyword)
	}


	return nil, true
}

extract_keyword :: proc(line: string) -> Obj_Keyword {
	start_index := 0
	end_index := strings.index_rune(line, ' ')

	if end_index == -1 {return .None}
	keyword: string = strings.trim(line[start_index:end_index], " ")

	switch keyword {
	case "#":
		return .Comment
	case "o":
		return .Object_Name
	case "v":
		return .Geometric_Vertex
	case "vn":
		return .Vertex_Normal
	case "vt":
		return .Texture_Vertex
	case "s":
		return .Smoothing_Group
	case "f":
		return .Face
	case "mtllib":
		return .Material_Library
	case "usemtl":
		return .Material_Name
	case:
		return .None
	}
}
