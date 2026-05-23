extends Node3D

@export_file("*.tscn") var menu_scene_path: String = "res://Start_Menu.tscn"
@export_file("*.tscn") var showroom_stage_scene_path: String = "res://showroom/customize_showroom_stage.tscn"

const GLASS_MARBLE_MODEL_SCENE: PackedScene = preload("res://glass_marble_model.tscn")
const GALAXY_MODEL_PATH: String = "res://extracted_minecraft_java_editions_stars.glb"
const MENU_SCENE_FALLBACKS: PackedStringArray = ["res://Start_Menu.tscn", "res://StartMenu.tscn"]
const GLASS_BUTTON_EFFECTS = preload("res://glass_button_effects.gd")
const SHOWROOM_HALO_SHADER: Shader = preload("res://shaders/showroom_halo.gdshader")
const SHOWROOM_MENU_LOGO_PATH: String = "res://ui/bano_header_wordmark.png"
const SHOWROOM_BACKGROUND_TEXTURE_PATH: String = "res://showroom/showroom_neon_background.png"
const SHOWROOM_MODE_MARBLES: String = "marbles"
const SHOWROOM_MODE_TRAILS: String = "trails"
const SHOWROOM_MODE_FIELDS: String = "fields"
const SHOWROOM_FIXED_DECOR_MARBLES_ENABLED: bool = false

var customization: Node
var marble_ids: PackedStringArray = PackedStringArray()
var trail_ids: PackedStringArray = PackedStringArray()
var field_ids: PackedStringArray = PackedStringArray()
var root: Control
var selected_marble_id: String = ""
var selected_trail_id: String = ""
var selected_field_id: String = ""
var displayed_marble_id: String = ""

var display_marble: Node3D
var marble_anchor: Node3D
var look_target: Node3D
var camera_anchor: Node3D
var preview_camera: Camera3D
var showroom_stage: Node3D
var showroom_selected_slot: ShowroomMarbleSlot
var showroom_runtime_root: Node3D
var showroom_decor_runtime_root: Node3D

var title_label: Label
var description_label: Label
var currency_label: Label
var status_label: Label
var apply_button: Button
var coins_button: Button
var gold_button: Button
var gold_store_page: Control
var gold_store_popup: Window
var gold_payment_popup: Window
var gold_payment_phone_input: LineEdit
var gold_payment_terms_checkbox: CheckBox
var gold_payment_status_label: Label
var gold_payment_buy_button: Button
var gold_payment_cancel_button: Button
var gold_payment_http_request: HTTPRequest
var gold_payment_pending_invoice_id: String = ""
var gold_payment_selected_amount: int = 10
var gold_payment_selected_price: int = 100
var gold_payment_status_timer: float = -1.0
var gold_payment_status_poll_count: int = 0
var gold_payment_request_kind: String = ""
var mode_buttons: Dictionary = {}
var marble_frame_panel: Panel
var trail_frame_panel: Panel
var field_frame_panel: Panel
var marble_belt_scroll: ScrollContainer
var trail_belt_scroll: ScrollContainer
var field_belt_scroll: ScrollContainer
var belt_row: HBoxContainer
var trail_belt_row: HBoxContainer
var field_belt_row: HBoxContainer
var marble_buttons: Dictionary = {}
var trail_buttons: Dictionary = {}
var field_buttons: Dictionary = {}
var preview_cache: Dictionary = {}
var marble_pool: Dictionary = {}
var trail_preview_cache: Dictionary = {}
var field_preview_cache: Dictionary = {}
var galaxy_backdrop: Node3D
var trail_preview_root: Node3D
var showroom_root: Node3D
var showroom_field_root: Node3D
var title_logo: TextureRect
var showroom_transition_tween: Tween
var showroom_transition_active: bool = false
var showroom_transition_direction: float = 1.0
var showroom_mode: String = SHOWROOM_MODE_MARBLES
var showroom_decor_slots_dirty: bool = true
var room_environment: WorldEnvironment
var showroom_environment: WorldEnvironment
var showroom_platform: MeshInstance3D
var showroom_fill_light: OmniLight3D
var showroom_rim_light: OmniLight3D
var customization_directional_light: DirectionalLight3D
var showroom_spotlight: SpotLight3D
var showroom_marble_front_light: OmniLight3D
var showroom_marble_top_light: OmniLight3D
var showroom_side_light: OmniLight3D
var status_message_timer: float = 0.0
var marble_belt_target_scroll: float = 0.0
var trail_belt_target_scroll: float = 0.0
var field_belt_target_scroll: float = 0.0
var belt_drag_active: bool = false
var belt_drag_last_position: Vector2 = Vector2.ZERO
var belt_drag_total_distance: float = 0.0
var belt_drag_ignore_click_until_msec: int = 0
const BELT_DRAG_CLICK_THRESHOLD: float = 8.0

var marble_float_time: float = 0.0
var marble_spin_time: float = 0.0
var dragging: bool = false
var last_touch: Vector2 = Vector2.ZERO
const SHOWROOM_MARBLE_BASE_POSITION := Vector3(0, 0, 0)
const SHOWROOM_MARBLE_SCALE: float = 2.0
const SHOWROOM_FLOAT_AMPLITUDE: float = 0.11
const SHOWROOM_ROTATION_SPEED: float = 0.18
const SHOWROOM_TRAIL_OFFSET: Vector3 = Vector3(-1.2, -0.1, 0.0)
const SHOWROOM_CAMERA_BASE_POSITION := Vector3(0.0, 3.8, 6.2)
const SHOWROOM_FIELD_CAMERA_POSITION := Vector3(0.0, 7.1, 15.4)
const SHOWROOM_FIELD_LOOK_TARGET := Vector3(0.0, 2.65, 0.9)
const SHOWROOM_TRANSITION_OFFSET := Vector3(3.1, 0.35, -1.0)
const SHOWROOM_TRANSITION_TIME: float = 0.16
const SHOWROOM_EXIT_TIME: float = 0.13
const SHOWROOM_SETTLE_TIME: float = 0.0
const SHOWROOM_POSITION_SMOOTH: float = 9.5
const SHOWROOM_ROTATION_SMOOTH: float = 8.5
const SHOWROOM_SCALE_SMOOTH: float = 10.0
const SHOWROOM_CAMERA_SMOOTH: float = 7.5
const SHOWROOM_AMBIENT_LIGHT_ENERGY: float = 1.22
const SHOWROOM_FILL_LIGHT_ENERGY: float = 0.86
const SHOWROOM_RIM_LIGHT_ENERGY: float = 0.32
const SHOWROOM_SPOTLIGHT_ENERGY: float = 0.95
const SHOWROOM_MARBLE_FRONT_LIGHT_ENERGY: float = 0.58
const SHOWROOM_MARBLE_TOP_LIGHT_ENERGY: float = 0.32
const SHOWROOM_SIDE_LIGHT_ENERGY: float = 0.22
const SHOWROOM_CEILING_WASH_LIGHT_ENERGY: float = 0.0
const SHOWROOM_BACK_WALL_LIGHT_ENERGY: float = 0.0
const SHOWROOM_FLOOR_BOUNCE_LIGHT_ENERGY: float = 0.0
const CUSTOMIZATION_DIRECTIONAL_LIGHT_ENERGY: float = 0.85
const CUSTOMIZATION_DIRECTIONAL_LIGHT_POSITION := Vector3(-2.7, 8.1, 4.35)
const CUSTOMIZATION_DIRECTIONAL_LIGHT_TARGET := Vector3(0.0, 4.05, 0.0)
const SHOWROOM_SHADER_MARBLE_EMISSION_SCALE: float = 0.0
const SHOWROOM_TEXTURED_MARBLE_EMISSION: float = 0.0
const SHOWROOM_STANDARD_MARBLE_EMISSION_MIN: float = 0.0
const SHOWROOM_STANDARD_MARBLE_EMISSION_MAX: float = 0.0
const SHOWROOM_MAIN_SPOT_POSITION := Vector3(0.0, 6.18, 2.05)
const SHOWROOM_MAIN_SPOT_TARGET := Vector3(0.0, 4.05, 0.0)
const SHOWROOM_LEFT_SPOT_POSITION := Vector3(-3.1, 5.45, 1.55)
const SHOWROOM_LEFT_SPOT_TARGET := Vector3(-2.8, 2.55, -0.6)
const SHOWROOM_RIGHT_SPOT_POSITION := Vector3(3.1, 5.45, 1.55)
const SHOWROOM_RIGHT_SPOT_TARGET := Vector3(2.8, 2.55, -0.6)
const PAYSTACK_INITIALIZE_ENDPOINT_PATH: String = "/payments/paystack/initialize"
const PAYSTACK_STATUS_ENDPOINT_PATH: String = "/payments/paystack/status"
const PAYMENT_TERMS_CHECKBOX_TEXT: String = "I understand that Gold/Coins are digital game currency only, have no real-money value, cannot be withdrawn, payments/donations are non-refundable, and Bano ke may contact me by email or message about this payment, support, account notices, and game updates."
const PAYMENT_FINAL_NOTICE_TEXT: String = "Check your amount carefully before paying. Donations and digital currency purchases are final and non-refundable."
const PAYMENT_TERMS_REQUIRED_STATUS: String = "Tick the payment and message consent checkbox before paying."
const STORE_GOLD_POUCH_TEXTURE_PATH: String = "res://ui/store/gold_pouch.png"
const STORE_GOLD_BOX_TEXTURE_PATH: String = "res://ui/store/gold_box.png"
const STORE_GOLD_CHEST_TEXTURE_PATH: String = "res://ui/store/gold_chest.png"
const GOLD_PACK_AMOUNT: int = 10
const GOLD_PACK_PRICE_KES: int = 100
const GOLD_PACK_MID_AMOUNT: int = 30
const GOLD_PACK_MID_PRICE_KES: int = 175
const GOLD_PACK_BIG_AMOUNT: int = 100
const GOLD_PACK_BIG_PRICE_KES: int = 500
const PAYMENT_STATUS_POLL_SECONDS: float = 3.0
const PAYMENT_STATUS_MAX_POLLS: int = 65

var showroom_target_position: Vector3 = SHOWROOM_MARBLE_BASE_POSITION
var showroom_target_rotation: Vector3 = Vector3.ZERO
var showroom_target_scale: Vector3 = Vector3.ONE * SHOWROOM_MARBLE_SCALE
var showroom_camera_target_position: Vector3 = SHOWROOM_CAMERA_BASE_POSITION
var showroom_look_target_position: Vector3 = SHOWROOM_MARBLE_BASE_POSITION


func _ready() -> void:
	customization = get_node_or_null("/root/CustomizationState")

	_setup_3d()
	_build_ui()
	_load_marble_collection()
	_refresh_display()

	# optional (keep disabled for now)
	# GLASS_BUTTON_EFFECTS.apply_to_tree(self)


func _process(delta: float) -> void:
	marble_float_time += delta
	marble_spin_time += delta
	status_message_timer = maxf(status_message_timer - delta, 0.0)
	if display_marble != null and not showroom_transition_active:
		showroom_target_position = _get_selected_slot_position()
		showroom_target_rotation = _get_selected_slot_rotation()
		showroom_target_scale = _get_selected_slot_scale()
	_display_marble_smoothly(delta)
	_update_decor_showroom_marbles()
	_update_belt_scroll(delta, marble_belt_scroll, marble_belt_target_scroll)
	_update_belt_scroll(delta, trail_belt_scroll, trail_belt_target_scroll)
	_update_belt_scroll(delta, field_belt_scroll, field_belt_target_scroll)
	_process_gold_payment_status_poll(delta)
	if display_marble != null and trail_preview_root != null:
		trail_preview_root.position = display_marble.position
	if preview_camera != null:
		var camera_weight: float = clampf(delta * SHOWROOM_CAMERA_SMOOTH, 0.0, 1.0)
		preview_camera.position = preview_camera.position.lerp(showroom_camera_target_position, camera_weight)
		preview_camera.look_at_from_position(preview_camera.position, showroom_look_target_position, Vector3.UP)
	if display_marble != null and not showroom_transition_active and not dragging:
		display_marble.rotate_y(delta * SHOWROOM_ROTATION_SPEED)


func _setup_3d() -> void:
	_ensure_showroom_stage()
	_bind_showroom_stage()
	_ensure_customization_directional_light()
	_brighten_showroom_lighting()
	_style_room_shell()
	_add_galaxy_model()

	if preview_camera != null:
		preview_camera.current = true
		showroom_camera_target_position = _get_default_camera_position()
	if display_marble != null:
		showroom_look_target_position = display_marble.global_transform.origin
	else:
		showroom_look_target_position = _get_default_look_target()
		preview_camera.position = showroom_camera_target_position
		preview_camera.look_at_from_position(preview_camera.position, showroom_look_target_position, Vector3.UP)


func _ensure_showroom_stage() -> void:
	showroom_stage = get_node_or_null("ShowroomStage") as Node3D
	if showroom_stage != null:
		return
	if showroom_stage_scene_path == "" or not ResourceLoader.exists(showroom_stage_scene_path):
		return
	var packed_scene: PackedScene = load(showroom_stage_scene_path) as PackedScene
	if packed_scene == null:
		return
	var stage_instance: Node = packed_scene.instantiate()
	showroom_stage = stage_instance as Node3D
	if showroom_stage == null:
		if stage_instance != null:
			stage_instance.queue_free()
		return
	showroom_stage.name = "ShowroomStage"
	add_child(showroom_stage)


func _bind_showroom_stage() -> void:
	room_environment = get_node_or_null("WorldEnvironment") as WorldEnvironment
	if showroom_stage == null:
		return
	showroom_environment = showroom_stage.get_node_or_null("Environment") as WorldEnvironment
	showroom_root = showroom_stage.get_node_or_null("ShowroomRoot") as Node3D
	showroom_field_root = showroom_stage.get_node_or_null("ShowroomFieldRoot") as Node3D
	showroom_platform = showroom_stage.get_node_or_null("Platform") as MeshInstance3D
	showroom_fill_light = showroom_stage.get_node_or_null("FillLight") as OmniLight3D
	showroom_rim_light = showroom_stage.get_node_or_null("RimLight") as OmniLight3D
	showroom_spotlight = showroom_stage.get_node_or_null("Spotlight") as SpotLight3D
	showroom_marble_front_light = showroom_stage.get_node_or_null("MarbleFrontLight") as OmniLight3D
	showroom_marble_top_light = showroom_stage.get_node_or_null("MarbleTopLight") as OmniLight3D
	showroom_side_light = showroom_stage.get_node_or_null("MarbleSideLight") as OmniLight3D
	preview_camera = showroom_stage.get_node_or_null("PreviewCamera") as Camera3D
	look_target = showroom_stage.get_node_or_null("LookTarget") as Node3D
	camera_anchor = showroom_stage.get_node_or_null("CameraAnchor") as Node3D
	showroom_selected_slot = showroom_stage.get_node_or_null("ShowroomRoot/SelectedMarbleSlot") as ShowroomMarbleSlot
	marble_anchor = showroom_selected_slot

	if showroom_root != null:
		showroom_runtime_root = showroom_root.get_node_or_null("RuntimeMarbles") as Node3D
		if showroom_runtime_root == null:
			showroom_runtime_root = Node3D.new()
			showroom_runtime_root.name = "RuntimeMarbles"
			showroom_root.add_child(showroom_runtime_root)

		showroom_decor_runtime_root = showroom_root.get_node_or_null("DecorRuntime") as Node3D
		if showroom_decor_runtime_root == null:
			showroom_decor_runtime_root = Node3D.new()
			showroom_decor_runtime_root.name = "DecorRuntime"
			showroom_root.add_child(showroom_decor_runtime_root)


func _ensure_customization_directional_light() -> void:
	customization_directional_light = get_node_or_null("CustomizationDirectionalLight") as DirectionalLight3D
	if customization_directional_light == null:
		customization_directional_light = get_node_or_null("WorldEnvironment/DirectionalLight3D") as DirectionalLight3D
		if customization_directional_light != null:
			customization_directional_light.name = "CustomizationDirectionalLight"
			var old_parent: Node = customization_directional_light.get_parent()
			if old_parent != self:
				old_parent.remove_child(customization_directional_light)
				add_child(customization_directional_light)

	if customization_directional_light == null:
		customization_directional_light = DirectionalLight3D.new()
		customization_directional_light.name = "CustomizationDirectionalLight"
		add_child(customization_directional_light)

	customization_directional_light.position = CUSTOMIZATION_DIRECTIONAL_LIGHT_POSITION
	customization_directional_light.look_at(CUSTOMIZATION_DIRECTIONAL_LIGHT_TARGET, Vector3.UP)
	customization_directional_light.light_color = Color(1.0, 0.96, 0.84, 1.0)
	customization_directional_light.light_energy = CUSTOMIZATION_DIRECTIONAL_LIGHT_ENERGY
	customization_directional_light.light_indirect_energy = 0.6
	customization_directional_light.shadow_enabled = false


func _brighten_showroom_lighting() -> void:
	if room_environment != null:
		_configure_showroom_environment(room_environment.environment)
	if showroom_environment != null and showroom_environment.environment != null:
		_configure_showroom_environment(showroom_environment.environment)

	if showroom_fill_light != null:
		showroom_fill_light.position = Vector3(-2.5, 5.9, 4.9)
		showroom_fill_light.light_color = Color(0.96, 0.98, 1.0, 1.0)
		showroom_fill_light.light_energy = SHOWROOM_FILL_LIGHT_ENERGY
		showroom_fill_light.omni_range = 11.0
	if showroom_rim_light != null:
		showroom_rim_light.position = Vector3(2.5, 6.2, -3.35)
		showroom_rim_light.light_color = Color(0.92, 0.96, 1.0, 1.0)
		showroom_rim_light.light_energy = SHOWROOM_RIM_LIGHT_ENERGY
		showroom_rim_light.omni_range = 10.5
	showroom_spotlight = _ensure_showroom_spotlight(
		"Spotlight",
		SHOWROOM_MAIN_SPOT_POSITION,
		SHOWROOM_MAIN_SPOT_TARGET,
		Color(1.0, 0.96, 0.82, 1.0),
		SHOWROOM_SPOTLIGHT_ENERGY,
		13.0,
		28.0,
		true
	)

	showroom_marble_front_light = _ensure_showroom_omni_light(
		"MarbleFrontLight",
		Vector3(0.0, 4.55, 4.55),
		Color(1.0, 1.0, 1.0, 1.0),
		SHOWROOM_MARBLE_FRONT_LIGHT_ENERGY,
		7.8
	)
	showroom_marble_top_light = _ensure_showroom_omni_light(
		"MarbleTopLight",
		Vector3(0.0, 6.9, 0.2),
		Color(0.98, 0.99, 1.0, 1.0),
		SHOWROOM_MARBLE_TOP_LIGHT_ENERGY,
		6.4
	)
	showroom_side_light = _ensure_showroom_omni_light(
		"MarbleSideLight",
		Vector3(-2.6, 4.9, 1.45),
		Color(0.98, 0.98, 1.0, 1.0),
		SHOWROOM_SIDE_LIGHT_ENERGY,
		7.4
	)

	_ensure_showroom_spotlight(
		"LeftMarbleSpotlight",
		SHOWROOM_LEFT_SPOT_POSITION,
		SHOWROOM_LEFT_SPOT_TARGET,
		Color(0.78, 0.94, 1.0, 1.0),
		0.0,
		8.0,
		34.0,
		false
	)
	_ensure_showroom_spotlight(
		"RightMarbleSpotlight",
		SHOWROOM_RIGHT_SPOT_POSITION,
		SHOWROOM_RIGHT_SPOT_TARGET,
		Color(1.0, 0.86, 0.68, 1.0),
		0.0,
		8.0,
		34.0,
		false
	)


func _configure_showroom_environment(environment: Environment, ambient_color: Color = Color(1.0, 1.0, 1.0, 1.0), background_color: Color = Color(0.005, 0.008, 0.018, 1.0)) -> void:
	if environment == null:
		return
	environment.background_color = background_color
	environment.background_energy_multiplier = maxf(environment.background_energy_multiplier, 0.68)
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = ambient_color
	environment.ambient_light_energy = SHOWROOM_AMBIENT_LIGHT_ENERGY
	environment.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	environment.glow_enabled = false
	environment.glow_intensity = 0.0
	environment.glow_bloom = 0.0


func _ensure_showroom_omni_light(light_name: String, light_position: Vector3, light_color: Color, light_energy: float, light_range: float) -> OmniLight3D:
	if showroom_stage == null:
		return null

	var light: OmniLight3D = showroom_stage.get_node_or_null(light_name) as OmniLight3D
	if light == null:
		light = OmniLight3D.new()
		light.name = light_name
		showroom_stage.add_child(light)

	light.position = light_position
	light.light_color = light_color
	light.light_energy = light_energy
	light.omni_range = light_range
	light.visible = light_energy > 0.0
	return light


func _ensure_showroom_spotlight(light_name: String, light_position: Vector3, target_position: Vector3, light_color: Color, light_energy: float, light_range: float, spot_angle: float, shadows_enabled: bool = true) -> SpotLight3D:
	if showroom_stage == null:
		return null

	var light: SpotLight3D = showroom_stage.get_node_or_null(light_name) as SpotLight3D
	if light == null:
		light = SpotLight3D.new()
		light.name = light_name
		showroom_stage.add_child(light)

	_configure_showroom_spotlight(light, light_position, target_position, light_color, light_energy, light_range, spot_angle, shadows_enabled)
	return light


func _configure_showroom_spotlight(light: SpotLight3D, light_position: Vector3, target_position: Vector3, light_color: Color, light_energy: float, light_range: float, spot_angle: float, shadows_enabled: bool = true) -> void:
	if light == null:
		return

	light.position = light_position
	light.look_at(target_position, Vector3.UP)
	light.light_color = light_color
	light.light_energy = light_energy
	light.spot_range = light_range
	light.spot_angle = spot_angle
	light.spot_angle_attenuation = 0.42
	light.shadow_enabled = shadows_enabled
	light.visible = light_energy > 0.0


func _get_default_marble_position() -> Vector3:
	if showroom_selected_slot != null:
		return showroom_selected_slot.position
	if marble_anchor != null:
		return marble_anchor.position
	return SHOWROOM_MARBLE_BASE_POSITION


func _get_default_marble_rotation() -> Vector3:
	if showroom_selected_slot != null:
		return showroom_selected_slot.rotation
	return Vector3.ZERO


func _get_default_marble_scale() -> Vector3:
	if showroom_selected_slot != null:
		var multiplier: float = maxf(showroom_selected_slot.scale_multiplier, 0.01)
		return showroom_selected_slot.scale * multiplier
	return Vector3.ONE * SHOWROOM_MARBLE_SCALE


func _get_default_camera_position() -> Vector3:
	if camera_anchor != null:
		return camera_anchor.position
	return SHOWROOM_CAMERA_BASE_POSITION


func _get_default_look_target() -> Vector3:
	if look_target != null:
		return look_target.position
	return _get_default_marble_position()


func _get_selected_slot_position() -> Vector3:
	return _get_default_marble_position()


func _get_selected_slot_rotation() -> Vector3:
	return _get_default_marble_rotation()


func _get_selected_slot_scale() -> Vector3:
	return _get_default_marble_scale()


func _style_room_shell() -> void:
	if showroom_stage == null:
		return

	_hide_showroom_box_shell()
	_ensure_showroom_neon_backdrop()
	_ensure_showroom_omni_light(
		"CeilingWashLight",
		Vector3(0.0, 4.55, 1.6),
		Color(1.0, 0.94, 0.82, 1.0),
		SHOWROOM_CEILING_WASH_LIGHT_ENERGY,
		10.5
	)
	_ensure_showroom_omni_light(
		"BackWallWashLight",
		Vector3(0.0, 3.45, -4.65),
		Color(0.64, 0.84, 1.0, 1.0),
		SHOWROOM_BACK_WALL_LIGHT_ENERGY,
		8.8
	)
	_ensure_showroom_omni_light(
		"FloorBounceLight",
		Vector3(0.0, 2.1, 2.75),
		Color(0.88, 0.94, 1.0, 1.0),
		SHOWROOM_FLOOR_BOUNCE_LIGHT_ENERGY,
		8.0
	)


func _hide_showroom_box_shell() -> void:
	if showroom_stage == null:
		return
	for node_name in [
		"Floor",
		"BackWall",
		"LeftWall",
		"RightWall",
		"Ceiling",
		"BackTrim",
		"Platform",
		"CeilingLightPanel",
		"BackWallLightPanel",
		"SharedGalaxy"
	]:
		var visual: Node3D = showroom_stage.get_node_or_null(node_name) as Node3D
		if visual != null:
			visual.visible = false


func _ensure_showroom_neon_backdrop() -> void:
	if showroom_stage == null:
		return

	var backdrop: MeshInstance3D = showroom_stage.get_node_or_null("NeonBackdrop") as MeshInstance3D
	if backdrop == null:
		backdrop = showroom_stage.get_node_or_null("MeshInstance3D") as MeshInstance3D
	if backdrop == null:
		backdrop = MeshInstance3D.new()
		backdrop.name = "NeonBackdrop"
		showroom_stage.add_child(backdrop)

	var backdrop_mesh: QuadMesh = backdrop.mesh as QuadMesh
	if backdrop_mesh == null:
		backdrop_mesh = QuadMesh.new()
		backdrop.mesh = backdrop_mesh
	backdrop_mesh.size = Vector2(45.0, 30.0)
	backdrop.position = Vector3(0.0, 4.2, -34.0)
	backdrop.rotation = Vector3.ZERO
	backdrop.visible = true

	var texture: Texture2D = (load(SHOWROOM_BACKGROUND_TEXTURE_PATH) as Texture2D) if ResourceLoader.exists(SHOWROOM_BACKGROUND_TEXTURE_PATH) else null
	if texture == null:
		return

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	material.albedo_texture = texture
	backdrop.material_override = material


func _configure_room_shell_mesh(mesh_instance: MeshInstance3D, material: Material) -> void:
	if mesh_instance == null:
		return
	mesh_instance.visible = true
	mesh_instance.material_override = material
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


func _make_lit_showroom_material(albedo_color: Color, emission_color: Color, emission_energy: float, metallic: float, roughness: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = albedo_color
	material.emission_enabled = false
	material.emission = Color(0.0, 0.0, 0.0, 1.0)
	material.emission_energy_multiplier = 0.0
	material.metallic = metallic
	material.roughness = roughness
	return material


func _ensure_showroom_light_panel(panel_name: String, panel_position: Vector3, panel_rotation: Vector3, panel_size: Vector2, panel_color: Color, emission_energy: float) -> MeshInstance3D:
	if showroom_stage == null:
		return null

	var panel: MeshInstance3D = showroom_stage.get_node_or_null(panel_name) as MeshInstance3D
	if panel == null:
		panel = MeshInstance3D.new()
		panel.name = panel_name
		showroom_stage.add_child(panel)

	var panel_mesh: QuadMesh = panel.mesh as QuadMesh
	if panel_mesh == null:
		panel_mesh = QuadMesh.new()
		panel.mesh = panel_mesh
	panel_mesh.size = panel_size
	panel.position = panel_position
	panel.rotation_degrees = panel_rotation
	panel.visible = true

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.albedo_color = panel_color
	material.emission_enabled = false
	material.emission_energy_multiplier = 0.0
	panel.material_override = material
	panel.visible = false
	return panel


func _add_reference_floor_glow() -> void:
	return
	if showroom_root == null:
		return
	if showroom_root.get_node_or_null("ReferenceFloorGlow") != null:
		return

	var glow: MeshInstance3D = MeshInstance3D.new()
	glow.name = "ReferenceFloorGlow"
	var glow_mesh: QuadMesh = QuadMesh.new()
	glow_mesh.size = Vector2(7.2, 3.2)
	glow.mesh = glow_mesh
	glow.position = Vector3(0.0, 1.08, -0.15)
	glow.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	var glow_material: StandardMaterial3D = StandardMaterial3D.new()
	glow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	glow_material.albedo_texture = _make_showroom_glow_texture()
	glow_material.albedo_color = Color(0.67, 0.2, 1.0, 0.42)
	glow_material.emission_enabled = true
	glow_material.emission = Color(0.72, 0.26, 1.0, 1.0)
	glow_material.emission_energy_multiplier = 1.35
	glow.material_override = glow_material
	showroom_root.add_child(glow)

	var shadow: MeshInstance3D = MeshInstance3D.new()
	shadow.name = "ReferenceFloorShadow"
	var shadow_mesh: QuadMesh = QuadMesh.new()
	shadow_mesh.size = Vector2(2.2, 0.72)
	shadow.mesh = shadow_mesh
	shadow.position = Vector3(0.0, 1.1, 0.25)
	shadow.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	var shadow_material: StandardMaterial3D = StandardMaterial3D.new()
	shadow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	shadow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	shadow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	shadow_material.albedo_texture = _make_showroom_glow_texture()
	shadow_material.albedo_color = Color(0.0, 0.0, 0.06, 0.55)
	shadow.material_override = shadow_material
	showroom_root.add_child(shadow)


func _add_galaxy_model() -> void:
	galaxy_backdrop = null
	if showroom_stage != null:
		galaxy_backdrop = showroom_stage.get_node_or_null("SharedGalaxy") as Node3D
	if galaxy_backdrop == null:
		_add_galaxy_fallback()


func _add_galaxy_fallback() -> void:
	if showroom_stage == null:
		return
	if showroom_stage.get_node_or_null("GalaxyFallback") != null:
		return

	var fallback_root: Node3D = Node3D.new()
	fallback_root.name = "GalaxyFallback"
	galaxy_backdrop = fallback_root
	showroom_stage.add_child(fallback_root)

	var backdrop: MeshInstance3D = MeshInstance3D.new()
	var backdrop_mesh: QuadMesh = QuadMesh.new()
	backdrop_mesh.size = Vector2(30.0, 18.0)
	backdrop.mesh = backdrop_mesh
	backdrop.position = Vector3(0.0, 4.7, -14.5)
	var backdrop_material: StandardMaterial3D = StandardMaterial3D.new()
	backdrop_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	backdrop_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	backdrop_material.albedo_color = Color(0.01, 0.018, 0.05, 0.96)
	backdrop_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	backdrop.material_override = backdrop_material
	fallback_root.add_child(backdrop)

	_add_galaxy_cloud(fallback_root, Vector3(-4.8, 5.7, -13.9), Vector2(11.5, 6.4), Color(0.18, 0.52, 1.0, 0.2), 1.55, -10.0)
	_add_galaxy_cloud(fallback_root, Vector3(2.9, 4.8, -13.6), Vector2(10.8, 5.9), Color(0.72, 0.32, 1.0, 0.16), 1.42, 8.0)
	_add_galaxy_cloud(fallback_root, Vector3(0.3, 6.2, -14.0), Vector2(8.8, 4.2), Color(0.22, 0.94, 0.88, 0.12), 1.28, 18.0)
	_add_galaxy_cloud(fallback_root, Vector3(0.2, 4.3, -13.1), Vector2(5.4, 3.2), Color(0.95, 0.98, 1.0, 0.1), 1.1, 0.0)

	for star_index in range(120):
		var star: MeshInstance3D = MeshInstance3D.new()
		var star_mesh: SphereMesh = SphereMesh.new()
		var radius: float = randf_range(0.006, 0.022)
		star_mesh.radius = radius
		star_mesh.height = radius * 2.0
		star.mesh = star_mesh
		star.position = Vector3(
			randf_range(-13.0, 13.0),
			randf_range(0.8, 8.4),
			randf_range(-15.0, -9.5)
		)
		var star_material: StandardMaterial3D = StandardMaterial3D.new()
		star_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		star_material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
		star_material.emission_enabled = true
		star_material.emission = Color(0.9, 0.94, 1.0, 1.0) if star_index % 4 != 0 else Color(0.84, 0.7, 1.0, 1.0)
		star_material.emission_energy_multiplier = randf_range(0.85, 1.9)
		star.material_override = star_material
		fallback_root.add_child(star)

	var star_band: MeshInstance3D = MeshInstance3D.new()
	var star_band_mesh: QuadMesh = QuadMesh.new()
	star_band_mesh.size = Vector2(14.0, 2.8)
	star_band.mesh = star_band_mesh
	star_band.position = Vector3(0.0, 5.15, -13.4)
	star_band.rotation_degrees = Vector3(0.0, 0.0, -10.0)
	var star_band_material: StandardMaterial3D = StandardMaterial3D.new()
	star_band_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	star_band_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	star_band_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	star_band_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	star_band_material.albedo_texture = _make_showroom_glow_texture()
	star_band_material.albedo_color = Color(0.55, 0.72, 1.0, 0.09)
	star_band_material.emission_enabled = true
	star_band_material.emission = Color(0.64, 0.8, 1.0, 1.0)
	star_band_material.emission_energy_multiplier = 1.3
	star_band.material_override = star_band_material
	fallback_root.add_child(star_band)


func _add_galaxy_cloud(parent: Node3D, position: Vector3, size: Vector2, color: Color, energy: float, roll_degrees: float) -> void:
	var cloud: MeshInstance3D = MeshInstance3D.new()
	var cloud_mesh: QuadMesh = QuadMesh.new()
	cloud_mesh.size = size
	cloud.mesh = cloud_mesh
	cloud.position = position
	cloud.rotation_degrees = Vector3(0.0, 0.0, roll_degrees)
	var cloud_material: StandardMaterial3D = StandardMaterial3D.new()
	cloud_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	cloud_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	cloud_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	cloud_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	cloud_material.albedo_texture = _make_showroom_glow_texture()
	cloud_material.albedo_color = color
	cloud_material.emission_enabled = true
	cloud_material.emission = color
	cloud_material.emission_energy_multiplier = energy
	cloud.material_override = cloud_material
	parent.add_child(cloud)


func _get_node_3d_bounds(root: Node3D) -> AABB:
	var has_bounds: bool = false
	var combined: AABB = AABB()
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			stack.append(child)
		var mesh_instance: MeshInstance3D = current as MeshInstance3D
		if mesh_instance == null or mesh_instance.mesh == null:
			continue
		var local_aabb: AABB = mesh_instance.mesh.get_aabb()
		var corners: Array[Vector3] = [
			local_aabb.position,
			local_aabb.position + Vector3(local_aabb.size.x, 0.0, 0.0),
			local_aabb.position + Vector3(0.0, local_aabb.size.y, 0.0),
			local_aabb.position + Vector3(0.0, 0.0, local_aabb.size.z),
			local_aabb.position + Vector3(local_aabb.size.x, local_aabb.size.y, 0.0),
			local_aabb.position + Vector3(local_aabb.size.x, 0.0, local_aabb.size.z),
			local_aabb.position + Vector3(0.0, local_aabb.size.y, local_aabb.size.z),
			local_aabb.position + local_aabb.size
		]
		for corner in corners:
			var world_corner: Vector3 = mesh_instance.global_transform * corner
			if not has_bounds:
				combined = AABB(world_corner, Vector3.ZERO)
				has_bounds = true
			else:
				combined = combined.expand(world_corner)
	if has_bounds:
		return combined
	return AABB()


func _build_ui() -> void:
	_build_reference_showroom_ui()
	return

	var canvas := CanvasLayer.new()
	add_child(canvas)

	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)
	
# ======================
# 📱 RIGHT SIDE MENU
# ======================
	var right_menu := VBoxContainer.new()

	# Anchor ONLY to the right side
	right_menu.anchor_left = 1
	right_menu.anchor_right = 1
	right_menu.anchor_top = 0.5
	right_menu.anchor_bottom = 0.5

	# Position it properly
	right_menu.offset_left = -110
	right_menu.offset_right = -10

	# Center vertically
	right_menu.offset_top = -250
	right_menu.offset_bottom = 250

	# Spacing between buttons
	right_menu.add_theme_constant_override("separation", 12)

	root.add_child(right_menu)

	# Buttons
	var btn_event = make_side_button("EVENT", "🎯")
	var btn_friends = make_side_button("FRIENDS", "👥")
	var btn_ranking = make_side_button("RANKING", "📊")
	var btn_video = make_side_button("VIDEO", "▶")
	var btn_settings = make_side_button("SETTINGS", "🛠")

	# Badge
	var badge := Label.new()
	badge.text = "3"
	badge.add_theme_font_size_override("font_size", 12)
	badge.modulate = Color(1,0,0)

	btn_video.add_child(badge)

	# Add buttons
	right_menu.add_child(btn_event)
	right_menu.add_child(btn_friends)
	right_menu.add_child(btn_ranking)
	right_menu.add_child(btn_video)
	right_menu.add_child(btn_settings)
	
	# ======================
	# 🎨 BACKGROUND
	# ======================
	var bg := ColorRect.new()
	root.add_child(bg)
	root.move_child(bg, 0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0, 0, 0, 0.4)

	# ======================
	# 🔝 TOP BAR
	# ======================
	var top := HBoxContainer.new()
	top.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top.offset_left = 20
	top.offset_right = -20
	top.offset_top = 10
	top.offset_bottom = 70
	top.add_theme_constant_override("separation", 20)
	root.add_child(top)

	# BACK BUTTON
	var back: Button = _make_glass_button("← BACK")
	back.custom_minimum_size = Vector2(140, 50)
	back.pressed.connect(_on_back_pressed)
	top.add_child(back)

	# TITLE
	title_label = Label.new()
	title_label.text = "Bano ke"
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 28)
	top.add_child(title_label)

	# CURRENCY
	var currency := HBoxContainer.new()
	currency.add_theme_constant_override("separation", 12)
	top.add_child(currency)

	coins_button = _make_glass_button("S 0")
	gold_button = _make_glass_button("G 0")

	currency.add_child(coins_button)
	currency.add_child(gold_button)

	# ======================
	# 📝 DESCRIPTION
	# ======================
	description_label = Label.new()
	description_label.anchor_left = 0.5
	description_label.anchor_top = 0.1
	description_label.anchor_right = 0.5
	description_label.offset_left = -300
	description_label.offset_right = 300
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.add_theme_font_size_override("font_size", 16)
	root.add_child(description_label)

	# ======================
	# 🔴 UNLOCK BUTTON
	# ======================
	apply_button = _make_glass_button("UNLOCK")
	apply_button.anchor_left = 1
	apply_button.offset_right = -20
	apply_button.anchor_top = 0
	apply_button.offset_top = 80
	apply_button.anchor_right = 1
	apply_button.offset_right = -20
	apply_button.custom_minimum_size = Vector2(160, 60)
	root.add_child(apply_button)

	# ======================
# 📦 BOTTOM BELT PANEL
# ======================
	var bottom := Panel.new()
	bottom.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom.offset_left = 20
	bottom.offset_right = -20
	bottom.offset_bottom = -10
	bottom.offset_top = -160
	root.add_child(bottom)

	var bottom_style := StyleBoxFlat.new()
	bottom_style.bg_color = Color(0.08, 0.1, 0.2, 0.35)
	bottom_style.border_color = Color(0.6, 0.8, 1.0, 0.35)
	bottom_style.border_width_top = 2
	bottom_style.corner_radius_top_left = 28
	bottom_style.corner_radius_top_right = 28

	bottom.add_theme_stylebox_override("panel", bottom_style)

	marble_belt_scroll = ScrollContainer.new()
	marble_belt_scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	marble_belt_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	marble_belt_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	bottom.add_child(marble_belt_scroll)

	# ✅ ADD THIS
	belt_row = HBoxContainer.new()
	belt_row.add_theme_constant_override("separation", 14)
	marble_belt_scroll.add_child(belt_row)

	# ======================
	# STATUS TEXT
	# ======================
	status_label = Label.new()
	status_label.anchor_left = 0.5
	status_label.anchor_top = 1
	status_label.offset_left = -300
	status_label.offset_right = 300
	status_label.offset_top = -160
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.text = "Ready"
	root.add_child(status_label)
	
func _build_reference_showroom_ui() -> void:
	var canvas: CanvasLayer = CanvasLayer.new()
	add_child(canvas)

	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)

	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.04, 0.36)
	root.add_child(shade)

	var top_scrim: ColorRect = ColorRect.new()
	top_scrim.anchor_left = 0.0
	top_scrim.anchor_top = 0.0
	top_scrim.anchor_right = 1.0
	top_scrim.anchor_bottom = 0.0
	top_scrim.offset_bottom = 96.0
	top_scrim.color = Color(0.0, 0.0, 0.06, 0.55)
	root.add_child(top_scrim)

	title_logo = TextureRect.new()
	title_logo.name = "HeaderLogo"
	title_logo.anchor_left = 0.0
	title_logo.anchor_top = 0.0
	title_logo.anchor_right = 0.0
	title_logo.anchor_bottom = 0.0
	title_logo.offset_left = 16.0
	title_logo.offset_top = 6.0
	title_logo.offset_right = 520.0
	title_logo.offset_bottom = 98.0
	title_logo.texture = _load_showroom_ui_texture(SHOWROOM_MENU_LOGO_PATH)
	title_logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	title_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	title_logo.clip_contents = true
	title_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(title_logo)

	title_label = Label.new()
	title_label.hide()
	root.add_child(title_label)

	description_label = Label.new()
	description_label.anchor_left = 0.0
	description_label.anchor_top = 0.0
	description_label.anchor_right = 0.7
	description_label.anchor_bottom = 0.0
	description_label.offset_left = 16.0
	description_label.offset_top = 76.0
	description_label.offset_right = -12.0
	description_label.offset_bottom = 96.0
	description_label.add_theme_font_size_override("font_size", 13)
	description_label.add_theme_color_override("font_color", Color(0.76, 0.8, 1.0, 1.0))
	description_label.clip_text = true
	root.add_child(description_label)

	var currency_bar: HBoxContainer = HBoxContainer.new()
	currency_bar.anchor_left = 1.0
	currency_bar.anchor_top = 0.0
	currency_bar.anchor_right = 1.0
	currency_bar.anchor_bottom = 0.0
	currency_bar.offset_left = -300.0
	currency_bar.offset_top = 20.0
	currency_bar.offset_right = -56.0
	currency_bar.offset_bottom = 65.0
	currency_bar.add_theme_constant_override("separation", 8)
	root.add_child(currency_bar)

	coins_button = _make_currency_chip("S 0", Color(0.75, 0.23, 1.0, 1.0))
	gold_button = _make_currency_chip("G 0", Color(1.0, 0.67, 0.03, 1.0))
	currency_bar.add_child(coins_button)
	currency_bar.add_child(gold_button)

	var gear_button: Button = _make_reference_button("GEAR", Vector2(44, 44), Color(0.06, 0.07, 0.18, 0.86), Color(0.46, 0.5, 1.0, 0.36), 12)
	gear_button.anchor_left = 1.0
	gear_button.anchor_top = 0.0
	gear_button.anchor_right = 1.0
	gear_button.anchor_bottom = 0.0
	gear_button.offset_left = -48.0
	gear_button.offset_top = 20.0
	gear_button.offset_right = -12.0
	gear_button.offset_bottom = 64.0
	root.add_child(gear_button)

	var back: Button = _make_reference_button("<- BACK", Vector2(132, 48), Color(0.07, 0.09, 0.2, 0.84), Color(0.5, 0.6, 1.0, 0.34), 12)
	back.anchor_left = 0.0
	back.anchor_top = 0.0
	back.anchor_right = 0.0
	back.anchor_bottom = 0.0
	back.offset_left = 18.0
	back.offset_top = 100.0
	back.offset_right = 150.0
	back.offset_bottom = 148.0
	back.pressed.connect(_on_back_pressed)
	root.add_child(back)

	apply_button = _make_reference_button("UNLOCK", Vector2(132, 42), Color(0.9, 0.04, 0.03, 0.96), Color(1.0, 0.38, 0.13, 1.0), 8)
	apply_button.anchor_left = 1.0
	apply_button.anchor_top = 0.0
	apply_button.anchor_right = 1.0
	apply_button.anchor_bottom = 0.0
	apply_button.offset_left = -256.0
	apply_button.offset_top = 110.0
	apply_button.offset_right = -122.0
	apply_button.offset_bottom = 152.0
	apply_button.add_theme_font_size_override("font_size", 18)
	apply_button.pressed.connect(_on_apply_pressed)
	root.add_child(apply_button)

	var share_button: Button = _make_reference_button("SHARE", Vector2(112, 42), Color(0.0, 0.48, 1.0, 0.92), Color(0.42, 0.82, 1.0, 1.0), 8)
	share_button.anchor_left = 1.0
	share_button.anchor_top = 0.0
	share_button.anchor_right = 1.0
	share_button.anchor_bottom = 0.0
	share_button.offset_left = -112.0
	share_button.offset_top = 110.0
	share_button.offset_right = -18.0
	share_button.offset_bottom = 152.0
	root.add_child(share_button)

	var left_modes: VBoxContainer = VBoxContainer.new()
	left_modes.anchor_left = 0.0
	left_modes.anchor_top = 0.5
	left_modes.anchor_right = 0.0
	left_modes.anchor_bottom = 0.5
	left_modes.offset_left = 22.0
	left_modes.offset_top = -176.0
	left_modes.offset_right = 148.0
	left_modes.offset_bottom = 176.0
	left_modes.add_theme_constant_override("separation", 8)
	root.add_child(left_modes)

	var marbles_button: Button = _make_mode_rail_button("MARBLES", "O")
	var store_button: Button = _make_mode_rail_button("STORE", "S")
	mode_buttons[SHOWROOM_MODE_MARBLES] = marbles_button
	marbles_button.pressed.connect(_on_showroom_mode_pressed.bind(SHOWROOM_MODE_MARBLES))
	store_button.pressed.connect(_on_store_pressed)
	left_modes.add_child(marbles_button)
	left_modes.add_child(store_button)
	store_button.add_child(_make_badge("3", Vector2(86.0, -8.0)))

	var left_plus: Button = _make_hex_plus_button()
	left_plus.anchor_left = 0.28
	left_plus.anchor_top = 0.48
	left_plus.anchor_right = 0.28
	left_plus.anchor_bottom = 0.48
	left_plus.offset_left = -36.0
	left_plus.offset_top = -36.0
	left_plus.offset_right = 36.0
	left_plus.offset_bottom = 36.0
	left_plus.pressed.connect(_on_prev_marble_pressed)
	root.add_child(left_plus)

	var right_plus: Button = _make_hex_plus_button()
	right_plus.anchor_left = 0.74
	right_plus.anchor_top = 0.48
	right_plus.anchor_right = 0.74
	right_plus.anchor_bottom = 0.48
	right_plus.offset_left = -36.0
	right_plus.offset_top = -36.0
	right_plus.offset_right = 36.0
	right_plus.offset_bottom = 36.0
	right_plus.pressed.connect(_on_next_marble_pressed)
	root.add_child(right_plus)

	status_label = Label.new()
	status_label.anchor_left = 0.0
	status_label.anchor_top = 1.0
	status_label.anchor_right = 1.0
	status_label.anchor_bottom = 1.0
	status_label.offset_left = 44.0
	status_label.offset_top = -194.0
	status_label.offset_right = -126.0
	status_label.offset_bottom = -166.0
	status_label.text = "Ready to equip."
	status_label.z_index = 5
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.25, 1.0))
	status_label.clip_text = true
	root.add_child(status_label)

	var marble_shelf: Dictionary = _create_showroom_shelf("Marbles")
	marble_frame_panel = marble_shelf["panel"] as Panel
	marble_belt_scroll = marble_shelf["scroll"] as ScrollContainer
	belt_row = marble_shelf["row"] as HBoxContainer

	trail_frame_panel = null
	trail_belt_scroll = null
	trail_belt_row = null
	field_frame_panel = null
	field_belt_scroll = null
	field_belt_row = null


func _load_showroom_ui_texture(texture_path: String) -> Texture2D:
	var image: Image = Image.new()
	var load_path: String = texture_path
	if texture_path.begins_with("res://"):
		load_path = ProjectSettings.globalize_path(texture_path)
	if image.load(load_path) == OK:
		return ImageTexture.create_from_image(image)
	if ResourceLoader.exists(texture_path):
		var texture_resource: Resource = ResourceLoader.load(texture_path)
		if texture_resource is Texture2D:
			return texture_resource as Texture2D
	push_warning("Could not load showroom UI texture: %s" % texture_path)
	return null


func _create_showroom_shelf(title_text: String) -> Dictionary:
	var panel: Panel = Panel.new()
	panel.anchor_left = 0.0
	panel.anchor_top = 1.0
	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0
	panel.offset_left = 28.0
	panel.offset_top = -202.0
	panel.offset_right = -84.0
	panel.offset_bottom = -18.0
	panel.add_theme_stylebox_override("panel", _make_showroom_style(Color(0.02, 0.025, 0.08, 0.58), Color(0.76, 0.82, 1.0, 0.48), 12, 1, 14))
	root.add_child(panel)

	var title: Label = Label.new()
	title.anchor_left = 0.0
	title.anchor_top = 0.0
	title.anchor_right = 1.0
	title.anchor_bottom = 0.0
	title.offset_left = 20.0
	title.offset_top = 46.0
	title.offset_right = -20.0
	title.offset_bottom = 74.0
	title.text = title_text
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.97, 0.98, 1.0, 1.0))
	panel.add_child(title)

	var frame: Panel = Panel.new()
	frame.anchor_left = 0.0
	frame.anchor_top = 0.0
	frame.anchor_right = 1.0
	frame.anchor_bottom = 1.0
	frame.offset_left = 18.0
	frame.offset_top = 82.0
	frame.offset_right = -18.0
	frame.offset_bottom = -10.0
	frame.add_theme_stylebox_override("panel", _make_showroom_style(Color(0.1, 0.11, 0.22, 0.36), Color(0.9, 0.92, 1.0, 0.75), 15, 1))
	panel.add_child(frame)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 8.0
	scroll.offset_top = 8.0
	scroll.offset_right = -8.0
	scroll.offset_bottom = -8.0
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_SHOW_NEVER
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	scroll.gui_input.connect(_on_marble_belt_gui_input)
	frame.add_child(scroll)

	var row: HBoxContainer = HBoxContainer.new()
	row.add_theme_constant_override("separation", 20)
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(row)

	return {
		"panel": panel,
		"scroll": scroll,
		"row": row
	}


func _make_showroom_style(fill_color: Color, border_color: Color, radius: int, border_width: int = 1, shadow_size: int = 0) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	if shadow_size > 0:
		style.shadow_color = Color(0.22, 0.0, 0.75, 0.45)
		style.shadow_size = shadow_size
	return style


func _make_reference_button(text_value: String, min_size: Vector2, fill_color: Color, border_color: Color, radius: int) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = min_size
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_stylebox_override("normal", _make_showroom_style(fill_color, border_color, radius, 1, 10))
	button.add_theme_stylebox_override("hover", _make_showroom_style(fill_color.lightened(0.08), border_color.lightened(0.2), radius, 1, 12))
	button.add_theme_stylebox_override("pressed", _make_showroom_style(fill_color.darkened(0.1), border_color, radius, 1, 8))
	button.add_theme_stylebox_override("disabled", _make_showroom_style(fill_color.darkened(0.25), border_color.darkened(0.2), radius, 1, 0))
	return button


func _make_currency_chip(text_value: String, accent_color: Color) -> Button:
	var button: Button = _make_reference_button(text_value, Vector2(118, 44), Color(0.05, 0.05, 0.18, 0.88), accent_color.darkened(0.15), 10)
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_color_override("font_color", Color(0.96, 0.97, 1.0, 1.0))
	return button


func _on_store_pressed() -> void:
	_show_gold_store_page()


func _show_gold_store_page() -> void:
	_ensure_gold_store_page()
	gold_store_page.show()


func _hide_gold_store_page() -> void:
	if gold_store_page != null:
		gold_store_page.hide()


func _ensure_gold_store_page() -> void:
	if gold_store_page == null:
		gold_store_page = Control.new()
		gold_store_page.name = "GoldStorePage"
		gold_store_page.set_anchors_preset(Control.PRESET_FULL_RECT)
		gold_store_page.z_index = 80
		root.add_child(gold_store_page)
		_rebuild_gold_store_page()


func _rebuild_gold_store_page() -> void:
	for child in gold_store_page.get_children():
		child.queue_free()

	var background: TextureRect = TextureRect.new()
	background.name = "GoldStoreBackground"
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.texture = _load_showroom_ui_texture(SHOWROOM_BACKGROUND_TEXTURE_PATH)
	background.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gold_store_page.add_child(background)

	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.0, 0.035, 0.34)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	gold_store_page.add_child(shade)

	var top_line: ColorRect = ColorRect.new()
	top_line.anchor_left = 0.0
	top_line.anchor_top = 0.0
	top_line.anchor_right = 1.0
	top_line.anchor_bottom = 0.0
	top_line.offset_top = 108
	top_line.offset_bottom = 110
	top_line.color = Color(0.72, 0.12, 1.0, 0.72)
	gold_store_page.add_child(top_line)

	var back_button: Button = _make_shop_icon_button("<", Vector2(92, 78))
	back_button.position = Vector2(24, 24)
	gold_store_page.add_child(back_button)
	back_button.pressed.connect(_hide_gold_store_page)

	var cart_button: Button = _make_shop_icon_button("S", Vector2(92, 78))
	cart_button.anchor_left = 1.0
	cart_button.anchor_top = 0.0
	cart_button.anchor_right = 1.0
	cart_button.anchor_bottom = 0.0
	cart_button.offset_left = -116
	cart_button.offset_top = 24
	cart_button.offset_right = -24
	cart_button.offset_bottom = 102
	gold_store_page.add_child(cart_button)

	var title: Label = _make_showroom_label("SHOP", 48, Color(0.98, 0.92, 1.0, 1.0))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 30
	title.offset_bottom = 92
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_shadow_color", Color(0.72, 0.24, 1.0, 1.0))
	title.add_theme_constant_override("shadow_outline_size", 16)
	gold_store_page.add_child(title)

	var content: HBoxContainer = HBoxContainer.new()
	content.anchor_left = 0.06
	content.anchor_top = 0.25
	content.anchor_right = 0.94
	content.anchor_bottom = 0.86
	content.add_theme_constant_override("separation", 30)
	gold_store_page.add_child(content)

	var packs: Array = [
		{"title": "POUCH OF GOLD", "gold": GOLD_PACK_AMOUNT, "price": GOLD_PACK_PRICE_KES, "tier": 0},
		{"title": "BOX OF GOLD", "gold": GOLD_PACK_MID_AMOUNT, "price": GOLD_PACK_MID_PRICE_KES, "tier": 1},
		{"title": "CHEST OF GOLD", "gold": GOLD_PACK_BIG_AMOUNT, "price": GOLD_PACK_BIG_PRICE_KES, "tier": 2}
	]
	for pack in packs:
		var card: Button = _make_gold_store_card(str(pack["title"]), int(pack["gold"]), int(pack["price"]), int(pack["tier"]))
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.size_flags_vertical = Control.SIZE_EXPAND_FILL
		content.add_child(card)


func _make_shop_icon_button(text_value: String, button_size: Vector2) -> Button:
	var button: Button = _make_reference_button(text_value, button_size, Color(0.04, 0.01, 0.12, 0.88), Color(0.76, 0.22, 1.0, 0.92), 14)
	button.add_theme_font_size_override("font_size", 34)
	return button


func _make_gold_store_card(title_text: String, gold_amount: int, price_kes: int, tier: int) -> Button:
	var card: Button = Button.new()
	card.focus_mode = Control.FOCUS_NONE
	card.text = ""
	card.clip_contents = true
	card.add_theme_stylebox_override("normal", _make_showroom_style(Color(0.035, 0.008, 0.08, 0.86), Color(0.82, 0.18, 1.0, 0.92), 16, 2, 18))
	card.add_theme_stylebox_override("hover", _make_showroom_style(Color(0.055, 0.012, 0.12, 0.94), Color(1.0, 0.36, 1.0, 1.0), 16, 2, 24))
	card.add_theme_stylebox_override("pressed", _make_showroom_style(Color(0.02, 0.004, 0.055, 0.98), Color(0.62, 0.08, 0.9, 1.0), 16, 2, 12))
	card.pressed.connect(_on_gold_pack_buy_pressed.bind(gold_amount, price_kes))

	var stack: VBoxContainer = VBoxContainer.new()
	stack.set_anchors_preset(Control.PRESET_FULL_RECT)
	stack.offset_left = 20
	stack.offset_top = 26
	stack.offset_right = -20
	stack.offset_bottom = -20
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 14)
	stack.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(stack)

	var title: Label = _make_showroom_label(title_text, 24, Color(0.98, 0.95, 1.0, 1.0))
	title.add_theme_font_size_override("font_size", 24)
	title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(title)

	var art: TextureRect = TextureRect.new()
	art.custom_minimum_size = Vector2(300, 230)
	art.texture = _get_gold_pack_texture(tier)
	art.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(art)

	var price_panel: Panel = Panel.new()
	price_panel.custom_minimum_size = Vector2(0, 74)
	price_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	price_panel.add_theme_stylebox_override("panel", _make_showroom_style(Color(0.06, 0.01, 0.12, 0.9), Color(0.82, 0.18, 1.0, 0.96), 14, 2, 10))
	price_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stack.add_child(price_panel)

	var price_label: Label = _make_showroom_label("%d GOLD   %d KSH" % [gold_amount, price_kes], 27, Color(1.0, 0.86, 0.2, 1.0))
	price_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	price_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	price_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	price_panel.add_child(price_label)
	return card


func _get_gold_pack_texture(tier: int) -> Texture2D:
	var texture: Texture2D = null
	match tier:
		1:
			texture = _load_showroom_ui_texture(STORE_GOLD_BOX_TEXTURE_PATH)
		2:
			texture = _load_showroom_ui_texture(STORE_GOLD_CHEST_TEXTURE_PATH)
		_:
			texture = _load_showroom_ui_texture(STORE_GOLD_POUCH_TEXTURE_PATH)
	return texture if texture != null else _make_gold_pack_texture(tier)


func _make_gold_pack_texture(tier: int) -> Texture2D:
	var size: Vector2i = Vector2i(320, 240)
	var image: Image = Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var count: int = 8 + tier * 8
	for index in range(count):
		var x: float = 82.0 + float((index * 37) % 152)
		var y: float = 154.0 - float((index * 19) % 92) * (0.45 + tier * 0.08)
		_draw_coin_on_image(image, Vector2(x, y), 34.0 - minf(float(index % 4) * 2.0, 7.0))
	if tier >= 1:
		_draw_crate_on_image(image, tier)
	return ImageTexture.create_from_image(image)


func _draw_coin_on_image(image: Image, center: Vector2, radius: float) -> void:
	var min_x: int = max(0, int(center.x - radius))
	var max_x: int = min(image.get_width() - 1, int(center.x + radius))
	var min_y: int = max(0, int(center.y - radius))
	var max_y: int = min(image.get_height() - 1, int(center.y + radius))
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			var delta: Vector2 = Vector2(x, y) - center
			var distance: float = delta.length()
			if distance > radius:
				continue
			var edge: float = clampf((radius - distance) / 4.0, 0.0, 1.0)
			var shine: float = clampf(1.0 - (center - Vector2(x - 8, y + 10)).length() / radius, 0.0, 1.0)
			var color: Color = Color(1.0, 0.64 + shine * 0.24, 0.02, 1.0).lerp(Color(1.0, 0.95, 0.2, 1.0), edge * 0.5)
			image.set_pixel(x, y, color)
	for angle_index in range(32):
		var angle: float = TAU * float(angle_index) / 32.0
		var point: Vector2 = center + Vector2(cos(angle), sin(angle)) * (radius * 0.62)
		if point.x >= 0 and point.y >= 0 and point.x < image.get_width() and point.y < image.get_height():
			image.set_pixelv(Vector2i(int(point.x), int(point.y)), Color(1.0, 0.95, 0.25, 1.0))


func _draw_crate_on_image(image: Image, tier: int) -> void:
	var rect: Rect2i = Rect2i(78, 122, 172, 72)
	var fill: Color = Color(0.55, 0.55, 0.58, 1.0) if tier == 1 else Color(0.95, 0.55, 0.02, 1.0)
	var border: Color = Color(0.86, 0.86, 0.78, 1.0) if tier == 1 else Color(1.0, 0.86, 0.18, 1.0)
	for y in range(rect.position.y, rect.position.y + rect.size.y):
		for x in range(rect.position.x, rect.position.x + rect.size.x):
			if x < 0 or y < 0 or x >= image.get_width() or y >= image.get_height():
				continue
			var is_border: bool = x < rect.position.x + 8 or x > rect.end.x - 8 or y < rect.position.y + 8 or y > rect.end.y - 8
			image.set_pixel(x, y, border if is_border else fill)


func _show_gold_store_popup() -> void:
	_ensure_gold_store_popup()
	gold_store_popup.popup_centered()


func _ensure_gold_store_popup() -> void:
	if gold_store_popup == null:
		gold_store_popup = Window.new()
		gold_store_popup.name = "GoldStorePopup"
		gold_store_popup.title = "Store"
		gold_store_popup.size = Vector2i(460, 330)
		gold_store_popup.unresizable = true
		gold_store_popup.exclusive = true
		add_child(gold_store_popup)
		gold_store_popup.close_requested.connect(gold_store_popup.hide)
	_rebuild_gold_store_popup()


func _rebuild_gold_store_popup() -> void:
	for child in gold_store_popup.get_children():
		child.queue_free()

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 24)
	gold_store_popup.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 18)
	margin.add_child(stack)

	var title: Label = _make_showroom_label("GOLD PACK", 30, Color(1.0, 0.82, 0.2, 1.0))
	stack.add_child(title)

	var offer: Label = _make_showroom_label("%d Gold = %d KSH" % [GOLD_PACK_AMOUNT, GOLD_PACK_PRICE_KES], 24, Color(0.96, 0.99, 1.0, 1.0))
	stack.add_child(offer)

	var buy_button: Button = _make_reference_button("BUY", Vector2(190, 54), Color(0.07, 0.05, 0.01, 0.9), Color(1.0, 0.82, 0.2, 1.0), 10)
	buy_button.add_theme_font_size_override("font_size", 20)
	stack.add_child(buy_button)
	buy_button.pressed.connect(_on_gold_pack_buy_pressed)

	var cancel_button: Button = _make_reference_button("CANCEL", Vector2(190, 46), Color(0.03, 0.04, 0.12, 0.78), Color(0.72, 0.36, 1.0, 0.9), 10)
	stack.add_child(cancel_button)
	cancel_button.pressed.connect(gold_store_popup.hide)


func _on_gold_pack_buy_pressed(gold_amount: int = GOLD_PACK_AMOUNT, price_kes: int = GOLD_PACK_PRICE_KES) -> void:
	gold_payment_selected_amount = gold_amount
	gold_payment_selected_price = price_kes
	if gold_store_popup != null:
		gold_store_popup.hide()
	if gold_store_page != null:
		gold_store_page.hide()
	_show_gold_payment_popup()


func _show_gold_payment_popup() -> void:
	_ensure_gold_payment_popup()
	gold_payment_phone_input.text = ""
	if gold_payment_terms_checkbox != null:
		gold_payment_terms_checkbox.button_pressed = false
	gold_payment_pending_invoice_id = ""
	gold_payment_status_timer = -1.0
	gold_payment_status_poll_count = 0
	_set_gold_payment_busy(false)
	_set_gold_payment_status("Enter your M-Pesa number to buy %d Gold for %d KSH." % [gold_payment_selected_amount, gold_payment_selected_price])
	gold_payment_popup.popup_centered()
	if not OS.has_feature("mobile"):
		gold_payment_phone_input.grab_focus()


func _ensure_gold_payment_popup() -> void:
	if gold_payment_popup == null:
		gold_payment_popup = Window.new()
		gold_payment_popup.name = "GoldPaymentPopup"
		gold_payment_popup.title = "Buy Gold"
		gold_payment_popup.size = Vector2i(620, 610)
		gold_payment_popup.unresizable = true
		gold_payment_popup.borderless = true
		gold_payment_popup.transparent_bg = true
		gold_payment_popup.exclusive = true
		add_child(gold_payment_popup)
		gold_payment_popup.close_requested.connect(gold_payment_popup.hide)
	_rebuild_gold_payment_popup()


func _rebuild_gold_payment_popup() -> void:
	for child in gold_payment_popup.get_children():
		child.queue_free()

	var background: ColorRect = ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.01, 0.0, 0.035, 0.86)
	gold_payment_popup.add_child(background)

	var panel: Panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 16
	panel.offset_top = 16
	panel.offset_right = -16
	panel.offset_bottom = -16
	panel.add_theme_stylebox_override("panel", _make_showroom_style(Color(0.025, 0.006, 0.07, 0.94), Color(0.82, 0.18, 1.0, 0.96), 16, 2, 24))
	gold_payment_popup.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 36)
	margin.add_theme_constant_override("margin_top", 32)
	margin.add_theme_constant_override("margin_right", 36)
	margin.add_theme_constant_override("margin_bottom", 32)
	panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	margin.add_child(stack)
	stack.add_child(_make_showroom_label("M-PESA PAYMENT", 28, Color(0.98, 0.92, 1.0, 1.0)))
	stack.add_child(_make_showroom_label("%d Gold - %d KSH" % [gold_payment_selected_amount, gold_payment_selected_price], 24, Color(1.0, 0.82, 0.2, 1.0)))
	stack.add_child(_make_showroom_label("M-Pesa phone number", 16, Color(0.9, 0.92, 1.0, 1.0)))

	gold_payment_phone_input = LineEdit.new()
	gold_payment_phone_input.placeholder_text = "07XXXXXXXX, 01XXXXXXXX, or +254XXXXXXXXX"
	gold_payment_phone_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PHONE
	gold_payment_phone_input.max_length = 16
	gold_payment_phone_input.custom_minimum_size = Vector2(0, 48)
	gold_payment_phone_input.add_theme_font_size_override("font_size", 18)
	gold_payment_phone_input.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	gold_payment_phone_input.add_theme_stylebox_override("normal", _make_showroom_style(Color(0.02, 0.03, 0.08, 0.9), Color(0.31, 0.97, 0.85, 0.9), 10, 1, 8))
	stack.add_child(gold_payment_phone_input)

	var payment_notice_label: Label = _make_showroom_label(PAYMENT_FINAL_NOTICE_TEXT, 13, Color(1.0, 0.9, 0.58, 0.96))
	payment_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	stack.add_child(payment_notice_label)

	var payment_terms_row: HBoxContainer = HBoxContainer.new()
	payment_terms_row.add_theme_constant_override("separation", 8)
	stack.add_child(payment_terms_row)

	gold_payment_terms_checkbox = CheckBox.new()
	gold_payment_terms_checkbox.name = "GoldPaymentTermsCheckbox"
	gold_payment_terms_checkbox.custom_minimum_size = Vector2(38, 38)
	payment_terms_row.add_child(gold_payment_terms_checkbox)

	var payment_terms_label: Label = _make_showroom_label(PAYMENT_TERMS_CHECKBOX_TEXT, 13, Color(0.9, 0.94, 1.0, 0.96))
	payment_terms_label.name = "GoldPaymentTermsLabel"
	payment_terms_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	payment_terms_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	payment_terms_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	payment_terms_row.add_child(payment_terms_label)

	gold_payment_status_label = _make_showroom_label("", 14, Color(0.86, 0.9, 1.0, 1.0))
	gold_payment_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	gold_payment_status_label.custom_minimum_size = Vector2(0, 56)
	stack.add_child(gold_payment_status_label)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	stack.add_child(buttons)

	gold_payment_buy_button = _make_reference_button("SEND STK", Vector2(0, 50), Color(0.02, 0.08, 0.07, 0.9), Color(0.31, 0.97, 0.85, 1.0), 10)
	gold_payment_buy_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(gold_payment_buy_button)
	gold_payment_buy_button.pressed.connect(_on_gold_payment_send_pressed)

	gold_payment_cancel_button = _make_reference_button("CANCEL", Vector2(0, 50), Color(0.04, 0.03, 0.1, 0.86), Color(0.72, 0.36, 1.0, 1.0), 10)
	gold_payment_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	buttons.add_child(gold_payment_cancel_button)
	gold_payment_cancel_button.pressed.connect(gold_payment_popup.hide)

	if gold_payment_http_request == null:
		gold_payment_http_request = HTTPRequest.new()
		gold_payment_http_request.name = "GoldPaymentHTTPRequest"
		add_child(gold_payment_http_request)
	if not gold_payment_http_request.request_completed.is_connected(_on_gold_payment_http_request_completed):
		gold_payment_http_request.request_completed.connect(_on_gold_payment_http_request_completed)


func _make_showroom_label(text_value: String, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	label.add_theme_constant_override("shadow_outline_size", 2)
	return label


func _on_gold_payment_send_pressed() -> void:
	var phone: String = _normalize_mpesa_phone(gold_payment_phone_input.text if gold_payment_phone_input != null else "")
	if phone == "":
		_set_gold_payment_status("Enter a valid Safaricom number.")
		return
	if gold_payment_terms_checkbox == null or not gold_payment_terms_checkbox.button_pressed:
		_set_gold_payment_status(PAYMENT_TERMS_REQUIRED_STATUS)
		return
	var payload: Dictionary = {
		"amount": gold_payment_selected_price,
		"phone_number": phone,
		"purpose": "gold",
		"gold_amount": gold_payment_selected_amount,
		"player_name": "Player",
		"terms_accepted": true,
		"communication_consent": true
	}
	var headers: PackedStringArray = PackedStringArray([
		"Content-Type: application/json"
	])
	gold_payment_request_kind = "initialize"
	_set_gold_payment_busy(true)
	_set_gold_payment_status("Sending STK request...")
	var error: Error = gold_payment_http_request.request(_get_payment_server_url(PAYSTACK_INITIALIZE_ENDPOINT_PATH), headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		_set_gold_payment_busy(false)
		_set_gold_payment_status("Could not contact payment server.")


func _on_gold_payment_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_set_gold_payment_busy(false)
	if result != HTTPRequest.RESULT_SUCCESS or response_code <= 0:
		_set_gold_payment_status("Could not reach payment server. Check the Android internet permission, connection, and server URL.")
		return
	var response_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(response_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		var clean_response: String = response_text.strip_edges().replace("\n", " ")
		if clean_response == "":
			clean_response = "empty response"
		_set_gold_payment_status("Payment server did not return JSON: %s" % clean_response.left(110))
		return
	var response: Dictionary = parsed
	if response_code < 200 or response_code >= 300 or not bool(response.get("ok", false)):
		_set_gold_payment_status(str(response.get("error", "Payment request failed.")))
		return
	if gold_payment_request_kind == "status":
		_handle_gold_payment_status_response(response)
		return
	gold_payment_pending_invoice_id = _extract_payment_invoice_id(response)
	var provider_message: String = _extract_payment_provider_message(response)
	if provider_message == "":
		provider_message = "STK request sent. Complete the M-Pesa prompt to continue."
	_set_gold_payment_status(provider_message)
	if gold_payment_pending_invoice_id != "":
		gold_payment_status_poll_count = 0
		gold_payment_status_timer = PAYMENT_STATUS_POLL_SECONDS


func _process_gold_payment_status_poll(delta: float) -> void:
	if gold_payment_status_timer < 0.0 or gold_payment_pending_invoice_id == "":
		return
	gold_payment_status_timer -= delta
	if gold_payment_status_timer > 0.0:
		return
	gold_payment_status_timer = -1.0
	_request_gold_payment_status()


func _request_gold_payment_status() -> void:
	if gold_payment_status_poll_count >= PAYMENT_STATUS_MAX_POLLS:
		_set_gold_payment_status("Payment is still pending. Check Paystack dashboard if it completed.")
		return
	gold_payment_status_poll_count += 1
	gold_payment_request_kind = "status"
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	var payload: Dictionary = {
		"invoice_id": gold_payment_pending_invoice_id,
		"reference": gold_payment_pending_invoice_id
	}
	var error: Error = gold_payment_http_request.request(_get_payment_server_url(PAYSTACK_STATUS_ENDPOINT_PATH), headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		gold_payment_status_timer = PAYMENT_STATUS_POLL_SECONDS


func _handle_gold_payment_status_response(response: Dictionary) -> void:
	var state: String = _extract_payment_state(response)
	if ["COMPLETE", "COMPLETED", "PAID", "SUCCESS", "SUCCESSFUL"].has(state):
		var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
		if currency_manager != null and currency_manager.has_method("add_purchased_gold"):
			currency_manager.call("add_purchased_gold", gold_payment_selected_amount)
		gold_payment_pending_invoice_id = ""
		gold_payment_status_timer = -1.0
		_set_gold_payment_status("Payment confirmed. Added %d Gold." % gold_payment_selected_amount)
		_refresh_display()
		return
	if ["FAILED", "CANCELLED", "CANCELED", "DECLINED"].has(state):
		gold_payment_pending_invoice_id = ""
		gold_payment_status_timer = -1.0
		_set_gold_payment_status("Payment was not completed: %s." % state.capitalize())
		return
	_set_gold_payment_status("Waiting for Paystack confirmation... (%s)" % (state if state != "" else "pending"))
	gold_payment_status_timer = PAYMENT_STATUS_POLL_SECONDS


func _set_gold_payment_busy(is_busy: bool) -> void:
	if gold_payment_buy_button != null:
		gold_payment_buy_button.disabled = is_busy
	if gold_payment_cancel_button != null:
		gold_payment_cancel_button.disabled = is_busy


func _set_gold_payment_status(text_value: String) -> void:
	if gold_payment_status_label != null:
		gold_payment_status_label.text = text_value


func _normalize_mpesa_phone(value: String) -> String:
	var digits: String = ""
	for index in range(value.length()):
		var character: String = value.substr(index, 1)
		if character >= "0" and character <= "9":
			digits += character
	if digits.begins_with("0") and digits.length() == 10:
		digits = "254%s" % digits.substr(1)
	if (digits.begins_with("7") or digits.begins_with("1")) and digits.length() == 9:
		digits = "254%s" % digits
	if digits.begins_with("254") and digits.length() == 12 and (digits.substr(3, 1) == "7" or digits.substr(3, 1) == "1"):
		return "+%s" % digits
	return ""


func _get_payment_server_url(path: String) -> String:
	var configured: String = str(ProjectSettings.get_setting("application/config/payment_server_url", "")).strip_edges()
	if configured == "":
		configured = str(ProjectSettings.get_setting("application/config/online_server_url", "")).strip_edges()
	if configured == "":
		configured = "https://multiplayer-server-rr9p.onrender.com"
	configured = configured.replace(" ", "")
	if configured.begins_with("wss://"):
		configured = "https://%s" % configured.substr(6)
	elif configured.begins_with("ws://"):
		configured = "http://%s" % configured.substr(5)
	if configured.ends_with("/"):
		configured = configured.substr(0, configured.length() - 1)
	return "%s%s" % [configured, path]


func _extract_payment_invoice_id(response: Dictionary) -> String:
	for key in ["invoice_id", "reference", "id"]:
		var value: String = str(response.get(key, "")).strip_edges()
		if value != "":
			return value
	var invoice: Dictionary = response.get("invoice", {}) if typeof(response.get("invoice", {})) == TYPE_DICTIONARY else {}
	for key in ["invoice_id", "reference", "id"]:
		var invoice_value: String = str(invoice.get(key, "")).strip_edges()
		if invoice_value != "":
			return invoice_value
	var provider: Dictionary = response.get("provider_response", {}) if typeof(response.get("provider_response", {})) == TYPE_DICTIONARY else {}
	var provider_data: Dictionary = provider.get("data", {}) if typeof(provider.get("data", {})) == TYPE_DICTIONARY else {}
	for key in ["reference", "invoice_id", "id"]:
		var data_value: String = str(provider_data.get(key, "")).strip_edges()
		if data_value != "":
			return data_value
	var provider_invoice: Dictionary = provider.get("invoice", {}) if typeof(provider.get("invoice", {})) == TYPE_DICTIONARY else {}
	for key in ["invoice_id", "reference", "id"]:
		var provider_value: String = str(provider_invoice.get(key, "")).strip_edges()
		if provider_value != "":
			return provider_value
	return ""


func _extract_payment_state(response: Dictionary) -> String:
	var state: String = str(response.get("state", "")).strip_edges().to_upper()
	if state != "":
		return state
	var invoice: Dictionary = response.get("invoice", {}) if typeof(response.get("invoice", {})) == TYPE_DICTIONARY else {}
	state = str(invoice.get("state", "")).strip_edges().to_upper()
	if state != "":
		return state
	var provider: Dictionary = response.get("provider_response", {}) if typeof(response.get("provider_response", {})) == TYPE_DICTIONARY else {}
	var provider_data: Dictionary = provider.get("data", {}) if typeof(provider.get("data", {})) == TYPE_DICTIONARY else {}
	return str(provider_data.get("status", "")).strip_edges().to_upper()


func _extract_payment_provider_message(response: Dictionary) -> String:
	for key in ["provider_message", "display_text", "message"]:
		var value: String = str(response.get(key, "")).strip_edges()
		if value != "":
			return value
	var provider: Dictionary = response.get("provider_response", {}) if typeof(response.get("provider_response", {})) == TYPE_DICTIONARY else {}
	var provider_data: Dictionary = provider.get("data", {}) if typeof(provider.get("data", {})) == TYPE_DICTIONARY else {}
	for key in ["display_text", "message", "gateway_response"]:
		var provider_value: String = str(provider_data.get(key, "")).strip_edges()
		if provider_value != "":
			return provider_value
	return ""


func _make_stat_card(label_text: String, value_text: String, value_color: Color) -> Panel:
	var panel: Panel = Panel.new()
	panel.custom_minimum_size = Vector2(148, 64)
	panel.add_theme_stylebox_override("panel", _make_showroom_style(Color(0.02, 0.02, 0.08, 0.82), Color(0.36, 0.24, 0.72, 0.7), 8, 1, 8))

	var box: VBoxContainer = VBoxContainer.new()
	box.set_anchors_preset(Control.PRESET_FULL_RECT)
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 2)
	panel.add_child(box)

	var label: Label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0, 1.0))
	box.add_child(label)

	var value: Label = Label.new()
	value.text = value_text
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	value.add_theme_font_size_override("font_size", 22)
	value.add_theme_color_override("font_color", value_color)
	box.add_child(value)

	return panel


func _make_mode_rail_button(label_text: String, icon_text: String) -> Button:
	var button: Button = _make_reference_button("%s\n%s" % [icon_text, label_text], Vector2(118, 82), Color(0.03, 0.04, 0.12, 0.76), Color(0.34, 0.23, 0.85, 0.42), 9)
	button.add_theme_font_size_override("font_size", 14)
	return button


func _style_mode_button(button: Button, selected: bool) -> void:
	var fill: Color = Color(0.03, 0.04, 0.12, 0.76)
	var border: Color = Color(0.34, 0.23, 0.85, 0.42)
	var shadow_size: int = 0
	if selected:
		fill = Color(0.11, 0.06, 0.26, 0.92)
		border = Color(0.82, 0.28, 1.0, 1.0)
		shadow_size = 16
	button.add_theme_stylebox_override("normal", _make_showroom_style(fill, border, 9, 2 if selected else 1, shadow_size))
	button.add_theme_stylebox_override("hover", _make_showroom_style(fill.lightened(0.08), border.lightened(0.16), 9, 2 if selected else 1, shadow_size + 4))
	button.add_theme_stylebox_override("pressed", _make_showroom_style(fill.darkened(0.08), border, 9, 2 if selected else 1, shadow_size))
	button.modulate = Color(1.0, 1.0, 1.0, 1.0) if selected else Color(0.76, 0.78, 0.92, 0.9)


func _make_hex_plus_button() -> Button:
	var button: Button = _make_reference_button("+", Vector2(72, 72), Color(0.16, 0.2, 0.5, 0.28), Color(0.68, 0.78, 1.0, 0.95), 18)
	button.add_theme_font_size_override("font_size", 42)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	return button


func _make_badge(text_value: String, badge_position: Vector2) -> Label:
	var badge: Label = Label.new()
	badge.text = text_value
	badge.position = badge_position
	badge.custom_minimum_size = Vector2(30, 20)
	badge.size = Vector2(30, 20)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size", 12)
	badge.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
	badge.add_theme_stylebox_override("normal", _make_showroom_style(Color(0.95, 0.02, 0.06, 1.0), Color(1.0, 0.34, 0.4, 1.0), 8, 0))
	return badge


func _format_showroom_amount(value: int) -> String:
	var digits: String = str(maxi(value, 0))
	var formatted: String = ""
	var group_count: int = 0
	for index in range(digits.length() - 1, -1, -1):
		if group_count == 3:
			formatted = "," + formatted
			group_count = 0
		formatted = digits.substr(index, 1) + formatted
		group_count += 1
	return formatted


func make_side_button(text: String, emoji: String) -> Button:
	var b := Button.new()
	b.text = "%s\n%s" % [emoji, text]
	b.custom_minimum_size = Vector2(96, 68)
	b.focus_mode = Control.FOCUS_NONE
	b.add_theme_stylebox_override("normal", _make_showroom_style(Color(0.025, 0.03, 0.1, 0.86), Color(0.28, 0.32, 0.75, 0.45), 5, 1))
	b.add_theme_stylebox_override("hover", _make_showroom_style(Color(0.05, 0.06, 0.18, 0.9), Color(0.46, 0.52, 1.0, 0.7), 5, 1))
	b.add_theme_stylebox_override("pressed", _make_showroom_style(Color(0.02, 0.02, 0.08, 0.95), Color(0.52, 0.56, 1.0, 0.8), 5, 1))
	b.add_theme_font_size_override("font_size", 13)
	b.add_theme_color_override("font_color", Color(0.96, 0.96, 1.0, 1.0))
	b.alignment = HORIZONTAL_ALIGNMENT_CENTER

	return b
func _make_glass_button(text):
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(120, 45)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(1,1,1,0.08)
	style.border_color = Color(1,1,1,0.3)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18

	b.add_theme_stylebox_override("normal", style)
	return b


func _make_menu_button(text):
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(120, 60)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1,0.1,0.2,0.6)
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16

	b.add_theme_stylebox_override("normal", style)
	return b

func _load_marble_collection() -> void:
	if customization == null or not customization.has_method("get_marble_ids"):
		return

	marble_ids = customization.call("get_marble_ids")
	if customization.has_method("get_trail_ids"):
		trail_ids = customization.call("get_trail_ids")
	if customization.has_method("get_field_ids"):
		field_ids = customization.call("get_field_ids")
	var selected_property: Variant = customization.get("selected_marble_id")
	if selected_property != null:
		selected_marble_id = str(selected_property)
	else:
		selected_marble_id = ""
	var selected_trail_property: Variant = customization.get("selected_trail_id")
	if selected_trail_property != null:
		selected_trail_id = str(selected_trail_property)
	else:
		selected_trail_id = ""
	var selected_field_property: Variant = customization.get("selected_field_id")
	if selected_field_property != null:
		selected_field_id = str(selected_field_property)
	else:
		selected_field_id = ""
	if (selected_marble_id == "" or not marble_ids.has(selected_marble_id)) and marble_ids.size() > 0:
		selected_marble_id = marble_ids[0]
	if selected_trail_id == "" and trail_ids.size() > 0:
		selected_trail_id = trail_ids[0]
	if selected_field_id == "" and field_ids.size() > 0:
		selected_field_id = field_ids[0]

	for marble_id_variant in marble_ids:
		var marble_id: String = str(marble_id_variant)
		var preset: Dictionary = customization.call("get_marble_preset", marble_id)
		var button: Button = _create_belt_button(marble_id, preset)
		belt_row.add_child(button)
		marble_buttons[marble_id] = button

	for trail_id_variant in trail_ids:
		if trail_belt_row == null:
			break
		var trail_id: String = str(trail_id_variant)
		var trail_preset: Dictionary = customization.call("get_trail_preset", trail_id)
		var trail_button: Button = _create_trail_belt_button(trail_id, trail_preset)
		trail_belt_row.add_child(trail_button)
		trail_buttons[trail_id] = trail_button

	for field_id_variant in field_ids:
		if field_belt_row == null:
			break
		var field_id: String = str(field_id_variant)
		var field_preset: Dictionary = customization.call("get_field_preset", field_id)
		var field_button: Button = _create_field_belt_button(field_id, field_preset)
		field_belt_row.add_child(field_button)
		field_buttons[field_id] = field_button


func _refresh_display() -> void:
	if customization == null or selected_marble_id == "":
		return
	showroom_mode = SHOWROOM_MODE_MARBLES

	var preset: Dictionary = customization.call("get_marble_preset", selected_marble_id)
	var field_preset: Dictionary = customization.call("get_field_preset", selected_field_id) if customization.has_method("get_field_preset") and selected_field_id != "" else {}
	_apply_showroom_field_theme(field_preset)
	if showroom_decor_slots_dirty:
		_rebuild_showroom_decor_slots()
	if showroom_mode == SHOWROOM_MODE_FIELDS:
		_show_field_preview_scene(field_preset)
		_clear_showroom_marble_preview()
	else:
		_transition_showroom_gallery_smooth(preset)
		
	_showroom_sync_panels()

	var marble_name: String = str(preset.get("name", selected_marble_id))
	var trail_name: String = selected_trail_id
	var field_name: String = selected_field_id
	if customization.has_method("get_trail_preset") and selected_trail_id != "":
		var selected_trail_preset: Dictionary = customization.call("get_trail_preset", selected_trail_id)
		trail_name = str(selected_trail_preset.get("name", selected_trail_id))
	if not field_preset.is_empty():
		field_name = str(field_preset.get("name", selected_field_id))
	if title_label != null:
		title_label.text = marble_name
	var marble_description: String = str(preset.get("description", "Choose a marble from the belt below."))
	var field_description: String = str(field_preset.get("description", "")) if not field_preset.is_empty() else ""
	description_label.text = marble_description

	var is_unlocked: bool = true
	if customization.has_method("is_marble_unlocked"):
		is_unlocked = bool(customization.call("is_marble_unlocked", selected_marble_id))
	var field_unlocked: bool = true
	if customization.has_method("is_field_unlocked") and selected_field_id != "":
		field_unlocked = bool(customization.call("is_field_unlocked", selected_field_id))

	var coin_balance: int = int(customization.call("get_coin_balance")) if customization.has_method("get_coin_balance") else 0
	var gold_balance: int = int(customization.call("get_gold_balance")) if customization.has_method("get_gold_balance") else 0

	if coins_button != null:
		coins_button.text = "S %s" % _format_showroom_amount(coin_balance)

	if gold_button != null:
		gold_button.text = "G %s" % _format_showroom_amount(gold_balance)

	if showroom_mode == SHOWROOM_MODE_FIELDS and not field_unlocked:
		var field_unlock_cost: int = int(customization.call("get_field_unlock_cost", selected_field_id)) if customization.has_method("get_field_unlock_cost") else 0
		var field_unlock_currency: String = str(customization.call("get_field_unlock_currency", selected_field_id)) if customization.has_method("get_field_unlock_currency") else "coins"
		var field_currency_name: String = str(customization.call("get_currency_display_name", field_unlock_currency)) if customization.has_method("get_currency_display_name") else field_unlock_currency.capitalize()
		var can_unlock_field: bool = customization.has_method("can_unlock_field") and bool(customization.call("can_unlock_field", selected_field_id))
		apply_button.text = "UNLOCK"
		status_label.text = "Unlock field for %d %s. Balance: %d S coins | %d Gold" % [field_unlock_cost, field_currency_name.to_lower(), coin_balance, gold_balance]
		apply_button.disabled = not can_unlock_field
	elif showroom_mode != SHOWROOM_MODE_FIELDS and not is_unlocked:
		var unlock_cost: int = int(customization.call("get_marble_unlock_cost", selected_marble_id)) if customization.has_method("get_marble_unlock_cost") else 0
		var unlock_currency: String = str(customization.call("get_marble_unlock_currency", selected_marble_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
		var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
		var can_unlock: bool = customization.has_method("can_unlock_marble") and bool(customization.call("can_unlock_marble", selected_marble_id))
		apply_button.text = "UNLOCK"
		status_label.text = "Unlock marble for %d %s. Balance: %d S coins | %d Gold" % [unlock_cost, currency_name.to_lower(), coin_balance, gold_balance]
		apply_button.disabled = not can_unlock
	else:
		apply_button.text = "APPLY FIELD" if showroom_mode == SHOWROOM_MODE_FIELDS else "APPLY"
		status_label.text = "Ready to equip. S coins: %d | Gold: %d" % [coin_balance, gold_balance]
		apply_button.disabled = false



	for marble_id in marble_buttons.keys():
		var button: Button = marble_buttons[marble_id]
		if button == null:
			continue

		var selected: bool = marble_id == selected_marble_id
		var affordable: bool = true
		if customization != null and customization.has_method("is_marble_unlocked") and not bool(customization.call("is_marble_unlocked", str(marble_id))):
			affordable = customization.has_method("can_unlock_marble") and bool(customization.call("can_unlock_marble", str(marble_id)))
		_style_belt_item_button(button, selected, not affordable)
		_update_marble_belt_price_label(button, str(marble_id))

	for trail_id in trail_buttons.keys():
		var trail_button: Button = trail_buttons[trail_id] as Button
		if trail_button == null:
			continue
		_style_belt_item_button(trail_button, str(trail_id) == selected_trail_id, false)


	for field_id in field_buttons.keys():
		var field_button: Button = field_buttons[field_id] as Button
		if field_button == null:
			continue
		var field_selected: bool = str(field_id) == selected_field_id
		var field_affordable: bool = true
		if customization != null and customization.has_method("is_field_unlocked") and not bool(customization.call("is_field_unlocked", str(field_id))):
			field_affordable = customization.has_method("can_unlock_field") and bool(customization.call("can_unlock_field", str(field_id)))
		_style_belt_item_button(field_button, field_selected, not field_affordable)

	for mode_name in mode_buttons.keys():
		var mode_button: Button = mode_buttons[mode_name] as Button
		if mode_button == null:
			continue
		_style_mode_button(mode_button, str(mode_name) == showroom_mode)

	_schedule_belt_centering()


func _create_belt_button(marble_id: String, preset: Dictionary) -> Button:
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(142, 92)
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_NONE
	button.gui_input.connect(_on_marble_belt_gui_input)
	_style_belt_item_button(button, false, false)
	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	button.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(box)

	var icon: TextureRect = TextureRect.new()
	icon.texture = _get_marble_preview_texture(marble_id, preset)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(78, 46)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(icon)

	var label: Label = Label.new()
	label.text = str(preset.get("name", marble_id))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0, 1.0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_child(label)

	if customization != null and customization.has_method("is_marble_unlocked") and not bool(customization.call("is_marble_unlocked", marble_id)):
		var lock_label: Label = Label.new()
		var unlock_cost: int = int(customization.call("get_marble_unlock_cost", marble_id)) if customization.has_method("get_marble_unlock_cost") else 0
		var unlock_currency: String = str(customization.call("get_marble_unlock_currency", marble_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
		var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
		lock_label.text = "%d %s" % [unlock_cost, currency_name.to_upper()]
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_label.add_theme_font_size_override("font_size", 10)
		lock_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48, 0.98))
		lock_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(lock_label)
		button.set_meta("price_label", lock_label)

	button.pressed.connect(_on_belt_button_pressed.bind(marble_id))
	return button


func _create_trail_belt_button(trail_id: String, preset: Dictionary) -> Button:
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(142, 92)
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_NONE
	_style_belt_item_button(button, false, false)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	button.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 8)
	margin.add_child(box)

	var icon: TextureRect = TextureRect.new()
	icon.texture = _get_trail_preview_texture(trail_id, preset)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(104, 26)
	box.add_child(icon)

	var label: Label = Label.new()
	label.text = str(preset.get("name", trail_id))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0, 1.0))
	box.add_child(label)

	button.pressed.connect(_on_trail_button_pressed.bind(trail_id))
	return button



func _create_field_belt_button(field_id: String, preset: Dictionary) -> Button:
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(150, 92)
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_NONE
	_style_belt_item_button(button, false, false)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	button.add_child(margin)

	var box: VBoxContainer = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 5)
	margin.add_child(box)

	var icon: TextureRect = TextureRect.new()
	icon.texture = _get_field_preview_texture(field_id, preset)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(112, 32)
	box.add_child(icon)

	var label: Label = Label.new()
	label.text = str(preset.get("name", field_id))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 11)
	label.add_theme_color_override("font_color", Color(0.94, 0.97, 1.0, 1.0))
	box.add_child(label)

	if customization != null and customization.has_method("is_field_unlocked") and not bool(customization.call("is_field_unlocked", field_id)):
		var lock_label: Label = Label.new()
		lock_label.text = "LOCKED"
		lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lock_label.add_theme_font_size_override("font_size", 10)
		lock_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48, 0.98))
		box.add_child(lock_label)

	button.pressed.connect(_on_field_button_pressed.bind(field_id))
	return button


func _update_marble_belt_price_label(button: Button, marble_id: String) -> void:
	if button == null:
		return
	var price_label := button.get_meta("price_label", null) as Label
	if price_label == null:
		return
	if customization == null or not customization.has_method("is_marble_unlocked"):
		price_label.visible = false
		return

	var marble_locked: bool = not bool(customization.call("is_marble_unlocked", marble_id))
	price_label.visible = marble_locked
	if not marble_locked:
		return

	var unlock_cost: int = int(customization.call("get_marble_unlock_cost", marble_id)) if customization.has_method("get_marble_unlock_cost") else 0
	var unlock_currency: String = str(customization.call("get_marble_unlock_currency", marble_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
	var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
	price_label.text = "%d %s" % [unlock_cost, currency_name.to_upper()]


func _style_belt_item_button(button: Button, selected: bool, locked: bool) -> void:
	var fill: Color = Color(0.12, 0.13, 0.27, 0.72)
	var border: Color = Color(0.42, 0.45, 0.78, 0.28)
	var shadow_size: int = 0
	if selected:
		fill = Color(0.18, 0.12, 0.34, 0.88)
		border = Color(0.9, 0.44, 1.0, 1.0)
		shadow_size = 12
	elif locked:
		fill = Color(0.05, 0.055, 0.11, 0.62)
		border = Color(0.38, 0.38, 0.5, 0.22)

	button.add_theme_stylebox_override("normal", _make_showroom_style(fill, border, 10, 2 if selected else 1, shadow_size))
	button.add_theme_stylebox_override("hover", _make_showroom_style(fill.lightened(0.08), border.lightened(0.16), 10, 2 if selected else 1, shadow_size + 4))
	button.add_theme_stylebox_override("pressed", _make_showroom_style(fill.darkened(0.08), border, 10, 2 if selected else 1, max(shadow_size - 2, 0)))
	button.modulate = Color(1.0, 1.0, 1.0, 1.0) if not locked else Color(0.62, 0.62, 0.72, 0.82)


func _on_marble_belt_gui_input(event: InputEvent) -> void:
	if marble_belt_scroll == null:
		return

	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_begin_belt_drag(touch_event.position)
		else:
			if _end_belt_drag():
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		_drag_belt_to(drag_event.position)
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			if mouse_button.pressed:
				_begin_belt_drag(mouse_button.position)
			else:
				if _end_belt_drag():
					get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion:
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		if belt_drag_active and (mouse_motion.button_mask & MOUSE_BUTTON_MASK_LEFT) != 0:
			_drag_belt_to(mouse_motion.position)
			get_viewport().set_input_as_handled()
	elif event is InputEventPanGesture:
		var pan_event: InputEventPanGesture = event as InputEventPanGesture
		marble_belt_scroll.scroll_horizontal += int(round(pan_event.delta.x))
		marble_belt_target_scroll = float(marble_belt_scroll.scroll_horizontal)
		get_viewport().set_input_as_handled()


func _begin_belt_drag(position: Vector2) -> void:
	belt_drag_active = true
	belt_drag_last_position = position
	belt_drag_total_distance = 0.0
	if marble_belt_scroll != null:
		marble_belt_target_scroll = float(marble_belt_scroll.scroll_horizontal)


func _drag_belt_to(position: Vector2) -> void:
	if marble_belt_scroll == null:
		return
	if not belt_drag_active:
		_begin_belt_drag(position)
		return

	var delta_x: float = position.x - belt_drag_last_position.x
	if is_zero_approx(delta_x):
		return

	belt_drag_total_distance += absf(delta_x)
	marble_belt_scroll.scroll_horizontal = int(round(float(marble_belt_scroll.scroll_horizontal) - delta_x))
	marble_belt_target_scroll = float(marble_belt_scroll.scroll_horizontal)
	belt_drag_last_position = position


func _end_belt_drag() -> bool:
	var was_dragging_item: bool = belt_drag_total_distance >= BELT_DRAG_CLICK_THRESHOLD
	if was_dragging_item:
		belt_drag_ignore_click_until_msec = Time.get_ticks_msec() + 220
	belt_drag_active = false
	belt_drag_total_distance = 0.0
	return was_dragging_item


func _on_belt_button_pressed(marble_id: String) -> void:
	if Time.get_ticks_msec() < belt_drag_ignore_click_until_msec:
		return
	showroom_mode = SHOWROOM_MODE_MARBLES
	selected_marble_id = marble_id
	_refresh_display()


func _on_trail_button_pressed(trail_id: String) -> void:
	showroom_mode = SHOWROOM_MODE_TRAILS
	selected_trail_id = trail_id
	_refresh_display()


func _on_field_button_pressed(field_id: String) -> void:
	showroom_mode = SHOWROOM_MODE_FIELDS
	selected_field_id = field_id
	_refresh_display()


func _on_showroom_mode_pressed(mode_name: String) -> void:
	showroom_mode = mode_name
	_refresh_display()


func _on_prev_marble_pressed() -> void:
	showroom_transition_direction = -1.0
	match showroom_mode:
		SHOWROOM_MODE_FIELDS:
			if field_ids.is_empty():
				return
			var field_index: int = maxi(field_ids.find(selected_field_id), 0)
			selected_field_id = field_ids[(field_index - 1 + field_ids.size()) % field_ids.size()]
		SHOWROOM_MODE_TRAILS:
			if trail_ids.is_empty():
				return
			var trail_index: int = maxi(trail_ids.find(selected_trail_id), 0)
			selected_trail_id = trail_ids[(trail_index - 1 + trail_ids.size()) % trail_ids.size()]
		_:
			if marble_ids.is_empty():
				return
			var current_index: int = maxi(marble_ids.find(selected_marble_id), 0)
			selected_marble_id = marble_ids[(current_index - 1 + marble_ids.size()) % marble_ids.size()]
	_refresh_display()


func _on_next_marble_pressed() -> void:
	showroom_transition_direction = 1.0
	match showroom_mode:
		SHOWROOM_MODE_FIELDS:
			if field_ids.is_empty():
				return
			var field_index: int = maxi(field_ids.find(selected_field_id), 0)
			selected_field_id = field_ids[(field_index + 1) % field_ids.size()]
		SHOWROOM_MODE_TRAILS:
			if trail_ids.is_empty():
				return
			var trail_index: int = maxi(trail_ids.find(selected_trail_id), 0)
			selected_trail_id = trail_ids[(trail_index + 1) % trail_ids.size()]
		_:
			if marble_ids.is_empty():
				return
			var current_index: int = maxi(marble_ids.find(selected_marble_id), 0)
			selected_marble_id = marble_ids[(current_index + 1) % marble_ids.size()]
	_refresh_display()


func _on_apply_pressed() -> void:
	if customization == null or selected_marble_id == "":
		return

	if showroom_mode == SHOWROOM_MODE_FIELDS:
		if selected_field_id != "" and customization.has_method("is_field_unlocked") and not bool(customization.call("is_field_unlocked", selected_field_id)):
			if customization.has_method("can_unlock_field") and bool(customization.call("can_unlock_field", selected_field_id)):
				customization.call("unlock_field", selected_field_id)
			else:
				var field_unlock_cost: int = int(customization.call("get_field_unlock_cost", selected_field_id)) if customization.has_method("get_field_unlock_cost") else 0
				var field_unlock_currency: String = str(customization.call("get_field_unlock_currency", selected_field_id)) if customization.has_method("get_field_unlock_currency") else "coins"
				var field_currency_name: String = str(customization.call("get_currency_display_name", field_unlock_currency)) if customization.has_method("get_currency_display_name") else field_unlock_currency.capitalize()
				status_label.text = "Field locked. Need %d %s." % [field_unlock_cost, field_currency_name.to_lower()]
				return

		if customization.has_method("set_selected_field") and selected_field_id != "":
			customization.call("set_selected_field", selected_field_id)

		_refresh_display()
		_show_status_message("Field Applied Successfully")
		_show_applied_popup() # ✅ ADDED
		return

	if customization.has_method("is_marble_unlocked") and not bool(customization.call("is_marble_unlocked", selected_marble_id)):
		if customization.has_method("can_unlock_marble") and bool(customization.call("can_unlock_marble", selected_marble_id)):
			customization.call("unlock_marble", selected_marble_id)
		else:
			var unlock_cost: int = 0
			if customization.has_method("get_marble_unlock_cost"):
				unlock_cost = int(customization.call("get_marble_unlock_cost", selected_marble_id))
			var unlock_currency: String = str(customization.call("get_marble_unlock_currency", selected_marble_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
			var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
			status_label.text = "Locked. Need %d %s." % [unlock_cost, currency_name.to_lower()]
			return

	if customization.has_method("set_selected_marble"):
		customization.call("set_selected_marble", selected_marble_id)

	if customization.has_method("set_selected_trail") and selected_trail_id != "":
		customization.call("set_selected_trail", selected_trail_id)

	_refresh_display()
	_show_status_message("Marble Applied Successfully")
	_show_applied_popup() # ✅ ADDED

	if customization.has_method("is_marble_unlocked") and not bool(customization.call("is_marble_unlocked", selected_marble_id)):
		if customization.has_method("can_unlock_marble") and bool(customization.call("can_unlock_marble", selected_marble_id)):
			customization.call("unlock_marble", selected_marble_id)
		else:
			var unlock_cost: int = 0
			if customization.has_method("get_marble_unlock_cost"):
				unlock_cost = int(customization.call("get_marble_unlock_cost", selected_marble_id))
			var unlock_currency: String = str(customization.call("get_marble_unlock_currency", selected_marble_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
			var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
			status_label.text = "Locked. Need %d %s." % [unlock_cost, currency_name.to_lower()]
			return



	_refresh_display()
	_show_status_message("Marble Applied Successfully")


func _on_back_pressed() -> void:
	if menu_scene_path != "" and ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
		return
	for fallback_path in MENU_SCENE_FALLBACKS:
		if ResourceLoader.exists(fallback_path):
			get_tree().change_scene_to_file(fallback_path)
			return


func _clear_display_marble() -> void:
	if showroom_transition_tween != null:
		showroom_transition_tween.kill()
		showroom_transition_tween = null
	showroom_transition_active = false
	if trail_preview_root != null:
		trail_preview_root.queue_free()
		trail_preview_root = null
	if showroom_runtime_root != null:
		for child in showroom_runtime_root.get_children():
			child.queue_free()
	display_marble = null
	displayed_marble_id = ""
	showroom_target_position = _get_default_marble_position()
	showroom_target_rotation = _get_default_marble_rotation()
	showroom_target_scale = _get_default_marble_scale()
	showroom_camera_target_position = _get_default_camera_position()


func _clear_showroom_marble_preview() -> void:
	if trail_preview_root != null:
		trail_preview_root.queue_free()
		trail_preview_root = null
	if showroom_transition_tween != null:
		showroom_transition_tween.kill()
		showroom_transition_tween = null
	showroom_transition_active = false
	if showroom_runtime_root != null:
		for child in showroom_runtime_root.get_children():
			child.queue_free()
	display_marble = null
	displayed_marble_id = ""
	if showroom_root != null:
		showroom_root.visible = true


func _cleanup_showroom_marbles(keep_a: Node3D = null, keep_b: Node3D = null) -> void:
	if showroom_runtime_root == null:
		return
	for child in showroom_runtime_root.get_children():
		var marble_child: Node3D = child as Node3D
		if marble_child == null:
			continue
		if marble_child == keep_a or marble_child == keep_b:
			continue
		marble_child.visible = false


func _showroom_sync_panels() -> void:
	if marble_frame_panel != null:
		marble_frame_panel.visible = showroom_mode == SHOWROOM_MODE_MARBLES
	if trail_frame_panel != null:
		trail_frame_panel.visible = showroom_mode == SHOWROOM_MODE_TRAILS
	if field_frame_panel != null:
		field_frame_panel.visible = showroom_mode == SHOWROOM_MODE_FIELDS
	if showroom_field_root != null:
		showroom_field_root.visible = showroom_mode == SHOWROOM_MODE_FIELDS
	if showroom_root != null:
		showroom_root.visible = showroom_mode != SHOWROOM_MODE_FIELDS
	if showroom_platform != null:
		showroom_platform.visible = false
	if showroom_mode == SHOWROOM_MODE_FIELDS:
		showroom_camera_target_position = SHOWROOM_FIELD_CAMERA_POSITION
		showroom_look_target_position = SHOWROOM_FIELD_LOOK_TARGET
	else:
		showroom_camera_target_position = _get_default_camera_position()
		showroom_look_target_position = _get_default_look_target()


func _show_status_message(message: String, duration: float = 2.0) -> void:
	status_message_timer = duration
	if status_label != null:
		status_label.text = message


func _schedule_belt_centering() -> void:
	call_deferred("_sync_belt_centering")


func _sync_belt_centering() -> void:
	_center_belt_on_button(marble_belt_scroll, marble_buttons.get(selected_marble_id, null) as Control, false)


func _center_belt_on_button(scroll: ScrollContainer, button: Control, is_field: bool) -> void:
	if scroll == null or button == null:
		return

	var content: Control = button.get_parent() as Control
	if content == null:
		return

	var viewport_width: float = scroll.size.x
	var content_width: float = content.size.x
	if viewport_width <= 0.0 or content_width <= viewport_width:
		if scroll == field_belt_scroll or is_field:
			field_belt_target_scroll = 0.0
		elif scroll == trail_belt_scroll:
			trail_belt_target_scroll = 0.0
		else:
			marble_belt_target_scroll = 0.0
		return

	var target_scroll: float = button.position.x + button.size.x * 0.5 - viewport_width * 0.5
	target_scroll = clampf(target_scroll, 0.0, maxf(content_width - viewport_width, 0.0))
	if scroll == field_belt_scroll or is_field:
		field_belt_target_scroll = target_scroll
	elif scroll == trail_belt_scroll:
		trail_belt_target_scroll = target_scroll
	else:
		marble_belt_target_scroll = target_scroll


func _update_belt_scroll(delta: float, scroll: ScrollContainer, target_scroll: float) -> void:
	if scroll == null:
		return
	if absf(float(scroll.scroll_horizontal) - target_scroll) < 0.5:
		return
	scroll.scroll_horizontal = int(round(lerpf(float(scroll.scroll_horizontal), target_scroll, clampf(delta * 10.0, 0.0, 1.0))))


func _show_field_preview_scene(field_preset: Dictionary) -> void:
	if showroom_field_root == null:
		return
	for child in showroom_field_root.get_children():
		child.queue_free()

	var scene_path: String = str(field_preset.get("showroom_scene_path", ""))
	var preview_root: Node3D = null
	if scene_path != "" and ResourceLoader.exists(scene_path):
		var packed_scene: PackedScene = load(scene_path) as PackedScene
		if packed_scene != null:
			preview_root = packed_scene.instantiate() as Node3D

	if preview_root == null:
		_rebuild_showroom_field_preview(field_preset.get("theme", {}))
		return

	preview_root.position = Vector3(0.0, 2.12, 0.0)
	preview_root.scale = Vector3.ONE * 0.86
	showroom_field_root.add_child(preview_root)
	if preview_root.has_method("set_theme"):
		preview_root.call("set_theme", field_preset.get("theme", {}))


func _build_showroom_gallery() -> void:
	if showroom_runtime_root == null:
		return
	_cleanup_showroom_marbles()

	var marble_preset: Dictionary = customization.call("get_marble_preset", selected_marble_id)
	var marble: Node3D = _create_preview_marble_node(marble_preset.get("palette", {}), SHOWROOM_MARBLE_SCALE)
	if marble == null:
		return
	marble.position = _get_default_marble_position()
	marble.rotation = _get_default_marble_rotation()
	marble.scale = _get_default_marble_scale()
	showroom_runtime_root.add_child(marble)
	_add_showroom_halo(marble)
	_add_showroom_variant_boost(marble, selected_marble_id)
	display_marble = marble
	displayed_marble_id = selected_marble_id
	showroom_target_position = marble.position
	showroom_target_rotation = marble.rotation
	showroom_target_scale = marble.scale


func _transition_showroom_gallery(marble_preset: Dictionary) -> void:
	if showroom_runtime_root == null:
		return
	_transition_showroom_gallery_smooth(marble_preset)
	return

	var next_marble_id: String = str(marble_preset.get("id", selected_marble_id))
	if displayed_marble_id == next_marble_id and display_marble != null and is_instance_valid(display_marble):
		return

	var was_transitioning: bool = showroom_transition_active
	if showroom_transition_tween != null:
		showroom_transition_tween.kill()
		showroom_transition_tween = null

	if trail_preview_root != null:
		trail_preview_root.queue_free()
		trail_preview_root = null

	var new_marble: Node3D = _create_preview_marble_node(
		marble_preset.get("palette", {}),
		SHOWROOM_MARBLE_SCALE
	)

	if new_marble == null:
		return

	var previous_marble: Node3D = display_marble if is_instance_valid(display_marble) else null

	showroom_runtime_root.add_child(new_marble)
	marble_pool[next_marble_id] = new_marble

	_add_showroom_halo(new_marble)
	_add_showroom_variant_boost(new_marble, next_marble_id)

	var base_position: Vector3 = _get_default_marble_position()
	var base_rotation: Vector3 = _get_default_marble_rotation()
	var base_scale: Vector3 = _get_default_marble_scale()

	var dir = showroom_transition_direction

	new_marble.position = base_position + Vector3(2.5 * dir, 0, 0)
	new_marble.rotation = base_rotation
	new_marble.scale = base_scale

	var tween = create_tween()
	tween.tween_property(new_marble, "position", base_position, 0.15)

	if previous_marble != null:
		var tween2 = create_tween()
		tween2.tween_property(
			previous_marble,
			"position",
			base_position + Vector3(-2.5 * dir, 0, 0),
			0.12
		)

	await get_tree().create_timer(0.02).timeout

	if previous_marble != null and is_instance_valid(previous_marble):
		previous_marble.visible = false
		previous_marble.position = Vector3(9999, 9999, 9999)

	display_marble = new_marble
	displayed_marble_id = next_marble_id

	showroom_target_position = base_position
	showroom_target_rotation = base_rotation
	showroom_target_scale = base_scale
	


# ✅ ALWAYS RUN
	display_marble = new_marble
	displayed_marble_id = next_marble_id

	showroom_target_position = base_position
	showroom_target_rotation = base_rotation
	showroom_target_scale = base_scale


func _get_pooled_showroom_marble(marble_id: String) -> Node3D:
	var pooled_value: Variant = marble_pool.get(marble_id, null)
	if pooled_value != null and is_instance_valid(pooled_value) and pooled_value is Node3D:
		return pooled_value as Node3D
	if marble_pool.has(marble_id):
		marble_pool.erase(marble_id)
	return null


func _hide_inactive_pooled_marbles(previous_marble: Node3D, next_marble: Node3D) -> void:
	var stale_ids: Array[String] = []
	for marble_id in marble_pool.keys():
		var pooled_value: Variant = marble_pool[marble_id]
		if pooled_value == null or not is_instance_valid(pooled_value) or not (pooled_value is Node3D):
			stale_ids.append(str(marble_id))
			continue
		var pooled_marble: Node3D = pooled_value as Node3D
		if pooled_marble != previous_marble and pooled_marble != next_marble:
			pooled_marble.visible = false
	for stale_id in stale_ids:
		marble_pool.erase(stale_id)


func _transition_showroom_gallery_smooth(marble_preset: Dictionary) -> void:
	if showroom_runtime_root == null:
		return

	var next_marble_id: String = str(marble_preset.get("id", selected_marble_id))
	if displayed_marble_id == next_marble_id and display_marble != null and is_instance_valid(display_marble):
		return

	var was_transitioning: bool = showroom_transition_active
	if showroom_transition_tween != null:
		showroom_transition_tween.kill()
		showroom_transition_tween = null

	if trail_preview_root != null:
		trail_preview_root.queue_free()
		trail_preview_root = null

	var base_position: Vector3 = _get_default_marble_position()
	var base_rotation: Vector3 = _get_default_marble_rotation()
	var base_scale: Vector3 = _get_default_marble_scale()
	var slide_offset: Vector3 = Vector3(2.35 * showroom_transition_direction, 0.0, 0.0)
	var previous_marble: Node3D = display_marble if display_marble != null and is_instance_valid(display_marble) else null
	var next_marble: Node3D = _get_pooled_showroom_marble(next_marble_id)

	if next_marble == null or not is_instance_valid(next_marble):
		next_marble = _create_preview_marble_node(
			marble_preset.get("palette", {}),
			SHOWROOM_MARBLE_SCALE
		)
		if next_marble == null:
			return
		showroom_runtime_root.add_child(next_marble)
		marble_pool[next_marble_id] = next_marble
		_add_showroom_halo(next_marble)
		_add_showroom_variant_boost(next_marble, next_marble_id)

	_hide_inactive_pooled_marbles(previous_marble, next_marble)

	next_marble.visible = true
	next_marble.position = base_position + slide_offset
	next_marble.rotation = base_rotation
	next_marble.scale = base_scale

	if previous_marble != null and previous_marble != next_marble:
		previous_marble.visible = true
		if not was_transitioning:
			previous_marble.position = base_position
		previous_marble.rotation = base_rotation
		previous_marble.scale = base_scale

	display_marble = next_marble
	displayed_marble_id = next_marble_id
	showroom_target_position = base_position
	showroom_target_rotation = base_rotation
	showroom_target_scale = base_scale
	showroom_transition_active = true

	showroom_transition_tween = create_tween()
	showroom_transition_tween.set_parallel(true)
	showroom_transition_tween.set_trans(Tween.TRANS_SINE)
	showroom_transition_tween.set_ease(Tween.EASE_IN_OUT)
	showroom_transition_tween.tween_property(next_marble, "position", base_position, SHOWROOM_TRANSITION_TIME)

	if previous_marble != null and previous_marble != next_marble:
		showroom_transition_tween.tween_property(previous_marble, "position", base_position - slide_offset, SHOWROOM_EXIT_TIME)
	showroom_transition_tween.finished.connect(_finish_showroom_slide.bind(previous_marble, next_marble))


func _finish_showroom_slide(previous_marble: Variant, current_marble: Variant) -> void:
	var current_valid: bool = current_marble != null and is_instance_valid(current_marble)
	if previous_marble != null and is_instance_valid(previous_marble) and previous_marble is Node3D and (not current_valid or previous_marble != current_marble):
		var previous_node: Node3D = previous_marble as Node3D
		previous_node.visible = false
		previous_node.position = Vector3(9999, 9999, 9999)
	if current_valid and current_marble is Node3D:
		var current_node: Node3D = current_marble as Node3D
		current_node.position = _get_default_marble_position()
		current_node.scale = _get_default_marble_scale()
	showroom_transition_active = false
	showroom_transition_tween = null


func _display_marble_smoothly(delta: float) -> void:
	if display_marble == null:
		return
	if showroom_transition_active:
		return
		
	display_marble.position = display_marble.position.lerp(showroom_target_position, delta * 6.0)
	display_marble.scale = display_marble.scale.lerp(showroom_target_scale, delta * 6.0)
	# ❌ REMOVE rotation smoothing completely
# display_marble.rotation = ...lerp(showroom_target_rotation, delta * 6.0)


func _input(event):
	if display_marble == null:
		return

	if event is InputEventScreenTouch:
		dragging = event.pressed
		last_touch = event.position

	elif event is InputEventScreenDrag and dragging:
		var delta = event.position - last_touch
		last_touch = event.position

		display_marble.rotation_degrees.y -= delta.x * 0.5


func _create_preview_marble_node(palette: Dictionary, model_scale: float, apply_showroom_effects: bool = true) -> Node3D:
	var scene_instance: Node = GLASS_MARBLE_MODEL_SCENE.instantiate()
	var marble: Node3D = scene_instance as Node3D
	if marble == null:
		return null
	if marble.has_method("set_palette"):
		marble.call("set_palette", palette)
	if apply_showroom_effects:
		_optimize_marble_for_showroom(marble, palette)
	marble.scale = Vector3.ONE * model_scale
	return marble


func _rebuild_showroom_decor_slots() -> void:
	if customization == null or showroom_stage == null or showroom_decor_runtime_root == null:
		return
	for child in showroom_decor_runtime_root.get_children():
		child.queue_free()
	if not SHOWROOM_FIXED_DECOR_MARBLES_ENABLED:
		showroom_decor_slots_dirty = false
		return

	for slot_node in get_tree().get_nodes_in_group("showroom_marble_slots"):
		var slot: ShowroomMarbleSlot = slot_node as ShowroomMarbleSlot
		if slot == null or slot.is_selected_slot():
			continue
		if showroom_stage != slot and not showroom_stage.is_ancestor_of(slot):
			continue
		var marble_id: String = slot.get_slot_marble_id()
		if marble_id == "" or not customization.has_method("get_marble_preset"):
			continue
		var preset: Dictionary = customization.call("get_marble_preset", marble_id)
		if preset.is_empty():
			continue
		var palette: Dictionary = preset.get("palette", {})
		var marble: Node3D = _create_preview_marble_node(palette, 1.0, slot.apply_showroom_effects)
		if marble == null:
			continue
		marble.name = "%sPreview" % slot.name
		marble.position = slot.position
		marble.rotation = slot.rotation
		marble.scale = slot.scale * maxf(slot.scale_multiplier, 0.01)
		showroom_decor_runtime_root.add_child(marble)
		if slot.halo_enabled:
			_add_showroom_halo(marble)
		if marble_id == "glass_ball_ii":
			_add_showroom_variant_boost(marble, marble_id)
	showroom_decor_slots_dirty = false


func _update_decor_showroom_marbles() -> void:
	if showroom_stage == null or showroom_decor_runtime_root == null:
		return
	if not SHOWROOM_FIXED_DECOR_MARBLES_ENABLED:
		return
	for slot_node in get_tree().get_nodes_in_group("showroom_marble_slots"):
		var slot: ShowroomMarbleSlot = slot_node as ShowroomMarbleSlot
		if slot == null or slot.is_selected_slot():
			continue
		if showroom_stage != slot and not showroom_stage.is_ancestor_of(slot):
			continue
		var marble: Node3D = showroom_decor_runtime_root.get_node_or_null("%sPreview" % slot.name) as Node3D
		if marble == null:
			continue
		marble.position = slot.position
		marble.rotation = slot.rotation
		marble.scale = slot.scale * maxf(slot.scale_multiplier, 0.01)
		if slot.enable_float:
			marble.position += Vector3(0.0, sin(marble_float_time * slot.float_speed) * slot.float_amplitude, 0.0)
		var spin_speed: float = slot.spin_speed if slot.enable_spin else SHOWROOM_ROTATION_SPEED
		marble.rotation += Vector3(0.0, marble_spin_time * spin_speed, 0.0)


func _optimize_marble_for_showroom(root: Node3D, palette: Dictionary) -> void:
	var allow_flame_effects := _palette_uses_flame_effects(palette)
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			stack.append(child)
		if current != root and _is_showroom_marble_illumination_node(current, allow_flame_effects):
			current.queue_free()
			continue
		var mesh_instance: MeshInstance3D = current as MeshInstance3D
		if mesh_instance == null:
			continue
		mesh_instance.extra_cull_margin = 6.0
		var override_shader: ShaderMaterial = mesh_instance.material_override as ShaderMaterial
		if override_shader != null:
			var showroom_shader: ShaderMaterial = override_shader.duplicate(true) as ShaderMaterial
			if showroom_shader != null:
				showroom_shader.set_shader_parameter("emission_strength", 0.0)
				showroom_shader.set_shader_parameter("glow_strength", 0.0)
				showroom_shader.set_shader_parameter("rim_strength", 0.0)
				showroom_shader.set_shader_parameter("alpha_strength", 1.0)
				mesh_instance.material_override = showroom_shader

		var override_standard: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
		if override_standard != null:
			var showroom_standard: StandardMaterial3D = override_standard.duplicate(true) as StandardMaterial3D
			if showroom_standard != null:
				_preserve_visible_showroom_color(showroom_standard)
				showroom_standard.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
				showroom_standard.emission_enabled = false
				showroom_standard.emission_energy_multiplier = 0.0
				showroom_standard.albedo_color.a = 1.0
				mesh_instance.material_override = showroom_standard

		if mesh_instance.mesh == null:
			continue

		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var surface_material: Material = mesh_instance.get_surface_override_material(surface_index)
			if surface_material == null:
				surface_material = mesh_instance.mesh.surface_get_material(surface_index)
			var surface_shader: ShaderMaterial = surface_material as ShaderMaterial
			if surface_shader != null:
				var showroom_surface_shader: ShaderMaterial = surface_shader.duplicate(true) as ShaderMaterial
				if showroom_surface_shader != null:
					showroom_surface_shader.set_shader_parameter("emission_strength", 0.0)
					showroom_surface_shader.set_shader_parameter("glow_strength", 0.0)
					showroom_surface_shader.set_shader_parameter("rim_strength", 0.0)
					showroom_surface_shader.set_shader_parameter("alpha_strength", 1.0)
					mesh_instance.set_surface_override_material(surface_index, showroom_surface_shader)
				continue

			var surface_standard: StandardMaterial3D = surface_material as StandardMaterial3D
			if surface_standard != null:
				var showroom_surface_standard: StandardMaterial3D = surface_standard.duplicate(true) as StandardMaterial3D
				if showroom_surface_standard != null:
					_preserve_visible_showroom_color(showroom_surface_standard)
					showroom_surface_standard.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
					showroom_surface_standard.emission_enabled = false
					showroom_surface_standard.emission_energy_multiplier = 0.0
					showroom_surface_standard.albedo_color.a = 1.0
					mesh_instance.set_surface_override_material(surface_index, showroom_surface_standard)


func _preserve_visible_showroom_color(material: StandardMaterial3D) -> void:
	if material == null:
		return
	if material.albedo_texture == null and material.emission_texture != null:
		material.albedo_texture = material.emission_texture
	if not material.emission_enabled:
		return
	var emission_color: Color = material.emission
	if _showroom_color_luminance(emission_color) <= _showroom_color_luminance(material.albedo_color) + 0.04:
		return
	var alpha: float = material.albedo_color.a
	if _showroom_color_luminance(material.albedo_color) < 0.16:
		material.albedo_color = Color(emission_color.r, emission_color.g, emission_color.b, alpha)
	else:
		material.albedo_color = material.albedo_color.lerp(Color(emission_color.r, emission_color.g, emission_color.b, alpha), 0.35)


func _showroom_color_luminance(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722


func _is_showroom_marble_illumination_node(node: Node, allow_flame_effects: bool) -> bool:
	var lowered_name := str(node.name).to_lower()
	if node is Light3D or node is WorldEnvironment or node is ReflectionProbe:
		return true
	if node is GPUParticles3D or node is CPUParticles3D:
		return not (allow_flame_effects and lowered_name.find("flame") != -1)
	if lowered_name.find("flamecrown") != -1:
		return not allow_flame_effects
	return false


func _palette_uses_imported_model_scene(palette: Dictionary) -> bool:
	var scene_path: String = str(palette.get("marble_scene_path", "")).to_lower()
	if scene_path == "":
		return false
	return scene_path.ends_with("_model.tscn") or scene_path.ends_with("marble_glass_ball_ii.tscn") or scene_path.ends_with("marble_aura.tscn")


func _palette_uses_flame_effects(palette: Dictionary) -> bool:
	var scene_path: String = str(palette.get("marble_scene_path", "")).to_lower()
	var marble_type: String = str(palette.get("marble_type", "")).to_lower()
	var pattern_name: String = str(palette.get("pattern_name", "")).to_lower()
	return scene_path.find("flame") != -1 or marble_type == "flame" or pattern_name == "flame"


func _add_showroom_halo(marble: Node3D) -> void:
	var existing_halo: Node = marble.get_node_or_null("ShowroomHalo")
	if existing_halo != null:
		existing_halo.queue_free()


func _add_showroom_variant_boost(marble: Node3D, marble_id_override: String = "") -> void:
	pass


func _apply_showroom_field_theme(field_preset: Dictionary) -> void:
	if field_preset.is_empty():
		return
	var theme: Dictionary = field_preset.get("theme", {})
	if theme.is_empty():
		return

	var themed_background: Color = theme.get("showroom_bg", Color(0.005, 0.008, 0.018, 1.0))
	var use_field_lighting: bool = showroom_mode == SHOWROOM_MODE_FIELDS
	var themed_ambient: Color = theme.get("showroom_ambient", Color(0.74, 0.84, 1.0, 1.0)).lightened(0.12) if use_field_lighting else Color(1.0, 1.0, 1.0, 1.0)
	if room_environment != null:
		_configure_showroom_environment(room_environment.environment, themed_ambient, themed_background)
	if showroom_environment != null:
		_configure_showroom_environment(showroom_environment.environment, themed_ambient, themed_background)

	if showroom_fill_light != null:
		showroom_fill_light.light_color = theme.get("showroom_light", Color(0.56, 0.78, 1.0, 1.0)) if use_field_lighting else Color(0.96, 0.98, 1.0, 1.0)
		showroom_fill_light.light_energy = SHOWROOM_FILL_LIGHT_ENERGY
	if showroom_rim_light != null:
		showroom_rim_light.light_color = theme.get("showroom_rim", Color(0.76, 0.9, 1.0, 1.0)) if use_field_lighting else Color(0.92, 0.96, 1.0, 1.0)
		showroom_rim_light.light_energy = SHOWROOM_RIM_LIGHT_ENERGY
	if showroom_spotlight != null:
		var themed_spotlight_color: Color = theme.get("showroom_light", Color(0.9, 0.96, 1.0, 1.0)) if use_field_lighting else Color(1.0, 0.96, 0.82, 1.0)
		_configure_showroom_spotlight(
			showroom_spotlight,
			SHOWROOM_MAIN_SPOT_POSITION,
			SHOWROOM_MAIN_SPOT_TARGET,
			themed_spotlight_color.lightened(0.08),
			SHOWROOM_SPOTLIGHT_ENERGY,
			13.0,
			28.0,
			true
		)
	if showroom_marble_front_light != null:
		showroom_marble_front_light.light_color = theme.get("showroom_light", Color(0.92, 0.97, 1.0, 1.0)).lightened(0.16) if use_field_lighting else Color(1.0, 1.0, 1.0, 1.0)
		showroom_marble_front_light.light_energy = SHOWROOM_MARBLE_FRONT_LIGHT_ENERGY
	if showroom_marble_top_light != null:
		showroom_marble_top_light.light_color = theme.get("showroom_rim", Color(0.72, 0.88, 1.0, 1.0)) if use_field_lighting else Color(0.98, 0.99, 1.0, 1.0)
		showroom_marble_top_light.light_energy = SHOWROOM_MARBLE_TOP_LIGHT_ENERGY
	if showroom_side_light != null:
		showroom_side_light.light_color = theme.get("showroom_rim", Color(0.76, 0.9, 1.0, 1.0)).lightened(0.18) if use_field_lighting else Color(0.98, 0.98, 1.0, 1.0)
		showroom_side_light.light_energy = SHOWROOM_SIDE_LIGHT_ENERGY

	if showroom_platform != null:
		var platform_material: StandardMaterial3D = StandardMaterial3D.new()
		platform_material.albedo_color = theme.get("showroom_platform", Color(0.08, 0.035, 0.18, 1.0)).lerp(Color(0.24, 0.06, 0.46, 1.0), 0.45)
		platform_material.emission_enabled = true
		platform_material.emission = theme.get("showroom_light", Color(0.68, 0.24, 1.0, 1.0))
		platform_material.emission_energy_multiplier = 0.22
		platform_material.metallic = 0.25
		platform_material.roughness = 0.18
		showroom_platform.material_override = platform_material


func _rebuild_showroom_field_preview(theme: Dictionary) -> void:
	if showroom_field_root == null:
		return
	for child in showroom_field_root.get_children():
		child.queue_free()

	showroom_field_root.position = Vector3(0.0, 2.12, 0.0)

	var turf: MeshInstance3D = MeshInstance3D.new()
	var turf_mesh: CylinderMesh = CylinderMesh.new()
	turf_mesh.top_radius = 2.8
	turf_mesh.bottom_radius = 2.92
	turf_mesh.height = 0.14
	turf.mesh = turf_mesh
	turf.position = Vector3(0.0, -0.02, 0.0)
	var turf_material: StandardMaterial3D = StandardMaterial3D.new()
	turf_material.albedo_color = theme.get("fairway_base", Color(0.34, 0.61, 0.31, 1.0))
	turf_material.emission_enabled = true
	turf_material.emission = theme.get("fairway_light", Color(0.51, 0.72, 0.43, 1.0))
	turf_material.emission_energy_multiplier = 0.12
	turf_material.roughness = 0.86
	turf.material_override = turf_material
	showroom_field_root.add_child(turf)

	var lake_ring: MeshInstance3D = MeshInstance3D.new()
	var ring_mesh: TorusMesh = TorusMesh.new()
	ring_mesh.inner_radius = 2.85
	ring_mesh.outer_radius = 3.95
	lake_ring.mesh = ring_mesh
	lake_ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	lake_ring.position = Vector3(0.0, -0.02, 0.0)
	var lake_material: StandardMaterial3D = StandardMaterial3D.new()
	lake_material.albedo_color = theme.get("lake_shallow", Color(0.08, 0.34, 0.42, 1.0))
	lake_material.emission_enabled = true
	lake_material.emission = theme.get("lake_foam", Color(0.78, 0.94, 1.0, 1.0))
	lake_material.emission_energy_multiplier = 0.28
	lake_material.roughness = 0.1
	lake_material.metallic = 0.18
	lake_ring.material_override = lake_material
	showroom_field_root.add_child(lake_ring)

	var glow: MeshInstance3D = MeshInstance3D.new()
	var glow_mesh: QuadMesh = QuadMesh.new()
	glow_mesh.size = Vector2(6.8, 6.8)
	glow.mesh = glow_mesh
	glow.rotation_degrees = Vector3(-90.0, 0.0, 0.0)
	glow.position = Vector3(0.0, 0.02, 0.0)
	var glow_material: StandardMaterial3D = StandardMaterial3D.new()
	glow_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	glow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	glow_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	glow_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	glow_material.albedo_texture = _make_showroom_glow_texture()
	glow_material.albedo_color = theme.get("showroom_light", Color(0.56, 0.78, 1.0, 1.0))
	glow_material.emission_enabled = true
	glow_material.emission = theme.get("showroom_rim", Color(0.76, 0.9, 1.0, 1.0))
	glow_material.emission_energy_multiplier = 1.2
	glow.material_override = glow_material
	showroom_field_root.add_child(glow)


func _make_showroom_glow_texture() -> ImageTexture:
	var size: int = 96
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	for y in range(size):
		for x in range(size):
			var uv: Vector2 = (Vector2(x, y) + Vector2(0.5, 0.5)) / float(size)
			var centered: Vector2 = uv * 2.0 - Vector2.ONE
			var radius: float = centered.length()
			var alpha: float = clampf(1.0 - smoothstep(0.2, 1.0, radius), 0.0, 1.0)
			image.set_pixel(x, y, Color(1.0, 1.0, 1.0, alpha * alpha))
	return ImageTexture.create_from_image(image)


func _make_ui_button(text_value: String) -> Button:
	var button: Button = Button.new()
	button.text = text_value
	button.custom_minimum_size = Vector2(0, 52)

	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", Color(1,1,1,1))

	var style = StyleBoxFlat.new()
	style.bg_color = Color(1,1,1,0.08) # transparent glass
	style.border_color = Color(1,1,1,0.25)
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20

	button.add_theme_stylebox_override("normal", style)

	return button

func _make_panel_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_left = 18
	style.corner_radius_bottom_right = 18
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 12
	return style


func _get_marble_preview_texture(marble_id: String, preset: Dictionary) -> Texture2D:
	if preview_cache.has(marble_id):
		return preview_cache[marble_id] as Texture2D
	var texture: Texture2D = _make_marble_preview_texture(preset)
	preview_cache[marble_id] = texture
	return texture


func _get_trail_preview_texture(trail_id: String, preset: Dictionary) -> Texture2D:
	if trail_preview_cache.has(trail_id):
		return trail_preview_cache[trail_id] as Texture2D
	var texture: Texture2D = _make_trail_preview_texture(preset)
	trail_preview_cache[trail_id] = texture
	return texture


func _get_field_preview_texture(field_id: String, preset: Dictionary) -> Texture2D:
	if field_preview_cache.has(field_id):
		return field_preview_cache[field_id] as Texture2D
	var texture: Texture2D = _make_field_preview_texture(preset)
	field_preview_cache[field_id] = texture
	return texture


func _make_marble_preview_texture(preset: Dictionary) -> Texture2D:
	var size: int = 120
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	var palette: Dictionary = preset.get("palette", {})
	var base_color: Color = palette.get("shell_base_color", Color(0.58, 0.8, 1.0, 0.18))
	var swirl_orange: Color = palette.get("shell_swirl_orange", Color(0.94, 0.48, 0.17, 1.0))
	var swirl_green: Color = palette.get("shell_swirl_green", Color(0.22, 0.78, 0.34, 1.0))
	var swirl_blue: Color = palette.get("shell_swirl_blue", Color(0.07, 0.18, 0.86, 1.0))
	var swirl_shadow: Color = palette.get("shell_swirl_shadow", Color(0.34, 0.09, 0.18, 1.0))
	var marble_type: String = str(preset.get("type", palette.get("marble_type", "default"))).to_lower()
	var pattern_name: String = str(preset.get("pattern", palette.get("pattern_name", "default"))).to_lower()

	for y in range(size):
		for x in range(size):
			var uv: Vector2 = (Vector2(x, y) + Vector2(0.5, 0.5)) / float(size)
			var p: Vector2 = uv * 2.0 - Vector2.ONE
			var radius: float = p.length()
			if radius > 0.94:
				image.set_pixel(x, y, Color(0.0, 0.0, 0.0, 0.0))
				continue

			var color: Color = base_color
			if marble_type == "flame" or pattern_name == "flame":
				var flicker: float = sin(uv.y * 15.0 + uv.x * 3.2) * 0.5 + 0.5
				var flame_glow: float = clampf(1.0 - radius / 0.94, 0.0, 1.0)
				color = swirl_orange.lerp(swirl_green, flicker)
				color = color.lerp(swirl_blue, 1.0 - flame_glow)
				color = color.lerp(Color(1.0, 0.95, 0.82, 1.0), flame_glow * 0.35)
			elif marble_type == "stripe" or pattern_name == "stripe":
				var stripe_mask: float = 1.0 if sin((uv.y + uv.x * 0.4) * 28.0) >= 0.0 else 0.0
				color = base_color.lerp(swirl_orange, stripe_mask * 0.92)
				color = color.lerp(swirl_shadow, (1.0 - stripe_mask) * 0.18)
			else:
				var band_a: float = _band_mask(abs(uv.y - (0.42 + sin(uv.x * TAU * 1.1) * 0.11)), 0.15, 0.04)
				var band_b: float = _band_mask(abs(uv.y - (0.62 + sin((uv.x + 0.2) * TAU * 1.4) * 0.09)), 0.1, 0.025)
				var shadow_band: float = _band_mask(abs(uv.y - (0.38 + sin(uv.x * TAU * 0.9) * 0.1)), 0.05, 0.02)
				color = color.lerp(swirl_orange, band_a * 0.85)
				color = color.lerp(swirl_green, band_b * 0.72)
				color = color.lerp(swirl_blue, band_b * 0.38)
				color = color.lerp(swirl_shadow, shadow_band * 0.58)

			var highlight: float = clampf(1.0 - ((p - Vector2(-0.28, -0.32)).length() / 0.26), 0.0, 1.0)
			color = color.lerp(Color(1.0, 1.0, 1.0, 1.0), highlight * 0.55)
			image.set_pixel(x, y, Color(color.r, color.g, color.b, 1.0))

	return ImageTexture.create_from_image(image)


func _make_trail_preview_texture(preset: Dictionary) -> Texture2D:
	var width: int = 120
	var height: int = 28
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	var enabled: bool = bool(preset.get("enabled", false))
	var primary: Color = preset.get("color", Color(0.42, 0.92, 1.0, 0.34))
	var secondary: Color = preset.get("secondary_color", primary)
	var emission: Color = preset.get("emission", primary)

	for y in range(height):
		for x in range(width):
			var uv: Vector2 = Vector2(float(x) / float(width - 1), float(y) / float(height - 1))
			var color: Color = Color(0.0, 0.0, 0.0, 0.0)
			if enabled:
				var wave_center: float = 0.5 + sin(uv.x * TAU * 1.2) * 0.1
				var mask: float = _band_mask(abs(uv.y - wave_center), 0.12, 0.18)
				color = primary.lerp(secondary, uv.x)
				color = color.lerp(emission, 0.35)
				color.a = mask
			else:
				var muted: float = _band_mask(abs(uv.y - 0.5), 0.1, 0.16)
				color = Color(0.45, 0.48, 0.54, muted * 0.8)
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)


func _make_field_preview_texture(preset: Dictionary) -> Texture2D:
	var width: int = 148
	var height: int = 42
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	var theme: Dictionary = preset.get("theme", {})
	var fairway_light: Color = theme.get("fairway_light", Color(0.5, 0.72, 0.43, 1.0))
	var fairway_dark: Color = theme.get("fairway_dark", Color(0.24, 0.46, 0.25, 1.0))
	var lake_color: Color = theme.get("lake_shallow", Color(0.08, 0.34, 0.42, 1.0))
	var sky_color: Color = theme.get("sky_horizon", Color(0.80, 0.90, 0.97, 1.0))

	for y in range(height):
		for x in range(width):
			var uv: Vector2 = Vector2(float(x) / float(width - 1), float(y) / float(height - 1))
			var color: Color
			if uv.y < 0.42:
				color = sky_color.lerp(Color(1.0, 1.0, 1.0, 1.0), 0.08 + uv.y * 0.12)
			elif uv.y < 0.7:
				var stripe: float = 0.5 + 0.5 * sin((uv.x * 12.0 + uv.y * 3.0) * PI)
				color = fairway_dark.lerp(fairway_light, stripe)
			else:
				color = lake_color.lerp(lake_color.darkened(0.42), smoothstep(0.7, 1.0, uv.y))
			image.set_pixel(x, y, color)

	return ImageTexture.create_from_image(image)



func _band_mask(distance: float, width: float, softness: float) -> float:
	return 1.0 - smoothstep(width, width + softness, distance)


func _make_trail_strip_texture(primary: Color, secondary: Color, alpha_scale: float) -> ImageTexture:
	var width: int = 96
	var height: int = 18
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		for x in range(width):
			var uv: Vector2 = Vector2(float(x) / float(width - 1), float(y) / float(height - 1))
			var edge_fade: float = 1.0 - smoothstep(0.0, 0.48, abs(uv.y - 0.5) * 2.0)
			var tail_fade: float = 1.0 - uv.x
			var color: Color = primary.lerp(secondary, uv.x * 0.85)
			color.a = edge_fade * tail_fade * alpha_scale
			image.set_pixel(x, y, color)
	return ImageTexture.create_from_image(image)
func _show_applied_popup():
	var popup = Label.new()
	popup.text = "APPLIED ✅"

	popup.add_theme_font_size_override("font_size", 28)
	popup.add_theme_color_override("font_color", Color(0.9, 1.0, 0.9, 1.0))

	popup.anchor_left = 0.5
	popup.anchor_top = 0.5
	popup.anchor_right = 0.5
	popup.anchor_bottom = 0.5
	popup.offset_left = -120
	popup.offset_top = -25
	popup.offset_right = 120
	popup.offset_bottom = 25

	add_child(popup)

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(popup, "modulate:a", 0.0, 1.5)

	await tween.finished
	popup.queue_free()
