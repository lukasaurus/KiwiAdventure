@tool
extends EditorScenePostImport

## Use this on Blockbench models (like the kiwi!) so their pixel-art
## textures stay sharp and blocky instead of going blurry.
##
## How: click the model (.glb / .gltf) in the FileSystem -> "Import" tab
## (next to the Scene tab, top left) -> "Import Script" -> pick this file
## -> press "Reimport".


func _post_import(scene: Node) -> Object:
	_make_crisp(scene)
	return scene


func _make_crisp(node: Node) -> void:
	for child in node.get_children():
		_make_crisp(child)

	if node is MeshInstance3D and node.mesh != null:
		for i in node.mesh.get_surface_count():
			_fix(node.mesh.surface_get_material(i))
			_fix(node.get_surface_override_material(i))


func _fix(material: Material) -> void:
	if material is BaseMaterial3D:
		material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
