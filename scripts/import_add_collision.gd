@tool
extends EditorScenePostImport

## Runs every time a model in models/PlatformerKit or models/MiniForest is imported.
## It gives every mesh a solid (trimesh) collision, so students can drag
## models straight into a level and stand on them - no setup needed.
## It also means pieces "land" on other pieces when dragged into the 3D view.

# Models whose file name starts with one of these words stay non-solid
# (decorations you can walk through, or models used by gameplay prefabs).
const NO_COLLISION := [
	"grass", "flowers", "plant", "mushrooms",
	"coin-", "heart", "jewel", "key", "star", "lock", "flag",
	"arrow", "weapon-", "character-",
	"trap-spikes", "saw", "block-moving", "spring",
]


func _post_import(scene: Node) -> Object:
	var file_name := get_source_file().get_file().get_basename()
	for word in NO_COLLISION:
		if file_name.begins_with(word):
			return scene
	_add_collision(scene, scene)
	return scene


func _add_collision(node: Node, scene_root: Node) -> void:
	for child in node.get_children():
		_add_collision(child, scene_root)

	if node is MeshInstance3D and node.mesh != null:
		var body := StaticBody3D.new()
		body.name = "Collision"
		node.add_child(body)
		body.owner = scene_root

		var shape := CollisionShape3D.new()
		shape.name = "Shape"
		shape.shape = node.mesh.create_trimesh_shape()
		body.add_child(shape)
		shape.owner = scene_root
