# odin-obj

A scuffed .obj importer in odin. Used this to learn about the file
    format, but releasing it just in case it can be of some use to someone.

## CURRENT SUPPORT

- [x] .obj files with 3-4 face elements

## TODOs

- [ ] Pooling for vertices and indices
- [ ] Reduce triangulation to a generic pattern to allow for more than 4 face elements
- [ ] Support .mtl files

## RESOURCES
- https://en.wikipedia.org/wiki/Wavefront_.obj_file
- https://www.fileformat.info/format/wavefrontobj/egff.htm
- https://www.loc.gov/preservation/digital/formats/fdd/fdd000508.shtml
- https://paulbourke.net/dataformats/mtl/
- https://stackoverflow.com/questions/23723993/converting-quadriladerals-in-an-obj-file-into-triangles
- https://stackoverflow.com/questions/23349080/opengl-index-buffers-difficulties