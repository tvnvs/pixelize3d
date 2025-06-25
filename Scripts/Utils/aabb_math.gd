class_name AABBMath


static func get_precise_aabb(mesh_instance: MeshInstance3D):
	var skeleton: Skeleton3D = mesh_instance.get_node_or_null(mesh_instance.skeleton)
	var start: Vector3       = Vector3.INF
	var end: Vector3         = -Vector3.INF

	for surface in mesh_instance.mesh.get_surface_count():
		var data                         := mesh_instance.mesh.surface_get_arrays(surface)
		var vertices: PackedVector3Array =  data[Mesh.ARRAY_VERTEX]
		var bones: PackedInt32Array      =  data[Mesh.ARRAY_BONES]
		var weights: PackedFloat32Array  =  data[Mesh.ARRAY_WEIGHTS]
		var vert_map                     := {} # to avoid recalculating

		for vert_idx in len(vertices):
			var vert: Vector3 = vertices[vert_idx]
			#
			if(vert in vert_map):
				continue
			else:
				vert_map[vert]=null

			if(skeleton and mesh_instance.skin):
				var bone_count: int           = len(weights)/len(vertices)
				var transformed_vert: Vector3 = Vector3.ZERO
				for i in bone_count:
					var weight = weights[vert_idx * bone_count + i]

					if(!weight):
						continue

					var bone_idx: int                 = bones[vert_idx * bone_count + i]
					var bind_pose: Transform3D        = mesh_instance.skin.get_bind_pose(bone_idx)
					var bone_global_pose: Transform3D = skeleton.get_bone_global_pose(bone_idx)
					transformed_vert += (bone_global_pose * bind_pose * vert) * weight

				vert = transformed_vert

			vert=mesh_instance.global_transform * vert

			start.x = vert.x if start.x > vert.x else start.x
			end.x = vert.x if vert.x > end.x else end.x

			start.y = vert.y if start.y > vert.y else start.y
			end.y = vert.y if vert.y > end.y else end.y

			start.z = vert.z if start.z > vert.z else start.z
			end.z = vert.z if vert.z > end.z else end.z

	return AABB(start, end - start)

static func get_aabb_vertices(aabb: AABB) -> PackedVector3Array:
	var vertices: PackedVector3Array = PackedVector3Array()
	var aux_vec: Vector3             = aabb.position + aabb.size

	vertices.push_back(aabb.position)
	for i in 3:
		var ver: Vector3 = Vector3(aabb.position)
		ver[i] += aabb.size[i]
		vertices.push_back(ver)

	for i in 3:
		var ver: Vector3 = Vector3(aux_vec)
		ver[i] -= aabb.size[i]
		vertices.push_back(ver)

	return vertices
	