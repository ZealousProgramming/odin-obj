package odin_obj_tests

// import "core:log"
// import "core:os"
// import "core:strings"
import "core:testing"

// import oo "../"

main :: proc() {
	t := testing.T{}

	// test_parse_property_desc(&t)
	// test_parse_properties(&t)
}

// @(test)
// test_parse_property_desc :: proc(t: ^testing.T) {
// 	raw, rok := os.read_entire_file_from_filename("./assets/cube/cube.obj")
// 	testing.expect(t, rok == true)

// 	defer delete(raw)

// 	data := string(raw)

// 	expected_results: [40]oo.Obj_Property_Desc = [40]oo.Obj_Property_Desc {
// 		oo.Obj_Property_Desc{key = .Comment, value = "Blender 4.0.2"},
// 		oo.Obj_Property_Desc{key = .Comment, value = "www.blender.org"},
// 		oo.Obj_Property_Desc{key = .Material_Library, value = "cube.mtl"},
// 		oo.Obj_Property_Desc{key = .Object_Name, value = "Cube"},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "1.000000 1.000000 -1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "1.000000 -1.000000 -1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "1.000000 1.000000 1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "1.000000 -1.000000 1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "-1.000000 1.000000 -1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "-1.000000 -1.000000 -1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "-1.000000 1.000000 1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Geometric_Vertex,
// 			value = "-1.000000 -1.000000 1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Vertex_Normal,
// 			value = "-0.0000 1.0000 -0.0000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Vertex_Normal,
// 			value = "-0.0000 -0.0000 1.0000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Vertex_Normal,
// 			value = "-1.0000 -0.0000 -0.0000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Vertex_Normal,
// 			value = "-0.0000 -1.0000 -0.0000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Vertex_Normal,
// 			value = "1.0000 -0.0000 -0.0000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Vertex_Normal,
// 			value = "-0.0000 -0.0000 -1.0000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.625000 0.500000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.875000 0.500000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.875000 0.750000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.625000 0.750000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.375000 0.750000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.625000 1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.375000 1.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.375000 0.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.625000 0.000000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.625000 0.250000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.375000 0.250000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.125000 0.500000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.375000 0.500000",
// 		},
// 		oo.Obj_Property_Desc {
// 			key = .Texture_Vertex,
// 			value = "0.125000 0.750000",
// 		},
// 		oo.Obj_Property_Desc{key = .Smoothing_Group, value = "0"},
// 		oo.Obj_Property_Desc{key = .Material_Name, value = "Material"},
// 		oo.Obj_Property_Desc{key = .Face, value = "1/1/1 5/2/1 7/3/1 3/4/1"},
// 		oo.Obj_Property_Desc{key = .Face, value = "4/5/2 3/4/2 7/6/2 8/7/2"},
// 		oo.Obj_Property_Desc{key = .Face, value = "8/8/3 7/9/3 5/10/3 6/11/3"},
// 		oo.Obj_Property_Desc {
// 			key = .Face,
// 			value = "6/12/4 2/13/4 4/5/4 8/14/4",
// 		},
// 		oo.Obj_Property_Desc{key = .Face, value = "2/13/5 1/1/5 3/4/5 4/5/5"},
// 		oo.Obj_Property_Desc {
// 			key = .Face,
// 			value = "6/11/6 5/10/6 1/1/6 2/13/6",
// 		},
// 	}

// 	count := 0
// 	for line in strings.split_lines_iterator(&data) {
// 		if len(line) == 0 {
// 			count += 1
// 			continue
// 		}

// 		desc := oo.extract_property_desc(line)

// 		testing.expect(t, desc.key == expected_results[count].key)
// 		testing.expect(t, desc.value == expected_results[count].value)

// 		count += 1
// 	}

// }


// @(test)
// test_parse_properties :: proc(t: ^testing.T) {
// 	raw, rok := os.read_entire_file_from_filename("./assets/cube/cube.obj")
// 	testing.expect(t, rok == true)

// 	defer delete(raw)

// 	data := string(raw)
// 	descs: [dynamic]oo.Obj_Property_Desc = make(
// 		[dynamic]oo.Obj_Property_Desc,
// 		0,
// 	)
// 	defer delete(descs)

// 	// Parse
// 	for line in strings.split_lines_iterator(&data) {
// 		if len(line) == 0 {continue}
// 		desc := oo.extract_property_desc(line)

// 		if desc.key != .None {
// 			append(&descs, desc)
// 		}

// 	}


// 	for desc in descs {
// 		#partial switch desc.key {
// 		case .Geometric_Vertex:
// 			{
// 				oo.extract_vec3(desc.value)
// 			}
// 		case .Vertex_Normal:
// 			{
// 				oo.extract_vec3(desc.value)
// 			}
// 		case .Texture_Vertex:
// 			{
// 				oo.extract_vec2(desc.value)
// 			}
// 		case:
// 		}
// 	}


// }
