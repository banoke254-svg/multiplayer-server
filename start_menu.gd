extends Control

@export_file("*.tscn") var main_scene_path: String = "res://main.tscn"
@export_file("*.tscn") var customize_scene_path: String = "res://customize_room.tscn"
@export var donate_url: String = ""
const BACKGROUND_PATH: String = "res://ui/bano_start_background.png"
const MENU_LOGO_PATH: String = "res://ui/bano_header_wordmark.png"
const RULES_PAGE_PATH: String = "res://ui/bano_rules_page.png"
const MENU_MUSIC_PATH: String = "res://audio_menu_theme.mp3"
const MENU_MUSIC_BUS_NAME: String = "Music"
const SFX_BUS_NAME: String = "SFX"
const SHOOTING_MECHANIC_DRAG_IMAGE_PATH: String = "res://ui/shoot_mechanic_drag.png"
const SHOOTING_MECHANIC_SPLIT_IMAGE_PATH: String = "res://ui/shoot_mechanic_split.png"
const SHOOTING_MECHANIC_HOLD_IMAGE_PATH: String = "res://ui/shoot_mechanic_hold.png"
const ONLINE_ROOMS_BACKGROUND_PATH: String = "res://ui/bano_online_rooms.png"
const ONLINE_ROOMS_BACKGROUND_FALLBACK_PATH: String = "C:/Users/LENOVO/Downloads/ChatGPT Image May 5, 2026, 07_42_00 AM.png"
const ONLINE_LOADING_SCREEN_PATH: String = "res://ui/bano_match_loading.png"
const ONLINE_LOADING_VIDEO_PATH: String = "res://ui/online_loading.ogv"
const ONLINE_PAGE_MARGIN_X: int = 18
const ONLINE_BODY_GAP: int = 14
const ONLINE_MATCHMAKING_PANEL_MIN_WIDTH: float = 350.0
const ONLINE_MATCHMAKING_PANEL_MAX_WIDTH: float = 430.0
const ONLINE_SOCIAL_PANEL_MIN_WIDTH: float = 300.0
const ONLINE_SOCIAL_PANEL_MAX_WIDTH: float = 380.0
const ONLINE_ROOMS_BACKGROUND_MARBLE_FOCUS_X: float = 0.68
const ONLINE_ROOMS_BACKGROUND_MAX_LEFT_SHIFT: float = 460.0
const ONLINE_CHAT_TOAST_SECONDS: float = 4.0
const ONLINE_CHAT_BUTTON_SIZE := Vector2(108.0, 52.0)
const ONLINE_CHAT_BUTTON_OFFSET := Vector2(24.0, 92.0)
const ONLINE_CHAT_BUTTON_DRAG_THRESHOLD: float = 8.0
const PAYSTACK_INITIALIZE_ENDPOINT_PATH: String = "/payments/paystack/initialize"
const PAYSTACK_STATUS_ENDPOINT_PATH: String = "/payments/paystack/status"
const GOOGLE_AUTH_START_ENDPOINT_PATH: String = "/auth/google/device/start"
const GOOGLE_AUTH_POLL_ENDPOINT_PATH: String = "/auth/google/device/poll"
const GOOGLE_PROFILE_SAVE_ENDPOINT_PATH: String = "/profiles/save"
const PAYMENT_STATUS_POLL_SECONDS: float = 3.0
const PAYMENT_STATUS_MAX_POLLS: int = 65
const GOOGLE_AUTH_DEFAULT_POLL_SECONDS: float = 5.0
const TERMS_ACCEPTANCE_PATH: String = "user://terms_acceptance.save"
const TERMS_VERSION: String = "2026-05-15-email-consent"
const PAYMENT_TERMS_CHECKBOX_TEXT: String = "I understand that Gold/Coins are digital game currency only, have no real-money value, cannot be withdrawn, payments/donations are non-refundable, and Bano ke may contact me by email or message about this payment, support, account notices, and game updates."
const PAYMENT_FINAL_NOTICE_TEXT: String = "Check your amount carefully before paying. Donations and digital currency purchases are final and non-refundable."
const PAYMENT_TERMS_REQUIRED_STATUS: String = "Tick the payment and message consent checkbox before paying."
const TERMS_TEXT: String = """
Bano ke Terms and Conditions

These Terms and Conditions apply to your access and use of Bano ke ("the Game", "we", "us", or "our"), including online multiplayer features, player accounts, donations, and purchases of digital game currency or digital items.

By using the Game, creating a player profile, making a payment, or receiving any digital game currency, you agree to these Terms.

1. About the Game

Bano ke is an entertainment game. The Game may include online multiplayer features, player profiles, leaderboards, digital currency, digital items, and optional payment features.

The Game is provided for personal entertainment only. It is not a gambling service, betting service, investment service, financial service, banking service, money transfer service, or real-money earning platform.

2. Player Accounts and Profiles

Players may create or use a player name, login ID, age, and other gameplay information.

You are responsible for providing accurate information when required. You must not impersonate another person, use offensive names, abuse other players, exploit bugs, or use the Game for illegal activity.

We may suspend, restrict, reset, or remove access to any player profile if we believe the player has violated these Terms, abused payment systems, cheated, threatened other users, attempted fraud, or harmed the Game.

3. Digital Game Currency

The Game may use digital currency, including but not limited to "Gold", "Coins", or similar in-game balances.

Digital game currency is not real money.

Digital game currency:
- has no cash value;
- cannot be withdrawn;
- cannot be exchanged for Kenyan Shillings or any other real-world currency;
- cannot be transferred outside the Game;
- cannot be sold, traded, or redeemed for real-world goods or services;
- is only a limited digital feature for use inside the Game.

Buying, receiving, or using digital game currency does not give you ownership of real currency, shares, property, or financial value. You only receive a limited permission to use that digital currency inside the Game, subject to these Terms.

4. Donations and Optional Payments

The Game may allow players to make optional payments or donations. Some donations or payments may reward the player with digital game currency or digital benefits.

All payment amounts are shown before you confirm payment. You are responsible for checking the amount carefully before paying.

Do not pay unless you are sure:
- the amount is correct;
- the phone number or payment account is correct;
- you understand that the payment is for digital game content or support of the Game;
- you understand that digital game currency is not real money;
- you understand the no-refund policy below.

5. No Refund Policy

All donations, digital currency purchases, and digital item purchases are final and non-refundable.

Once payment is made and the digital currency, digital item, or donation benefit is processed, we do not provide refunds, reversals, cash returns, or exchanges, except where required by applicable law or where we choose to correct a confirmed technical error.

Please be careful before paying. If you enter the wrong amount, pay by mistake, change your mind, stop playing, lose access due to your own device/account issue, or decide you no longer want the digital currency, we are not required to refund the payment.

6. Technical Errors

If you paid successfully but did not receive the correct digital currency or digital benefit because of a confirmed server or payment processing error, contact us using the support details below.

We may ask for:
- payment reference;
- phone number used for payment;
- player name or login ID;
- date and time of payment;
- screenshot or proof of payment.

If we confirm a technical issue, our usual remedy will be to credit the correct digital currency or digital item to your player profile. A cash refund is not guaranteed and may only be provided if required by law or approved by us.

7. Chargebacks, Reversals, and Payment Disputes

Payments may be processed through Paystack or other payment providers. By making a payment, you agree to comply with the payment provider's rules.

If you file a false chargeback, payment dispute, or reversal after receiving digital currency or digital benefits, we may:
- suspend or ban your player profile;
- remove the digital currency or items connected to the disputed payment;
- block future payments;
- provide evidence to the payment provider that the digital content was delivered;
- take any other action allowed by law.

A payment dispute does not automatically mean you are entitled to keep digital currency or digital benefits.

8. Payment Provider

Payments are processed by Paystack or another third-party payment provider. We do not control all payment provider decisions, bank decisions, mobile money provider decisions, transaction delays, chargebacks, failed payments, reversals, or account reviews.

Paystack and other providers may collect and process your payment information according to their own terms and privacy policies.

We do not store your full card details, mobile money PIN, or sensitive payment credentials.

9. Delivery of Digital Currency

Digital currency or digital items are normally delivered inside the Game after a successful payment confirmation.

Delivery may be delayed due to network problems, server issues, payment provider delays, phone network delays, or maintenance.

Digital delivery means the digital currency or item is added to your player profile or made available inside the Game. No physical goods will be delivered.

10. Age and Guardian Permission

If you are under 18 years old, you must have permission from your parent or legal guardian before using paid features, making donations, or buying digital currency.

Parents and guardians are responsible for payments made by minors using their device, phone number, account, mobile money wallet, card, or payment method.

If you allow a child or another person to use your device or payment method, you are responsible for any payments they make.

11. Fair Use and Prohibited Conduct

You must not:
- use the Game for gambling, betting, lotteries, cash prizes, or illegal activity;
- sell or trade digital currency outside the Game;
- attempt to convert digital currency into real money;
- exploit bugs or server errors;
- use cheats, bots, hacks, modified clients, or unauthorized tools;
- threaten, harass, abuse, or scam other players;
- attempt to reverse payments dishonestly;
- interfere with servers, payment systems, or other players' access.

We may restrict or permanently ban accounts that violate these rules.

12. Changes to Digital Currency and Game Features

We may update, rebalance, modify, limit, remove, or rename digital currency, items, prices, rewards, features, game modes, or multiplayer systems at any time.

Digital currency and digital items may lose usefulness if the Game changes, if a feature is removed, or if a player is banned for violating these Terms.

We are not required to provide refunds because of game updates, balance changes, removed features, downtime, or discontinued services, except where required by law.

13. Server Availability

The Game and online features may not always be available. Servers may go offline for maintenance, updates, errors, internet problems, hosting issues, payment provider issues, or reasons outside our control.

We do not guarantee uninterrupted access to the Game, multiplayer servers, player profiles, digital currency, or payment features.

14. Privacy and Player Data

We may collect player information such as player name, login ID, age, email address, game activity, payment reference, purchase records, device/network information, and server logs.

We use this information to:
- operate the Game;
- show player profiles and multiplayer sessions;
- process payments;
- deliver digital currency;
- prevent fraud and abuse;
- respond to support requests;
- send payment, support, account, and game update messages where you consent;
- comply with legal and payment provider obligations.

Payment information may also be processed by Paystack or other payment providers according to their own privacy policies.

15. Customer Support

For payment questions, missing digital currency, technical issues, or account problems, contact:

Name: Bano ke
Email: bano.ke.254@gmail.com

Support hours: Monday to Friday, 9:00 AM to 5:00 PM EAT

When contacting support about a payment, include your payment reference, player name/login ID, phone number used for payment, amount paid, and date of payment.

16. Limitation of Liability

To the maximum extent allowed by law, we are not responsible for indirect losses, lost progress, lost profits, loss of data, device issues, network problems, payment provider delays, bank/mobile money issues, or inability to access the Game.

Our responsibility for a confirmed payment delivery error is normally limited to correcting the digital currency or digital item inside the Game.

17. Termination

We may suspend, restrict, or terminate access to the Game or a player profile if you violate these Terms, abuse payments, cheat, commit fraud, or harm other players or the Game.

If your account is suspended or banned for violating these Terms, you may lose access to digital currency, digital items, and online features without refund.

18. Updates to These Terms

We may update these Terms from time to time. The updated Terms will apply when posted or made available in the Game, website, or payment page.

Continued use of the Game after updates means you accept the updated Terms.

19. Governing Law

These Terms are governed by the laws applicable in Kenya, unless another law is required to apply.

20. Acceptance

By using the Game or making a payment, you confirm that you have read, understood, and agreed to these Terms, including that digital game currency is not real money and that donations and digital currency purchases are non-refundable.
"""
const GLASS_MARBLE_MODEL_SCENE: PackedScene = preload("res://glass_marble_model.tscn")
const CUSTOMIZE_ROOM_SCENE_PATH: String = "res://customize_room.tscn"
const GLASS_BUTTON_EFFECTS = preload("res://glass_button_effects.gd")
const MENU_BUTTON_MIN_SIZE := Vector2(560, 54)
const MENU_BUTTON_FONT_SIZE: int = 24
const LAN_DEFAULT_PORT: int = 24570
const STARTUP_LOADING_MIN_SECONDS: float = 5.0
const STARTUP_LOADING_MAX_SECONDS: float = 9.5

var background: TextureRect
var background_overlay: ColorRect
var top_glow: Panel
var bottom_glow: Panel
var glass_panel: Panel
var menu_music_player: AudioStreamPlayer
var menu_music_should_play: bool = true
var content_box: VBoxContainer
var title_logo: TextureRect
var title_label: Label
var subtitle_label: Label
var player_name_panel: VBoxContainer
var player_name_input: LineEdit
var player_name_save_button: Button
var player_name_status: Label
var coin_balance_label: Label
var player_name_popup: Window
var player_name_popup_input: LineEdit
var player_age_popup_input: LineEdit
var player_name_popup_save_button: Button
var player_name_popup_status: Label
var player_terms_checkbox: CheckBox
var player_terms_view_button: Button
var player_google_signin_button: Button
var terms_popup: Window
var terms_close_button: Button
var google_auth_http_request: HTTPRequest
var google_auth_request_kind: String = ""
var google_auth_device_code: String = ""
var google_auth_user_code: String = ""
var google_auth_verification_url: String = ""
var google_auth_poll_timer: float = -1.0
var google_auth_poll_interval: float = GOOGLE_AUTH_DEFAULT_POLL_SECONDS
var google_auth_expires_at_msec: int = 0
var google_auth_pending_profile: Dictionary = {}
var google_auth_pending_auth_token: String = ""

var play_button: Button
var host_lan_button: Button
var join_lan_button: Button
var tutorial_button: Button
var customize_button: Button
var rules_button: Button
var credits_button: Button
var settings_button: Button
var quit_button: Button
var donate_button: Button
var payment_popup: Window
var payment_amount_input: LineEdit
var payment_phone_input: LineEdit
var payment_email_input: LineEdit
var payment_terms_checkbox: CheckBox
var payment_submit_button: Button
var payment_cancel_button: Button
var payment_status_label: Label
var payment_http_request: HTTPRequest
var payment_status_timer: float = -1.0
var payment_status_poll_count: int = 0
var payment_pending_invoice_id: String = ""
var payment_pending_purpose: String = ""
var payment_pending_gold_amount: int = 0
var payment_request_kind: String = ""

var rules_popup: Window
var rules_close_button: Button
var credits_popup: Window
var credits_close_button: Button
var lan_popup: Window
var lan_heading_label: Label
var lan_ip_input: LineEdit
var lan_port_input: LineEdit
var lan_connect_button: Button
var lan_cancel_button: Button
var lan_status_label: Label
var lan_popup_mode: String = "online_join"
var online_rooms_page: Control
var online_rooms_list: VBoxContainer
var online_live_rooms_stack: VBoxContainer
var online_players_list_stack: VBoxContainer
var online_friends_list_stack: VBoxContainer
var online_friend_requests_list_stack: VBoxContainer
var online_chat_log_stack: VBoxContainer
var online_chat_input: LineEdit
var online_chat_send_button: Button
var online_chat_bubble_button: Button
var online_chat_popup_panel: Panel
var online_chat_title_label: Label
var online_chat_toast_panel: Panel
var online_chat_toast_sender_label: Label
var online_chat_toast_text_label: Label
var online_invite_popup_panel: Panel
var online_invite_popup_title_label: Label
var online_invite_popup_message_label: Label
var online_invite_accept_button: Button
var online_invite_decline_button: Button
var online_loading_chat_log_stack: VBoxContainer
var online_loading_chat_input: LineEdit
var online_loading_chat_send_button: Button
var online_loading_chat_panel: Panel
var online_loading_chat_title_label: Label
var online_loading_chat_toggle_button: Button
var online_status_label: Label
var online_current_room_label: Label
var online_private_code_input: LineEdit
var online_private_size_picker: OptionButton
var online_back_button: Button
var online_refresh_button: Button
var online_quick_match_button: Button
var online_private_create_button: Button
var online_private_join_button: Button
var online_start_button: Button
var online_loading_panel: Panel
var online_loading_title_label: Label
var online_loading_players_label: Label
var online_loading_marble_label: Label
var online_loading_status_label: Label
var online_loading_info_panel: Panel
var online_loading_start_button: Button
var online_loading_cancel_button: Button
var online_loading_background: TextureRect
var online_loading_video_player: VideoStreamPlayer
var online_loading_slots_grid: GridContainer
var online_loading_progress_bar: ProgressBar
var online_loading_slot_name_labels: Array = []
var online_loading_slot_status_labels: Array = []
var startup_loading_panel: Panel
var startup_loading_title_label: Label
var startup_loading_status_label: Label
var startup_loading_progress_bar: ProgressBar
var startup_loading_background: TextureRect
var startup_loading_timer: float = -1.0
var startup_server_ready: bool = false
var startup_server_connection_started: bool = false
var online_public_room_buttons: Dictionary = {}
var online_latest_rooms: Array = []
var online_latest_players: Array = []
var online_chat_history: Array = []
var online_chat_expanded: bool = false
var online_chat_target_id: String = ""
var online_chat_target_name: String = ""
var online_chat_toast_timer: float = 0.0
var online_chat_toast_target_id: String = ""
var online_chat_toast_target_name: String = ""
var online_chat_button_pressing: bool = false
var online_chat_button_dragging: bool = false
var online_chat_button_drag_start_global: Vector2 = Vector2.ZERO
var online_chat_button_drag_start_position: Vector2 = Vector2.ZERO
var online_chat_button_drag_pointer_offset: Vector2 = Vector2.ZERO
var online_chat_button_drag_touch_index: int = -1
var online_chat_button_drag_started_by_touch: bool = false
var online_chat_button_has_custom_position: bool = false
var online_chat_button_custom_position: Vector2 = Vector2.ZERO
var online_pending_invite: Dictionary = {}
var online_invite_room_hold_active: bool = false
var online_invite_room_code: String = ""
var online_accepting_invite_room: bool = false
var online_invite_follow_host_id: String = ""
var online_invite_follow_host_name: String = ""
var online_auto_following_invite_host: bool = false
var online_loading_chat_visible: bool = true
var online_loading_transition_tween: Tween
var online_room_refresh_timer: float = 0.0
var online_match_start_timer: float = -1.0
var online_scene_start_timer: float = -1.0
var online_scene_start_duration: float = 1.0
var online_start_fallback_timer: float = -1.0
var online_match_start_requested: bool = false
var online_currency_amount_labels: Dictionary = {}
var online_stat_amount_labels: Dictionary = {}
var online_party_slot_name_labels: Array = []
var online_party_slot_status_labels: Array = []
var online_touch_scroll_last_positions: Dictionary = {}
var online_marble_display_panel: Panel
var online_marble_preview_frame: Panel
var online_marble_name_label: Label
var online_marble_status_label: Label
var online_marble_preview_node: Node3D
var online_marble_visual_node: Node3D
var online_hologram_effects_root: Node3D
var online_owned_marble_ids: PackedStringArray = PackedStringArray()
var online_selected_marble_id: String = ""
var online_marble_dragging: bool = false
var online_marble_drag_start: Vector2 = Vector2.ZERO
var online_marble_drag_last: Vector2 = Vector2.ZERO

const ONLINE_AUTO_START_SECONDS: float = 1.4
const ONLINE_START_FALLBACK_SECONDS: float = 3.0
const ONLINE_SCENE_LOAD_DELAY_SECONDS: float = 2.2

var settings_popup: Window
var settings_back_button: Button
var settings_account_button: Button
var shooting_mechanics_popup: Window
var shooting_mechanics_button: Button
var aim_inversion_button: Button
var shooting_mechanics_prompt_required: bool = false
var shooting_mechanics_prompt_pending_after_name: bool = false
var master_slider: HSlider
var music_slider: HSlider
var sfx_slider: HSlider
var shoot_sensitivity_slider: HSlider
var online_server_input: LineEdit
var online_server_save_button: Button

var customize_popup: Control
var customize_back_button: Button
var customize_apply_button: Button
var customize_prev_marble_button: Button
var customize_next_marble_button: Button
var customize_prev_trail_button: Button
var customize_next_trail_button: Button
var marble_picker: OptionButton
var trail_picker: OptionButton
var marble_cards_grid: GridContainer
var trail_cards_grid: GridContainer
var customize_marble_belt: HBoxContainer
var customize_marble_belt_scroll: ScrollContainer
var customize_preview_title: Label
var customize_preview_text: Label
var customize_marble_preview_holder: Panel
var customize_trail_preview_holder: Panel
var customize_color_preview: ColorRect
var customize_accent_preview: ColorRect
var customize_status_label: Label
var customize_preview_marble_node: Node3D
var customize_preview_dragging: bool = false
var customize_preview_last_pointer: Vector2 = Vector2.ZERO
var selected_customize_marble_id: String = ""
var selected_customize_trail_id: String = ""
var customize_marble_ids: PackedStringArray = PackedStringArray()
var customize_trail_ids: PackedStringArray = PackedStringArray()
var marble_card_buttons: Dictionary = {}
var trail_card_buttons: Dictionary = {}
var marble_preview_cache: Dictionary = {}
var trail_preview_cache: Dictionary = {}
var customize_marble_belt_target_scroll: float = 0.0

var title_font: SystemFont
var ui_font: SystemFont
var icon_font: SystemFont


func _ready() -> void:
	_ensure_fonts()
	_ensure_audio_buses()
	_ensure_menu_music()
	_setup_background()
	_setup_background_effects()
	_setup_ui()
	_style_glass_panel()
	_style_text()
	_style_buttons()
	_bind_buttons()
	_ensure_rules_popup()
	_ensure_credits_popup()
	rules_popup.position = Vector2i(300, 120)
	_ensure_settings_popup()
	_ensure_shooting_mechanics_popup()
	_ensure_customize_popup()
	_ensure_player_name_popup()
	_ensure_terms_popup()
	_ensure_payment_popup()
	_ensure_lan_popup()
	_ensure_online_rooms_page()
	_ensure_startup_loading_panel()
	_style_popups()
	_init_audio_sliders()
	_init_shoot_sensitivity_slider()
	_init_online_server_input()
	_hide_menu_popups()
	_init_player_name_controls()
	_bind_lan_signals()
	_bind_online_signals()
	GLASS_BUTTON_EFFECTS.apply_to_tree(self )


func _ensure_audio_buses() -> void:
	_ensure_audio_bus(MENU_MUSIC_BUS_NAME)
	_ensure_audio_bus(SFX_BUS_NAME)


func _ensure_audio_bus(bus_name: String, send_bus_name: String = "Master") -> void:
	if bus_name == "" or AudioServer.get_bus_index(bus_name) != -1:
		return

	var bus_index: int = AudioServer.bus_count
	AudioServer.add_bus(bus_index)
	AudioServer.set_bus_name(bus_index, bus_name)
	if AudioServer.get_bus_index(send_bus_name) != -1:
		AudioServer.set_bus_send(bus_index, send_bus_name)


func _ensure_menu_music() -> void:
	menu_music_should_play = true
	var root: Window = get_tree().root
	if root == null:
		return
	menu_music_player = _get_or_create_menu_music_player(root)
	menu_music_player.bus = MENU_MUSIC_BUS_NAME if AudioServer.get_bus_index(MENU_MUSIC_BUS_NAME) != -1 else "Master"
	menu_music_player.max_polyphony = 1

	if menu_music_player.stream == null:
		menu_music_player.stream = _load_menu_music_stream()

	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("allow_menu_music"):
		game_manager.call("allow_menu_music")

	if not menu_music_should_play:
		return

	if menu_music_player.stream != null and not menu_music_player.playing:
		menu_music_player.play()


func _get_or_create_menu_music_player(root: Window) -> AudioStreamPlayer:
	var primary_player: AudioStreamPlayer = null
	for child in root.get_children():
		var player: AudioStreamPlayer = child as AudioStreamPlayer
		if player == null or not str(player.name).begins_with("MenuMusicPlayer"):
			continue
		if primary_player == null:
			primary_player = player
			primary_player.name = "MenuMusicPlayer"
			continue
		player.stop()
		player.queue_free()

	if primary_player == null:
		primary_player = AudioStreamPlayer.new()
		primary_player.name = "MenuMusicPlayer"
		primary_player.process_mode = Node.PROCESS_MODE_ALWAYS
		root.add_child(primary_player)
	return primary_player


func _start_menu_music_player() -> void:
	if not menu_music_should_play:
		return
	if menu_music_player == null:
		return
	if not menu_music_player.is_inside_tree():
		call_deferred("_start_menu_music_player")
		return
	if not menu_music_should_play:
		return
	var root: Window = get_tree().root
	if root != null:
		menu_music_player = _get_or_create_menu_music_player(root)
	if menu_music_player.stream != null and not menu_music_player.playing:
		menu_music_player.play()


func _load_menu_music_stream() -> AudioStream:
	if ResourceLoader.exists(MENU_MUSIC_PATH):
		var stream_resource: Resource = ResourceLoader.load(MENU_MUSIC_PATH)
		if stream_resource is AudioStream:
			return _make_looping_audio_stream(stream_resource as AudioStream)

	var global_path: String = ProjectSettings.globalize_path(MENU_MUSIC_PATH)
	if FileAccess.file_exists(global_path):
		var file_bytes: PackedByteArray = FileAccess.get_file_as_bytes(global_path)
		if not file_bytes.is_empty():
			var mp3_stream: AudioStreamMP3 = AudioStreamMP3.new()
			mp3_stream.data = file_bytes
			mp3_stream.loop = true
			return mp3_stream

	push_warning("Could not load menu music from %s." % MENU_MUSIC_PATH)
	return null


func _make_looping_audio_stream(source_stream: AudioStream) -> AudioStream:
	var music_stream: AudioStream = source_stream.duplicate(true) as AudioStream
	if music_stream == null:
		music_stream = source_stream
	if music_stream is AudioStreamMP3:
		(music_stream as AudioStreamMP3).loop = true
	elif music_stream is AudioStreamOggVorbis:
		(music_stream as AudioStreamOggVorbis).loop = true
	elif music_stream is AudioStreamWAV:
		(music_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	return music_stream


func _process(delta: float) -> void:
	_process_startup_loading(delta)
	_process_online_room_refresh(delta)
	_process_online_match_loading(delta)
	_process_online_start_fallback(delta)
	_process_online_scene_start(delta)
	_process_online_chat_toast(delta)
	_process_payment_status_poll(delta)
	_process_google_auth_poll(delta)
	_process_online_marble_preview(delta)
	_process_customize_preview_spin(delta)
	if customize_marble_belt_scroll == null:
		return
	if absf(float(customize_marble_belt_scroll.scroll_horizontal) - customize_marble_belt_target_scroll) < 0.5:
		return
	customize_marble_belt_scroll.scroll_horizontal = int(round(
		lerpf(
			float(customize_marble_belt_scroll.scroll_horizontal),
			customize_marble_belt_target_scroll,
			clampf(delta * 10.0, 0.0, 1.0)
		)
	))


func _input(event: InputEvent) -> void:
	if online_chat_button_pressing:
		_handle_online_chat_button_drag_input(event)


func _ensure_fonts() -> void:
	title_font = SystemFont.new()
	title_font.font_names = PackedStringArray(["Franklin Gothic Heavy", "Franklin Gothic", "Arial Black", "Impact", "Bahnschrift"])

	ui_font = SystemFont.new()
	ui_font.font_names = PackedStringArray(["Bahnschrift", "Trebuchet MS", "Verdana", "Arial"])

	icon_font = SystemFont.new()
	icon_font.font_names = PackedStringArray(["Segoe UI Symbol", "Segoe Fluent Icons", "Arial Unicode MS", "Bahnschrift"])


func _setup_background() -> void:
	background = get_node_or_null("Background") as TextureRect
	if background == null:
		background = TextureRect.new()
		background.name = "Background"
		add_child(background)
		move_child(background, 0)

	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.texture = load(BACKGROUND_PATH)
	background.show()
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.z_index = -120
	background.modulate = Color(1.0, 1.0, 1.0, 1.0)


func _setup_background_effects() -> void:
	background_overlay = get_node_or_null("BackgroundOverlay") as ColorRect
	if background_overlay == null:
		background_overlay = ColorRect.new()
		background_overlay.name = "BackgroundOverlay"
		add_child(background_overlay)
		move_child(background_overlay, 1)

	background_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_overlay.color = Color(0.005, 0.0, 0.02, 0.18)
	background_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background_overlay.z_index = -110
	_setup_neon_backdrop_bands()

	top_glow = get_node_or_null("TopGlow") as Panel
	if top_glow == null:
		top_glow = Panel.new()
		top_glow.name = "TopGlow"
		add_child(top_glow)
		move_child(top_glow, 2)

	top_glow.anchor_left = 0.0
	top_glow.anchor_top = 0.0
	top_glow.anchor_right = 0.0
	top_glow.anchor_bottom = 0.0
	top_glow.offset_left = -120.0
	top_glow.offset_top = -90.0
	top_glow.offset_right = 470.0
	top_glow.offset_bottom = 270.0
	top_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_glow.z_index = -105
	top_glow.add_theme_stylebox_override("panel", _make_glow_style(Color(0.31, 0.97, 0.85, 0.3)))
	top_glow.hide()

	bottom_glow = get_node_or_null("BottomGlow") as Panel
	if bottom_glow == null:
		bottom_glow = Panel.new()
		bottom_glow.name = "BottomGlow"
		add_child(bottom_glow)
		move_child(bottom_glow, 3)

	bottom_glow.anchor_left = 1.0
	bottom_glow.anchor_top = 1.0
	bottom_glow.anchor_right = 1.0
	bottom_glow.anchor_bottom = 1.0
	bottom_glow.offset_left = -420.0
	bottom_glow.offset_top = -250.0
	bottom_glow.offset_right = 120.0
	bottom_glow.offset_bottom = 100.0
	bottom_glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bottom_glow.z_index = -105
	bottom_glow.add_theme_stylebox_override("panel", _make_glow_style(Color(0.42, 0.36, 1.0, 0.28)))
	bottom_glow.hide()


func _setup_neon_backdrop_bands() -> void:
	var band_root: Control = get_node_or_null("NeonBackdropBands") as Control
	if band_root == null:
		band_root = Control.new()
		band_root.name = "NeonBackdropBands"
		add_child(band_root)
		move_child(band_root, 2)

	band_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	band_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	band_root.z_index = -108
	band_root.hide()

	for child in band_root.get_children():
		child.queue_free()

	_add_backdrop_band(band_root, Vector2(-80.0, 108.0), Vector2(620.0, 24.0), -18.0, Color(0.31, 0.97, 0.85, 0.13))
	_add_backdrop_band(band_root, Vector2(760.0, 64.0), Vector2(560.0, 20.0), -18.0, Color(0.42, 0.36, 1.0, 0.16))
	_add_backdrop_band(band_root, Vector2(80.0, 570.0), Vector2(620.0, 18.0), -18.0, Color(0.42, 0.72, 1.0, 0.12))
	_add_backdrop_band(band_root, Vector2(820.0, 520.0), Vector2(520.0, 18.0), -18.0, Color(0.31, 0.97, 0.85, 0.1))


func _add_backdrop_band(parent: Control, position: Vector2, size: Vector2, rotation_degrees_value: float, color: Color) -> void:
	var band: ColorRect = ColorRect.new()
	band.position = position
	band.size = size
	band.rotation_degrees = rotation_degrees_value
	band.color = color
	band.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(band)


func _setup_ui() -> void:
	glass_panel = get_node_or_null("Center/GlassPanel") as Panel
	var center: CenterContainer = get_node_or_null("Center") as CenterContainer
	if center == null:
		center = CenterContainer.new()
		center.name = "Center"
		add_child(center)
		center.set_anchors_preset(Control.PRESET_FULL_RECT)

	if glass_panel == null:
		glass_panel = Panel.new()
		glass_panel.name = "GlassPanel"
		center.add_child(glass_panel)

	content_box = glass_panel.find_child("Content", true, false) as VBoxContainer
	if content_box == null:
		content_box = VBoxContainer.new()
		content_box.name = "Content"
		glass_panel.add_child(content_box)

	play_button = glass_panel.find_child("PlayButton", true, false) as Button
	host_lan_button = glass_panel.find_child("HostLanButton", true, false) as Button
	join_lan_button = glass_panel.find_child("JoinLanButton", true, false) as Button
	customize_button = glass_panel.find_child("CustomizeButton", true, false) as Button
	rules_button = glass_panel.find_child("RulesButton", true, false) as Button
	credits_button = glass_panel.find_child("CreditsButton", true, false) as Button
	settings_button = glass_panel.find_child("SettingsButton", true, false) as Button
	quit_button = glass_panel.find_child("QuitButton", true, false) as Button
	tutorial_button = glass_panel.find_child("TutorialButton", true, false) as Button


	if play_button == null:
		play_button = _create_menu_button("PlayButton", "PLAY")
		content_box.add_child(play_button)

	if host_lan_button == null:
		host_lan_button = _create_menu_button("HostLanButton", "HOST LAN")
		content_box.add_child(host_lan_button)

	if join_lan_button == null:
		join_lan_button = _create_menu_button("JoinLanButton", "JOIN LAN")
		content_box.add_child(join_lan_button)

	if tutorial_button == null:
		tutorial_button = _create_menu_button("TutorialButton", "TUTORIAL")
		content_box.add_child(tutorial_button)

	if customize_button == null:
		customize_button = _create_menu_button("CustomizeButton", "CUSTOMIZE")
		content_box.add_child(customize_button)

	if rules_button == null:
		rules_button = _create_menu_button("RulesButton", "RULES")
		content_box.add_child(rules_button)

	if credits_button == null:
		credits_button = _create_menu_button("CreditsButton", "CREDITS")
		content_box.add_child(credits_button)

	if settings_button == null:
		settings_button = _create_menu_button("SettingsButton", "SETTINGS")
		content_box.add_child(settings_button)

	if quit_button == null:
		quit_button = _create_menu_button("QuitButton", "QUIT")
		content_box.add_child(quit_button)

	_ensure_donate_button()
	_ensure_header_labels()
	_normalize_menu_layout()


func _ensure_donate_button() -> void:
	donate_button = get_node_or_null("DonateButton") as Button
	if donate_button == null:
		donate_button = Button.new()
		donate_button.name = "DonateButton"
		add_child(donate_button)

	donate_button.text = "DONATE"
	donate_button.tooltip_text = "Support Bano ke"
	donate_button.focus_mode = Control.FOCUS_NONE
	donate_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	donate_button.offset_left = -184.0
	donate_button.offset_top = 14.0
	donate_button.offset_right = -18.0
	donate_button.offset_bottom = 66.0
	donate_button.custom_minimum_size = Vector2(166.0, 52.0)
	donate_button.z_index = 90


func _ensure_header_labels() -> void:
	title_logo = glass_panel.find_child("TitleLogo", true, false) as TextureRect
	if title_logo == null:
		title_logo = TextureRect.new()
		title_logo.name = "TitleLogo"
		content_box.add_child(title_logo)
	content_box.move_child(title_logo, 0)

	title_label = glass_panel.find_child("TitleLabel", true, false) as Label
	if title_label == null:
		title_label = Label.new()
		title_label.name = "TitleLabel"
		content_box.add_child(title_label)
	content_box.move_child(title_label, 1)

	subtitle_label = glass_panel.find_child("SubtitleLabel", true, false) as Label
	if subtitle_label == null:
		subtitle_label = Label.new()
		subtitle_label.name = "SubtitleLabel"
		content_box.add_child(subtitle_label)
	content_box.move_child(subtitle_label, 2)

	title_label.text = "Bano ke"
	subtitle_label.text = "CLEAN SHOTS, SHARP RICOCHETS,\nONE MARBLE AT A TIME."
	title_logo.texture = _load_texture_from_path(MENU_LOGO_PATH)
	title_logo.show()

	player_name_panel = glass_panel.find_child("PlayerNamePanel", true, false) as VBoxContainer
	if player_name_panel == null:
		player_name_panel = VBoxContainer.new()
		player_name_panel.name = "PlayerNamePanel"
		player_name_panel.add_theme_constant_override("separation", 8)
		content_box.add_child(player_name_panel)
		content_box.move_child(player_name_panel, 3)

	var name_prompt: Label = player_name_panel.find_child("PlayerNamePrompt", true, false) as Label
	if name_prompt == null:
		name_prompt = Label.new()
		name_prompt.name = "PlayerNamePrompt"
		name_prompt.text = "Choose Player Name"
		player_name_panel.add_child(name_prompt)

	player_name_input = player_name_panel.find_child("PlayerNameInput", true, false) as LineEdit
	if player_name_input == null:
		player_name_input = LineEdit.new()
		player_name_input.name = "PlayerNameInput"
		player_name_input.placeholder_text = "Enter your name"
		player_name_input.max_length = 18
		player_name_panel.add_child(player_name_input)

	player_name_save_button = player_name_panel.find_child("PlayerNameSaveButton", true, false) as Button
	if player_name_save_button == null:
		player_name_save_button = Button.new()
		player_name_save_button.name = "PlayerNameSaveButton"
		player_name_save_button.text = "SAVE NAME"
		player_name_panel.add_child(player_name_save_button)

	player_name_status = player_name_panel.find_child("PlayerNameStatus", true, false) as Label
	if player_name_status == null:
		player_name_status = Label.new()
		player_name_status.name = "PlayerNameStatus"
		player_name_panel.add_child(player_name_status)

	coin_balance_label = player_name_panel.find_child("CoinBalanceLabel", true, false) as Label
	if coin_balance_label == null:
		coin_balance_label = Label.new()
		coin_balance_label.name = "CoinBalanceLabel"
		player_name_panel.add_child(coin_balance_label)


func _normalize_menu_layout() -> void:
	glass_panel.custom_minimum_size = Vector2(640, 720)

	content_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_box.offset_left = 32.0
	content_box.offset_top = -14.0
	content_box.offset_right = -32.0
	content_box.offset_bottom = -56.0
	content_box.alignment = BoxContainer.ALIGNMENT_CENTER
	content_box.add_theme_constant_override("separation", 7)

	play_button.text = "PLAY"
	host_lan_button.text = "ONLINE"
	host_lan_button.show()
	join_lan_button.text = "JOIN ONLINE"
	join_lan_button.hide()
	customize_button.text = "CUSTOMIZE"
	rules_button.text = "RULES"
	credits_button.text = "CREDITS"
	settings_button.text = "SETTINGS"
	quit_button.text = "QUIT"
	content_box.move_child(player_name_panel, 3)
	content_box.move_child(play_button, 4)
	content_box.move_child(host_lan_button, 5)
	content_box.move_child(join_lan_button, 6)
	content_box.move_child(tutorial_button, 7)
	content_box.move_child(customize_button, 8)
	content_box.move_child(rules_button, 9)
	content_box.move_child(credits_button, 10)
	content_box.move_child(settings_button, 11)
	content_box.move_child(quit_button, 12)


func _style_glass_panel() -> void:
	if glass_panel == null:
		return

	glass_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())


func _style_text() -> void:
	if title_logo:
		title_logo.custom_minimum_size = Vector2(560, 182)
		title_logo.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		title_logo.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		title_logo.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		title_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		title_logo.clip_contents = true
		title_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
		title_logo.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

	if title_label:
		title_label.hide()
		title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title_label.add_theme_font_override("font", title_font)
		title_label.add_theme_font_size_override("font_size", 74)
		title_label.add_theme_color_override("font_color", Color(0.97, 0.99, 1.0, 1.0))
		title_label.add_theme_color_override("font_outline_color", Color(0.58, 0.16, 1.0, 0.95))
		title_label.add_theme_color_override("font_shadow_color", Color(0.72, 0.2, 1.0, 0.9))
		title_label.add_theme_constant_override("outline_size", 2)
		title_label.add_theme_constant_override("shadow_offset_x", 0)
		title_label.add_theme_constant_override("shadow_offset_y", 0)
		title_label.add_theme_constant_override("shadow_outline_size", 14)
		title_label.custom_minimum_size = Vector2(0, 82)

	if subtitle_label:
		subtitle_label.hide()
		subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		subtitle_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		subtitle_label.add_theme_font_override("font", ui_font)
		subtitle_label.add_theme_font_size_override("font_size", 18)
		subtitle_label.add_theme_color_override("font_color", Color(0.94, 0.94, 1.0, 0.98))
		subtitle_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
		subtitle_label.add_theme_constant_override("shadow_offset_y", 2)
		subtitle_label.add_theme_constant_override("shadow_outline_size", 4)
		subtitle_label.custom_minimum_size = Vector2(0, 56)

	if player_name_status:
		player_name_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		player_name_status.add_theme_font_override("font", ui_font)
		player_name_status.add_theme_font_size_override("font_size", 14)
		player_name_status.add_theme_color_override("font_color", Color(0.78, 0.9, 0.98, 0.92))

	if coin_balance_label:
		coin_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		coin_balance_label.add_theme_font_override("font", ui_font)
		coin_balance_label.add_theme_font_size_override("font_size", 16)
		coin_balance_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5, 0.98))


func _style_buttons() -> void:
	_apply_standard_menu_button_style(play_button, Color(0.31, 0.97, 0.85, 1.0))
	_apply_standard_menu_button_style(host_lan_button, Color(0.25, 0.78, 1.0, 1.0))
	_apply_standard_menu_button_style(join_lan_button, Color(0.56, 0.54, 1.0, 1.0))
	_apply_standard_menu_button_style(customize_button, Color(0.42, 0.72, 1.0, 1.0))
	_apply_standard_menu_button_style(rules_button, Color(1.0, 0.82, 0.2, 1.0))
	_apply_standard_menu_button_style(credits_button, Color(0.86, 0.52, 1.0, 1.0))
	_apply_standard_menu_button_style(settings_button, Color(0.72, 0.8, 0.92, 1.0))
	_apply_standard_menu_button_style(quit_button, Color(1.0, 0.35, 0.32, 1.0))
	_apply_standard_menu_button_style(tutorial_button, Color(0.72, 0.36, 1.0, 1.0))
	_style_donate_button()

	if player_name_save_button != null:
		_apply_standard_menu_button_style(player_name_save_button, Color(0.31, 0.97, 0.85, 1.0))
		player_name_save_button.custom_minimum_size = Vector2(220, MENU_BUTTON_MIN_SIZE.y)
		player_name_save_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	if player_name_input:
		player_name_input.custom_minimum_size = Vector2(0, 48)
		player_name_input.add_theme_font_override("font", ui_font)
		player_name_input.add_theme_font_size_override("font_size", 18)
		player_name_input.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
		player_name_input.add_theme_color_override("font_placeholder_color", Color(0.7, 0.82, 0.9, 0.7))
		player_name_input.add_theme_stylebox_override("normal", _make_menu_button_style(Color(0.03, 0.07, 0.1, 0.78), Color(0.42, 0.72, 1.0, 0.55)))
		player_name_input.add_theme_stylebox_override("focus", _make_menu_button_style(Color(0.04, 0.09, 0.13, 0.9), Color(0.31, 0.97, 0.85, 0.95)))


func _style_donate_button() -> void:
	if donate_button == null:
		return
	donate_button.flat = false
	donate_button.add_theme_font_override("font", ui_font)
	donate_button.add_theme_font_size_override("font_size", 16)
	donate_button.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0, 1.0))
	donate_button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	donate_button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.65))
	donate_button.add_theme_constant_override("shadow_offset_y", 1)
	donate_button.add_theme_constant_override("shadow_outline_size", 2)
	donate_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.035, 0.02, 0.055, 0.72), Color(1.0, 0.74, 0.24, 0.9), 12))
	donate_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.07, 0.04, 0.1, 0.88), Color(1.0, 0.9, 0.48, 1.0), 12))
	donate_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.02, 0.01, 0.035, 0.96), Color(0.9, 0.58, 0.14, 1.0), 12))


func _apply_standard_menu_button_style(button: Button, accent_color: Color = Color(0.31, 0.97, 0.85, 1.0)) -> void:
	if button == null:
		return
	button.flat = false
	button.custom_minimum_size = MENU_BUTTON_MIN_SIZE
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", MENU_BUTTON_FONT_SIZE)
	button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.93, 1.0, 0.99, 1.0))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.55))
	button.add_theme_constant_override("shadow_offset_y", 1)
	button.add_theme_constant_override("shadow_outline_size", 2)
	button.add_theme_stylebox_override("normal", _make_neon_menu_button_style(Color(0.015, 0.01, 0.035, 0.72), accent_color))
	button.add_theme_stylebox_override("hover", _make_neon_menu_button_style(Color(0.03, 0.02, 0.07, 0.82), accent_color.lightened(0.16)))
	button.add_theme_stylebox_override("pressed", _make_neon_menu_button_style(Color(0.01, 0.005, 0.025, 0.92), accent_color.darkened(0.08)))
	button.focus_mode = Control.FOCUS_NONE
	var clean_text: String = button.text.strip_edges()
	button.text = ""
	_ensure_menu_button_overlay(button, clean_text, _get_menu_button_icon(button.name), accent_color)


func _get_menu_button_icon(button_name: StringName) -> String:
	match str(button_name):
		"PlayButton":
			return "▷"
		"HostLanButton":
			return "◎"
		"TutorialButton":
			return "▱"
		"CustomizeButton":
			return "◌"
		"RulesButton":
			return "▤"
		"CreditsButton":
			return "*"
		"SettingsButton":
			return "⚙"
		"QuitButton":
			return "⏻"
		_:
			return ""


func _ensure_menu_button_overlay(button: Button, label_text: String, icon_text: String, accent_color: Color) -> void:
	var row: HBoxContainer = button.get_node_or_null("ButtonContent") as HBoxContainer
	if row == null:
		row = HBoxContainer.new()
		row.name = "ButtonContent"
		button.add_child(row)

	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 30.0
	row.offset_top = 0.0
	row.offset_right = -30.0
	row.offset_bottom = 0.0
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 0)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var icon_label: Label = row.get_node_or_null("Icon") as Label
	if icon_label == null:
		icon_label = Label.new()
		icon_label.name = "Icon"
		row.add_child(icon_label)

	var text_label: Label = row.get_node_or_null("Text") as Label
	if text_label == null:
		text_label = Label.new()
		text_label.name = "Text"
		row.add_child(text_label)

	var right_balance: Control = row.get_node_or_null("RightBalance") as Control
	if right_balance == null:
		right_balance = Control.new()
		right_balance.name = "RightBalance"
		row.add_child(right_balance)

	row.move_child(icon_label, 0)
	row.move_child(text_label, 1)
	row.move_child(right_balance, 2)

	icon_label.text = icon_text
	icon_label.custom_minimum_size = Vector2(108, 0)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_override("font", icon_font)
	icon_label.add_theme_font_size_override("font_size", 36)
	icon_label.add_theme_color_override("font_color", accent_color)
	icon_label.add_theme_color_override("font_shadow_color", accent_color)
	icon_label.add_theme_constant_override("shadow_offset_x", 0)
	icon_label.add_theme_constant_override("shadow_offset_y", 0)
	icon_label.add_theme_constant_override("shadow_outline_size", 8)
	icon_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	text_label.text = label_text
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	text_label.add_theme_font_override("font", ui_font)
	text_label.add_theme_font_size_override("font_size", MENU_BUTTON_FONT_SIZE)
	text_label.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0, 1.0))
	text_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	text_label.add_theme_constant_override("shadow_offset_y", 2)
	text_label.add_theme_constant_override("shadow_outline_size", 4)
	text_label.mouse_filter = Control.MOUSE_FILTER_IGNORE

	right_balance.custom_minimum_size = Vector2(108, 0)
	right_balance.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _bind_buttons():

	if play_button and not play_button.pressed.is_connected(_on_play_pressed):
		play_button.pressed.connect(_on_play_pressed)

	if host_lan_button and not host_lan_button.pressed.is_connected(_on_online_pressed):
		host_lan_button.pressed.connect(_on_online_pressed)

	if join_lan_button and not join_lan_button.pressed.is_connected(_on_online_pressed):
		join_lan_button.pressed.connect(_on_online_pressed)

	if tutorial_button and not tutorial_button.pressed.is_connected(_on_tutorial_pressed):
		tutorial_button.pressed.connect(_on_tutorial_pressed)

	if customize_button and not customize_button.pressed.is_connected(_on_customize_pressed):
		customize_button.pressed.connect(_on_customize_pressed)

	if rules_button and not rules_button.pressed.is_connected(_on_rules_pressed):
		rules_button.pressed.connect(_on_rules_pressed)

	if credits_button and not credits_button.pressed.is_connected(_on_credits_pressed):
		credits_button.pressed.connect(_on_credits_pressed)

	if settings_button and not settings_button.pressed.is_connected(_on_settings_pressed):
		settings_button.pressed.connect(_on_settings_pressed)

	if quit_button and not quit_button.pressed.is_connected(_on_quit_pressed):
		quit_button.pressed.connect(_on_quit_pressed)

	if donate_button and not donate_button.pressed.is_connected(_on_donate_pressed):
		donate_button.pressed.connect(_on_donate_pressed)

	if player_name_save_button and not player_name_save_button.pressed.is_connected(_on_player_name_save_pressed):
		player_name_save_button.pressed.connect(_on_player_name_save_pressed)

	if player_name_input and not player_name_input.text_submitted.is_connected(_on_player_name_submitted):
		player_name_input.text_submitted.connect(_on_player_name_submitted)


func _on_donate_pressed() -> void:
	_show_payment_popup()


func _ensure_payment_popup() -> void:
	payment_popup = get_node_or_null("PaymentPopup") as Window
	if payment_popup == null:
		payment_popup = Window.new()
		payment_popup.name = "PaymentPopup"
		add_child(payment_popup)

	payment_popup.title = "Support Bano ke"
	payment_popup.size = Vector2i(620, 700)
	payment_popup.unresizable = true
	payment_popup.borderless = true
	payment_popup.transparent_bg = true
	payment_popup.exclusive = true
	payment_popup.hide()
	if not payment_popup.close_requested.is_connected(_hide_payment_popup):
		payment_popup.close_requested.connect(_hide_payment_popup)

	for child in payment_popup.get_children():
		child.queue_free()

	var background: ColorRect = ColorRect.new()
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.color = Color(0.01, 0.0, 0.035, 0.86)
	payment_popup.add_child(background)

	var panel: Panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.offset_left = 16
	panel.offset_top = 16
	panel.offset_right = -16
	panel.offset_bottom = -16
	panel.add_theme_stylebox_override("panel", _make_settings_control_style(Color(0.025, 0.006, 0.07, 0.94), Color(0.82, 0.18, 1.0, 0.96), 16))
	payment_popup.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 38)
	margin.add_theme_constant_override("margin_top", 34)
	margin.add_theme_constant_override("margin_right", 38)
	margin.add_theme_constant_override("margin_bottom", 34)
	panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 14)
	margin.add_child(stack)

	var title: Label = _create_settings_label("M-PESA DONATION")
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color(0.98, 0.92, 1.0, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.72, 0.24, 1.0, 1.0))
	title.add_theme_constant_override("shadow_outline_size", 12)
	stack.add_child(title)

	var amount_label: Label = _create_settings_label("Amount in KES")
	stack.add_child(amount_label)
	payment_amount_input = LineEdit.new()
	payment_amount_input.placeholder_text = "Example: 100"
	payment_amount_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	payment_amount_input.max_length = 7
	payment_amount_input.custom_minimum_size = Vector2(0, 48)
	_style_online_line_edit(payment_amount_input, Color(1.0, 0.82, 0.2, 1.0))
	stack.add_child(payment_amount_input)
	if not payment_amount_input.text_changed.is_connected(_on_payment_amount_changed):
		payment_amount_input.text_changed.connect(_on_payment_amount_changed)

	var phone_label: Label = _create_settings_label("M-Pesa phone number")
	stack.add_child(phone_label)
	payment_phone_input = LineEdit.new()
	payment_phone_input.placeholder_text = "07XXXXXXXX, 01XXXXXXXX, or +254XXXXXXXXX"
	payment_phone_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_PHONE
	payment_phone_input.max_length = 16
	payment_phone_input.custom_minimum_size = Vector2(0, 48)
	_style_online_line_edit(payment_phone_input, Color(0.31, 0.97, 0.85, 1.0))
	stack.add_child(payment_phone_input)

	var email_label: Label = _create_settings_label("Email address")
	stack.add_child(email_label)
	payment_email_input = LineEdit.new()
	payment_email_input.placeholder_text = "you@example.com"
	payment_email_input.max_length = 120
	payment_email_input.custom_minimum_size = Vector2(0, 48)
	_style_online_line_edit(payment_email_input, Color(0.82, 0.58, 1.0, 1.0))
	stack.add_child(payment_email_input)

	var payment_notice_label: Label = _create_settings_label(PAYMENT_FINAL_NOTICE_TEXT)
	payment_notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	payment_notice_label.add_theme_font_size_override("font_size", 13)
	payment_notice_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58, 0.96))
	stack.add_child(payment_notice_label)

	var payment_terms_row: HBoxContainer = HBoxContainer.new()
	payment_terms_row.add_theme_constant_override("separation", 8)
	stack.add_child(payment_terms_row)

	payment_terms_checkbox = CheckBox.new()
	payment_terms_checkbox.name = "PaymentTermsCheckbox"
	payment_terms_checkbox.custom_minimum_size = Vector2(38, 38)
	payment_terms_row.add_child(payment_terms_checkbox)

	var payment_terms_label: Label = _create_settings_label(PAYMENT_TERMS_CHECKBOX_TEXT)
	payment_terms_label.name = "PaymentTermsLabel"
	payment_terms_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	payment_terms_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	payment_terms_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	payment_terms_label.add_theme_font_size_override("font_size", 13)
	payment_terms_row.add_child(payment_terms_label)

	payment_status_label = _create_settings_label("")
	payment_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	payment_status_label.custom_minimum_size = Vector2(0, 58)
	payment_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(payment_status_label)

	var buttons: HBoxContainer = HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 12)
	stack.add_child(buttons)

	payment_submit_button = Button.new()
	payment_submit_button.text = "SEND STK"
	payment_submit_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(payment_submit_button, Color(0.31, 0.97, 0.85, 1.0), 14)
	buttons.add_child(payment_submit_button)
	if not payment_submit_button.pressed.is_connected(_on_payment_submit_pressed):
		payment_submit_button.pressed.connect(_on_payment_submit_pressed)

	payment_cancel_button = Button.new()
	payment_cancel_button.text = "CANCEL"
	payment_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(payment_cancel_button, Color(0.72, 0.36, 1.0, 1.0), 14)
	buttons.add_child(payment_cancel_button)
	if not payment_cancel_button.pressed.is_connected(_hide_payment_popup):
		payment_cancel_button.pressed.connect(_hide_payment_popup)

	payment_http_request = get_node_or_null("PaymentHTTPRequest") as HTTPRequest
	if payment_http_request == null:
		payment_http_request = HTTPRequest.new()
		payment_http_request.name = "PaymentHTTPRequest"
		add_child(payment_http_request)
	if not payment_http_request.request_completed.is_connected(_on_payment_http_request_completed):
		payment_http_request.request_completed.connect(_on_payment_http_request_completed)
	_update_payment_preview()


func _show_payment_popup() -> void:
	if payment_popup == null:
		_ensure_payment_popup()
	if payment_popup == null:
		return
	payment_amount_input.text = ""
	payment_phone_input.text = ""
	if payment_email_input != null:
		payment_email_input.text = ""
	if payment_terms_checkbox != null:
		payment_terms_checkbox.button_pressed = false
	payment_pending_invoice_id = ""
	payment_pending_purpose = ""
	payment_pending_gold_amount = 0
	payment_request_kind = ""
	payment_status_timer = -1.0
	payment_status_poll_count = 0
	_set_payment_busy(false)
	_update_payment_preview()
	payment_popup.popup_centered()
	if payment_amount_input != null and not OS.has_feature("mobile"):
		payment_amount_input.grab_focus()


func _hide_payment_popup() -> void:
	if payment_popup != null:
		payment_popup.hide()


func _on_payment_amount_changed(_text: String) -> void:
	_update_payment_preview()


func _update_payment_preview() -> void:
	if payment_status_label == null:
		return
	payment_status_label.text = "Donate any amount by M-Pesa through Paystack."


func _on_payment_submit_pressed() -> void:
	var amount: int = _parse_positive_int(payment_amount_input.text if payment_amount_input != null else "")
	var phone: String = _normalize_mpesa_phone(payment_phone_input.text if payment_phone_input != null else "")
	var email: String = _normalize_payment_email(payment_email_input.text if payment_email_input != null else "")
	if amount <= 0:
		_set_payment_status("Enter a valid KES amount.")
		return
	if phone == "":
		_set_payment_status("Enter a valid Safaricom number.")
		return
	if email == "":
		_set_payment_status("Enter a valid email address.")
		return
	if payment_terms_checkbox == null or not payment_terms_checkbox.button_pressed:
		_set_payment_status(PAYMENT_TERMS_REQUIRED_STATUS)
		return

	var purpose: String = "donation"
	var gold_amount: int = 0
	var payload: Dictionary = {
		"amount": amount,
		"phone_number": phone,
		"email": email,
		"purpose": purpose,
		"gold_amount": gold_amount,
		"player_name": _get_online_local_player_name(),
		"player_login_id": _get_online_local_player_login_id(),
		"player_age": _get_online_local_player_age(),
		"terms_accepted": true,
		"communication_consent": true
	}
	payment_pending_purpose = purpose
	payment_pending_gold_amount = gold_amount
	payment_request_kind = "initialize"
	_set_payment_busy(true)
	_set_payment_status("Sending STK request...")
	_request_payment_initialize(payload, PAYSTACK_INITIALIZE_ENDPOINT_PATH)


func _request_payment_initialize(payload: Dictionary, endpoint_path: String) -> void:
	var url: String = _get_payment_server_url(endpoint_path)
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	var error: Error = payment_http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		_set_payment_busy(false)
		_set_payment_status("Could not contact payment server.")


func _on_payment_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	_set_payment_busy(false)
	if result != HTTPRequest.RESULT_SUCCESS or response_code <= 0:
		_set_payment_status("Could not reach payment server. Check the Android internet permission, connection, and server URL.")
		return
	var response_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(response_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		var clean_response: String = response_text.strip_edges().replace("\n", " ").replace("\r", " ")
		if clean_response == "":
			clean_response = "empty response"
		_set_payment_status("Payment server did not return JSON: %s" % clean_response.left(110))
		return
	var response: Dictionary = parsed
	if response_code < 200 or response_code >= 300 or not bool(response.get("ok", false)):
		_set_payment_status(str(response.get("error", "Payment request failed.")))
		return
	if payment_request_kind == "status":
		_handle_payment_status_response(response)
		return

	payment_pending_invoice_id = _extract_payment_invoice_id(response)
	var provider_message: String = _extract_payment_provider_message(response)
	if provider_message == "":
		provider_message = "STK request sent. Complete the M-Pesa prompt to continue."
	_set_payment_status(provider_message)
	if payment_pending_invoice_id != "":
		payment_status_poll_count = 0
		payment_status_timer = PAYMENT_STATUS_POLL_SECONDS


func _process_payment_status_poll(delta: float) -> void:
	if payment_status_timer < 0.0 or payment_pending_invoice_id == "":
		return
	payment_status_timer -= delta
	if payment_status_timer > 0.0:
		return
	payment_status_timer = -1.0
	_request_payment_status()


func _request_payment_status() -> void:
	if payment_pending_invoice_id == "":
		return
	if payment_status_poll_count >= PAYMENT_STATUS_MAX_POLLS:
		_set_payment_status("Payment is still pending. Check Paystack dashboard if it completed.")
		return
	payment_status_poll_count += 1
	payment_request_kind = "status"
	var payload: Dictionary = {
		"invoice_id": payment_pending_invoice_id,
		"reference": payment_pending_invoice_id
	}
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	var error: Error = payment_http_request.request(_get_payment_server_url(PAYSTACK_STATUS_ENDPOINT_PATH), headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		payment_status_timer = PAYMENT_STATUS_POLL_SECONDS


func _handle_payment_status_response(response: Dictionary) -> void:
	var state: String = _extract_payment_state(response)
	if ["COMPLETE", "COMPLETED", "PAID", "SUCCESS", "SUCCESSFUL"].has(state):
		if payment_pending_purpose == "gold" and payment_pending_gold_amount > 0:
			var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
			if currency_manager != null and currency_manager.has_method("add_purchased_gold"):
				currency_manager.call("add_purchased_gold", payment_pending_gold_amount)
			_refresh_coin_balance_label()
			_refresh_online_currency_display()
			_set_payment_status("Payment confirmed. Added %d Gold." % payment_pending_gold_amount)
		else:
			_set_payment_status("Donation received. Thank you for supporting Bano ke.")
		payment_pending_invoice_id = ""
		payment_status_timer = -1.0
		return
	if ["FAILED", "CANCELLED", "CANCELED", "DECLINED"].has(state):
		_set_payment_status("Payment was not completed: %s." % state.capitalize())
		payment_pending_invoice_id = ""
		payment_status_timer = -1.0
		return
	_set_payment_status("Waiting for Paystack confirmation... (%s)" % (state if state != "" else "pending"))
	payment_status_timer = PAYMENT_STATUS_POLL_SECONDS


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
	for key in ["reference", "id"]:
		var provider_data_value: String = str(provider_data.get(key, "")).strip_edges()
		if provider_data_value != "":
			return provider_data_value
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
	state = str(invoice.get("state", invoice.get("status", ""))).strip_edges().to_upper()
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


func _set_payment_busy(is_busy: bool) -> void:
	if payment_submit_button != null:
		payment_submit_button.disabled = is_busy
	if payment_cancel_button != null:
		payment_cancel_button.disabled = is_busy


func _set_payment_status(text_value: String) -> void:
	if payment_status_label != null:
		payment_status_label.text = text_value


func _parse_positive_int(value: String) -> int:
	var digits: String = ""
	for index in range(value.length()):
		var character: String = value.substr(index, 1)
		if character >= "0" and character <= "9":
			digits += character
	if digits == "":
		return 0
	return max(int(digits), 0)


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


func _normalize_payment_email(value: String) -> String:
	var email: String = value.strip_edges().to_lower()
	if email.length() > 120:
		email = email.substr(0, 120)
	if email.find(" ") != -1 or email.find("\t") != -1:
		return ""
	var at_index: int = email.find("@")
	if at_index <= 0 or at_index != email.rfind("@"):
		return ""
	var domain: String = email.substr(at_index + 1)
	if domain.length() < 3 or domain.find(".") <= 0 or domain.ends_with("."):
		return ""
	return email


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


func _on_tutorial_pressed() -> void:
	print("Tutorial button pressed")
	
	var tutorial_path = "res://tutorial.tscn"

	if ResourceLoader.exists(tutorial_path):
		_stop_menu_music_for_gameplay()
		get_tree().change_scene_to_file(tutorial_path)
	else:
		push_error("Tutorial scene not found at: %s" % tutorial_path)
		
func _ensure_rules_popup() -> void:
	rules_popup = get_node_or_null("RulesPopup") as Window
	if rules_popup == null:
		rules_popup = Window.new()
		rules_popup.name = "RulesPopup"
		add_child(rules_popup)

	rules_popup.title = "Rules"
	rules_popup.size = Vector2i(1280, 720)
	rules_popup.unresizable = true
	rules_popup.borderless = true
	rules_popup.transparent_bg = true
	rules_popup.exclusive = true
	rules_popup.hide()
	if not rules_popup.close_requested.is_connected(_hide_rules_popup):
		rules_popup.close_requested.connect(_hide_rules_popup)
	_rebuild_rules_popup_contents()
	call_deferred("_rebuild_rules_popup_contents")


func _rebuild_rules_popup_contents() -> void:
	for child in rules_popup.get_children():
		child.queue_free()

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "RulesBackground"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.texture = load(BACKGROUND_PATH)
	background_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rules_popup.add_child(background_rect)

	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.22)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rules_popup.add_child(shade)

	var art_center: CenterContainer = CenterContainer.new()
	art_center.set_anchors_preset(Control.PRESET_FULL_RECT)
	art_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rules_popup.add_child(art_center)

	var rules_art: TextureRect = TextureRect.new()
	rules_art.name = "RulesArtwork"
	rules_art.custom_minimum_size = Vector2(1136, 639)
	rules_art.texture = load(RULES_PAGE_PATH)
	rules_art.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	rules_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rules_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art_center.add_child(rules_art)

	rules_close_button = Button.new()
	rules_close_button.name = "RulesBackButton"
	rules_close_button.text = "<"
	rules_close_button.flat = false
	rules_close_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	rules_close_button.offset_left = 32
	rules_close_button.offset_top = 28
	rules_close_button.offset_right = 104
	rules_close_button.offset_bottom = 90
	rules_close_button.focus_mode = Control.FOCUS_NONE
	rules_close_button.add_theme_font_override("font", ui_font)
	rules_close_button.add_theme_font_size_override("font_size", 40)
	rules_close_button.add_theme_color_override("font_color", Color(0.98, 0.92, 1.0, 1.0))
	rules_close_button.add_theme_color_override("font_shadow_color", Color(0.76, 0.16, 1.0, 0.92))
	rules_close_button.add_theme_constant_override("shadow_offset_x", 0)
	rules_close_button.add_theme_constant_override("shadow_offset_y", 0)
	rules_close_button.add_theme_constant_override("shadow_outline_size", 10)
	rules_close_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.015, 0.005, 0.04, 0.78), Color(0.75, 0.2, 1.0, 0.95), 14))
	rules_close_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.035, 0.01, 0.08, 0.9), Color(0.94, 0.58, 1.0, 1.0), 14))
	rules_close_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.01, 0.0, 0.025, 0.98), Color(0.65, 0.1, 0.88, 1.0), 14))
	rules_popup.add_child(rules_close_button)
	if not rules_close_button.pressed.is_connected(_hide_rules_popup):
		rules_close_button.pressed.connect(_hide_rules_popup)
	return

	var root: MarginContainer = MarginContainer.new()
	root.name = "RulesRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 20)
	root.add_theme_constant_override("margin_top", 20)
	root.add_theme_constant_override("margin_right", 20)
	root.add_theme_constant_override("margin_bottom", 20)
	rules_popup.add_child(root)
	var glass_bg := Panel.new()
	glass_bg.set_anchors_preset(Control.PRESET_FULL_RECT)

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.07, 0.11, 0.16, 0.55)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(1, 1, 1, 0.18)

	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28

	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 30
	style.shadow_offset = Vector2(0, 10)

	glass_bg.add_theme_stylebox_override("panel", style)

	root.add_child(glass_bg)
	root.move_child(glass_bg, 0)

	var vb: VBoxContainer = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 16)
	root.add_child(vb)

	var heading: Label = Label.new()
	heading.text = "RULES"
	vb.add_child(heading)
	heading.add_theme_font_size_override("font_size", 32)
	heading.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0))
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var rules_text: RichTextLabel = RichTextLabel.new()
	rules_text.name = "RulesText"
	rules_text.bbcode_enabled = false
	rules_text.scroll_active = true
	rules_text.fit_content = false
	rules_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	rules_text.text = "1. All marbles start from the point farthest from the hole. Everyone takes an opening shot toward the hole.\n\n2. The first turn order is set by who reaches the hole first. If nobody reaches it, the order is decided by which marble stops closest to the hole.\n\n3. If two or more marbles enter the hole in the lineup, only those tied marbles shoot again to decide who goes first.\n\n4. After the lineup decides the order, the real game begins from where every marble actually stopped.\n\n5. A player can eliminate someone in three ways: enter the hole first and then hit another marble from the hole, hit another marble first while outside the hole and then use the next shot to enter the hole, or hit another marble and fall into the hole on that same shot.\n\n6. If your marble hits another marble while you are still outside the hole and does not enter the hole, you earn another chance to try entering the hole. If that next shot enters the hole, the marble you hit is eliminated.\n\n7. When a marble enters the hole, it stays where it really lands in the bowl. It is not reset to a new spawn point.\n\n8. If your shot misses these elimination conditions, the turn moves to the next marble in the order.\n\n9. The winner is the last player still in the game."
	vb.add_child(rules_text)

	rules_close_button = Button.new()
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(1, 1, 1, 0.1)
	btn_style.border_width_left = 1
	btn_style.border_width_top = 1
	btn_style.border_width_right = 1
	btn_style.border_width_bottom = 1
	btn_style.border_color = Color(1, 1, 1, 0.25)

	btn_style.corner_radius_top_left = 18
	btn_style.corner_radius_top_right = 18
	btn_style.corner_radius_bottom_left = 18
	btn_style.corner_radius_bottom_right = 18

	rules_close_button.add_theme_stylebox_override("normal", btn_style)
	rules_close_button.custom_minimum_size = Vector2(140, 50)
	rules_close_button.name = "CloseButton"
	rules_close_button.text = "CLOSE"
	vb.add_child(rules_close_button)

	if not rules_close_button.pressed.is_connected(_hide_rules_popup):
		rules_close_button.pressed.connect(_hide_rules_popup)


func _ensure_credits_popup() -> void:
	credits_popup = get_node_or_null("CreditsPopup") as Window
	if credits_popup == null:
		credits_popup = Window.new()
		credits_popup.name = "CreditsPopup"
		add_child(credits_popup)

	credits_popup.title = "Credits"
	credits_popup.size = Vector2i(1280, 720)
	credits_popup.unresizable = true
	credits_popup.borderless = true
	credits_popup.transparent_bg = true
	credits_popup.exclusive = true
	credits_popup.hide()
	if not credits_popup.close_requested.is_connected(_hide_credits_popup):
		credits_popup.close_requested.connect(_hide_credits_popup)
	_rebuild_credits_popup_contents()


func _rebuild_credits_popup_contents() -> void:
	if credits_popup == null:
		return
	for child in credits_popup.get_children():
		child.queue_free()

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "CreditsBackground"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.texture = load(BACKGROUND_PATH)
	background_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credits_popup.add_child(background_rect)

	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.38)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	credits_popup.add_child(shade)

	var root: MarginContainer = MarginContainer.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 42)
	root.add_theme_constant_override("margin_top", 34)
	root.add_theme_constant_override("margin_right", 42)
	root.add_theme_constant_override("margin_bottom", 42)
	credits_popup.add_child(root)

	var page: VBoxContainer = VBoxContainer.new()
	page.add_theme_constant_override("separation", 24)
	root.add_child(page)

	var header: HBoxContainer = HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 74)
	header.add_theme_constant_override("separation", 24)
	page.add_child(header)

	credits_close_button = Button.new()
	credits_close_button.name = "CreditsBackButton"
	credits_close_button.text = "<"
	credits_close_button.custom_minimum_size = Vector2(72, 62)
	credits_close_button.add_theme_font_override("font", ui_font)
	credits_close_button.add_theme_font_size_override("font_size", 40)
	credits_close_button.add_theme_color_override("font_color", Color(0.98, 0.92, 1.0, 1.0))
	credits_close_button.add_theme_color_override("font_shadow_color", Color(0.76, 0.16, 1.0, 0.92))
	credits_close_button.add_theme_constant_override("shadow_offset_x", 0)
	credits_close_button.add_theme_constant_override("shadow_offset_y", 0)
	credits_close_button.add_theme_constant_override("shadow_outline_size", 10)
	credits_close_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.015, 0.005, 0.04, 0.78), Color(0.75, 0.2, 1.0, 0.95), 14))
	credits_close_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.035, 0.01, 0.08, 0.9), Color(0.94, 0.58, 1.0, 1.0), 14))
	credits_close_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.01, 0.0, 0.025, 0.98), Color(0.65, 0.1, 0.88, 1.0), 14))
	header.add_child(credits_close_button)

	var heading: Label = Label.new()
	heading.text = "CREDITS"
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", title_font)
	heading.add_theme_font_size_override("font_size", 42)
	heading.add_theme_color_override("font_color", Color(0.98, 0.96, 1.0, 1.0))
	heading.add_theme_color_override("font_outline_color", Color(0.58, 0.16, 1.0, 0.95))
	heading.add_theme_color_override("font_shadow_color", Color(0.72, 0.2, 1.0, 0.9))
	heading.add_theme_constant_override("outline_size", 2)
	heading.add_theme_constant_override("shadow_offset_x", 0)
	heading.add_theme_constant_override("shadow_offset_y", 0)
	heading.add_theme_constant_override("shadow_outline_size", 12)
	header.add_child(heading)

	var panel: Panel = Panel.new()
	panel.custom_minimum_size = Vector2(860, 420)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_settings_outer_panel_style())
	page.add_child(panel)

	var panel_margin: MarginContainer = MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.add_theme_constant_override("margin_left", 34)
	panel_margin.add_theme_constant_override("margin_top", 30)
	panel_margin.add_theme_constant_override("margin_right", 34)
	panel_margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(panel_margin)

	var content: VBoxContainer = VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 20)
	panel_margin.add_child(content)

	var music_title: Label = _create_settings_label("MUSIC")
	music_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	music_title.add_theme_font_override("font", title_font)
	music_title.add_theme_font_size_override("font_size", 34)
	music_title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.34, 1.0))
	content.add_child(music_title)

	var credit_text: Label = _create_settings_label(
		"Music track: Born to Win by Aylex\n" +
		"Source: https://freetouse.com/music\n" +
		"Free Background Music for Video"
	)
	credit_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	credit_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	credit_text.add_theme_font_size_override("font_size", 24)
	credit_text.add_theme_color_override("font_color", Color(0.92, 0.96, 1.0, 0.98))
	content.add_child(credit_text)

	var thanks: Label = _create_settings_label("Thanks for playing Bano ke.")
	thanks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	thanks.add_theme_font_size_override("font_size", 18)
	thanks.add_theme_color_override("font_color", Color(0.31, 0.97, 0.85, 0.92))
	content.add_child(thanks)

	if not credits_close_button.pressed.is_connected(_hide_credits_popup):
		credits_close_button.pressed.connect(_hide_credits_popup)


func _ensure_settings_popup() -> void:
	settings_popup = get_node_or_null("SettingsPopup") as Window
	if settings_popup == null:
		settings_popup = Window.new()
		settings_popup.name = "SettingsPopup"
		add_child(settings_popup)

	settings_popup.title = "Settings"
	settings_popup.size = Vector2i(1280, 720)
	settings_popup.unresizable = true
	settings_popup.borderless = true
	settings_popup.transparent_bg = true
	settings_popup.exclusive = true
	settings_popup.hide()
	if not settings_popup.close_requested.is_connected(_hide_settings_popup):
		settings_popup.close_requested.connect(_hide_settings_popup)
	_rebuild_settings_popup_contents()


func _ensure_shooting_mechanics_popup() -> void:
	shooting_mechanics_popup = get_node_or_null("ShootingMechanicsPopup") as Window
	if shooting_mechanics_popup == null:
		shooting_mechanics_popup = Window.new()
		shooting_mechanics_popup.name = "ShootingMechanicsPopup"
		add_child(shooting_mechanics_popup)

	shooting_mechanics_popup.title = "Shooting Mechanics"
	shooting_mechanics_popup.size = Vector2i(920, 520)
	shooting_mechanics_popup.unresizable = true
	shooting_mechanics_popup.borderless = true
	shooting_mechanics_popup.transparent_bg = true
	shooting_mechanics_popup.exclusive = true
	shooting_mechanics_popup.hide()
	_rebuild_shooting_mechanics_popup_contents()


func _ensure_customize_popup() -> void:
	customize_popup = get_node_or_null("CustomizePopup") as Control
	if customize_popup == null:
		customize_popup = ColorRect.new()
		customize_popup.name = "CustomizePopup"
		add_child(customize_popup)
	customize_popup.set_anchors_preset(Control.PRESET_FULL_RECT)
	(customize_popup as ColorRect).color = Color(0.015, 0.018, 0.03, 1.0)
	customize_popup.mouse_filter = Control.MOUSE_FILTER_STOP
	customize_popup.hide()
	_rebuild_customize_popup_contents()


func _ensure_player_name_popup() -> void:
	player_name_popup = get_node_or_null("PlayerNamePopup") as Window
	if player_name_popup == null:
		player_name_popup = Window.new()
		player_name_popup.name = "PlayerNamePopup"
		add_child(player_name_popup)

	player_name_popup.title = "Player Login"
	player_name_popup.size = Vector2i(760, 620)
	player_name_popup.unresizable = true
	player_name_popup.exclusive = true
	player_name_popup.borderless = true
	player_name_popup.transparent_bg = true
	player_name_popup.hide()
	_rebuild_player_name_popup_contents()
	if not player_name_popup.close_requested.is_connected(_on_player_name_popup_close_requested):
		player_name_popup.close_requested.connect(_on_player_name_popup_close_requested)


func _rebuild_player_name_popup_contents() -> void:
	if player_name_popup == null:
		return

	for child in player_name_popup.get_children():
		child.queue_free()

	var backdrop: TextureRect = TextureRect.new()
	backdrop.name = "PlayerLoginBackdrop"
	backdrop.texture = load(BACKGROUND_PATH)
	backdrop.set_anchors_preset(Control.PRESET_FULL_RECT)
	backdrop.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_name_popup.add_child(backdrop)

	var shade: ColorRect = ColorRect.new()
	shade.name = "PlayerLoginShade"
	shade.color = Color(0.005, 0.006, 0.025, 0.72)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	player_name_popup.add_child(shade)

	var root: MarginContainer = MarginContainer.new()
	root.name = "PlayerNameRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 24)
	root.add_theme_constant_override("margin_top", 24)
	root.add_theme_constant_override("margin_right", 24)
	root.add_theme_constant_override("margin_bottom", 24)
	player_name_popup.add_child(root)

	var frame: Panel = Panel.new()
	frame.name = "PlayerLoginFrame"
	frame.custom_minimum_size = Vector2(600, 0)
	frame.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	frame.size_flags_vertical = Control.SIZE_EXPAND_FILL
	frame.add_theme_stylebox_override("panel", _make_menu_panel_style(Color(0.02, 0.012, 0.07, 0.94), Color(0.72, 0.36, 1.0, 0.95)))
	root.add_child(frame)

	var content_margin: MarginContainer = MarginContainer.new()
	content_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	content_margin.add_theme_constant_override("margin_left", 24)
	content_margin.add_theme_constant_override("margin_top", 22)
	content_margin.add_theme_constant_override("margin_right", 24)
	content_margin.add_theme_constant_override("margin_bottom", 20)
	frame.add_child(content_margin)

	var scroll: ScrollContainer = ScrollContainer.new()
	scroll.name = "PlayerLoginScroll"
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_margin.add_child(scroll)

	var content: VBoxContainer = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 9)
	scroll.add_child(content)

	var heading: Label = Label.new()
	heading.text = "CREATE PLAYER LOGIN"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", ui_font)
	heading.add_theme_font_size_override("font_size", 27)
	heading.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	heading.add_theme_color_override("font_shadow_color", Color(0.75, 0.22, 1.0, 0.9))
	heading.add_theme_constant_override("shadow_outline_size", 8)
	content.add_child(heading)

	var description: Label = Label.new()
	description.text = "Set your player details before entering online parties, the HUD, and leaderboard matches."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description.add_theme_font_override("font", ui_font)
	description.add_theme_font_size_override("font_size", 14)
	description.add_theme_color_override("font_color", Color(0.8, 0.9, 0.98, 0.94))
	content.add_child(description)

	player_google_signin_button = Button.new()
	player_google_signin_button.name = "GoogleSignInButton"
	player_google_signin_button.text = "SIGN IN WITH GOOGLE"
	player_google_signin_button.custom_minimum_size = Vector2(0, 48)
	player_google_signin_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(player_google_signin_button)
	_style_popup_action_button(player_google_signin_button, Color(0.42, 0.72, 1.0, 1.0), 17, Vector2(0, 48))
	if not player_google_signin_button.pressed.is_connected(_on_google_signin_pressed):
		player_google_signin_button.pressed.connect(_on_google_signin_pressed)

	var guest_label: Label = _create_settings_label("Or play as guest")
	guest_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guest_label.add_theme_font_size_override("font_size", 13)
	guest_label.add_theme_color_override("font_color", Color(0.88, 0.94, 1.0, 0.72))
	content.add_child(guest_label)

	var name_label: Label = _create_online_section_label("PLAYER NAME")
	name_label.add_theme_font_size_override("font_size", 15)
	content.add_child(name_label)

	player_name_popup_input = LineEdit.new()
	player_name_popup_input.name = "PlayerNamePopupInput"
	player_name_popup_input.placeholder_text = "Enter your name"
	player_name_popup_input.max_length = 18
	player_name_popup_input.custom_minimum_size = Vector2(0, 48)
	_style_player_login_line_edit(player_name_popup_input)
	content.add_child(player_name_popup_input)

	var age_label: Label = _create_online_section_label("AGE")
	age_label.add_theme_font_size_override("font_size", 15)
	content.add_child(age_label)

	player_age_popup_input = LineEdit.new()
	player_age_popup_input.name = "PlayerAgePopupInput"
	player_age_popup_input.placeholder_text = "Enter your age"
	player_age_popup_input.max_length = 3
	player_age_popup_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	player_age_popup_input.custom_minimum_size = Vector2(0, 48)
	_style_player_login_line_edit(player_age_popup_input)
	content.add_child(player_age_popup_input)

	var terms_row: HBoxContainer = HBoxContainer.new()
	terms_row.add_theme_constant_override("separation", 10)
	content.add_child(terms_row)

	player_terms_checkbox = CheckBox.new()
	player_terms_checkbox.name = "PlayerTermsCheckbox"
	player_terms_checkbox.text = "I accept the Terms and Conditions"
	player_terms_checkbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_terms_checkbox.add_theme_font_override("font", ui_font)
	player_terms_checkbox.add_theme_font_size_override("font_size", 14)
	player_terms_checkbox.add_theme_color_override("font_color", Color(0.9, 0.94, 1.0, 0.96))
	terms_row.add_child(player_terms_checkbox)

	player_terms_view_button = Button.new()
	player_terms_view_button.name = "ViewTermsButton"
	player_terms_view_button.text = "VIEW"
	player_terms_view_button.custom_minimum_size = Vector2(100, 40)
	terms_row.add_child(player_terms_view_button)
	_style_popup_action_button(player_terms_view_button, Color(0.72, 0.36, 1.0, 1.0), 15, Vector2(100, 40))
	if not player_terms_view_button.pressed.is_connected(_show_terms_popup):
		player_terms_view_button.pressed.connect(_show_terms_popup)

	player_name_popup_save_button = Button.new()
	player_name_popup_save_button.name = "PlayerNamePopupSaveButton"
	player_name_popup_save_button.text = "CONTINUE"
	player_name_popup_save_button.custom_minimum_size = Vector2(0, 50)
	player_name_popup_save_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(player_name_popup_save_button)
	_style_popup_action_button(player_name_popup_save_button, Color(0.31, 0.97, 0.85, 1.0), 20, Vector2(0, 50))

	player_name_popup_status = Label.new()
	player_name_popup_status.name = "PlayerNamePopupStatus"
	player_name_popup_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	player_name_popup_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_name_popup_status.add_theme_font_override("font", ui_font)
	player_name_popup_status.add_theme_font_size_override("font_size", 14)
	player_name_popup_status.add_theme_color_override("font_color", Color(0.84, 0.92, 0.98, 0.92))
	content.add_child(player_name_popup_status)

	if not player_name_popup_save_button.pressed.is_connected(_on_player_name_popup_save_pressed):
		player_name_popup_save_button.pressed.connect(_on_player_name_popup_save_pressed)
	if not player_name_popup_input.text_submitted.is_connected(_on_player_name_popup_submitted):
		player_name_popup_input.text_submitted.connect(_on_player_name_popup_submitted)
	if not player_age_popup_input.text_submitted.is_connected(_on_player_age_popup_submitted):
		player_age_popup_input.text_submitted.connect(_on_player_age_popup_submitted)
	_ensure_google_auth_http_request()


func _style_player_login_line_edit(line_edit: LineEdit) -> void:
	if line_edit == null:
		return
	line_edit.add_theme_font_override("font", ui_font)
	line_edit.add_theme_font_size_override("font_size", 18)
	line_edit.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	line_edit.add_theme_color_override("font_placeholder_color", Color(0.68, 0.82, 0.95, 0.68))
	line_edit.add_theme_stylebox_override("normal", _make_menu_button_style(Color(0.025, 0.018, 0.08, 0.88), Color(0.42, 0.72, 1.0, 0.62)))
	line_edit.add_theme_stylebox_override("focus", _make_menu_button_style(Color(0.04, 0.035, 0.12, 0.96), Color(0.31, 0.97, 0.85, 0.98)))


func _style_popup_action_button(button: Button, accent_color: Color, font_size: int, min_size: Vector2) -> void:
	if button == null:
		return
	button.flat = false
	button.custom_minimum_size = min_size
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color(0.98, 0.99, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.92, 1.0, 0.98, 1.0))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	button.add_theme_constant_override("shadow_offset_y", 1)
	button.add_theme_constant_override("shadow_outline_size", 3)
	button.add_theme_stylebox_override("normal", _make_menu_button_style(Color(0.018, 0.012, 0.05, 0.86), accent_color))
	button.add_theme_stylebox_override("hover", _make_menu_button_style(Color(0.035, 0.02, 0.085, 0.94), accent_color.lightened(0.16)))
	button.add_theme_stylebox_override("pressed", _make_menu_button_style(Color(0.01, 0.006, 0.035, 0.98), accent_color.darkened(0.12)))
	button.focus_mode = Control.FOCUS_NONE


func _ensure_terms_popup() -> void:
	terms_popup = get_node_or_null("TermsPopup") as Window
	if terms_popup == null:
		terms_popup = Window.new()
		terms_popup.name = "TermsPopup"
		add_child(terms_popup)

	terms_popup.title = "Terms and Conditions"
	terms_popup.size = Vector2i(860, 620)
	terms_popup.unresizable = true
	terms_popup.borderless = true
	terms_popup.transparent_bg = true
	terms_popup.exclusive = true
	terms_popup.hide()
	if not terms_popup.close_requested.is_connected(_hide_terms_popup):
		terms_popup.close_requested.connect(_hide_terms_popup)

	for child in terms_popup.get_children():
		child.queue_free()

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "TermsBackground"
	background_rect.texture = load(BACKGROUND_PATH)
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	terms_popup.add_child(background_rect)

	var shade: ColorRect = ColorRect.new()
	shade.name = "TermsShade"
	shade.color = Color(0.005, 0.004, 0.025, 0.78)
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	terms_popup.add_child(shade)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_top", 24)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_bottom", 24)
	terms_popup.add_child(margin)

	var panel: Panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel", _make_menu_panel_style(Color(0.02, 0.012, 0.07, 0.94), Color(0.72, 0.36, 1.0, 0.95)))
	margin.add_child(panel)

	var panel_margin: MarginContainer = MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.add_theme_constant_override("margin_left", 26)
	panel_margin.add_theme_constant_override("margin_top", 24)
	panel_margin.add_theme_constant_override("margin_right", 26)
	panel_margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(panel_margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 12)
	panel_margin.add_child(stack)

	var heading: Label = _create_settings_label("TERMS AND CONDITIONS")
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", title_font)
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	heading.add_theme_color_override("font_shadow_color", Color(0.75, 0.22, 1.0, 0.9))
	heading.add_theme_constant_override("shadow_outline_size", 8)
	stack.add_child(heading)

	var terms_text: RichTextLabel = RichTextLabel.new()
	terms_text.name = "TermsText"
	terms_text.text = TERMS_TEXT
	terms_text.fit_content = false
	terms_text.scroll_active = true
	terms_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	terms_text.add_theme_stylebox_override("normal", _make_menu_button_style(Color(0.01, 0.008, 0.04, 0.82), Color(0.42, 0.72, 1.0, 0.45)))
	terms_text.add_theme_font_override("normal_font", ui_font)
	terms_text.add_theme_font_size_override("normal_font_size", 14)
	terms_text.add_theme_color_override("default_color", Color(0.88, 0.94, 1.0, 0.96))
	stack.add_child(terms_text)

	terms_close_button = Button.new()
	terms_close_button.text = "CLOSE"
	terms_close_button.custom_minimum_size = Vector2(170, 48)
	terms_close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	stack.add_child(terms_close_button)
	_style_popup_action_button(terms_close_button, Color(0.72, 0.36, 1.0, 1.0), 18, Vector2(170, 48))
	if not terms_close_button.pressed.is_connected(_hide_terms_popup):
		terms_close_button.pressed.connect(_hide_terms_popup)


func _show_terms_popup() -> void:
	if terms_popup == null:
		_ensure_terms_popup()
	if terms_popup != null:
		var viewport_size: Vector2 = get_viewport_rect().size
		var popup_width: int = maxi(360, mini(860, int(viewport_size.x) - 32))
		var popup_height: int = maxi(460, mini(620, int(viewport_size.y) - 32))
		terms_popup.size = Vector2i(popup_width, popup_height)
		terms_popup.popup_centered()


func _hide_terms_popup() -> void:
	if terms_popup != null:
		terms_popup.hide()


func _ensure_google_auth_http_request() -> void:
	google_auth_http_request = get_node_or_null("GoogleAuthHTTPRequest") as HTTPRequest
	if google_auth_http_request == null:
		google_auth_http_request = HTTPRequest.new()
		google_auth_http_request.name = "GoogleAuthHTTPRequest"
		add_child(google_auth_http_request)
	if not google_auth_http_request.request_completed.is_connected(_on_google_auth_http_request_completed):
		google_auth_http_request.request_completed.connect(_on_google_auth_http_request_completed)


func _on_google_signin_pressed() -> void:
	_ensure_google_auth_http_request()
	google_auth_device_code = ""
	google_auth_user_code = ""
	google_auth_verification_url = ""
	google_auth_poll_timer = -1.0
	google_auth_expires_at_msec = 0
	google_auth_request_kind = "start"
	_set_google_auth_status("Starting Google sign-in...")
	_set_google_signin_button_state(true, "CONNECTING...")
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	var error: Error = google_auth_http_request.request(_get_payment_server_url(GOOGLE_AUTH_START_ENDPOINT_PATH), headers, HTTPClient.METHOD_POST, JSON.stringify({}))
	if error != OK:
		google_auth_request_kind = ""
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
		_set_google_auth_status("Could not contact the login server.")


func _process_google_auth_poll(delta: float) -> void:
	if google_auth_device_code == "" or google_auth_poll_timer < 0.0:
		return
	if google_auth_expires_at_msec > 0 and Time.get_ticks_msec() >= google_auth_expires_at_msec:
		google_auth_device_code = ""
		google_auth_poll_timer = -1.0
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
		_set_google_auth_status("Google sign-in expired. Try again.")
		return
	google_auth_poll_timer -= delta
	if google_auth_poll_timer > 0.0:
		return
	_request_google_auth_poll()


func _request_google_auth_poll() -> void:
	if google_auth_http_request == null or google_auth_device_code == "":
		return
	google_auth_request_kind = "poll"
	google_auth_poll_timer = -1.0
	_set_google_signin_button_state(true, "WAITING...")
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	var payload: Dictionary = {
		"device_code": google_auth_device_code
	}
	var error: Error = google_auth_http_request.request(_get_payment_server_url(GOOGLE_AUTH_POLL_ENDPOINT_PATH), headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		google_auth_poll_timer = 2.0
		_set_google_auth_status("Still waiting for Google sign-in...")


func _on_google_auth_http_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	var request_kind: String = google_auth_request_kind
	google_auth_request_kind = ""
	if result != HTTPRequest.RESULT_SUCCESS or response_code <= 0:
		if request_kind == "poll" and google_auth_device_code != "":
			google_auth_poll_timer = google_auth_poll_interval
			_set_google_auth_status("Waiting for Google sign-in... Code: %s" % google_auth_user_code)
			return
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
		_set_google_auth_status("Could not reach the login server.")
		return

	var response_text: String = body.get_string_from_utf8()
	var parsed: Variant = JSON.parse_string(response_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
		_set_google_auth_status("Login server did not return JSON.")
		return

	var response: Dictionary = parsed
	if response_code < 200 or response_code >= 300 or not bool(response.get("ok", false)):
		google_auth_device_code = ""
		google_auth_poll_timer = -1.0
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
		_set_google_auth_status(str(response.get("error", "Google sign-in failed.")))
		return

	match request_kind:
		"start":
			_handle_google_auth_start_response(response)
		"poll":
			_handle_google_auth_poll_response(response)
		"profile_save":
			_set_google_auth_status("Google profile connected. Progress sync is ready.")
		_:
			_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")


func _handle_google_auth_start_response(response: Dictionary) -> void:
	google_auth_device_code = str(response.get("device_code", "")).strip_edges()
	google_auth_user_code = str(response.get("user_code", "")).strip_edges()
	google_auth_verification_url = str(response.get("verification_url", "https://www.google.com/device")).strip_edges()
	google_auth_poll_interval = maxf(float(response.get("interval", GOOGLE_AUTH_DEFAULT_POLL_SECONDS)), 2.0)
	var expires_in: int = max(int(response.get("expires_in", 1800)), 60)
	google_auth_expires_at_msec = Time.get_ticks_msec() + (expires_in * 1000)
	if google_auth_device_code == "" or google_auth_user_code == "":
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
		_set_google_auth_status("Google sign-in did not return a login code.")
		return
	if google_auth_verification_url != "":
		OS.shell_open(google_auth_verification_url)
	_set_google_auth_status("Google opened in your browser. Enter code %s, then return here." % google_auth_user_code)
	google_auth_poll_timer = 1.0


func _handle_google_auth_poll_response(response: Dictionary) -> void:
	if bool(response.get("pending", false)):
		google_auth_poll_interval = maxf(float(response.get("interval", google_auth_poll_interval)), 2.0)
		google_auth_poll_timer = google_auth_poll_interval
		_set_google_auth_status("Waiting for Google approval... Code: %s" % google_auth_user_code)
		return

	var profile: Dictionary = response.get("profile", {}) if typeof(response.get("profile", {})) == TYPE_DICTIONARY else {}
	var auth_token: String = str(response.get("auth_token", "")).strip_edges()
	if profile.is_empty() or auth_token == "":
		google_auth_device_code = ""
		google_auth_poll_timer = -1.0
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
		_set_google_auth_status("Google sign-in finished, but no profile was returned.")
		return

	profile["auth_token"] = auth_token
	google_auth_pending_profile = profile.duplicate(true)
	google_auth_pending_auth_token = auth_token
	google_auth_device_code = ""
	google_auth_poll_timer = -1.0
	var google_name: String = str(profile.get("name", "")).strip_edges()
	if google_name != "" and player_name_popup_input != null:
		player_name_popup_input.text = google_name.left(18)
	var remote_age: int = int(profile.get("player_age", 0))
	if remote_age > 0 and player_age_popup_input != null and player_age_popup_input.text.strip_edges() == "":
		player_age_popup_input.text = str(remote_age)
	_set_google_signin_button_state(false, "GOOGLE CONNECTED")
	var google_name_suffix: String = " as %s" % google_name if google_name != "" else ""
	_set_google_auth_status("Google verified%s. Enter your age, accept the Terms, then Continue." % google_name_suffix)


func _set_google_signin_button_state(is_busy: bool, label: String) -> void:
	if player_google_signin_button != null:
		player_google_signin_button.disabled = is_busy
		player_google_signin_button.text = label


func _set_google_auth_status(text_value: String) -> void:
	if player_name_popup_status != null:
		player_name_popup_status.text = text_value
	elif player_name_status != null:
		player_name_status.text = text_value


func _save_google_profile_progress() -> void:
	_ensure_google_auth_http_request()
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_google_profile_sync_payload"):
		return
	var payload: Dictionary = customization.call("get_google_profile_sync_payload")
	if payload.is_empty():
		return
	google_auth_request_kind = "profile_save"
	var headers: PackedStringArray = PackedStringArray(["Content-Type: application/json"])
	var error: Error = google_auth_http_request.request(_get_payment_server_url(GOOGLE_PROFILE_SAVE_ENDPOINT_PATH), headers, HTTPClient.METHOD_POST, JSON.stringify(payload))
	if error != OK:
		google_auth_request_kind = ""


func _ensure_lan_popup() -> void:
	lan_popup = get_node_or_null("LanPopup") as Window
	if lan_popup == null:
		lan_popup = Window.new()
		lan_popup.name = "LanPopup"
		add_child(lan_popup)

	lan_popup.title = "Join LAN"
	lan_popup.size = Vector2i(700, 430)
	lan_popup.unresizable = true
	lan_popup.hide()

	for child in lan_popup.get_children():
		child.queue_free()

	var root: MarginContainer = MarginContainer.new()
	root.name = "LanRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 28)
	root.add_theme_constant_override("margin_top", 24)
	root.add_theme_constant_override("margin_right", 28)
	root.add_theme_constant_override("margin_bottom", 24)
	lan_popup.add_child(root)

	var vb: VBoxContainer = VBoxContainer.new()
	vb.add_theme_constant_override("separation", 14)
	root.add_child(vb)

	lan_heading_label = _create_settings_label("Play online with a party code")
	lan_heading_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(lan_heading_label)

	lan_status_label = Label.new()
	lan_status_label.name = "LanStatus"
	lan_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lan_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lan_status_label.add_theme_font_override("font", ui_font)
	lan_status_label.add_theme_font_size_override("font_size", 15)
	lan_status_label.add_theme_color_override("font_color", Color(0.78, 0.9, 1.0, 0.96))
	vb.add_child(lan_status_label)

	var input_row: HBoxContainer = HBoxContainer.new()
	input_row.add_theme_constant_override("separation", 12)
	vb.add_child(input_row)

	lan_ip_input = LineEdit.new()
	lan_ip_input.name = "HostIpInput"
	lan_ip_input.placeholder_text = "Party code"
	lan_ip_input.text = ""
	lan_ip_input.custom_minimum_size = Vector2(0, 64)
	lan_ip_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lan_ip_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	input_row.add_child(lan_ip_input)

	lan_port_input = LineEdit.new()
	lan_port_input.name = "HostPortInput"
	lan_port_input.placeholder_text = "Port"
	lan_port_input.text = str(LAN_DEFAULT_PORT)
	lan_port_input.custom_minimum_size = Vector2(150, 64)
	lan_port_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_NUMBER
	input_row.add_child(lan_port_input)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 12)
	vb.add_child(button_row)

	lan_connect_button = Button.new()
	lan_connect_button.name = "LanConnectButton"
	lan_connect_button.text = "CONNECT"
	lan_connect_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(lan_connect_button)

	lan_cancel_button = Button.new()
	lan_cancel_button.name = "LanCancelButton"
	lan_cancel_button.text = "CANCEL"
	lan_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(lan_cancel_button)

	if not lan_connect_button.pressed.is_connected(_on_lan_connect_pressed):
		lan_connect_button.pressed.connect(_on_lan_connect_pressed)
	if not lan_cancel_button.pressed.is_connected(_hide_lan_popup):
		lan_cancel_button.pressed.connect(_hide_lan_popup)
	if not lan_ip_input.text_submitted.is_connected(_on_lan_ip_submitted):
		lan_ip_input.text_submitted.connect(_on_lan_ip_submitted)
	if not lan_port_input.text_submitted.is_connected(_on_lan_port_submitted):
		lan_port_input.text_submitted.connect(_on_lan_port_submitted)
	if not lan_popup.close_requested.is_connected(_hide_lan_popup):
		lan_popup.close_requested.connect(_hide_lan_popup)

	_refresh_lan_status()


func _ensure_online_rooms_page() -> void:
	online_rooms_page = get_node_or_null("OnlineRoomsPage") as Control
	if online_rooms_page == null:
		online_rooms_page = Control.new()
		online_rooms_page.name = "OnlineRoomsPage"
		add_child(online_rooms_page)

	online_rooms_page.set_anchors_preset(Control.PRESET_FULL_RECT)
	online_rooms_page.custom_minimum_size = get_viewport_rect().size
	online_rooms_page.set_deferred("size", get_viewport_rect().size)
	online_rooms_page.z_index = 80
	online_rooms_page.hide()

	for child in online_rooms_page.get_children():
		child.queue_free()
	online_public_room_buttons.clear()
	online_currency_amount_labels.clear()
	online_stat_amount_labels.clear()
	online_party_slot_name_labels.clear()
	online_party_slot_status_labels.clear()
	online_live_rooms_stack = null
	online_players_list_stack = null
	online_friends_list_stack = null
	online_friend_requests_list_stack = null
	online_chat_log_stack = null
	online_chat_input = null
	online_chat_send_button = null
	online_chat_bubble_button = null
	online_chat_popup_panel = null
	online_chat_title_label = null
	online_chat_toast_panel = null
	online_chat_toast_sender_label = null
	online_chat_toast_text_label = null
	online_chat_toast_timer = 0.0
	online_invite_popup_panel = null
	online_invite_popup_title_label = null
	online_invite_popup_message_label = null
	online_invite_accept_button = null
	online_invite_decline_button = null
	online_loading_chat_log_stack = null
	online_loading_chat_input = null
	online_loading_chat_send_button = null
	online_loading_chat_panel = null
	online_loading_chat_title_label = null
	online_loading_chat_toggle_button = null
	online_loading_video_player = null
	online_loading_info_panel = null
	online_loading_cancel_button = null
	online_loading_transition_tween = null
	online_rooms_list = null
	online_touch_scroll_last_positions.clear()
	online_current_room_label = null
	online_marble_display_panel = null
	online_marble_preview_frame = null
	online_marble_preview_node = null
	online_marble_visual_node = null
	online_hologram_effects_root = null
	var viewport_size: Vector2 = get_viewport_rect().size
	var matchmaking_panel_width: float = clampf(
		viewport_size.x * 0.29,
		ONLINE_MATCHMAKING_PANEL_MIN_WIDTH,
		ONLINE_MATCHMAKING_PANEL_MAX_WIDTH
	)
	var social_panel_width: float = clampf(
		viewport_size.x * 0.23,
		ONLINE_SOCIAL_PANEL_MIN_WIDTH,
		ONLINE_SOCIAL_PANEL_MAX_WIDTH
	)

	var background_base: ColorRect = ColorRect.new()
	background_base.name = "OnlineRoomsBackgroundBase"
	background_base.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_base.color = Color(0.005, 0.003, 0.018, 1.0)
	background_base.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_rooms_page.add_child(background_base)

	var background_image: TextureRect = TextureRect.new()
	background_image.name = "OnlineRoomsBackground"
	background_image.set_anchors_preset(Control.PRESET_FULL_RECT)
	_position_online_rooms_background(background_image, viewport_size, matchmaking_panel_width, social_panel_width)
	background_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_set_online_background_texture(background_image)
	online_rooms_page.add_child(background_image)

	var screen_shade: ColorRect = ColorRect.new()
	screen_shade.name = "OnlineRoomsShade"
	screen_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	screen_shade.color = Color(0.0, 0.0, 0.0, 0.02)
	screen_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_rooms_page.add_child(screen_shade)

	var page_margin: MarginContainer = MarginContainer.new()
	page_margin.name = "OnlineRoomsContent"
	page_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	page_margin.custom_minimum_size = viewport_size
	page_margin.add_theme_constant_override("margin_left", ONLINE_PAGE_MARGIN_X)
	page_margin.add_theme_constant_override("margin_top", 14)
	page_margin.add_theme_constant_override("margin_right", ONLINE_PAGE_MARGIN_X)
	page_margin.add_theme_constant_override("margin_bottom", 18)
	online_rooms_page.add_child(page_margin)

	var page_stack: VBoxContainer = VBoxContainer.new()
	page_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page_stack.add_theme_constant_override("separation", 12)
	page_margin.add_child(page_stack)

	var top_bar: HBoxContainer = HBoxContainer.new()
	top_bar.custom_minimum_size = Vector2(0, 68)
	top_bar.add_theme_constant_override("separation", 10)
	page_stack.add_child(top_bar)

	var brand_panel: Panel = Panel.new()
	brand_panel.custom_minimum_size = Vector2(240, 60)
	brand_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	brand_panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.02, 0.04, 0.08, 0.74), Color(0.31, 0.97, 0.85, 0.85), 10))
	top_bar.add_child(brand_panel)

	var brand_margin: MarginContainer = MarginContainer.new()
	brand_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	brand_margin.add_theme_constant_override("margin_left", 14)
	brand_margin.add_theme_constant_override("margin_top", 6)
	brand_margin.add_theme_constant_override("margin_right", 14)
	brand_margin.add_theme_constant_override("margin_bottom", 6)
	brand_panel.add_child(brand_margin)

	var brand_stack: VBoxContainer = VBoxContainer.new()
	brand_stack.add_theme_constant_override("separation", 0)
	brand_margin.add_child(brand_stack)

	var brand_label: Label = _create_online_text_label("Bano ke Online", 25, Color(0.98, 0.99, 1.0, 1.0), title_font)
	brand_stack.add_child(brand_label)

	var brand_subtitle: Label = _create_online_text_label("MARBLE BATTLE ARENA", 11, Color(0.83, 0.94, 1.0, 0.92), ui_font)
	brand_stack.add_child(brand_subtitle)

	var status_panel: Panel = Panel.new()
	status_panel.custom_minimum_size = Vector2(220, 60)
	status_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	status_panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.01, 0.025, 0.055, 0.72), Color(0.72, 0.36, 1.0, 0.72), 10))
	top_bar.add_child(status_panel)

	var status_margin: MarginContainer = MarginContainer.new()
	status_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	status_margin.add_theme_constant_override("margin_left", 14)
	status_margin.add_theme_constant_override("margin_top", 7)
	status_margin.add_theme_constant_override("margin_right", 14)
	status_margin.add_theme_constant_override("margin_bottom", 7)
	status_panel.add_child(status_margin)

	online_status_label = _create_online_text_label("Connecting to online parties...", 14, Color(0.82, 0.94, 1.0, 0.96), ui_font)
	online_status_label.name = "OnlineStatus"
	online_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_margin.add_child(online_status_label)

	if viewport_size.x >= 1120.0:
		for stat_data in [
			{"key": "players", "label": "ONLINE", "accent": Color(0.31, 0.97, 0.85, 1.0)},
			{"key": "open", "label": "OPEN", "accent": Color(0.42, 0.72, 1.0, 1.0)},
			{"key": "running", "label": "LIVE", "accent": Color(1.0, 0.82, 0.2, 1.0)}
		]:
			var stat_accent: Color = stat_data["accent"]
			var stat_box: Panel = _create_online_stat_box(str(stat_data["label"]), str(stat_data["key"]), stat_accent)
			top_bar.add_child(stat_box)

	if viewport_size.x >= 1500.0:
		for currency_data in [
			{"key": "coins", "accent": Color(0.72, 0.36, 1.0, 1.0)},
			{"key": "gold", "accent": Color(1.0, 0.82, 0.2, 1.0)}
		]:
			var currency_key: String = str(currency_data["key"])
			var currency_prefix: String = "G" if currency_key == "gold" else "S"
			var currency_accent: Color = currency_data["accent"]
			var currency_box: Panel = _create_online_currency_box("%s 0" % currency_prefix, currency_accent)
			top_bar.add_child(currency_box)
			var amount_label: Label = currency_box.get_meta("amount_label", null) as Label
			if amount_label != null:
				online_currency_amount_labels[currency_key] = amount_label

	var gear_button: Button = _create_online_top_button("SETTINGS", Color(0.86, 0.82, 1.0, 1.0))
	top_bar.add_child(gear_button)
	gear_button.pressed.connect(_on_settings_pressed)

	online_refresh_button = _create_online_top_button("REFRESH", Color(0.08, 0.9, 1.0, 1.0))
	online_refresh_button.name = "OnlineRefreshButton"
	top_bar.add_child(online_refresh_button)

	online_back_button = _create_online_top_button("BACK", Color(0.72, 0.36, 1.0, 1.0))
	online_back_button.name = "OnlineBackButton"
	top_bar.add_child(online_back_button)

	var body_row: HBoxContainer = HBoxContainer.new()
	body_row.custom_minimum_size = Vector2(0, maxf(viewport_size.y - 112.0, 460.0))
	body_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_row.add_theme_constant_override("separation", ONLINE_BODY_GAP)
	page_stack.add_child(body_row)

	var matchmaking_stack: VBoxContainer = _create_online_panel_stack(
		body_row,
		"OnlineMatchmakingPanel",
		Vector2(matchmaking_panel_width, 0.0),
		Color(0.31, 0.97, 0.85, 0.88)
	)
	online_rooms_list = matchmaking_stack

	var match_title_row: HBoxContainer = HBoxContainer.new()
	match_title_row.add_theme_constant_override("separation", 10)
	matchmaking_stack.add_child(match_title_row)

	var match_title: Label = _create_online_section_label("MATCHMAKING")
	match_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_title_row.add_child(match_title)

	var match_badge: Label = _create_online_badge("SERVER")
	match_title_row.add_child(match_badge)

	online_quick_match_button = Button.new()
	online_quick_match_button.name = "OnlineQuickMatchButton"
	online_quick_match_button.text = "QUICK PARTY\n5 PLAYER BATTLE  |  0/5 READY"
	online_quick_match_button.custom_minimum_size = Vector2(0, 92)
	online_quick_match_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(online_quick_match_button, Color(1.0, 0.82, 0.2, 1.0), 20)
	matchmaking_stack.add_child(online_quick_match_button)

	var public_label: Label = _create_online_section_label("PUBLIC PARTIES")
	matchmaking_stack.add_child(public_label)

	var public_grid: GridContainer = GridContainer.new()
	public_grid.name = "AlwaysOpenRoomsGrid"
	public_grid.columns = 2
	public_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	public_grid.add_theme_constant_override("h_separation", 10)
	public_grid.add_theme_constant_override("v_separation", 10)
	matchmaking_stack.add_child(public_grid)

	for human_capacity in [2, 3, 4, 5]:
		var button: Button = Button.new()
		button.name = "OpenRoom%dButton" % human_capacity
		button.text = "%dP PARTY\nOPEN NOW" % human_capacity
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 70)
		_style_online_button(button, _get_online_room_accent(human_capacity), 16)
		button.pressed.connect(_on_online_public_room_pressed.bind(human_capacity))
		public_grid.add_child(button)
		online_public_room_buttons[human_capacity] = button

	var private_label: Label = _create_online_section_label("PRIVATE PARTY")
	matchmaking_stack.add_child(private_label)

	var private_row: HBoxContainer = HBoxContainer.new()
	private_row.add_theme_constant_override("separation", 10)
	matchmaking_stack.add_child(private_row)

	online_private_size_picker = OptionButton.new()
	online_private_size_picker.name = "OnlinePrivateSizePicker"
	online_private_size_picker.custom_minimum_size = Vector2(136, 58)
	for human_capacity in [2, 3, 4, 5]:
		online_private_size_picker.add_item("%d PLAYERS" % human_capacity, human_capacity)
	_style_online_option_button(online_private_size_picker, Color(0.72, 0.36, 1.0, 1.0))
	private_row.add_child(online_private_size_picker)

	online_private_code_input = LineEdit.new()
	online_private_code_input.name = "OnlinePrivateCodeInput"
	online_private_code_input.placeholder_text = "CODE"
	online_private_code_input.max_length = 5
	online_private_code_input.custom_minimum_size = Vector2(0, 58)
	online_private_code_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_private_code_input.virtual_keyboard_type = LineEdit.KEYBOARD_TYPE_DEFAULT
	_style_online_line_edit(online_private_code_input, Color(0.72, 0.36, 1.0, 1.0))
	private_row.add_child(online_private_code_input)

	var private_buttons_row: HBoxContainer = HBoxContainer.new()
	private_buttons_row.add_theme_constant_override("separation", 10)
	matchmaking_stack.add_child(private_buttons_row)

	online_private_create_button = Button.new()
	online_private_create_button.name = "OnlinePrivateCreateButton"
	online_private_create_button.text = "CREATE"
	online_private_create_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_private_create_button.custom_minimum_size = Vector2(0, 62)
	_style_online_button(online_private_create_button, Color(0.08, 0.9, 1.0, 1.0), 17)
	private_buttons_row.add_child(online_private_create_button)

	online_private_join_button = Button.new()
	online_private_join_button.name = "OnlinePrivateJoinButton"
	online_private_join_button.text = "JOIN"
	online_private_join_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_private_join_button.custom_minimum_size = Vector2(0, 62)
	_style_online_button(online_private_join_button, Color(0.72, 0.36, 1.0, 1.0), 17)
	private_buttons_row.add_child(online_private_join_button)

	online_current_room_label = _create_online_text_label("No party joined yet.", 13, Color(0.82, 0.94, 1.0, 0.9), ui_font)
	online_current_room_label.name = "OnlineCurrentPartyLabel"
	online_current_room_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_current_room_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	matchmaking_stack.add_child(online_current_room_label)

	online_start_button = Button.new()
	online_start_button.name = "OnlineStartButton"
	online_start_button.text = "WAITING FOR HOST"
	online_start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_start_button.custom_minimum_size = Vector2(0, 62)
	_style_online_button(online_start_button, Color(0.72, 0.78, 0.9, 0.75), 18)
	online_start_button.hide()
	matchmaking_stack.add_child(online_start_button)

	var match_spacer: Control = Control.new()
	match_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	matchmaking_stack.add_child(match_spacer)

	var body_spacer: Control = Control.new()
	body_spacer.name = "OnlineBodySpacer"
	body_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body_row.add_child(body_spacer)

	var social_stack: VBoxContainer = _create_online_panel_stack(
		body_row,
		"OnlineSocialPanel",
		Vector2(social_panel_width, 0.0),
		Color(0.72, 0.36, 1.0, 0.9)
	)

	var social_title_row: HBoxContainer = HBoxContainer.new()
	social_title_row.add_theme_constant_override("separation", 10)
	social_stack.add_child(social_title_row)

	var social_title: Label = _create_online_section_label("PLAYERS")
	social_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	social_title_row.add_child(social_title)

	var social_badge: Label = _create_online_badge("INVITES")
	social_title_row.add_child(social_badge)

	var directory_tabs: TabContainer = TabContainer.new()
	directory_tabs.name = "OnlineDirectoryTabs"
	directory_tabs.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	directory_tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	directory_tabs.clip_tabs = true
	_style_online_tab_container(directory_tabs)
	social_stack.add_child(directory_tabs)

	var players_tab: VBoxContainer = VBoxContainer.new()
	players_tab.name = "ONLINE"
	players_tab.add_theme_constant_override("separation", 8)
	directory_tabs.add_child(players_tab)

	var players_scroll: ScrollContainer = ScrollContainer.new()
	players_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	players_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configure_online_touch_scroll(players_scroll)
	players_tab.add_child(players_scroll)

	online_players_list_stack = VBoxContainer.new()
	online_players_list_stack.name = "OnlinePlayersListStack"
	online_players_list_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_players_list_stack.add_theme_constant_override("separation", 8)
	players_scroll.add_child(online_players_list_stack)
	_attach_online_touch_scroll_content(online_players_list_stack, players_scroll)

	var friends_tab: VBoxContainer = VBoxContainer.new()
	friends_tab.name = "FRIENDS"
	friends_tab.add_theme_constant_override("separation", 8)
	directory_tabs.add_child(friends_tab)

	var friends_scroll: ScrollContainer = ScrollContainer.new()
	friends_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	friends_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configure_online_touch_scroll(friends_scroll)
	friends_tab.add_child(friends_scroll)

	online_friends_list_stack = VBoxContainer.new()
	online_friends_list_stack.name = "OnlineFriendsListStack"
	online_friends_list_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_friends_list_stack.add_theme_constant_override("separation", 8)
	friends_scroll.add_child(online_friends_list_stack)
	_attach_online_touch_scroll_content(online_friends_list_stack, friends_scroll)

	var requests_tab: VBoxContainer = VBoxContainer.new()
	requests_tab.name = "REQUESTS"
	requests_tab.add_theme_constant_override("separation", 8)
	directory_tabs.add_child(requests_tab)

	var requests_scroll: ScrollContainer = ScrollContainer.new()
	requests_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	requests_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configure_online_touch_scroll(requests_scroll)
	requests_tab.add_child(requests_scroll)

	online_friend_requests_list_stack = VBoxContainer.new()
	online_friend_requests_list_stack.name = "OnlineFriendRequestsListStack"
	online_friend_requests_list_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_friend_requests_list_stack.add_theme_constant_override("separation", 8)
	requests_scroll.add_child(online_friend_requests_list_stack)
	_attach_online_touch_scroll_content(online_friend_requests_list_stack, requests_scroll)

	var parties_tab: VBoxContainer = VBoxContainer.new()
	parties_tab.name = "PARTIES"
	parties_tab.add_theme_constant_override("separation", 8)
	directory_tabs.add_child(parties_tab)

	var parties_scroll: ScrollContainer = ScrollContainer.new()
	parties_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parties_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_configure_online_touch_scroll(parties_scroll)
	parties_tab.add_child(parties_scroll)

	online_live_rooms_stack = VBoxContainer.new()
	online_live_rooms_stack.name = "OnlineLiveRoomsStack"
	online_live_rooms_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_live_rooms_stack.add_theme_constant_override("separation", 8)
	parties_scroll.add_child(online_live_rooms_stack)
	_attach_online_touch_scroll_content(online_live_rooms_stack, parties_scroll)

	_build_online_floating_chat()
	_build_online_invite_popup()

	if not online_back_button.pressed.is_connected(_hide_online_rooms_page):
		online_back_button.pressed.connect(_hide_online_rooms_page)
	if not online_refresh_button.pressed.is_connected(_on_online_refresh_pressed):
		online_refresh_button.pressed.connect(_on_online_refresh_pressed)
	if not online_quick_match_button.pressed.is_connected(_on_online_quick_match_pressed):
		online_quick_match_button.pressed.connect(_on_online_quick_match_pressed)
	if not online_private_create_button.pressed.is_connected(_on_online_private_create_pressed):
		online_private_create_button.pressed.connect(_on_online_private_create_pressed)
	if not online_private_join_button.pressed.is_connected(_on_online_private_join_pressed):
		online_private_join_button.pressed.connect(_on_online_private_join_pressed)
	if not online_start_button.pressed.is_connected(_on_online_start_pressed):
		online_start_button.pressed.connect(_on_online_start_pressed)
	if not online_private_code_input.text_submitted.is_connected(_on_online_private_code_submitted):
		online_private_code_input.text_submitted.connect(_on_online_private_code_submitted)
	if online_chat_send_button != null and not online_chat_send_button.pressed.is_connected(_on_online_chat_send_pressed):
		online_chat_send_button.pressed.connect(_on_online_chat_send_pressed)
	if online_chat_input != null and not online_chat_input.text_submitted.is_connected(_on_online_chat_submitted):
		online_chat_input.text_submitted.connect(_on_online_chat_submitted)

	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	if currency_manager != null and currency_manager.has_signal("currency_changed"):
		var currency_callable: Callable = Callable(self, "_on_online_currency_changed")
		if not currency_manager.is_connected("currency_changed", currency_callable):
			currency_manager.connect("currency_changed", currency_callable)

	_ensure_online_loading_panel()
	_refresh_online_stat_display()
	_refresh_online_currency_display()
	_refresh_online_rooms_view()
	_refresh_online_friends_list()
	_refresh_online_friend_requests_list()
	_refresh_online_chat_log()


func _build_online_floating_chat() -> void:
	if online_rooms_page == null:
		return

	online_chat_popup_panel = Panel.new()
	online_chat_popup_panel.name = "OnlineFloatingChatPanel"
	online_chat_popup_panel.anchor_left = 1.0
	online_chat_popup_panel.anchor_top = 1.0
	online_chat_popup_panel.anchor_right = 1.0
	online_chat_popup_panel.anchor_bottom = 1.0
	online_chat_popup_panel.offset_left = -408.0
	online_chat_popup_panel.offset_top = -386.0
	online_chat_popup_panel.offset_right = -24.0
	online_chat_popup_panel.offset_bottom = -92.0
	online_chat_popup_panel.z_index = 720
	online_chat_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	online_chat_popup_panel.visible = online_chat_expanded
	online_chat_popup_panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.015, 0.025, 0.055, 0.9), Color(0.72, 0.36, 1.0, 0.9), 10))
	online_rooms_page.add_child(online_chat_popup_panel)

	var panel_margin: MarginContainer = MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.add_theme_constant_override("margin_left", 14)
	panel_margin.add_theme_constant_override("margin_top", 12)
	panel_margin.add_theme_constant_override("margin_right", 14)
	panel_margin.add_theme_constant_override("margin_bottom", 12)
	online_chat_popup_panel.add_child(panel_margin)

	var panel_stack: VBoxContainer = VBoxContainer.new()
	panel_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_stack.add_theme_constant_override("separation", 10)
	panel_margin.add_child(panel_stack)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	panel_stack.add_child(title_row)

	online_chat_title_label = _create_online_text_label("PARTY CHAT", 15, Color(0.96, 0.99, 1.0, 0.96), ui_font)
	online_chat_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(online_chat_title_label)

	var close_button: Button = Button.new()
	close_button.text = "X"
	close_button.custom_minimum_size = Vector2(36, 30)
	_style_online_button(close_button, Color(0.72, 0.36, 1.0, 1.0), 12)
	title_row.add_child(close_button)
	close_button.pressed.connect(_toggle_online_chat)

	var chat_scroll: ScrollContainer = ScrollContainer.new()
	chat_scroll.name = "OnlineFloatingChatScroll"
	chat_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_stack.add_child(chat_scroll)

	online_chat_log_stack = VBoxContainer.new()
	online_chat_log_stack.name = "OnlineFloatingChatLog"
	online_chat_log_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_chat_log_stack.add_theme_constant_override("separation", 7)
	chat_scroll.add_child(online_chat_log_stack)

	var chat_input_row: HBoxContainer = HBoxContainer.new()
	chat_input_row.add_theme_constant_override("separation", 8)
	panel_stack.add_child(chat_input_row)

	online_chat_input = LineEdit.new()
	online_chat_input.name = "OnlineFloatingChatInput"
	online_chat_input.placeholder_text = "MESSAGE"
	online_chat_input.max_length = 160
	online_chat_input.custom_minimum_size = Vector2(0, 44)
	online_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_line_edit(online_chat_input, Color(0.72, 0.36, 1.0, 1.0))
	chat_input_row.add_child(online_chat_input)

	online_chat_send_button = Button.new()
	online_chat_send_button.name = "OnlineFloatingChatSendButton"
	online_chat_send_button.text = "SEND"
	online_chat_send_button.custom_minimum_size = Vector2(82, 44)
	_style_online_button(online_chat_send_button, Color(0.31, 0.97, 0.85, 1.0), 13)
	chat_input_row.add_child(online_chat_send_button)

	online_chat_bubble_button = Button.new()
	online_chat_bubble_button.name = "OnlineChatBubbleButton"
	online_chat_bubble_button.z_index = 730
	online_chat_bubble_button.text = "CHAT"
	online_chat_bubble_button.tooltip_text = "Open party chat"
	online_chat_bubble_button.custom_minimum_size = ONLINE_CHAT_BUTTON_SIZE
	online_chat_bubble_button.size = ONLINE_CHAT_BUTTON_SIZE
	_style_online_button(online_chat_bubble_button, Color(0.31, 0.97, 0.85, 1.0), 14)
	online_rooms_page.add_child(online_chat_bubble_button)
	_position_online_chat_bubble_button()
	if not online_rooms_page.resized.is_connected(_on_online_rooms_page_resized):
		online_rooms_page.resized.connect(_on_online_rooms_page_resized)
	call_deferred("_position_online_chat_bubble_button")
	online_chat_bubble_button.gui_input.connect(_on_online_chat_bubble_gui_input)
	_build_online_chat_toast()
	_sync_online_chat_visibility()


func _position_online_chat_bubble_button() -> void:
	if online_chat_bubble_button == null:
		return
	online_chat_bubble_button.anchor_left = 0.0
	online_chat_bubble_button.anchor_top = 0.0
	online_chat_bubble_button.anchor_right = 0.0
	online_chat_bubble_button.anchor_bottom = 0.0
	online_chat_bubble_button.size = ONLINE_CHAT_BUTTON_SIZE
	if online_chat_button_has_custom_position:
		online_chat_bubble_button.position = _clamp_online_chat_button_position(online_chat_button_custom_position)
		return
	var parent_size: Vector2 = get_viewport().get_visible_rect().size
	online_chat_bubble_button.position = _clamp_online_chat_button_position(Vector2(
		parent_size.x - ONLINE_CHAT_BUTTON_OFFSET.x - ONLINE_CHAT_BUTTON_SIZE.x,
		ONLINE_CHAT_BUTTON_OFFSET.y
	))


func _clamp_online_chat_button_position(candidate_position: Vector2) -> Vector2:
	var parent_size: Vector2 = get_viewport().get_visible_rect().size
	var button_size: Vector2 = ONLINE_CHAT_BUTTON_SIZE
	if online_chat_bubble_button != null:
		button_size = online_chat_bubble_button.size
	return Vector2(
		clampf(candidate_position.x, 0.0, maxf(parent_size.x - button_size.x, 0.0)),
		clampf(candidate_position.y, 0.0, maxf(parent_size.y - button_size.y, 0.0))
	)


func _clamp_online_chat_button_global_position(candidate_position: Vector2) -> Vector2:
	var visible_rect: Rect2 = get_viewport().get_visible_rect()
	var button_size: Vector2 = ONLINE_CHAT_BUTTON_SIZE
	if online_chat_bubble_button != null:
		button_size = online_chat_bubble_button.size
	return Vector2(
		clampf(candidate_position.x, visible_rect.position.x, maxf(visible_rect.end.x - button_size.x, visible_rect.position.x)),
		clampf(candidate_position.y, visible_rect.position.y, maxf(visible_rect.end.y - button_size.y, visible_rect.position.y))
	)


func _on_online_rooms_page_resized() -> void:
	_position_online_chat_bubble_button()


func _on_online_chat_bubble_gui_input(event: InputEvent) -> void:
	if online_chat_bubble_button == null:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_event.pressed:
			_begin_online_chat_button_drag(get_global_mouse_position())
		else:
			_finish_online_chat_button_drag()
		online_chat_bubble_button.accept_event()
	elif event is InputEventMouseMotion and online_chat_button_pressing:
		_update_online_chat_button_drag(get_global_mouse_position())
		online_chat_bubble_button.accept_event()
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			_begin_online_chat_button_drag(touch_event.position, touch_event.index, true)
		elif touch_event.index == online_chat_button_drag_touch_index:
			_finish_online_chat_button_drag()
		online_chat_bubble_button.accept_event()
	elif event is InputEventScreenDrag and online_chat_button_pressing:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if drag_event.index != online_chat_button_drag_touch_index:
			return
		_update_online_chat_button_drag(drag_event.position)
		online_chat_bubble_button.accept_event()


func _handle_online_chat_button_drag_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT:
			_finish_online_chat_button_drag()
			accept_event()
	elif event is InputEventMouseMotion:
		_update_online_chat_button_drag(get_global_mouse_position())
		accept_event()
	elif event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if not touch_event.pressed and touch_event.index == online_chat_button_drag_touch_index:
			_finish_online_chat_button_drag()
			accept_event()
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		if drag_event.index != online_chat_button_drag_touch_index:
			return
		_update_online_chat_button_drag(drag_event.position)
		accept_event()


func _begin_online_chat_button_drag(pointer_position: Vector2, touch_index: int = -1, started_by_touch: bool = false) -> void:
	online_chat_button_pressing = true
	online_chat_button_dragging = false
	online_chat_button_drag_start_global = pointer_position
	online_chat_button_drag_start_position = online_chat_bubble_button.position
	online_chat_button_drag_pointer_offset = pointer_position - online_chat_bubble_button.global_position
	online_chat_button_drag_touch_index = touch_index
	online_chat_button_drag_started_by_touch = started_by_touch


func _update_online_chat_button_drag(pointer_position: Vector2) -> void:
	var drag_delta: Vector2 = pointer_position - online_chat_button_drag_start_global
	if not online_chat_button_dragging and not online_chat_button_drag_started_by_touch and drag_delta.length() < ONLINE_CHAT_BUTTON_DRAG_THRESHOLD:
		return
	online_chat_button_dragging = true
	online_chat_bubble_button.global_position = _clamp_online_chat_button_global_position(pointer_position - online_chat_button_drag_pointer_offset)
	online_chat_button_custom_position = online_chat_bubble_button.position
	online_chat_button_has_custom_position = true


func _finish_online_chat_button_drag() -> void:
	if not online_chat_button_pressing:
		return
	var opened_by_click: bool = not online_chat_button_dragging
	if online_chat_button_dragging and online_chat_bubble_button != null:
		online_chat_button_custom_position = online_chat_bubble_button.position
		online_chat_button_has_custom_position = true
	online_chat_button_pressing = false
	online_chat_button_dragging = false
	online_chat_button_drag_touch_index = -1
	online_chat_button_drag_started_by_touch = false
	if opened_by_click:
		_toggle_online_chat()


func _build_online_chat_toast() -> void:
	if online_rooms_page == null:
		return

	online_chat_toast_panel = Panel.new()
	online_chat_toast_panel.name = "OnlineChatToast"
	online_chat_toast_panel.set_anchors_preset(Control.PRESET_CENTER)
	online_chat_toast_panel.offset_left = -210.0
	online_chat_toast_panel.offset_top = -54.0
	online_chat_toast_panel.offset_right = 210.0
	online_chat_toast_panel.offset_bottom = 54.0
	online_chat_toast_panel.z_index = 900
	online_chat_toast_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	online_chat_toast_panel.hide()
	online_chat_toast_panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.015, 0.025, 0.055, 0.94), Color(0.31, 0.97, 0.85, 0.92), 12))
	online_rooms_page.add_child(online_chat_toast_panel)
	if not online_chat_toast_panel.gui_input.is_connected(_on_online_chat_toast_gui_input):
		online_chat_toast_panel.gui_input.connect(_on_online_chat_toast_gui_input)

	var toast_margin: MarginContainer = MarginContainer.new()
	toast_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	toast_margin.add_theme_constant_override("margin_left", 18)
	toast_margin.add_theme_constant_override("margin_top", 12)
	toast_margin.add_theme_constant_override("margin_right", 18)
	toast_margin.add_theme_constant_override("margin_bottom", 12)
	online_chat_toast_panel.add_child(toast_margin)

	var toast_stack: VBoxContainer = VBoxContainer.new()
	toast_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	toast_stack.add_theme_constant_override("separation", 4)
	toast_margin.add_child(toast_stack)

	online_chat_toast_sender_label = _create_online_text_label("NEW MESSAGE", 13, Color(0.31, 0.97, 0.85, 1.0), ui_font)
	online_chat_toast_sender_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_chat_toast_sender_label.clip_text = true
	toast_stack.add_child(online_chat_toast_sender_label)

	online_chat_toast_text_label = _create_online_text_label("", 16, Color(0.96, 0.99, 1.0, 1.0), ui_font)
	online_chat_toast_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_chat_toast_text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_chat_toast_text_label.max_lines_visible = 2
	toast_stack.add_child(online_chat_toast_text_label)


func _build_online_invite_popup() -> void:
	if online_rooms_page == null:
		return

	online_invite_popup_panel = Panel.new()
	online_invite_popup_panel.name = "OnlineInvitePopup"
	online_invite_popup_panel.set_anchors_preset(Control.PRESET_CENTER)
	online_invite_popup_panel.offset_left = -236.0
	online_invite_popup_panel.offset_top = -112.0
	online_invite_popup_panel.offset_right = 236.0
	online_invite_popup_panel.offset_bottom = 112.0
	online_invite_popup_panel.z_index = 930
	online_invite_popup_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	online_invite_popup_panel.hide()
	online_invite_popup_panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.015, 0.025, 0.055, 0.96), Color(0.31, 0.97, 0.85, 0.94), 12))
	online_rooms_page.add_child(online_invite_popup_panel)

	var invite_margin: MarginContainer = MarginContainer.new()
	invite_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	invite_margin.add_theme_constant_override("margin_left", 20)
	invite_margin.add_theme_constant_override("margin_top", 18)
	invite_margin.add_theme_constant_override("margin_right", 20)
	invite_margin.add_theme_constant_override("margin_bottom", 18)
	online_invite_popup_panel.add_child(invite_margin)

	var invite_stack: VBoxContainer = VBoxContainer.new()
	invite_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	invite_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	invite_stack.add_theme_constant_override("separation", 12)
	invite_margin.add_child(invite_stack)

	online_invite_popup_title_label = _create_online_text_label("PARTY INVITE", 18, Color(0.31, 0.97, 0.85, 1.0), title_font)
	online_invite_popup_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	invite_stack.add_child(online_invite_popup_title_label)

	online_invite_popup_message_label = _create_online_text_label("", 15, Color(0.96, 0.99, 1.0, 0.96), ui_font)
	online_invite_popup_message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_invite_popup_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_invite_popup_message_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	invite_stack.add_child(online_invite_popup_message_label)

	var button_row: HBoxContainer = HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 12)
	invite_stack.add_child(button_row)

	online_invite_decline_button = Button.new()
	online_invite_decline_button.text = "DECLINE"
	online_invite_decline_button.custom_minimum_size = Vector2(0, 48)
	online_invite_decline_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(online_invite_decline_button, Color(0.72, 0.36, 1.0, 1.0), 14)
	button_row.add_child(online_invite_decline_button)

	online_invite_accept_button = Button.new()
	online_invite_accept_button.text = "ACCEPT"
	online_invite_accept_button.custom_minimum_size = Vector2(0, 48)
	online_invite_accept_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(online_invite_accept_button, Color(1.0, 0.82, 0.2, 1.0), 14)
	button_row.add_child(online_invite_accept_button)

	if not online_invite_accept_button.pressed.is_connected(_on_online_invite_accept_pressed):
		online_invite_accept_button.pressed.connect(_on_online_invite_accept_pressed)
	if not online_invite_decline_button.pressed.is_connected(_on_online_invite_decline_pressed):
		online_invite_decline_button.pressed.connect(_on_online_invite_decline_pressed)


func _create_online_panel_stack(parent: Control, panel_name: String, minimum_size: Vector2, accent_color: Color) -> VBoxContainer:
	var panel: Panel = Panel.new()
	panel.name = panel_name
	panel.custom_minimum_size = minimum_size
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL if minimum_size.x <= 0.0 else Control.SIZE_SHRINK_BEGIN
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.01, 0.025, 0.055, 0.54), accent_color, 10))
	parent.add_child(panel)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_theme_constant_override("separation", 12)
	margin.add_child(stack)
	return stack


func _create_online_text_label(label_text: String, font_size: int, text_color: Color, font_resource: Font) -> Label:
	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_font_override("font", font_resource)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", text_color)
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("shadow_outline_size", 3)
	return label


func _create_online_badge(label_text: String) -> Label:
	var badge: Label = _create_online_text_label(label_text, 12, Color(0.94, 0.98, 1.0, 0.96), ui_font)
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	badge.custom_minimum_size = Vector2(76, 26)
	badge.add_theme_stylebox_override("normal", _make_online_card_style(Color(0.04, 0.03, 0.1, 0.72), Color(1.0, 0.82, 0.2, 0.84), 8))
	return badge


func _create_online_stat_box(label_text: String, stat_key: String, accent_color: Color) -> Panel:
	var panel: Panel = Panel.new()
	panel.custom_minimum_size = Vector2(76, 56)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.02, 0.04, 0.08, 0.74), accent_color, 10))

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 8)
	margin.add_theme_constant_override("margin_top", 6)
	margin.add_theme_constant_override("margin_right", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	panel.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 0)
	margin.add_child(stack)

	var amount_label: Label = _create_online_text_label("0", 20, Color(0.98, 0.99, 1.0, 1.0), ui_font)
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(amount_label)

	var name_label: Label = _create_online_text_label(label_text, 10, Color(0.82, 0.9, 1.0, 0.9), ui_font)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(name_label)

	online_stat_amount_labels[stat_key] = amount_label
	return panel


func _style_online_tab_container(tab_container: TabContainer) -> void:
	if tab_container == null:
		return
	tab_container.add_theme_font_override("font", ui_font)
	tab_container.add_theme_font_size_override("font_size", 16)
	tab_container.add_theme_color_override("font_selected_color", Color(0.98, 0.99, 1.0, 1.0))
	tab_container.add_theme_color_override("font_unselected_color", Color(0.72, 0.82, 0.92, 0.82))
	tab_container.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	tab_container.add_theme_stylebox_override("tab_selected", _make_online_card_style(Color(0.03, 0.06, 0.1, 0.86), Color(0.31, 0.97, 0.85, 0.92), 8))
	tab_container.add_theme_stylebox_override("tab_unselected", _make_online_card_style(Color(0.015, 0.025, 0.05, 0.62), Color(0.72, 0.36, 1.0, 0.55), 8))
	tab_container.add_theme_stylebox_override("tab_hovered", _make_online_card_style(Color(0.04, 0.07, 0.12, 0.82), Color(1.0, 0.82, 0.2, 0.78), 8))


func _configure_online_touch_scroll(scroll: ScrollContainer) -> void:
	if scroll == null:
		return
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	scroll.follow_focus = true
	scroll.scroll_deadzone = 4
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	var scroll_input_callable: Callable = Callable(self, "_on_online_touch_scroll_gui_input").bind(scroll)
	if not scroll.gui_input.is_connected(scroll_input_callable):
		scroll.gui_input.connect(scroll_input_callable)


func _attach_online_touch_scroll_content(content: Control, scroll: ScrollContainer) -> void:
	if content == null or scroll == null:
		return
	content.set_meta("online_touch_scroll", scroll)
	content.mouse_filter = Control.MOUSE_FILTER_PASS
	_bind_online_touch_scroll_children(content)


func _bind_online_touch_scroll_children(content: Control) -> void:
	if content == null or not content.has_meta("online_touch_scroll"):
		return
	var scroll: ScrollContainer = content.get_meta("online_touch_scroll", null) as ScrollContainer
	if scroll == null:
		return
	_bind_online_touch_scroll_control(content, scroll)
	for child in content.get_children():
		_bind_online_touch_scroll_descendants(child, scroll)


func _bind_online_touch_scroll_descendants(node: Node, scroll: ScrollContainer) -> void:
	var control: Control = node as Control
	if control != null:
		_bind_online_touch_scroll_control(control, scroll)
	for child in node.get_children():
		_bind_online_touch_scroll_descendants(child, scroll)


func _bind_online_touch_scroll_control(control: Control, scroll: ScrollContainer) -> void:
	if control == null or scroll == null:
		return
	if control.mouse_filter == Control.MOUSE_FILTER_STOP and not (control is Button) and not (control is LineEdit):
		control.mouse_filter = Control.MOUSE_FILTER_PASS
	var scroll_input_callable: Callable = Callable(self, "_on_online_touch_scroll_gui_input").bind(scroll)
	if not control.gui_input.is_connected(scroll_input_callable):
		control.gui_input.connect(scroll_input_callable)


func _on_online_touch_scroll_gui_input(event: InputEvent, scroll: ScrollContainer) -> void:
	if scroll == null:
		return
	var scroll_key: int = scroll.get_instance_id()
	if event is InputEventScreenTouch:
		var touch_event: InputEventScreenTouch = event as InputEventScreenTouch
		if touch_event.pressed:
			online_touch_scroll_last_positions[scroll_key] = touch_event.position
		else:
			online_touch_scroll_last_positions.erase(scroll_key)
	elif event is InputEventScreenDrag:
		var drag_event: InputEventScreenDrag = event as InputEventScreenDrag
		scroll.scroll_vertical = maxi(0, scroll.scroll_vertical - int(round(drag_event.relative.y)))
		online_touch_scroll_last_positions[scroll_key] = drag_event.position
		scroll.accept_event()
	elif event is InputEventMouseButton:
		var mouse_button: InputEventMouseButton = event as InputEventMouseButton
		if mouse_button.button_index != MOUSE_BUTTON_LEFT:
			return
		if mouse_button.pressed:
			online_touch_scroll_last_positions[scroll_key] = mouse_button.position
		else:
			online_touch_scroll_last_positions.erase(scroll_key)
	elif event is InputEventMouseMotion and online_touch_scroll_last_positions.has(scroll_key) and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var mouse_motion: InputEventMouseMotion = event as InputEventMouseMotion
		var last_position: Vector2 = online_touch_scroll_last_positions.get(scroll_key, mouse_motion.position)
		var motion_delta: Vector2 = mouse_motion.position - last_position
		online_touch_scroll_last_positions[scroll_key] = mouse_motion.position
		if absf(motion_delta.y) >= 1.0:
			scroll.scroll_vertical = maxi(0, scroll.scroll_vertical - int(round(motion_delta.y)))
			scroll.accept_event()


func _load_texture_from_path(texture_path: String) -> Texture2D:
	var direct_texture: Texture2D = _load_image_texture_direct(texture_path)
	if direct_texture != null:
		return direct_texture

	if ResourceLoader.exists(texture_path):
		var texture_resource: Resource = ResourceLoader.load(texture_path)
		if texture_resource is Texture2D:
			return texture_resource as Texture2D

	var loaded_image: Image = Image.new()
	var load_error: int = loaded_image.load(texture_path)
	if load_error == OK:
		return ImageTexture.create_from_image(loaded_image)

	push_warning("Could not load texture: %s" % texture_path)
	return null


func _set_online_background_texture(background_image: TextureRect) -> void:
	if background_image == null:
		return
	background_image.texture = _load_texture_from_path(ONLINE_ROOMS_BACKGROUND_PATH)
	if background_image.texture == null:
		background_image.texture = _load_texture_from_path(ONLINE_ROOMS_BACKGROUND_FALLBACK_PATH)
	if background_image.texture == null:
		push_warning("Online rooms background is missing. Checked %s and %s." % [ONLINE_ROOMS_BACKGROUND_PATH, ONLINE_ROOMS_BACKGROUND_FALLBACK_PATH])


func _position_online_rooms_background(background_image: TextureRect, viewport_size: Vector2, matchmaking_panel_width: float, social_panel_width: float) -> void:
	if background_image == null:
		return

	var left_panel_right: float = float(ONLINE_PAGE_MARGIN_X) + matchmaking_panel_width
	var right_panel_left: float = viewport_size.x - float(ONLINE_PAGE_MARGIN_X) - social_panel_width
	var target_marble_center_x: float = (left_panel_right + right_panel_left) * 0.5
	var natural_marble_center_x: float = viewport_size.x * ONLINE_ROOMS_BACKGROUND_MARBLE_FOCUS_X
	var background_left_shift: float = clampf(
		natural_marble_center_x - target_marble_center_x,
		0.0,
		ONLINE_ROOMS_BACKGROUND_MAX_LEFT_SHIFT
	)

	background_image.offset_left = -background_left_shift
	background_image.offset_top = 0.0
	background_image.offset_right = -background_left_shift
	background_image.offset_bottom = 0.0
	background_image.custom_minimum_size = viewport_size
	background_image.set_deferred("size", viewport_size)


func _load_image_texture_direct(texture_path: String) -> Texture2D:
	var lower_path: String = texture_path.to_lower()
	if not (lower_path.ends_with(".png") or lower_path.ends_with(".jpg") or lower_path.ends_with(".jpeg") or lower_path.ends_with(".webp")):
		return null

	var image: Image = Image.new()
	var load_path: String = texture_path
	if texture_path.begins_with("res://"):
		load_path = ProjectSettings.globalize_path(texture_path)

	var load_error: int = image.load(load_path)
	if load_error != OK:
		push_warning("Could not directly load image %s. Error: %d" % [load_path, load_error])
		return null
	return ImageTexture.create_from_image(image)


func _load_online_loading_texture() -> Texture2D:
	return _load_texture_from_path(ONLINE_LOADING_SCREEN_PATH)


func _load_online_loading_video() -> VideoStream:
	if not ResourceLoader.exists(ONLINE_LOADING_VIDEO_PATH):
		return null
	var video_resource: Resource = ResourceLoader.load(ONLINE_LOADING_VIDEO_PATH)
	return video_resource as VideoStream


func _create_online_section_label(label_text: String) -> Label:
	var label: Label = Label.new()
	label.text = label_text
	label.add_theme_font_override("font", ui_font)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.82, 0.34, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.7))
	label.add_theme_constant_override("shadow_outline_size", 3)
	return label


func _create_online_currency_box(label_text: String, accent_color: Color) -> Panel:
	var panel: Panel = Panel.new()
	panel.custom_minimum_size = Vector2(104, 52)
	panel.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.03, 0.02, 0.12, 0.72), accent_color, 12))

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_top", 7)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 7)
	panel.add_child(margin)

	var label: Label = Label.new()
	label.text = label_text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", ui_font)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.72))
	label.add_theme_constant_override("shadow_outline_size", 3)
	margin.add_child(label)
	panel.set_meta("amount_label", label)
	return panel


func _build_online_marble_display(parent: Control) -> void:
	online_marble_display_panel = Panel.new()
	online_marble_display_panel.name = "OnlineMarbleDisplay"
	online_marble_display_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	online_marble_display_panel.offset_left = 18
	online_marble_display_panel.offset_top = 20
	online_marble_display_panel.offset_right = -18
	online_marble_display_panel.offset_bottom = -20
	online_marble_display_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	online_marble_display_panel.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	parent.add_child(online_marble_display_panel)
	if not online_marble_display_panel.gui_input.is_connected(_on_online_marble_preview_gui_input):
		online_marble_display_panel.gui_input.connect(_on_online_marble_preview_gui_input)

	online_marble_preview_frame = Panel.new()
	online_marble_preview_frame.name = "OnlineMarblePreviewFrame"
	online_marble_preview_frame.set_anchors_preset(Control.PRESET_CENTER)
	online_marble_preview_frame.offset_left = -260
	online_marble_preview_frame.offset_top = -330
	online_marble_preview_frame.offset_right = 260
	online_marble_preview_frame.offset_bottom = 190
	online_marble_preview_frame.clip_contents = true
	online_marble_preview_frame.mouse_filter = Control.MOUSE_FILTER_STOP
	online_marble_preview_frame.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	online_marble_display_panel.add_child(online_marble_preview_frame)
	if not online_marble_preview_frame.gui_input.is_connected(_on_online_marble_preview_gui_input):
		online_marble_preview_frame.gui_input.connect(_on_online_marble_preview_gui_input)

	var info_panel: Panel = Panel.new()
	info_panel.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	info_panel.offset_left = -180
	info_panel.offset_top = -124
	info_panel.offset_right = 180
	info_panel.offset_bottom = -30
	info_panel.custom_minimum_size = Vector2(360, 94)
	info_panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.02, 0.05, 0.08, 0.72), Color(0.72, 0.36, 1.0, 0.86), 18))
	online_marble_display_panel.add_child(info_panel)

	var info_margin: MarginContainer = MarginContainer.new()
	info_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	info_margin.add_theme_constant_override("margin_left", 22)
	info_margin.add_theme_constant_override("margin_top", 12)
	info_margin.add_theme_constant_override("margin_right", 22)
	info_margin.add_theme_constant_override("margin_bottom", 12)
	info_panel.add_child(info_margin)

	var info_stack: VBoxContainer = VBoxContainer.new()
	info_stack.alignment = BoxContainer.ALIGNMENT_CENTER
	info_stack.add_theme_constant_override("separation", 4)
	info_margin.add_child(info_stack)

	online_marble_name_label = Label.new()
	online_marble_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_marble_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_marble_name_label.add_theme_font_override("font", ui_font)
	online_marble_name_label.add_theme_font_size_override("font_size", 25)
	online_marble_name_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.38, 1.0))
	online_marble_name_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
	online_marble_name_label.add_theme_constant_override("shadow_outline_size", 4)
	info_stack.add_child(online_marble_name_label)

	online_marble_status_label = Label.new()
	online_marble_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_marble_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_marble_status_label.add_theme_font_override("font", ui_font)
	online_marble_status_label.add_theme_font_size_override("font_size", 15)
	online_marble_status_label.add_theme_color_override("font_color", Color(0.84, 0.91, 1.0, 0.95))
	info_stack.add_child(online_marble_status_label)


func _refresh_online_marble_display() -> void:
	_refresh_online_owned_marbles()
	if online_marble_preview_frame == null:
		return

	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or online_owned_marble_ids.is_empty():
		if online_marble_name_label != null:
			online_marble_name_label.text = "NO MARBLES OWNED"
		if online_marble_status_label != null:
			online_marble_status_label.text = "Unlock marbles in Customize first."
		_clear_node_children(online_marble_preview_frame)
		online_marble_preview_node = null
		online_marble_visual_node = null
		online_hologram_effects_root = null
		return

	if online_selected_marble_id == "" or not online_owned_marble_ids.has(online_selected_marble_id):
		online_selected_marble_id = str(online_owned_marble_ids[0])

	if customization.has_method("set_selected_marble"):
		customization.call("set_selected_marble", online_selected_marble_id)

	var preset: Dictionary = customization.call("get_marble_preset", online_selected_marble_id) if customization.has_method("get_marble_preset") else {}
	var marble_name: String = str(preset.get("name", online_selected_marble_id))
	var selected_index: int = online_owned_marble_ids.find(online_selected_marble_id) + 1
	if online_marble_name_label != null:
		online_marble_name_label.text = marble_name.to_upper()
	if online_marble_status_label != null:
		online_marble_status_label.text = "Swipe left or right to choose. Owned %d/%d." % [
			maxi(selected_index, 1),
			maxi(online_owned_marble_ids.size(), 1)
		]

	_fill_online_marble_preview_frame(preset)


func _refresh_online_owned_marbles() -> void:
	online_owned_marble_ids.clear()
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_marble_ids"):
		return

	var selected_id: String = str(customization.get("selected_marble_id"))
	var marble_ids: PackedStringArray = customization.call("get_marble_ids")
	for marble_id_variant in marble_ids:
		var marble_id: String = str(marble_id_variant)
		var unlocked: bool = true
		if customization.has_method("is_marble_unlocked"):
			unlocked = bool(customization.call("is_marble_unlocked", marble_id))
		if unlocked:
			online_owned_marble_ids.append(marble_id)

	if selected_id != "" and online_owned_marble_ids.has(selected_id):
		online_selected_marble_id = selected_id
	elif online_selected_marble_id == "" or not online_owned_marble_ids.has(online_selected_marble_id):
		online_selected_marble_id = str(online_owned_marble_ids[0]) if not online_owned_marble_ids.is_empty() else ""


func _fill_online_marble_preview_frame(preset: Dictionary) -> void:
	_clear_node_children(online_marble_preview_frame)
	online_marble_preview_node = null
	online_marble_visual_node = null
	online_hologram_effects_root = null

	var preview: SubViewportContainer = _create_preview_viewport(Vector2i(1024, 1024), true)
	preview.mouse_filter = Control.MOUSE_FILTER_STOP
	if not preview.gui_input.is_connected(_on_online_marble_preview_gui_input):
		preview.gui_input.connect(_on_online_marble_preview_gui_input)
	online_marble_preview_frame.add_child(preview)
	preview.set_anchors_preset(Control.PRESET_FULL_RECT)

	var viewport: SubViewport = preview.get_node("PreviewViewport") as SubViewport
	if viewport == null:
		return
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS

	_build_online_marble_hologram_preview(viewport, preset)


func _build_online_marble_hologram_preview(viewport: SubViewport, preset: Dictionary) -> void:
	_clear_node_children(viewport)
	online_marble_preview_node = null
	online_marble_visual_node = null
	online_hologram_effects_root = null

	var environment_resource: Environment = Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color(0.0, 0.0, 0.0, 0.0)
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_resource.ambient_light_color = Color(0.74, 0.78, 1.0, 1.0)
	environment_resource.ambient_light_energy = 1.0
	environment_resource.glow_enabled = false
	environment_resource.glow_intensity = 0.0
	environment_resource.glow_bloom = 0.0
	environment_resource.tonemap_mode = Environment.TONE_MAPPER_LINEAR

	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = environment_resource
	viewport.add_child(environment)

	var root: Node3D = Node3D.new()
	root.name = "OnlineMarbleHologramRoot"
	viewport.add_child(root)

	var camera: Camera3D = Camera3D.new()
	camera.current = true
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 4.4
	camera.position = Vector3(0.0, 0.0, 6.0)
	camera.look_at(Vector3(0.0, 0.0, 0.0), Vector3.UP)
	root.add_child(camera)

	var key_light: DirectionalLight3D = DirectionalLight3D.new()
	key_light.rotation_degrees = Vector3(-42.0, 32.0, 0.0)
	key_light.light_color = Color(0.94, 0.98, 1.0, 1.0)
	key_light.light_energy = 0.85
	key_light.shadow_enabled = false
	root.add_child(key_light)

	var front_light: OmniLight3D = OmniLight3D.new()
	front_light.position = Vector3(0.0, 0.8, 2.7)
	front_light.light_color = Color(0.9, 0.96, 1.0, 1.0)
	front_light.light_energy = 0.45
	front_light.omni_range = 6.0
	root.add_child(front_light)

	var purple_rim: OmniLight3D = OmniLight3D.new()
	purple_rim.position = Vector3(-2.0, 1.1, 0.6)
	purple_rim.light_color = Color(0.78, 0.24, 1.0, 1.0)
	purple_rim.light_energy = 0.0
	purple_rim.omni_range = 5.0
	root.add_child(purple_rim)

	var gold_rim: OmniLight3D = OmniLight3D.new()
	gold_rim.position = Vector3(2.1, 0.8, 1.2)
	gold_rim.light_color = Color(1.0, 0.68, 0.22, 1.0)
	gold_rim.light_energy = 0.0
	gold_rim.omni_range = 4.8
	root.add_child(gold_rim)

	var effects_root: Node3D = Node3D.new()
	effects_root.name = "OnlineHologramEffects"
	root.add_child(effects_root)
	_add_online_hologram_effects(effects_root)
	online_hologram_effects_root = effects_root

	var marble_anchor: Node3D = Node3D.new()
	marble_anchor.name = "OnlineCenteredMarble"
	marble_anchor.position = Vector3.ZERO
	root.add_child(marble_anchor)
	var marble: Node3D = _create_online_fixed_hologram_marble(preset)
	marble_anchor.add_child(marble)
	marble.rotation_degrees = Vector3(-5, 18, 0)
	online_marble_preview_node = marble_anchor
	online_marble_visual_node = marble


func _add_online_hologram_effects(parent: Node3D) -> void:
	return
	var colors: Array[Color] = [
		Color(0.68, 0.18, 1.0, 0.58),
		Color(1.0, 0.58, 0.16, 0.5),
		Color(0.42, 0.82, 1.0, 0.38)
	]
	for index in range(3):
		var ring: MeshInstance3D = MeshInstance3D.new()
		var ring_mesh: TorusMesh = TorusMesh.new()
		ring_mesh.inner_radius = 0.94 + float(index) * 0.13
		ring_mesh.outer_radius = ring_mesh.inner_radius + 0.025
		ring.mesh = ring_mesh
		ring.position = Vector3(0.0, -0.02 + float(index) * 0.03, -0.04)
		ring.rotation_degrees = Vector3(78.0, 0.0, -18.0 + float(index) * 15.0)
		var ring_material := _make_online_hologram_material(colors[index], 1.45 - float(index) * 0.18)
		ring.material_override = ring_material
		parent.add_child(ring)

	for index in range(8):
		var spark: MeshInstance3D = MeshInstance3D.new()
		var spark_mesh: BoxMesh = BoxMesh.new()
		spark_mesh.size = Vector3(0.34, 0.035, 0.035)
		spark.mesh = spark_mesh
		var angle: float = TAU * float(index) / 8.0
		var radius: float = 0.98 + 0.18 * float(index % 3)
		spark.position = Vector3(cos(angle) * radius, sin(angle * 1.7) * 0.34, sin(angle) * 0.24)
		spark.rotation_degrees = Vector3(0.0, rad_to_deg(angle), -22.0 + float(index % 4) * 14.0)
		var spark_color: Color = colors[index % colors.size()]
		spark.material_override = _make_online_hologram_material(spark_color, 1.25)
		parent.add_child(spark)


func _make_online_hologram_material(color: Color, emission_energy: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = Color(color.r, color.g, color.b, 1.0)
	material.emission_energy_multiplier = emission_energy
	return material


func _create_online_fixed_hologram_marble(preset: Dictionary) -> Node3D:
	var palette: Dictionary = preset.get("palette", {})
	var marble := MeshInstance3D.new()
	marble.name = "OnlineSelectedMarble"
	var sphere := SphereMesh.new()
	sphere.radius = 0.72
	sphere.height = 1.44
	sphere.radial_segments = 96
	sphere.rings = 48
	marble.mesh = sphere

	var material := StandardMaterial3D.new()
	var base_color: Color = palette.get("shell_base_color", Color(0.18, 0.04, 0.32, 1.0))
	var accent_color: Color = palette.get("shell_swirl_blue", palette.get("emission_color", Color(0.72, 0.24, 1.0, 1.0)))
	material.albedo_color = base_color
	material.metallic = 0.38
	material.roughness = 0.13
	material.emission_enabled = true
	material.emission = accent_color
	material.emission_energy_multiplier = 0.22
	marble.material_override = material

	var stripe := MeshInstance3D.new()
	stripe.name = "OnlineMarbleBand"
	var torus := TorusMesh.new()
	torus.inner_radius = 0.56
	torus.outer_radius = 0.61
	stripe.mesh = torus
	stripe.rotation_degrees = Vector3(72.0, 0.0, -24.0)
	var stripe_material := StandardMaterial3D.new()
	stripe_material.albedo_color = accent_color
	stripe_material.emission_enabled = true
	stripe_material.emission = accent_color
	stripe_material.emission_energy_multiplier = 0.65
	stripe.material_override = stripe_material
	marble.add_child(stripe)
	return marble


func _create_online_marble_node_from_preset(preset: Dictionary) -> Node3D:
	var palette: Dictionary = preset.get("palette", {})
	var marble: Node3D = _create_preview_marble_node(palette, 1.0)
	if marble != null:
		marble.name = "OnlineSelectedMarble"
	return marble


func _force_configure_imported_marble_models(root: Node) -> void:
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		if current.has_method("_configure_model"):
			current.call("_configure_model")
		for child in current.get_children():
			stack.append(child)


func _fit_online_marble_to_preview(marble: Node3D) -> void:
	if marble == null:
		return

	marble.position = Vector3.ZERO
	var bounds: AABB = _get_node_3d_bounds(marble)
	if bounds.size.length() <= 0.001:
		marble.scale = Vector3.ONE * 1.15
		return

	var center: Vector3 = bounds.position + bounds.size * 0.5
	marble.global_position -= center

	bounds = _get_node_3d_bounds(marble)
	var largest_span: float = maxf(bounds.size.x, maxf(bounds.size.y, bounds.size.z))
	if largest_span > 0.001:
		var fit_scale: float = 1.15 / largest_span
		marble.scale *= fit_scale

	bounds = _get_node_3d_bounds(marble)
	center = bounds.position + bounds.size * 0.5
	marble.global_position -= center


func _refit_online_marble_preview() -> void:
	if online_marble_visual_node == null or not is_instance_valid(online_marble_visual_node):
		return
	_force_configure_imported_marble_models(online_marble_visual_node)
	_fit_online_marble_to_preview(online_marble_visual_node)
	_ensure_online_marble_has_visible_mesh(online_marble_preview_node, online_marble_visual_node)
	online_marble_visual_node.rotation_degrees = Vector3(-5, 18, 0)
	if online_marble_preview_node != null and is_instance_valid(online_marble_preview_node):
		online_marble_preview_node.position = Vector3.ZERO
		online_marble_preview_node.rotation = Vector3.ZERO


func _ensure_online_marble_has_visible_mesh(anchor: Node3D, marble: Node3D) -> void:
	if anchor == null or marble == null:
		return
	var bounds: AABB = _get_node_3d_bounds(marble)
	if bounds.size.length() > 0.001:
		var fallback: Node = anchor.get_node_or_null("OnlineFallbackMarble")
		if fallback != null:
			fallback.queue_free()
		return
	if anchor.get_node_or_null("OnlineFallbackMarble") != null:
		return

	var fallback_marble := MeshInstance3D.new()
	fallback_marble.name = "OnlineFallbackMarble"
	var sphere := SphereMesh.new()
	sphere.radius = 0.58
	sphere.height = 1.16
	fallback_marble.mesh = sphere
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.18, 0.04, 0.32, 1.0)
	material.metallic = 0.04
	material.roughness = 0.68
	material.emission_enabled = false
	material.emission_energy_multiplier = 0.0
	fallback_marble.material_override = material
	anchor.add_child(fallback_marble)


func _process_online_marble_preview(delta: float) -> void:
	if online_marble_preview_node == null:
		return
	if not online_marble_dragging:
		online_marble_preview_node.rotate_y(delta * 0.24)
	if online_hologram_effects_root != null:
		online_hologram_effects_root.rotate_y(-delta * 0.28)
		online_hologram_effects_root.rotate_z(delta * 0.08)


func _process_customize_preview_spin(delta: float) -> void:
	if customize_preview_marble_node == null or customize_preview_dragging:
		return
	customize_preview_marble_node.rotate_y(delta * 0.18)


func _on_online_marble_preview_gui_input(event: InputEvent) -> void:
	if online_owned_marble_ids.size() <= 1:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			online_marble_dragging = true
			online_marble_drag_start = event.position
			online_marble_drag_last = event.position
		else:
			_finish_online_marble_swipe(event.position)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventScreenDrag and online_marble_dragging:
		online_marble_drag_last = event.position
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			online_marble_dragging = true
			online_marble_drag_start = event.position
			online_marble_drag_last = event.position
		else:
			_finish_online_marble_swipe(event.position)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and online_marble_dragging:
		online_marble_drag_last = event.position
		get_viewport().set_input_as_handled()


func _finish_online_marble_swipe(release_position: Vector2) -> void:
	if not online_marble_dragging:
		return
	online_marble_dragging = false
	var drag_delta: Vector2 = release_position - online_marble_drag_start
	if absf(drag_delta.x) < 46.0 or absf(drag_delta.x) < absf(drag_delta.y):
		return
	_cycle_online_marble(1 if drag_delta.x < 0.0 else -1)


func _cycle_online_marble(step: int) -> void:
	if online_owned_marble_ids.is_empty():
		return
	var current_index: int = online_owned_marble_ids.find(online_selected_marble_id)
	if current_index < 0:
		current_index = 0
	current_index = posmod(current_index + step, online_owned_marble_ids.size())
	online_selected_marble_id = str(online_owned_marble_ids[current_index])
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("set_selected_marble"):
		customization.call("set_selected_marble", online_selected_marble_id)
	_refresh_online_marble_display()


func _create_online_top_button(button_text: String, accent_color: Color) -> Button:
	var button: Button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(80 if button_text == "BACK" else 98, 52)
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_style_online_button(button, accent_color, 15)
	return button


func _create_online_side_button(button_text: String, accent_color: Color) -> Button:
	var button: Button = Button.new()
	button.text = button_text
	button.custom_minimum_size = Vector2(138, 74)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(button, accent_color, 14)
	return button


func _style_online_button(button: Button, accent_color: Color, font_size: int) -> void:
	if button == null:
		return
	button.flat = false
	button.focus_mode = Control.FOCUS_NONE
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", font_size)
	button.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", accent_color.lightened(0.24))
	button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.75))
	button.add_theme_constant_override("shadow_outline_size", 3)
	button.add_theme_stylebox_override("normal", _make_online_card_style(Color(0.02, 0.04, 0.08, 0.74), accent_color, 12))
	button.add_theme_stylebox_override("hover", _make_online_card_style(Color(0.04, 0.08, 0.13, 0.84), accent_color.lightened(0.16), 12))
	button.add_theme_stylebox_override("pressed", _make_online_card_style(Color(0.01, 0.03, 0.06, 0.92), accent_color.darkened(0.12), 12))


func _style_online_option_button(button: OptionButton, accent_color: Color) -> void:
	if button == null:
		return
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_override("font", ui_font)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(1.0, 1.0, 1.0, 1.0))
	button.add_theme_color_override("font_pressed_color", accent_color.lightened(0.22))
	button.add_theme_stylebox_override("normal", _make_online_card_style(Color(0.02, 0.05, 0.08, 0.86), accent_color, 12))
	button.add_theme_stylebox_override("hover", _make_online_card_style(Color(0.04, 0.08, 0.13, 0.93), accent_color.lightened(0.14), 12))
	button.add_theme_stylebox_override("pressed", _make_online_card_style(Color(0.01, 0.03, 0.06, 0.98), accent_color.darkened(0.1), 12))


func _style_online_line_edit(line_edit: LineEdit, accent_color: Color) -> void:
	if line_edit == null:
		return
	line_edit.add_theme_font_override("font", ui_font)
	line_edit.add_theme_font_size_override("font_size", 18)
	line_edit.add_theme_color_override("font_color", Color(0.98, 0.98, 1.0, 1.0))
	line_edit.add_theme_color_override("font_placeholder_color", Color(0.72, 0.78, 0.9, 0.8))
	line_edit.add_theme_stylebox_override("normal", _make_online_card_style(Color(0.02, 0.05, 0.08, 0.86), accent_color, 12))
	line_edit.add_theme_stylebox_override("focus", _make_online_card_style(Color(0.04, 0.08, 0.13, 0.96), accent_color.lightened(0.16), 12))


func _make_online_card_style(fill_color: Color, border_color: Color, corner_radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.shadow_color = border_color.darkened(0.72)
	style.shadow_size = 12
	style.shadow_offset = Vector2(0, 6)
	style.content_margin_left = 16.0
	style.content_margin_top = 12.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 12.0
	style.anti_aliasing = true
	return style


func _ensure_online_loading_panel() -> void:
	online_loading_panel = Panel.new()
	online_loading_panel.name = "OnlineLoadingPanel"
	online_loading_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	online_loading_panel.z_index = 500
	online_loading_panel.set_as_top_level(true)
	online_loading_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	online_loading_panel.hide()
	online_loading_panel.add_theme_stylebox_override("panel", _make_menu_panel_style(
		Color(0.005, 0.012, 0.035, 0.98),
		Color(0.31, 0.97, 0.85, 0.88)
	))
	online_rooms_page.add_child(online_loading_panel)
	if not online_loading_panel.visibility_changed.is_connected(_on_online_loading_panel_visibility_changed):
		online_loading_panel.visibility_changed.connect(_on_online_loading_panel_visibility_changed)

	online_loading_background = TextureRect.new()
	online_loading_background.name = "OnlineLoadingBackground"
	online_loading_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	online_loading_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	online_loading_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	online_loading_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_loading_background.texture = _load_online_loading_texture()
	online_loading_panel.add_child(online_loading_background)

	online_loading_video_player = VideoStreamPlayer.new()
	online_loading_video_player.name = "OnlineLoadingVideo"
	online_loading_video_player.set_anchors_preset(Control.PRESET_FULL_RECT)
	online_loading_video_player.expand = true
	online_loading_video_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_loading_video_player.volume_db = -80.0
	online_loading_video_player.stream = _load_online_loading_video()
	online_loading_video_player.visible = online_loading_video_player.stream != null
	online_loading_panel.add_child(online_loading_video_player)
	if not online_loading_video_player.finished.is_connected(_on_online_loading_video_finished):
		online_loading_video_player.finished.connect(_on_online_loading_video_finished)

	var loading_shade: ColorRect = ColorRect.new()
	loading_shade.name = "OnlineLoadingShade"
	loading_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	loading_shade.color = Color(0.0, 0.0, 0.0, 0.18)
	loading_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	online_loading_panel.add_child(loading_shade)

	var loading_viewport_size: Vector2 = get_viewport_rect().size
	var loading_margin_x: int = 24 if loading_viewport_size.x < 820.0 else 42
	var loading_margin_y: int = 24 if loading_viewport_size.y < 760.0 else 38
	var loading_panel_width: float = minf(maxf(300.0, loading_viewport_size.x - float(loading_margin_x * 2)), 960.0)
	var loading_panel_height: float = minf(maxf(328.0, loading_viewport_size.y * 0.48), maxf(300.0, loading_viewport_size.y - float(loading_margin_y * 2)))
	var compact_loading_ui: bool = loading_viewport_size.y < 760.0 or loading_panel_width < 760.0

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", loading_margin_x)
	margin.add_theme_constant_override("margin_top", loading_margin_y)
	margin.add_theme_constant_override("margin_right", loading_margin_x)
	margin.add_theme_constant_override("margin_bottom", loading_margin_y)
	online_loading_panel.add_child(margin)

	var outer_stack: VBoxContainer = VBoxContainer.new()
	outer_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_stack.alignment = BoxContainer.ALIGNMENT_END
	margin.add_child(outer_stack)

	var info_panel: Panel = Panel.new()
	info_panel.name = "OnlineLoadingInfoPanel"
	online_loading_info_panel = info_panel
	info_panel.custom_minimum_size = Vector2(loading_panel_width, loading_panel_height)
	info_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	info_panel.add_theme_stylebox_override("panel", _make_menu_panel_style(
		Color(0.005, 0.012, 0.035, 0.54),
		Color(0.31, 0.97, 0.85, 0.82)
	))
	outer_stack.add_child(info_panel)

	var info_margin: MarginContainer = MarginContainer.new()
	info_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	info_margin.add_theme_constant_override("margin_left", 20)
	info_margin.add_theme_constant_override("margin_top", 12)
	info_margin.add_theme_constant_override("margin_right", 20)
	info_margin.add_theme_constant_override("margin_bottom", 12)
	info_panel.add_child(info_margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 7 if compact_loading_ui else 9)
	info_margin.add_child(stack)

	online_loading_title_label = Label.new()
	online_loading_title_label.text = "LOADING MATCH"
	online_loading_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_loading_title_label.add_theme_font_override("font", title_font)
	online_loading_title_label.add_theme_font_size_override("font_size", 28 if compact_loading_ui else 32)
	online_loading_title_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	online_loading_title_label.clip_text = true
	stack.add_child(online_loading_title_label)

	online_loading_marble_label = Label.new()
	online_loading_marble_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_loading_marble_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_loading_marble_label.add_theme_font_override("font", ui_font)
	online_loading_marble_label.add_theme_font_size_override("font_size", 17 if compact_loading_ui else 19)
	online_loading_marble_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.42, 0.98))
	online_loading_marble_label.hide()
	stack.add_child(online_loading_marble_label)

	online_loading_slots_grid = GridContainer.new()
	online_loading_slots_grid.name = "OnlineLoadingSlotsGrid"
	online_loading_slots_grid.columns = 5 if loading_panel_width >= 720.0 else (3 if loading_panel_width >= 520.0 else 2)
	online_loading_slots_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_loading_slots_grid.add_theme_constant_override("h_separation", 8)
	online_loading_slots_grid.add_theme_constant_override("v_separation", 8)
	online_loading_slots_grid.hide()
	stack.add_child(online_loading_slots_grid)

	online_loading_slot_name_labels.clear()
	online_loading_slot_status_labels.clear()
	for slot_index in range(5):
		var slot_panel: Panel = Panel.new()
		slot_panel.name = "OnlineSlot%d" % (slot_index + 1)
		slot_panel.custom_minimum_size = Vector2(104 if online_loading_slots_grid.columns == 5 else 120, 70 if compact_loading_ui else 78)
		slot_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		slot_panel.add_theme_stylebox_override("panel", _make_button_style(Color(0.03, 0.07, 0.1, 0.78), Color(0.31, 0.97, 0.85, 0.42)))
		online_loading_slots_grid.add_child(slot_panel)

		var slot_margin: MarginContainer = MarginContainer.new()
		slot_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
		slot_margin.add_theme_constant_override("margin_left", 8)
		slot_margin.add_theme_constant_override("margin_top", 6)
		slot_margin.add_theme_constant_override("margin_right", 8)
		slot_margin.add_theme_constant_override("margin_bottom", 6)
		slot_panel.add_child(slot_margin)

		var slot_stack: VBoxContainer = VBoxContainer.new()
		slot_stack.alignment = BoxContainer.ALIGNMENT_CENTER
		slot_stack.add_theme_constant_override("separation", 4)
		slot_margin.add_child(slot_stack)

		var slot_name_label: Label = Label.new()
		slot_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		slot_name_label.add_theme_font_override("font", ui_font)
		slot_name_label.add_theme_font_size_override("font_size", 15 if compact_loading_ui else 16)
		slot_name_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
		slot_stack.add_child(slot_name_label)
		online_loading_slot_name_labels.append(slot_name_label)

		var slot_status_label: Label = Label.new()
		slot_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		slot_status_label.add_theme_font_override("font", ui_font)
		slot_status_label.add_theme_font_size_override("font_size", 11 if compact_loading_ui else 12)
		slot_status_label.add_theme_color_override("font_color", Color(0.31, 0.97, 0.85, 0.95))
		slot_stack.add_child(slot_status_label)
		online_loading_slot_status_labels.append(slot_status_label)

	online_loading_players_label = Label.new()
	online_loading_players_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_loading_players_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_loading_players_label.add_theme_font_override("font", ui_font)
	online_loading_players_label.add_theme_font_size_override("font_size", 18 if compact_loading_ui else 20)
	online_loading_players_label.add_theme_color_override("font_color", Color(0.86, 0.95, 1.0, 0.98))
	online_loading_players_label.hide()
	stack.add_child(online_loading_players_label)

	online_loading_status_label = Label.new()
	online_loading_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	online_loading_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	online_loading_status_label.add_theme_font_override("font", ui_font)
	online_loading_status_label.add_theme_font_size_override("font_size", 15 if compact_loading_ui else 17)
	online_loading_status_label.add_theme_color_override("font_color", Color(0.31, 0.97, 0.85, 0.98))
	stack.add_child(online_loading_status_label)

	online_loading_progress_bar = ProgressBar.new()
	online_loading_progress_bar.name = "OnlineLoadingProgress"
	online_loading_progress_bar.min_value = 0.0
	online_loading_progress_bar.max_value = 100.0
	online_loading_progress_bar.value = 0.0
	online_loading_progress_bar.show_percentage = false
	online_loading_progress_bar.custom_minimum_size = Vector2(0, 18 if compact_loading_ui else 22)
	online_loading_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_loading_progress_bar.add_theme_stylebox_override("background", _make_online_card_style(Color(0.01, 0.02, 0.045, 0.92), Color(0.31, 0.97, 0.85, 0.78), 10))
	online_loading_progress_bar.add_theme_stylebox_override("fill", _make_online_card_style(Color(1.0, 0.74, 0.18, 0.98), Color(0.95, 0.22, 1.0, 0.92), 10))
	stack.add_child(online_loading_progress_bar)

	var loading_button_row: HBoxContainer = HBoxContainer.new()
	loading_button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	loading_button_row.alignment = BoxContainer.ALIGNMENT_CENTER
	loading_button_row.add_theme_constant_override("separation", 12)
	stack.add_child(loading_button_row)

	online_loading_start_button = Button.new()
	online_loading_start_button.name = "OnlineLoadingStartButton"
	online_loading_start_button.text = "START GAME"
	online_loading_start_button.custom_minimum_size = Vector2(190, 52)
	online_loading_start_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(online_loading_start_button, Color(1.0, 0.82, 0.2, 1.0), 15)
	online_loading_start_button.hide()
	loading_button_row.add_child(online_loading_start_button)
	if not online_loading_start_button.pressed.is_connected(_on_online_start_pressed):
		online_loading_start_button.pressed.connect(_on_online_start_pressed)

	online_loading_cancel_button = Button.new()
	online_loading_cancel_button.name = "OnlineLoadingCancelButton"
	online_loading_cancel_button.text = "CANCEL"
	online_loading_cancel_button.custom_minimum_size = Vector2(180, 52)
	online_loading_cancel_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_button(online_loading_cancel_button, Color(0.95, 0.2, 0.16, 1.0), 15)
	loading_button_row.add_child(online_loading_cancel_button)
	if not online_loading_cancel_button.pressed.is_connected(_on_online_loading_cancel_pressed):
		online_loading_cancel_button.pressed.connect(_on_online_loading_cancel_pressed)

	_build_online_loading_chat()


func _on_online_loading_panel_visibility_changed() -> void:
	if online_loading_panel != null and online_loading_panel.visible:
		online_loading_chat_visible = false
		_sync_online_loading_chat_visibility()
		_play_online_loading_entry_transition()
		_play_online_loading_video()
	else:
		_stop_online_loading_video()
		_stop_online_loading_entry_transition()


func _play_online_loading_entry_transition() -> void:
	if online_loading_panel == null:
		return
	_stop_online_loading_entry_transition(false)
	online_loading_panel.modulate = Color(1.0, 1.0, 1.0, 0.0)
	if online_loading_info_panel != null:
		online_loading_info_panel.scale = Vector2(0.96, 0.96)
		online_loading_info_panel.pivot_offset = online_loading_info_panel.size * 0.5

	online_loading_transition_tween = create_tween()
	online_loading_transition_tween.set_parallel(true)
	online_loading_transition_tween.set_trans(Tween.TRANS_SINE)
	online_loading_transition_tween.set_ease(Tween.EASE_OUT)
	online_loading_transition_tween.tween_property(online_loading_panel, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.42)
	if online_loading_info_panel != null:
		online_loading_transition_tween.tween_property(online_loading_info_panel, "scale", Vector2.ONE, 0.46)


func _stop_online_loading_entry_transition(reset_alpha: bool = true) -> void:
	if online_loading_transition_tween != null and online_loading_transition_tween.is_valid():
		online_loading_transition_tween.kill()
	online_loading_transition_tween = null
	if reset_alpha and online_loading_panel != null:
		online_loading_panel.modulate = Color(1.0, 1.0, 1.0, 1.0)
	if reset_alpha and online_loading_info_panel != null:
		online_loading_info_panel.scale = Vector2.ONE


func _play_online_loading_video() -> void:
	if online_loading_video_player == null or online_loading_video_player.stream == null:
		return
	online_loading_video_player.show()
	online_loading_video_player.play()


func _stop_online_loading_video() -> void:
	if online_loading_video_player == null:
		return
	online_loading_video_player.stop()


func _on_online_loading_video_finished() -> void:
	if online_loading_panel == null or not online_loading_panel.visible:
		return
	_play_online_loading_video()


func _build_online_loading_chat() -> void:
	if online_loading_panel == null:
		return

	var chat_panel: Panel = Panel.new()
	chat_panel.name = "OnlineLoadingChatPanel"
	online_loading_chat_panel = chat_panel
	chat_panel.anchor_left = 1.0
	chat_panel.anchor_top = 1.0
	chat_panel.anchor_right = 1.0
	chat_panel.anchor_bottom = 1.0
	var loading_chat_width: float = clampf(get_viewport_rect().size.x * 0.32, 320.0, 420.0)
	chat_panel.offset_left = -loading_chat_width - 42.0
	chat_panel.offset_top = -280.0
	chat_panel.offset_right = -42.0
	chat_panel.offset_bottom = -42.0
	chat_panel.z_index = 40
	chat_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	chat_panel.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.015, 0.025, 0.055, 0.88), Color(0.72, 0.36, 1.0, 0.88), 10))
	online_loading_panel.add_child(chat_panel)

	var panel_margin: MarginContainer = MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.add_theme_constant_override("margin_left", 14)
	panel_margin.add_theme_constant_override("margin_top", 12)
	panel_margin.add_theme_constant_override("margin_right", 14)
	panel_margin.add_theme_constant_override("margin_bottom", 12)
	chat_panel.add_child(panel_margin)

	var panel_stack: VBoxContainer = VBoxContainer.new()
	panel_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_stack.add_theme_constant_override("separation", 8)
	panel_margin.add_child(panel_stack)

	var title_row: HBoxContainer = HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 8)
	panel_stack.add_child(title_row)

	online_loading_chat_title_label = _create_online_text_label("PARTY CHAT", 14, Color(0.96, 0.99, 1.0, 0.96), ui_font)
	online_loading_chat_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_loading_chat_title_label.clip_text = true
	title_row.add_child(online_loading_chat_title_label)

	var hide_button: Button = Button.new()
	hide_button.text = "HIDE"
	hide_button.custom_minimum_size = Vector2(64, 30)
	_style_online_button(hide_button, Color(0.72, 0.36, 1.0, 1.0), 11)
	title_row.add_child(hide_button)
	hide_button.pressed.connect(_toggle_online_loading_chat)

	var chat_scroll: ScrollContainer = ScrollContainer.new()
	chat_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	chat_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	chat_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel_stack.add_child(chat_scroll)

	online_loading_chat_log_stack = VBoxContainer.new()
	online_loading_chat_log_stack.name = "OnlineLoadingChatLog"
	online_loading_chat_log_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	online_loading_chat_log_stack.add_theme_constant_override("separation", 7)
	chat_scroll.add_child(online_loading_chat_log_stack)

	var chat_input_row: HBoxContainer = HBoxContainer.new()
	chat_input_row.add_theme_constant_override("separation", 8)
	panel_stack.add_child(chat_input_row)

	online_loading_chat_input = LineEdit.new()
	online_loading_chat_input.name = "OnlineLoadingChatInput"
	online_loading_chat_input.placeholder_text = "MESSAGE"
	online_loading_chat_input.max_length = 160
	online_loading_chat_input.custom_minimum_size = Vector2(0, 42)
	online_loading_chat_input.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_online_line_edit(online_loading_chat_input, Color(0.72, 0.36, 1.0, 1.0))
	chat_input_row.add_child(online_loading_chat_input)

	online_loading_chat_send_button = Button.new()
	online_loading_chat_send_button.name = "OnlineLoadingChatSendButton"
	online_loading_chat_send_button.text = "SEND"
	online_loading_chat_send_button.custom_minimum_size = Vector2(78, 42)
	_style_online_button(online_loading_chat_send_button, Color(0.31, 0.97, 0.85, 1.0), 13)
	chat_input_row.add_child(online_loading_chat_send_button)

	if not online_loading_chat_send_button.pressed.is_connected(_on_online_loading_chat_send_pressed):
		online_loading_chat_send_button.pressed.connect(_on_online_loading_chat_send_pressed)
	if not online_loading_chat_input.text_submitted.is_connected(_on_online_loading_chat_submitted):
		online_loading_chat_input.text_submitted.connect(_on_online_loading_chat_submitted)

	online_loading_chat_toggle_button = Button.new()
	online_loading_chat_toggle_button.name = "OnlineLoadingChatToggleButton"
	online_loading_chat_toggle_button.anchor_left = 1.0
	online_loading_chat_toggle_button.anchor_top = 0.0
	online_loading_chat_toggle_button.anchor_right = 1.0
	online_loading_chat_toggle_button.anchor_bottom = 0.0
	online_loading_chat_toggle_button.offset_left = -126.0
	online_loading_chat_toggle_button.offset_top = 42.0
	online_loading_chat_toggle_button.offset_right = -42.0
	online_loading_chat_toggle_button.offset_bottom = 88.0
	online_loading_chat_toggle_button.z_index = 41
	online_loading_chat_toggle_button.text = "CHAT"
	online_loading_chat_toggle_button.tooltip_text = "Open party chat"
	_style_online_button(online_loading_chat_toggle_button, Color(0.31, 0.97, 0.85, 1.0), 13)
	online_loading_panel.add_child(online_loading_chat_toggle_button)
	online_loading_chat_toggle_button.pressed.connect(_toggle_online_loading_chat)
	_sync_online_loading_chat_visibility()


func _toggle_online_loading_chat() -> void:
	online_loading_chat_visible = not online_loading_chat_visible
	_sync_online_loading_chat_visibility()
	if online_loading_chat_visible and online_loading_chat_input != null:
		online_loading_chat_input.grab_focus()


func _sync_online_loading_chat_visibility(room_data = null) -> void:
	if online_loading_chat_panel != null:
		online_loading_chat_panel.visible = online_loading_chat_visible
	if online_loading_chat_toggle_button != null:
		online_loading_chat_toggle_button.visible = not online_loading_chat_visible
	if online_loading_chat_title_label != null:
		online_loading_chat_title_label.text = _get_online_loading_chat_title(room_data)


func _get_online_loading_chat_title(room_data = null) -> String:
	var room: Dictionary = room_data if typeof(room_data) == TYPE_DICTIONARY else {}
	if room.is_empty():
		var online: Node = get_node_or_null("/root/MultiplayerManager")
		if online != null and online.has_method("get_room"):
			room = online.call("get_room")

	var players: Array = room.get("players", [])
	var player_names: PackedStringArray = PackedStringArray()
	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = player as Dictionary
		if bool(player_data.get("is_ai", false)):
			continue
		var player_name: String = str(player_data.get("name", "Player")).strip_edges()
		if player_name == "":
			player_name = "Player"
		player_names.append(player_name.to_upper())
		if player_names.size() >= 3:
			break
	if not player_names.is_empty():
		if players.size() > player_names.size():
			player_names.append("+%d" % (players.size() - player_names.size()))
		return "PARTY CHAT // %s" % ", ".join(player_names)

	var code: String = _get_online_room_code(room) if not room.is_empty() else ""
	if code != "":
		return "PARTY CHAT // %s" % code
	return "PARTY CHAT"


func _ensure_startup_loading_panel() -> void:
	if startup_loading_panel != null and is_instance_valid(startup_loading_panel):
		return

	startup_loading_panel = Panel.new()
	startup_loading_panel.name = "StartupLoadingPanel"
	startup_loading_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	startup_loading_panel.z_index = 920
	startup_loading_panel.set_as_top_level(true)
	startup_loading_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	startup_loading_panel.hide()
	startup_loading_panel.add_theme_stylebox_override("panel", _make_menu_panel_style(
		Color(0.005, 0.012, 0.035, 0.98),
		Color(0.31, 0.97, 0.85, 0.88)
	))
	add_child(startup_loading_panel)

	startup_loading_background = TextureRect.new()
	startup_loading_background.name = "StartupLoadingBackground"
	startup_loading_background.set_anchors_preset(Control.PRESET_FULL_RECT)
	startup_loading_background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	startup_loading_background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	startup_loading_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	startup_loading_background.texture = _load_online_loading_texture()
	startup_loading_panel.add_child(startup_loading_background)

	var loading_shade: ColorRect = ColorRect.new()
	loading_shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	loading_shade.color = Color(0.0, 0.0, 0.0, 0.12)
	loading_shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	startup_loading_panel.add_child(loading_shade)

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 42)
	margin.add_theme_constant_override("margin_top", 38)
	margin.add_theme_constant_override("margin_right", 42)
	margin.add_theme_constant_override("margin_bottom", 38)
	startup_loading_panel.add_child(margin)

	var outer_stack: VBoxContainer = VBoxContainer.new()
	outer_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer_stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	outer_stack.alignment = BoxContainer.ALIGNMENT_END
	margin.add_child(outer_stack)

	var info_panel: Panel = Panel.new()
	info_panel.custom_minimum_size = Vector2(clampf(get_viewport_rect().size.x - 120.0, 360.0, 640.0), 142.0)
	info_panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	info_panel.add_theme_stylebox_override("panel", _make_menu_panel_style(
		Color(0.005, 0.012, 0.035, 0.54),
		Color(0.31, 0.97, 0.85, 0.82)
	))
	outer_stack.add_child(info_panel)

	var info_margin: MarginContainer = MarginContainer.new()
	info_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	info_margin.add_theme_constant_override("margin_left", 22)
	info_margin.add_theme_constant_override("margin_top", 18)
	info_margin.add_theme_constant_override("margin_right", 22)
	info_margin.add_theme_constant_override("margin_bottom", 18)
	info_panel.add_child(info_margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 12)
	info_margin.add_child(stack)

	startup_loading_title_label = Label.new()
	startup_loading_title_label.text = "LOADING Bano ke"
	startup_loading_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_loading_title_label.add_theme_font_override("font", title_font)
	startup_loading_title_label.add_theme_font_size_override("font_size", 34)
	startup_loading_title_label.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
	stack.add_child(startup_loading_title_label)

	startup_loading_status_label = Label.new()
	startup_loading_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	startup_loading_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	startup_loading_status_label.add_theme_font_override("font", ui_font)
	startup_loading_status_label.add_theme_font_size_override("font_size", 18)
	startup_loading_status_label.add_theme_color_override("font_color", Color(0.31, 0.97, 0.85, 0.98))
	stack.add_child(startup_loading_status_label)

	startup_loading_progress_bar = ProgressBar.new()
	startup_loading_progress_bar.name = "StartupLoadingProgress"
	startup_loading_progress_bar.min_value = 0.0
	startup_loading_progress_bar.max_value = 100.0
	startup_loading_progress_bar.value = 0.0
	startup_loading_progress_bar.show_percentage = false
	startup_loading_progress_bar.custom_minimum_size = Vector2(0, 16)
	startup_loading_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	startup_loading_progress_bar.add_theme_stylebox_override("background", _make_online_card_style(Color(0.02, 0.02, 0.04, 0.78), Color(0.38, 0.18, 0.72, 0.55), 8))
	startup_loading_progress_bar.add_theme_stylebox_override("fill", _make_online_card_style(Color(0.78, 0.22, 1.0, 0.96), Color(1.0, 0.72, 0.22, 0.92), 8))
	stack.add_child(startup_loading_progress_bar)


func _show_startup_loading_once() -> void:
	if startup_loading_panel == null:
		return
	var root: Window = get_tree().root
	if root == null:
		return
	if bool(root.get_meta("bano_startup_loading_seen", false)):
		startup_loading_panel.hide()
		startup_loading_timer = -1.0
		return

	root.set_meta("bano_startup_loading_seen", true)
	startup_loading_timer = 0.0
	startup_server_ready = false
	startup_server_connection_started = false
	startup_loading_panel.show()
	_begin_startup_server_connection()
	_update_startup_loading_screen(0.0)


func _process_startup_loading(delta: float) -> void:
	if startup_loading_timer < 0.0 or startup_loading_panel == null or not startup_loading_panel.visible:
		return

	startup_loading_timer += delta
	var time_progress: float = clampf(startup_loading_timer / maxf(STARTUP_LOADING_MAX_SECONDS, 0.001), 0.0, 1.0)
	var minimum_progress: float = clampf(startup_loading_timer / maxf(STARTUP_LOADING_MIN_SECONDS, 0.001), 0.0, 1.0)
	var progress: float = maxf(time_progress, minimum_progress * (0.86 if not startup_server_ready else 1.0))
	_update_startup_loading_screen(progress)
	if startup_loading_timer >= STARTUP_LOADING_MIN_SECONDS and (startup_server_ready or startup_loading_timer >= STARTUP_LOADING_MAX_SECONDS):
		startup_loading_panel.hide()
		startup_loading_timer = -1.0


func _begin_startup_server_connection() -> void:
	if startup_server_connection_started:
		return
	startup_server_connection_started = true
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("connect_to_server"):
		startup_server_ready = true
		return
	online.call("connect_to_server", "", true)


func _update_startup_loading_screen(progress: float) -> void:
	var eased_progress: float = progress * progress * (3.0 - 2.0 * progress)
	if startup_loading_title_label != null:
		startup_loading_title_label.text = "LOADING Bano ke"
	if startup_loading_status_label != null:
		if progress < 0.34:
			startup_loading_status_label.text = "Warming up the arena lights..."
		elif progress < 0.72:
			startup_loading_status_label.text = "Connecting to online parties..."
		elif not startup_server_ready:
			startup_loading_status_label.text = "Waiting for the server..."
		else:
			startup_loading_status_label.text = "Opening the main menu..."
	if startup_loading_progress_bar != null:
		startup_loading_progress_bar.value = clampf(lerpf(6.0, 100.0, eased_progress), 0.0, 100.0)


func _rebuild_settings_popup_contents() -> void:
	for child in settings_popup.get_children():
		child.queue_free()

	online_server_input = null
	online_server_save_button = null

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "SettingsBackground"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.texture = load(BACKGROUND_PATH)
	background_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_popup.add_child(background_rect)

	var shade: ColorRect = ColorRect.new()
	shade.name = "SettingsShade"
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.24)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	settings_popup.add_child(shade)

	var root: MarginContainer = MarginContainer.new()
	root.name = "SettingsRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 34)
	root.add_theme_constant_override("margin_top", 26)
	root.add_theme_constant_override("margin_right", 34)
	root.add_theme_constant_override("margin_bottom", 38)
	settings_popup.add_child(root)

	var page: VBoxContainer = VBoxContainer.new()
	page.add_theme_constant_override("separation", 20)
	root.add_child(page)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 28)
	header.custom_minimum_size = Vector2(0, 74)
	page.add_child(header)

	settings_back_button = Button.new()
	settings_back_button.name = "CloseSettingsButton"
	settings_back_button.custom_minimum_size = Vector2(72, 62)
	settings_back_button.text = "<"
	settings_back_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	settings_back_button.add_theme_font_override("font", ui_font)
	settings_back_button.add_theme_font_size_override("font_size", 40)
	settings_back_button.add_theme_color_override("font_color", Color(0.98, 0.92, 1.0, 1.0))
	settings_back_button.add_theme_color_override("font_shadow_color", Color(0.76, 0.16, 1.0, 0.92))
	settings_back_button.add_theme_constant_override("shadow_offset_x", 0)
	settings_back_button.add_theme_constant_override("shadow_offset_y", 0)
	settings_back_button.add_theme_constant_override("shadow_outline_size", 10)
	settings_back_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.015, 0.005, 0.04, 0.74), Color(0.75, 0.2, 1.0, 0.92), 14))
	settings_back_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.035, 0.01, 0.08, 0.86), Color(0.94, 0.58, 1.0, 1.0), 14))
	settings_back_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.01, 0.0, 0.025, 0.96), Color(0.65, 0.1, 0.88, 1.0), 14))
	header.add_child(settings_back_button)

	var heading: Label = Label.new()
	heading.text = "SETTINGS"
	heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", title_font)
	heading.add_theme_font_size_override("font_size", 40)
	heading.add_theme_color_override("font_color", Color(0.98, 0.96, 1.0, 1.0))
	heading.add_theme_color_override("font_outline_color", Color(0.58, 0.16, 1.0, 0.95))
	heading.add_theme_color_override("font_shadow_color", Color(0.72, 0.2, 1.0, 0.9))
	heading.add_theme_constant_override("outline_size", 2)
	heading.add_theme_constant_override("shadow_offset_x", 0)
	heading.add_theme_constant_override("shadow_offset_y", 0)
	heading.add_theme_constant_override("shadow_outline_size", 11)
	header.add_child(heading)

	var panel: Panel = Panel.new()
	panel.name = "SettingsPanel"
	panel.custom_minimum_size = Vector2(960, 500)
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_settings_outer_panel_style())
	page.add_child(panel)

	var panel_margin: MarginContainer = MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.add_theme_constant_override("margin_left", 18)
	panel_margin.add_theme_constant_override("margin_top", 22)
	panel_margin.add_theme_constant_override("margin_right", 18)
	panel_margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(panel_margin)

	var rows: VBoxContainer = VBoxContainer.new()
	rows.add_theme_constant_override("separation", 14)
	panel_margin.add_child(rows)

	master_slider = _create_volume_slider("MasterSlider")
	rows.add_child(_create_settings_slider_row("MASTER VOLUME", "🔊", master_slider))

	music_slider = _create_volume_slider("MusicSlider")
	rows.add_child(_create_settings_slider_row("MUSIC VOLUME", "♪", music_slider))

	sfx_slider = _create_volume_slider("SFXSlider")
	rows.add_child(_create_settings_slider_row("SFX VOLUME", "▥", sfx_slider))

	shoot_sensitivity_slider = _create_sensitivity_slider("ShootSensitivitySlider")
	rows.add_child(_create_settings_slider_row("SHOOTING SENSITIVITY", "⌖", shoot_sensitivity_slider))

	aim_inversion_button = Button.new()
	aim_inversion_button.name = "AimInversionButton"
	rows.add_child(_create_settings_aim_inversion_row())

	shooting_mechanics_button = Button.new()
	shooting_mechanics_button.name = "ShootingMechanicsButton"
	shooting_mechanics_button.text = _get_selected_shooting_mechanic_name().to_upper()
	rows.add_child(_create_settings_mechanics_row())

	settings_account_button = Button.new()
	settings_account_button.name = "SettingsAccountButton"
	settings_account_button.text = "ACCOUNT / GOOGLE"
	rows.add_child(_create_settings_account_row())

	if not settings_back_button.pressed.is_connected(_hide_settings_popup):
		settings_back_button.pressed.connect(_hide_settings_popup)
	if not shooting_mechanics_button.pressed.is_connected(_on_shooting_mechanics_pressed):
		shooting_mechanics_button.pressed.connect(_on_shooting_mechanics_pressed)
	if not aim_inversion_button.pressed.is_connected(_on_aim_inversion_pressed):
		aim_inversion_button.pressed.connect(_on_aim_inversion_pressed)
	if not settings_account_button.pressed.is_connected(_on_settings_account_pressed):
		settings_account_button.pressed.connect(_on_settings_account_pressed)


func _create_settings_slider_row(label_text: String, icon_text: String, slider: HSlider) -> Panel:
	var row: Panel = _create_settings_row_panel()

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 10)
	row.add_child(margin)

	var content: HBoxContainer = HBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	margin.add_child(content)

	var icon_label: Label = _create_settings_icon_label(icon_text)
	content.add_child(icon_label)

	var title: Label = _create_settings_row_title(label_text)
	title.custom_minimum_size = Vector2(240, 0)
	content.add_child(title)

	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(0, 42)
	slider.add_theme_stylebox_override("slider", _make_settings_slider_track_style())
	slider.add_theme_stylebox_override("grabber_area", _make_settings_slider_fill_style())
	slider.add_theme_stylebox_override("grabber_area_highlight", _make_settings_slider_fill_style())
	slider.add_theme_icon_override("grabber", _create_settings_slider_grabber_texture(Color(0.98, 0.88, 1.0, 1.0)))
	slider.add_theme_icon_override("grabber_highlight", _create_settings_slider_grabber_texture(Color(1.0, 1.0, 1.0, 1.0)))
	content.add_child(slider)

	var percent_label: Label = Label.new()
	percent_label.name = "PercentLabel"
	percent_label.custom_minimum_size = Vector2(74, 0)
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	percent_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	percent_label.add_theme_font_override("font", ui_font)
	percent_label.add_theme_font_size_override("font_size", 22)
	percent_label.add_theme_color_override("font_color", Color(0.83, 0.43, 1.0, 1.0))
	percent_label.add_theme_color_override("font_shadow_color", Color(0.5, 0.04, 0.88, 0.8))
	percent_label.add_theme_constant_override("shadow_offset_x", 0)
	percent_label.add_theme_constant_override("shadow_offset_y", 0)
	percent_label.add_theme_constant_override("shadow_outline_size", 7)
	content.add_child(percent_label)
	slider.set_meta("percent_label", percent_label)
	return row


func _create_settings_aim_inversion_row() -> Panel:
	var row: Panel = _create_settings_row_panel()

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 10)
	row.add_child(margin)

	var content: HBoxContainer = HBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	margin.add_child(content)

	content.add_child(_create_settings_icon_label("A"))

	var title: Label = _create_settings_row_title("AIM INVERSION")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(title)

	aim_inversion_button.custom_minimum_size = Vector2(220, 50)
	aim_inversion_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	aim_inversion_button.add_theme_font_override("font", ui_font)
	aim_inversion_button.add_theme_font_size_override("font_size", 20)
	aim_inversion_button.add_theme_color_override("font_color", Color(0.98, 0.96, 1.0, 1.0))
	aim_inversion_button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	aim_inversion_button.add_theme_constant_override("shadow_offset_y", 2)
	aim_inversion_button.add_theme_constant_override("shadow_outline_size", 4)
	aim_inversion_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.02, 0.005, 0.045, 0.82), Color(0.84, 0.24, 1.0, 0.92), 10))
	aim_inversion_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.04, 0.01, 0.075, 0.9), Color(1.0, 0.55, 1.0, 1.0), 10))
	aim_inversion_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.015, 0.0, 0.03, 0.98), Color(0.74, 0.12, 0.9, 1.0), 10))
	_refresh_aim_inversion_button()
	content.add_child(aim_inversion_button)
	return row


func _create_settings_mechanics_row() -> Panel:
	var row: Panel = _create_settings_row_panel()

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 10)
	row.add_child(margin)

	var content: HBoxContainer = HBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	margin.add_child(content)

	content.add_child(_create_settings_icon_label("⌖"))

	var title: Label = _create_settings_row_title("SHOOTING MECHANICS")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(title)

	shooting_mechanics_button.custom_minimum_size = Vector2(360, 50)
	shooting_mechanics_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	shooting_mechanics_button.text = ""
	shooting_mechanics_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.02, 0.005, 0.045, 0.82), Color(0.84, 0.24, 1.0, 0.92), 10))
	shooting_mechanics_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.04, 0.01, 0.075, 0.9), Color(1.0, 0.55, 1.0, 1.0), 10))
	shooting_mechanics_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.015, 0.0, 0.03, 0.98), Color(0.74, 0.12, 0.9, 1.0), 10))
	_ensure_settings_dropdown_button_overlay(shooting_mechanics_button, _get_selected_shooting_mechanic_name().to_upper())
	content.add_child(shooting_mechanics_button)
	return row


func _create_settings_account_row() -> Panel:
	var row: Panel = _create_settings_row_panel()

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_bottom", 10)
	row.add_child(margin)

	var content: HBoxContainer = HBoxContainer.new()
	content.add_theme_constant_override("separation", 24)
	margin.add_child(content)

	content.add_child(_create_settings_icon_label("ID"))

	var title: Label = _create_settings_row_title("PLAYER ACCOUNT")
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(title)

	settings_account_button.custom_minimum_size = Vector2(300, 50)
	settings_account_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	settings_account_button.add_theme_font_override("font", ui_font)
	settings_account_button.add_theme_font_size_override("font_size", 18)
	settings_account_button.add_theme_color_override("font_color", Color(0.98, 0.96, 1.0, 1.0))
	settings_account_button.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	settings_account_button.add_theme_constant_override("shadow_offset_y", 2)
	settings_account_button.add_theme_constant_override("shadow_outline_size", 4)
	settings_account_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.02, 0.005, 0.045, 0.82), Color(0.42, 0.72, 1.0, 0.92), 10))
	settings_account_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.04, 0.01, 0.075, 0.9), Color(0.68, 0.9, 1.0, 1.0), 10))
	settings_account_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.015, 0.0, 0.03, 0.98), Color(0.28, 0.54, 0.9, 1.0), 10))
	content.add_child(settings_account_button)
	return row


func _create_settings_row_panel() -> Panel:
	var row: Panel = Panel.new()
	row.custom_minimum_size = Vector2(0, 78)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override("panel", _make_settings_control_style(Color(0.01, 0.005, 0.03, 0.64), Color(0.55, 0.08, 0.9, 0.72), 6))
	return row


func _create_settings_icon_label(icon_text: String) -> Label:
	var icon_label: Label = Label.new()
	icon_label.text = icon_text
	icon_label.custom_minimum_size = Vector2(58, 58)
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_override("font", icon_font)
	icon_label.add_theme_font_size_override("font_size", 34)
	icon_label.add_theme_color_override("font_color", Color(0.98, 0.9, 1.0, 1.0))
	icon_label.add_theme_color_override("font_shadow_color", Color(0.82, 0.16, 1.0, 0.9))
	icon_label.add_theme_constant_override("shadow_offset_x", 0)
	icon_label.add_theme_constant_override("shadow_offset_y", 0)
	icon_label.add_theme_constant_override("shadow_outline_size", 10)
	icon_label.add_theme_stylebox_override("normal", _make_settings_hex_style(Color(0.035, 0.0, 0.08, 0.78), Color(0.84, 0.16, 1.0, 0.9)))
	return icon_label


func _create_settings_row_title(label_text: String) -> Label:
	var title: Label = Label.new()
	title.text = label_text
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", ui_font)
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", Color(0.96, 0.96, 1.0, 1.0))
	title.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.78))
	title.add_theme_constant_override("shadow_offset_y", 2)
	title.add_theme_constant_override("shadow_outline_size", 4)
	return title


func _ensure_settings_dropdown_button_overlay(button: Button, label_text: String) -> void:
	var row: HBoxContainer = button.get_node_or_null("DropdownContent") as HBoxContainer
	if row == null:
		row = HBoxContainer.new()
		row.name = "DropdownContent"
		button.add_child(row)
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 22
	row.offset_right = -18
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var label: Label = row.get_node_or_null("Label") as Label
	if label == null:
		label = Label.new()
		label.name = "Label"
		row.add_child(label)
	var arrow: Label = row.get_node_or_null("Arrow") as Label
	if arrow == null:
		arrow = Label.new()
		arrow.name = "Arrow"
		row.add_child(arrow)

	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", ui_font)
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(0.98, 0.96, 1.0, 1.0))
	label.add_theme_color_override("font_shadow_color", Color(0.0, 0.0, 0.0, 0.82))
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.add_theme_constant_override("shadow_outline_size", 4)

	arrow.text = "⌄"
	arrow.custom_minimum_size = Vector2(54, 0)
	arrow.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	arrow.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	arrow.add_theme_font_override("font", icon_font)
	arrow.add_theme_font_size_override("font_size", 30)
	arrow.add_theme_color_override("font_color", Color(0.92, 0.56, 1.0, 1.0))


func _rebuild_shooting_mechanics_popup_contents() -> void:
	if shooting_mechanics_popup == null:
		return
	for child in shooting_mechanics_popup.get_children():
		child.queue_free()

	var background_rect: TextureRect = TextureRect.new()
	background_rect.name = "ShootingMechanicsBackground"
	background_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	background_rect.texture = load(BACKGROUND_PATH)
	background_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	background_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	background_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shooting_mechanics_popup.add_child(background_rect)

	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.0, 0.0, 0.0, 0.34)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	shooting_mechanics_popup.add_child(shade)

	var root: MarginContainer = MarginContainer.new()
	root.name = "ShootingMechanicsRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("margin_left", 32)
	root.add_theme_constant_override("margin_top", 26)
	root.add_theme_constant_override("margin_right", 32)
	root.add_theme_constant_override("margin_bottom", 30)
	shooting_mechanics_popup.add_child(root)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 18)
	root.add_child(stack)

	var header: HBoxContainer = HBoxContainer.new()
	header.add_theme_constant_override("separation", 22)
	header.custom_minimum_size = Vector2(0, 64)
	stack.add_child(header)

	var close_button: Button = Button.new()
	close_button.name = "ShootingMechanicsCloseButton"
	close_button.custom_minimum_size = Vector2(68, 58)
	close_button.text = "<"
	close_button.add_theme_font_override("font", ui_font)
	close_button.add_theme_font_size_override("font_size", 38)
	close_button.add_theme_color_override("font_color", Color(0.98, 0.92, 1.0, 1.0))
	close_button.add_theme_color_override("font_shadow_color", Color(0.76, 0.16, 1.0, 0.92))
	close_button.add_theme_constant_override("shadow_offset_x", 0)
	close_button.add_theme_constant_override("shadow_offset_y", 0)
	close_button.add_theme_constant_override("shadow_outline_size", 10)
	close_button.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.015, 0.005, 0.04, 0.74), Color(0.75, 0.2, 1.0, 0.92), 14))
	close_button.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.035, 0.01, 0.08, 0.86), Color(0.94, 0.58, 1.0, 1.0), 14))
	close_button.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.01, 0.0, 0.025, 0.96), Color(0.65, 0.1, 0.88, 1.0), 14))
	header.add_child(close_button)
	close_button.pressed.connect(func(): shooting_mechanics_popup.hide())

	var title: Label = Label.new()
	title.text = "CHOOSE YOUR SHOT STYLE" if shooting_mechanics_prompt_required else "SHOOTING MECHANICS"
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_override("font", title_font)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color(0.98, 0.96, 1.0, 1.0))
	title.add_theme_color_override("font_outline_color", Color(0.58, 0.16, 1.0, 0.95))
	title.add_theme_color_override("font_shadow_color", Color(0.72, 0.2, 1.0, 0.9))
	title.add_theme_constant_override("outline_size", 2)
	title.add_theme_constant_override("shadow_offset_x", 0)
	title.add_theme_constant_override("shadow_offset_y", 0)
	title.add_theme_constant_override("shadow_outline_size", 10)
	header.add_child(title)
	if shooting_mechanics_prompt_required:
		header.move_child(title, 0)
		close_button.hide()

	var panel: Panel = Panel.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _make_settings_outer_panel_style())
	stack.add_child(panel)

	var panel_margin: MarginContainer = MarginContainer.new()
	panel_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel_margin.add_theme_constant_override("margin_left", 20)
	panel_margin.add_theme_constant_override("margin_top", 22)
	panel_margin.add_theme_constant_override("margin_right", 20)
	panel_margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(panel_margin)

	var cards: HBoxContainer = HBoxContainer.new()
	cards.add_theme_constant_override("separation", 16)
	cards.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cards.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel_margin.add_child(cards)

	var selected_id: String = _get_selected_shooting_mechanic_id()
	for option in _get_shooting_mechanic_options():
		var option_dict: Dictionary = option if typeof(option) == TYPE_DICTIONARY else {}
		var option_id: String = str(option_dict.get("id", "drag"))
		var option_card: Button = _create_shooting_mechanic_card(option_dict, option_id == selected_id)
		cards.add_child(option_card)
		option_card.pressed.connect(_on_shooting_mechanic_option_pressed.bind(option_id))


func _create_shooting_mechanic_card(option: Dictionary, selected: bool) -> Button:
	var card: Button = Button.new()
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(238, 270)
	card.focus_mode = Control.FOCUS_NONE
	card.text = ""
	var accent: Color = Color(1.0, 0.35, 1.0, 1.0) if selected else Color(0.72, 0.24, 1.0, 0.9)
	card.add_theme_stylebox_override("normal", _make_settings_control_style(Color(0.012, 0.004, 0.035, 0.78), accent, 12))
	card.add_theme_stylebox_override("hover", _make_settings_control_style(Color(0.03, 0.01, 0.07, 0.9), accent.lightened(0.12), 12))
	card.add_theme_stylebox_override("pressed", _make_settings_control_style(Color(0.01, 0.0, 0.025, 0.98), accent.darkened(0.08), 12))

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	card.add_child(margin)

	var stack: VBoxContainer = VBoxContainer.new()
	stack.add_theme_constant_override("separation", 10)
	margin.add_child(stack)

	var preview: TextureRect = TextureRect.new()
	preview.custom_minimum_size = Vector2(0, 120)
	preview.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview.texture = _get_shooting_mechanic_preview_texture(str(option.get("id", "drag")))
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stack.add_child(preview)

	var name_label: Label = _create_settings_label(str(option.get("name", "Classic Drag")).to_upper())
	name_label.add_theme_font_size_override("font_size", 18)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(name_label)

	var description_label: Label = _create_settings_label(str(option.get("description", "")))
	description_label.add_theme_font_size_override("font_size", 14)
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(description_label)

	var status_label: Label = _create_settings_label("SELECTED" if selected else "TAP TO USE")
	status_label.add_theme_font_size_override("font_size", 13)
	status_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.28, 1.0) if selected else Color(0.66, 0.86, 1.0, 0.88))
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	stack.add_child(status_label)
	return card


func _get_shooting_mechanic_preview_texture(option_id: String) -> Texture2D:
	var texture_path: String = SHOOTING_MECHANIC_DRAG_IMAGE_PATH
	match option_id:
		"split":
			texture_path = SHOOTING_MECHANIC_SPLIT_IMAGE_PATH
		"press":
			texture_path = SHOOTING_MECHANIC_HOLD_IMAGE_PATH
		_:
			texture_path = SHOOTING_MECHANIC_DRAG_IMAGE_PATH
	return _load_texture_from_path(texture_path)


func _rebuild_customize_popup_contents() -> void:
	for child in customize_popup.get_children():
		child.queue_free()

	var root: Control = Control.new()
	root.name = "CustomizeRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	customize_popup.add_child(root)

	customize_marble_preview_holder = _create_preview_frame(Vector2.ZERO)
	customize_marble_preview_holder.name = "CustomizeShowroom"
	customize_marble_preview_holder.set_anchors_preset(Control.PRESET_FULL_RECT)
	customize_marble_preview_holder.offset_left = 96
	customize_marble_preview_holder.offset_top = 96
	customize_marble_preview_holder.offset_right = -96
	customize_marble_preview_holder.offset_bottom = -196
	customize_marble_preview_holder.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
	root.add_child(customize_marble_preview_holder)

	var top_margin: MarginContainer = MarginContainer.new()
	top_margin.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_margin.offset_left = 20
	top_margin.offset_top = 18
	top_margin.offset_right = -20
	top_margin.offset_bottom = 92
	root.add_child(top_margin)

	var top_bar: HBoxContainer = HBoxContainer.new()
	top_bar.add_theme_constant_override("separation", 12)
	top_margin.add_child(top_bar)

	var title_stack: VBoxContainer = VBoxContainer.new()
	title_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_stack.add_theme_constant_override("separation", 2)
	top_bar.add_child(title_stack)

	var page_title: Label = _create_settings_label("CUSTOMIZE")
	page_title.add_theme_font_size_override("font_size", 24)
	page_title.add_theme_color_override("font_color", Color(0.96, 0.98, 1.0, 1.0))
	title_stack.add_child(page_title)

	var page_subtitle: Label = Label.new()
	page_subtitle.text = "Select a marble from the belt below"
	page_subtitle.add_theme_font_override("font", ui_font)
	page_subtitle.add_theme_font_size_override("font_size", 13)
	page_subtitle.add_theme_color_override("font_color", Color(0.74, 0.82, 0.96, 0.82))
	title_stack.add_child(page_subtitle)

	customize_back_button = Button.new()
	customize_back_button.name = "CustomizeBackButton"
	customize_back_button.text = "BACK"
	top_bar.add_child(customize_back_button)

	customize_apply_button = Button.new()
	customize_apply_button.name = "CustomizeApplyButton"
	customize_apply_button.text = "APPLY"
	top_bar.add_child(customize_apply_button)

	customize_prev_marble_button = Button.new()
	customize_prev_marble_button.name = "CustomizePrevMarbleButton"
	customize_prev_marble_button.text = "<"
	customize_prev_marble_button.set_anchors_preset(Control.PRESET_LEFT_WIDE)
	customize_prev_marble_button.offset_left = 24
	customize_prev_marble_button.offset_top = 140
	customize_prev_marble_button.offset_right = 92
	customize_prev_marble_button.offset_bottom = -210
	customize_prev_marble_button.custom_minimum_size = Vector2(68, 160)
	root.add_child(customize_prev_marble_button)

	customize_next_marble_button = Button.new()
	customize_next_marble_button.name = "CustomizeNextMarbleButton"
	customize_next_marble_button.text = ">"
	customize_next_marble_button.set_anchors_preset(Control.PRESET_RIGHT_WIDE)
	customize_next_marble_button.offset_left = -92
	customize_next_marble_button.offset_top = 140
	customize_next_marble_button.offset_right = -24
	customize_next_marble_button.offset_bottom = -210
	customize_next_marble_button.custom_minimum_size = Vector2(68, 160)
	root.add_child(customize_next_marble_button)

	var bottom_panel: Panel = Panel.new()
	bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	bottom_panel.offset_left = 28
	bottom_panel.offset_top = -184
	bottom_panel.offset_right = -28
	bottom_panel.offset_bottom = -22
	bottom_panel.add_theme_stylebox_override("panel", _make_button_style(Color(0.03, 0.05, 0.09, 0.86), Color(0.44, 0.56, 0.9, 0.22)))
	root.add_child(bottom_panel)

	var bottom_margin: MarginContainer = MarginContainer.new()
	bottom_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	bottom_margin.add_theme_constant_override("margin_left", 16)
	bottom_margin.add_theme_constant_override("margin_top", 12)
	bottom_margin.add_theme_constant_override("margin_right", 16)
	bottom_margin.add_theme_constant_override("margin_bottom", 12)
	bottom_panel.add_child(bottom_margin)

	var bottom_layout: VBoxContainer = VBoxContainer.new()
	bottom_layout.add_theme_constant_override("separation", 12)
	bottom_margin.add_child(bottom_layout)

	var info_row: HBoxContainer = HBoxContainer.new()
	info_row.add_theme_constant_override("separation", 14)
	bottom_layout.add_child(info_row)

	var info_column: VBoxContainer = VBoxContainer.new()
	info_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info_column.add_theme_constant_override("separation", 6)
	info_row.add_child(info_column)

	customize_preview_title = Label.new()
	customize_preview_title.name = "PreviewTitle"
	customize_preview_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	customize_preview_title.add_theme_font_override("font", ui_font)
	customize_preview_title.add_theme_font_size_override("font_size", 22)
	customize_preview_title.add_theme_color_override("font_color", Color(0.95, 0.98, 1.0, 1.0))
	customize_preview_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	info_column.add_child(customize_preview_title)

	customize_preview_text = Label.new()
	customize_preview_text.name = "PreviewText"
	customize_preview_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	customize_preview_text.add_theme_font_override("font", ui_font)
	customize_preview_text.add_theme_font_size_override("font_size", 13)
	customize_preview_text.add_theme_color_override("font_color", Color(0.78, 0.86, 0.96, 0.96))
	customize_preview_text.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	info_column.add_child(customize_preview_text)

	customize_status_label = Label.new()
	customize_status_label.name = "CustomizeStatusLabel"
	customize_status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	customize_status_label.add_theme_font_override("font", ui_font)
	customize_status_label.add_theme_font_size_override("font_size", 13)
	customize_status_label.add_theme_color_override("font_color", Color(0.77, 0.54, 0.16, 0.96))
	info_column.add_child(customize_status_label)

	var trail_button_row: HBoxContainer = HBoxContainer.new()
	trail_button_row.add_theme_constant_override("separation", 8)
	info_row.add_child(trail_button_row)

	customize_prev_trail_button = Button.new()
	customize_prev_trail_button.name = "CustomizePrevTrailButton"
	customize_prev_trail_button.text = "< TRAIL"
	trail_button_row.add_child(customize_prev_trail_button)

	customize_next_trail_button = Button.new()
	customize_next_trail_button.name = "CustomizeNextTrailButton"
	customize_next_trail_button.text = "TRAIL >"
	trail_button_row.add_child(customize_next_trail_button)

	customize_trail_preview_holder = null

	var belt_frame: Panel = _create_preview_frame(Vector2(0, 92))
	belt_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	belt_frame.add_theme_stylebox_override("panel", _make_button_style(Color(0.92, 0.95, 1.0, 0.12), Color(0.92, 0.96, 1.0, 0.68)))
	bottom_layout.add_child(belt_frame)

	var belt_margin: MarginContainer = MarginContainer.new()
	belt_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	belt_margin.add_theme_constant_override("margin_left", 12)
	belt_margin.add_theme_constant_override("margin_top", 10)
	belt_margin.add_theme_constant_override("margin_right", 12)
	belt_margin.add_theme_constant_override("margin_bottom", 10)
	belt_frame.add_child(belt_margin)

	var belt_scroll: ScrollContainer = ScrollContainer.new()
	belt_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	belt_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	belt_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	belt_margin.add_child(belt_scroll)
	customize_marble_belt_scroll = belt_scroll

	customize_marble_belt = HBoxContainer.new()
	customize_marble_belt.name = "CustomizeMarbleBelt"
	customize_marble_belt.add_theme_constant_override("separation", 12)
	belt_scroll.add_child(customize_marble_belt)

	var swatch_row: HBoxContainer = HBoxContainer.new()
	swatch_row.add_theme_constant_override("separation", 12)
	bottom_layout.add_child(swatch_row)

	customize_color_preview = ColorRect.new()
	customize_color_preview.custom_minimum_size = Vector2(120, 32)
	swatch_row.add_child(customize_color_preview)

	customize_accent_preview = ColorRect.new()
	customize_accent_preview.custom_minimum_size = Vector2(120, 32)
	swatch_row.add_child(customize_accent_preview)

	customize_preview_marble_node = null
	customize_preview_dragging = false
	marble_cards_grid = null
	trail_cards_grid = null

	if not customize_back_button.pressed.is_connected(_hide_customize_popup):
		customize_back_button.pressed.connect(_hide_customize_popup)
	if not customize_apply_button.pressed.is_connected(_on_customize_apply_pressed):
		customize_apply_button.pressed.connect(_on_customize_apply_pressed)
	if not customize_prev_marble_button.pressed.is_connected(_on_customize_prev_marble_pressed):
		customize_prev_marble_button.pressed.connect(_on_customize_prev_marble_pressed)
	if not customize_next_marble_button.pressed.is_connected(_on_customize_next_marble_pressed):
		customize_next_marble_button.pressed.connect(_on_customize_next_marble_pressed)
	if not customize_prev_trail_button.pressed.is_connected(_on_customize_prev_trail_pressed):
		customize_prev_trail_button.pressed.connect(_on_customize_prev_trail_pressed)
	if not customize_next_trail_button.pressed.is_connected(_on_customize_next_trail_pressed):
		customize_next_trail_button.pressed.connect(_on_customize_next_trail_pressed)


func _style_popups() -> void:
	if rules_popup:
		var heading: Node = rules_popup.find_child("RulesRoot", true, false)
		
			

	var rules_text: RichTextLabel = rules_popup.find_child("RulesText", true, false) as RichTextLabel
	if rules_text:
		rules_text.add_theme_font_override("normal_font", ui_font)
		rules_text.add_theme_font_size_override("normal_font_size", 18)
		rules_text.add_theme_color_override("default_color", Color(0.82, 0.9, 1.0))

	for button in [rules_close_button, online_server_save_button, customize_back_button, customize_apply_button, customize_prev_marble_button, customize_next_marble_button, customize_prev_trail_button, customize_next_trail_button, player_name_popup_save_button, lan_connect_button, lan_cancel_button, online_back_button, online_refresh_button, online_quick_match_button, online_private_create_button, online_private_join_button, online_start_button]:
		if button == null:
			continue
		if button == player_name_popup_save_button:
			continue
		if button in [online_back_button, online_refresh_button, online_quick_match_button, online_private_create_button, online_private_join_button, online_start_button]:
			continue
		if button == customize_prev_marble_button or button == customize_next_marble_button:
			button.custom_minimum_size = Vector2(72, 420)
		elif button == lan_connect_button or button == lan_cancel_button:
			button.custom_minimum_size = Vector2(0, 64)
		elif button == online_quick_match_button:
			button.custom_minimum_size = Vector2(0, 96)
		else:
			button.custom_minimum_size = Vector2(0, 54)
		button.add_theme_font_override("font", ui_font)
		button.add_theme_font_size_override("font_size", 23 if button == online_quick_match_button else 22)
		button.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))

	for slider in [master_slider, music_slider, sfx_slider, shoot_sensitivity_slider]:
		if slider == null:
			continue
		slider.custom_minimum_size = Vector2(0, 42)

	for picker in [marble_picker, trail_picker, online_private_size_picker]:
		if picker == null:
			continue
		if picker == online_private_size_picker:
			continue
		picker.custom_minimum_size = Vector2(0, 48)
		picker.add_theme_font_override("font", ui_font)
		picker.add_theme_font_size_override("font_size", 18)
		picker.add_theme_color_override("font_color", Color(0.94, 0.99, 1.0, 1.0))

	for line_edit in [player_name_popup_input, player_age_popup_input, lan_ip_input, lan_port_input, online_server_input, online_private_code_input]:
		if line_edit == null:
			continue
		if line_edit == player_name_popup_input or line_edit == player_age_popup_input:
			continue
		if line_edit == online_private_code_input:
			continue
		line_edit.add_theme_font_override("font", ui_font)
		line_edit.add_theme_font_size_override("font_size", 20)
		line_edit.add_theme_color_override("font_color", Color(0.96, 0.99, 1.0, 1.0))
		line_edit.add_theme_color_override("font_placeholder_color", Color(0.7, 0.82, 0.9, 0.7))
		line_edit.add_theme_stylebox_override("normal", _make_menu_button_style(Color(0.03, 0.07, 0.1, 0.78), Color(0.42, 0.72, 1.0, 0.55)))
		line_edit.add_theme_stylebox_override("focus", _make_menu_button_style(Color(0.04, 0.09, 0.13, 0.9), Color(0.31, 0.97, 0.85, 0.95)))


func _init_audio_sliders() -> void:
	_ensure_audio_buses()
	var master_idx: int = AudioServer.get_bus_index("Master")
	var music_idx: int = AudioServer.get_bus_index(MENU_MUSIC_BUS_NAME)
	var sfx_idx: int = AudioServer.get_bus_index(SFX_BUS_NAME)

	if master_slider:
		master_slider.value = _get_bus_slider_value(master_idx)
		_update_slider_percent_label(master_slider)
		if not master_slider.value_changed.is_connected(_on_master_slider_changed):
			master_slider.value_changed.connect(_on_master_slider_changed)

	if music_slider:
		music_slider.value = _get_bus_slider_value(music_idx)
		_update_slider_percent_label(music_slider)
		if not music_slider.value_changed.is_connected(_on_music_slider_changed):
			music_slider.value_changed.connect(_on_music_slider_changed)

	if sfx_slider:
		sfx_slider.value = _get_bus_slider_value(sfx_idx)
		_update_slider_percent_label(sfx_slider)
		if not sfx_slider.value_changed.is_connected(_on_sfx_slider_changed):
			sfx_slider.value_changed.connect(_on_sfx_slider_changed)


func _init_shoot_sensitivity_slider() -> void:
	if shoot_sensitivity_slider == null:
		return

	var customization: Node = get_node_or_null("/root/CustomizationState")
	var sensitivity := 1.0
	if customization != null and customization.has_method("get_shoot_sensitivity"):
		sensitivity = float(customization.call("get_shoot_sensitivity"))

	shoot_sensitivity_slider.value = sensitivity
	_update_slider_percent_label(shoot_sensitivity_slider)
	if not shoot_sensitivity_slider.value_changed.is_connected(_on_shoot_sensitivity_changed):
		shoot_sensitivity_slider.value_changed.connect(_on_shoot_sensitivity_changed)


func _init_online_server_input() -> void:
	if online_server_input == null:
		return

	var customization: Node = get_node_or_null("/root/CustomizationState")
	var saved_url: String = ""
	if customization != null and customization.has_method("get_online_server_url"):
		saved_url = str(customization.call("get_online_server_url")).strip_edges()
	if saved_url == "":
		saved_url = str(ProjectSettings.get_setting("application/config/online_server_url", "")).strip_edges()
	online_server_input.text = saved_url


func _get_bus_slider_value(bus_idx: int) -> float:
	if bus_idx == -1:
		return 0.5
	return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))


func _on_master_slider_changed(value: float) -> void:
	_update_slider_percent_label(master_slider)
	_set_bus_volume("Master", value)


func _on_music_slider_changed(value: float) -> void:
	_update_slider_percent_label(music_slider)
	_set_bus_volume(MENU_MUSIC_BUS_NAME, value)


func _on_sfx_slider_changed(value: float) -> void:
	_update_slider_percent_label(sfx_slider)
	_set_bus_volume(SFX_BUS_NAME, value)


func _set_bus_volume(bus_name: String, value: float) -> void:
	if bus_name != "Master":
		_ensure_audio_bus(bus_name)
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(maxf(value, 0.001)))


func _on_shoot_sensitivity_changed(value: float) -> void:
	_update_slider_percent_label(shoot_sensitivity_slider)
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("set_shoot_sensitivity"):
		customization.call("set_shoot_sensitivity", value)


func _on_aim_inversion_pressed() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("set_aim_inverted"):
		customization.call("set_aim_inverted", not _is_aim_inverted())
	_refresh_aim_inversion_button()


func _on_shooting_mechanics_pressed() -> void:
	shooting_mechanics_prompt_required = false
	shooting_mechanics_prompt_pending_after_name = false
	_ensure_shooting_mechanics_popup()
	if shooting_mechanics_popup:
		shooting_mechanics_popup.size = Vector2i(920, 520)
		_rebuild_shooting_mechanics_popup_contents()
		shooting_mechanics_popup.popup_centered()
		shooting_mechanics_popup.show()


func _on_shooting_mechanic_option_pressed(mechanic_id: String) -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("set_shooting_mechanic"):
		customization.call("set_shooting_mechanic", mechanic_id)
	_refresh_shooting_mechanics_button()
	if shooting_mechanics_prompt_required:
		shooting_mechanics_prompt_required = false
		shooting_mechanics_prompt_pending_after_name = false
		if shooting_mechanics_popup != null:
			shooting_mechanics_popup.hide()
		_show_startup_loading_once()
		return
	_rebuild_shooting_mechanics_popup_contents()


func _should_prompt_shooting_mechanics() -> bool:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return false
	if customization.has_method("has_player_name") and not bool(customization.call("has_player_name")):
		return false
	if customization.has_method("has_chosen_shooting_mechanic"):
		return not bool(customization.call("has_chosen_shooting_mechanic"))
	return false


func _show_shooting_mechanics_prompt_if_needed() -> bool:
	if not _should_prompt_shooting_mechanics():
		return false
	shooting_mechanics_prompt_required = true
	_ensure_shooting_mechanics_popup()
	if shooting_mechanics_popup != null:
		var viewport_size: Vector2 = get_viewport_rect().size
		shooting_mechanics_popup.size = Vector2i(
			int(maxf(300.0, minf(1040.0, viewport_size.x - 32.0))),
			int(maxf(420.0, minf(680.0, viewport_size.y - 32.0)))
		)
		_rebuild_shooting_mechanics_popup_contents()
		shooting_mechanics_popup.popup_centered()
		shooting_mechanics_popup.show()
	return true


func _refresh_aim_inversion_button() -> void:
	if aim_inversion_button != null:
		aim_inversion_button.text = _get_aim_inversion_label()


func _get_aim_inversion_label() -> String:
	return "INVERTED" if _is_aim_inverted() else "NORMAL"


func _is_aim_inverted() -> bool:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("is_aim_inverted"):
		return bool(customization.call("is_aim_inverted"))
	return false


func _refresh_shooting_mechanics_button() -> void:
	if shooting_mechanics_button != null:
		shooting_mechanics_button.text = ""
		_ensure_settings_dropdown_button_overlay(shooting_mechanics_button, _get_selected_shooting_mechanic_name().to_upper())


func _update_slider_percent_label(slider: HSlider) -> void:
	if slider == null:
		return
	var percent_label: Label = slider.get_meta("percent_label", null) as Label
	if percent_label == null:
		return
	percent_label.text = "%d%%" % int(round(slider.value * 100.0))


func _get_selected_shooting_mechanic_id() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic"):
		return str(customization.call("get_shooting_mechanic"))
	return "drag"


func _get_selected_shooting_mechanic_name() -> String:
	var selected_id: String = _get_selected_shooting_mechanic_id()
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic_name"):
		return str(customization.call("get_shooting_mechanic_name", selected_id))
	for option in _get_shooting_mechanic_options():
		var option_dict: Dictionary = option if typeof(option) == TYPE_DICTIONARY else {}
		if str(option_dict.get("id", "")) == selected_id:
			return str(option_dict.get("name", "Classic Drag"))
	return "Classic Drag"


func _get_shooting_mechanic_options() -> Array:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_shooting_mechanic_options"):
		var options: Variant = customization.call("get_shooting_mechanic_options")
		if typeof(options) == TYPE_ARRAY:
			return options
	return [
		{"id": "drag", "name": "Classic Drag", "description": "One finger aims and shoots by dragging."},
		{"id": "split", "name": "Split Control", "description": "Left side aims. Right side drags to shoot."},
		{"id": "press", "name": "Hold Button", "description": "Aim anywhere, then hold the shoot button for power."}
	]


func _on_online_server_save_pressed() -> void:
	if online_server_input == null:
		return
	var clean_url: String = _normalize_online_server_url_for_display(online_server_input.text)
	online_server_input.text = clean_url
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("set_online_server_url"):
		customization.call("set_online_server_url", clean_url)
	if online_server_save_button != null:
		online_server_save_button.text = "SAVED"


func _normalize_online_server_url_for_display(raw_url: String) -> String:
	var clean_url: String = raw_url.strip_edges().replace(" ", "")
	if clean_url.begins_with("https://"):
		clean_url = "wss://%s" % clean_url.substr(8)
	elif clean_url.begins_with("http://"):
		clean_url = "ws://%s" % clean_url.substr(7)
	elif clean_url != "" and not clean_url.begins_with("ws://") and not clean_url.begins_with("wss://"):
		clean_url = "wss://%s" % clean_url
	if clean_url.ends_with("/"):
		clean_url = clean_url.substr(0, clean_url.length() - 1)
	return clean_url


func _on_play_pressed() -> void:
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan != null and lan.has_method("start_offline_game"):
		lan.call("start_offline_game")
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("disconnect_from_server"):
		online.call("disconnect_from_server", false)

	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("has_player_name") and not customization.call("has_player_name"):
		_show_player_name_popup()
		return
	if _show_shooting_mechanics_prompt_if_needed():
		return

	_start_main_scene()


func _on_online_pressed() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("has_player_name") and not customization.call("has_player_name"):
		_show_player_name_popup()
		return
	if _show_shooting_mechanics_prompt_if_needed():
		return

	_show_online_rooms_page()
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("connect_to_server"):
		if online_status_label != null:
			online_status_label.text = "MultiplayerManager autoload is missing."
		return

	if online_status_label != null:
		online_status_label.text = "Connecting to online parties..."
	online.call("connect_to_server", "", true)


func _show_online_rooms_page() -> void:
	if online_rooms_page == null:
		return
	if glass_panel:
		glass_panel.hide()
	if donate_button:
		donate_button.hide()
	if background:
		background.hide()
	if background_overlay:
		background_overlay.hide()
	if top_glow:
		top_glow.hide()
	if bottom_glow:
		bottom_glow.hide()
	_set_neon_backdrop_visible(false)
	if online_loading_panel != null:
		online_loading_panel.hide()
	_set_online_rooms_content_visible(true)
	var online_background: TextureRect = online_rooms_page.get_node_or_null("OnlineRoomsBackground") as TextureRect
	_set_online_background_texture(online_background)
	online_match_start_timer = -1.0
	online_scene_start_timer = -1.0
	online_start_fallback_timer = -1.0
	online_match_start_requested = false
	online_rooms_page.show()
	var viewport_size: Vector2 = get_viewport_rect().size
	online_rooms_page.custom_minimum_size = viewport_size
	online_rooms_page.size = viewport_size
	var content: Control = online_rooms_page.get_node_or_null("OnlineRoomsContent") as Control
	if content != null:
		content.custom_minimum_size = viewport_size
	_sync_online_chat_visibility()
	online_room_refresh_timer = 0.0
	_refresh_online_currency_display()
	_refresh_online_rooms_view()


func _set_online_rooms_content_visible(is_visible: bool) -> void:
	if online_rooms_page == null:
		return
	var content: CanvasItem = online_rooms_page.get_node_or_null("OnlineRoomsContent") as CanvasItem
	if content != null:
		content.visible = is_visible
	_sync_online_chat_visibility()


func _configure_online_loading_screen(title_text: String, status_text: String, progress_value: float, show_start_button: bool = false, show_cancel_button: bool = true) -> void:
	if online_loading_title_label != null:
		online_loading_title_label.text = title_text
	if online_loading_status_label != null:
		online_loading_status_label.text = status_text
	if online_loading_progress_bar != null:
		online_loading_progress_bar.value = clampf(progress_value, 0.0, 100.0)
	if online_loading_marble_label != null:
		online_loading_marble_label.hide()
	if online_loading_slots_grid != null:
		online_loading_slots_grid.hide()
	if online_loading_players_label != null:
		online_loading_players_label.hide()
	if online_loading_start_button != null:
		online_loading_start_button.visible = show_start_button
	if online_loading_cancel_button != null:
		online_loading_cancel_button.visible = show_cancel_button
		online_loading_cancel_button.disabled = false
		online_loading_cancel_button.text = "CANCEL"
	_sync_online_loading_chat_visibility()
	_sync_online_chat_visibility()


func _begin_online_scene_loading(duration: float, status_text: String = "Entering field...") -> void:
	online_scene_start_duration = maxf(duration, 0.1)
	online_scene_start_timer = online_scene_start_duration
	if online_loading_panel != null:
		online_loading_panel.show()
	_set_online_rooms_content_visible(false)
	_configure_online_loading_screen("LOADING MATCH", status_text, 68.0, false, false)


func _process_online_room_refresh(delta: float) -> void:
	if online_rooms_page == null or not online_rooms_page.visible:
		return
	if online_loading_panel != null and online_loading_panel.visible:
		return
	online_room_refresh_timer += delta
	if online_room_refresh_timer < 2.5:
		return
	online_room_refresh_timer = 0.0
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("request_rooms"):
		online.call("request_rooms")


func _process_online_match_loading(delta: float) -> void:
	if online_match_start_timer < 0.0:
		return

	online_match_start_timer -= delta
	if online_loading_status_label != null:
		online_loading_status_label.text = "Finding players..."
	if online_loading_progress_bar != null:
		var elapsed: float = ONLINE_AUTO_START_SECONDS - maxf(online_match_start_timer, 0.0)
		online_loading_progress_bar.value = clampf(lerpf(14.0, 52.0, elapsed / maxf(ONLINE_AUTO_START_SECONDS, 0.001)), 0.0, 100.0)

	if online_match_start_timer > 0.0:
		return

	online_match_start_timer = -1.0
	online_scene_start_timer = -1.0
	if online_match_start_requested:
		return

	online_match_start_requested = true
	_request_online_match_start()


func _process_online_start_fallback(delta: float) -> void:
	if online_start_fallback_timer < 0.0:
		return
	online_start_fallback_timer -= delta
	if online_start_fallback_timer > 0.0:
		return
	online_start_fallback_timer = -1.0

	if online_loading_status_label != null:
		online_loading_status_label.text = "Still waiting for the server..."


func _process_online_scene_start(delta: float) -> void:
	if online_scene_start_timer < 0.0:
		return
	online_scene_start_timer -= delta
	if online_loading_progress_bar != null:
		var progress: float = 1.0 - clampf(online_scene_start_timer / maxf(online_scene_start_duration, 0.001), 0.0, 1.0)
		online_loading_progress_bar.value = clampf(lerpf(68.0, 100.0, progress), 0.0, 100.0)
	if online_loading_status_label != null:
		online_loading_status_label.text = "Entering field..."
	if online_scene_start_timer > 0.0:
		return
	online_scene_start_timer = -1.0
	if online_rooms_page != null:
		online_rooms_page.hide()
	_start_main_scene()


func _on_online_refresh_pressed() -> void:
	online_room_refresh_timer = 0.0
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null:
		return
	if online_status_label != null:
		online_status_label.text = "Refreshing parties..."
	if online.has_method("request_rooms"):
		online.call("request_rooms")


func _on_online_quick_match_pressed() -> void:
	if online_status_label != null:
		online_status_label.text = "Searching for the fastest open party..."
	_on_online_public_room_pressed(5)


func _on_online_side_button_pressed(section_name: String) -> void:
	if online_current_room_label != null:
		if section_name == "LEADERBOARD":
			online_current_room_label.text = _format_local_leaderboard_text()
		else:
			online_current_room_label.text = "%s opens after the next rankings update." % section_name.capitalize()


func _format_local_leaderboard_text() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null or not customization.has_method("get_leaderboard_entries"):
		return "Leaderboard is empty. Win a match to claim the top spot."
	var entries: Array = customization.call("get_leaderboard_entries")
	if entries.is_empty():
		return "Leaderboard is empty. Win a match to claim the top spot."
	var lines: PackedStringArray = PackedStringArray(["LEADERBOARD"])
	if customization.has_method("get_player_login_id") and customization.has_method("get_player_name"):
		var login_id: String = str(customization.call("get_player_login_id")).strip_edges()
		var login_name: String = str(customization.call("get_player_name")).strip_edges()
		if login_id != "" and login_name != "":
			lines.append("LOGIN: %s  ID: %s" % [login_name, login_id])
	var limit: int = mini(entries.size(), 3)
	for index in range(limit):
		var entry: Dictionary = entries[index] as Dictionary
		lines.append("%d. %s  -  %d wins" % [
			index + 1,
			str(entry.get("name", "Player")),
			int(entry.get("wins", 0))
		])
	return "\n".join(lines)


func _on_online_public_room_pressed(human_capacity: int) -> void:
	_release_online_invite_room_hold()
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("join_public_room"):
		return
	if online_status_label != null:
		online_status_label.text = "Finding a %d-player public party..." % human_capacity
	var error: Error = online.call("join_public_room", human_capacity)
	if error != OK and online_status_label != null:
		online_status_label.text = "Could not join yet. Make sure the online service is running."
		return
	if online_loading_panel != null:
		online_loading_panel.show()
		_set_online_rooms_content_visible(false)
		_configure_online_loading_screen("PUBLIC PARTY", "Waiting for the server to place you in a party...", 8.0)


func _on_online_private_create_pressed() -> void:
	_release_online_invite_room_hold()
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("create_private_room"):
		return
	var human_capacity: int = _get_online_private_size()
	if online_status_label != null:
		online_status_label.text = "Creating private %d-player party..." % human_capacity
	var error: Error = online.call("create_private_room", human_capacity)
	if error != OK and online_status_label != null:
		online_status_label.text = "Could not create yet. Make sure the online service is running."


func _on_online_private_join_pressed() -> void:
	_release_online_invite_room_hold()
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("join_private_room"):
		return
	var room_code: String = online_private_code_input.text.strip_edges().to_upper() if online_private_code_input != null else ""
	if online_status_label != null:
		online_status_label.text = "Joining private party %s..." % room_code
	var error: Error = online.call("join_private_room", room_code)
	if error != OK and online_status_label != null:
		online_status_label.text = "Enter a code, then make sure the online server is running."


func _on_online_private_code_submitted(_text_value: String) -> void:
	_on_online_private_join_pressed()


func _on_online_start_pressed() -> void:
	_release_online_invite_room_hold()
	online_match_start_timer = -1.0
	online_match_start_requested = true
	if online_status_label != null:
		online_status_label.text = "Starting online game..."
	if online_loading_panel != null:
		online_loading_panel.show()
	_set_online_rooms_content_visible(false)
	_configure_online_loading_screen("LOADING MATCH", "Starting match...", 58.0, false, false)
	_request_online_match_start()


func _on_online_loading_cancel_pressed() -> void:
	online_match_start_timer = -1.0
	online_scene_start_timer = -1.0
	online_start_fallback_timer = -1.0
	online_match_start_requested = false
	_release_online_invite_room_hold()
	online_chat_history.clear()
	_refresh_online_chat_log()

	if online_loading_cancel_button != null:
		online_loading_cancel_button.disabled = true
		online_loading_cancel_button.text = "CANCELLING"
	if online_loading_panel != null:
		online_loading_panel.hide()
	_set_online_rooms_content_visible(true)
	if online_status_label != null:
		online_status_label.text = "Matchmaking cancelled. Returning to online rooms..."

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("disconnect_from_server"):
		online.call("disconnect_from_server", false)
	if online != null and online.has_method("connect_to_server"):
		online.call_deferred("connect_to_server", "", true)

	online_latest_rooms.clear()
	_refresh_online_rooms_view()

	if online_loading_cancel_button != null:
		online_loading_cancel_button.disabled = false
		online_loading_cancel_button.text = "CANCEL"


func _begin_online_field_transition() -> void:
	online_match_start_timer = -1.0
	online_start_fallback_timer = -1.0
	_begin_online_scene_loading(ONLINE_SCENE_LOAD_DELAY_SECONDS, "Entering field...")


func _request_online_match_start() -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("start_game"):
		return
	online_start_fallback_timer = ONLINE_START_FALLBACK_SECONDS
	if online_loading_status_label != null:
		online_loading_status_label.text = "Starting match..."
	if online_loading_progress_bar != null:
		online_loading_progress_bar.value = 58.0
	if online_loading_cancel_button != null:
		online_loading_cancel_button.hide()
	online.call("start_game")


func _get_online_private_size() -> int:
	if online_private_size_picker == null:
		return 2
	var selected_id: int = online_private_size_picker.get_selected_id()
	if selected_id >= 2:
		return selected_id
	return online_private_size_picker.get_selected() + 2


func _get_online_room_accent(human_capacity: int) -> Color:
	match human_capacity:
		2:
			return Color(0.31, 0.97, 0.85, 1.0)
		3:
			return Color(0.42, 0.72, 1.0, 1.0)
		4:
			return Color(0.72, 0.36, 1.0, 1.0)
		5:
			return Color(1.0, 0.82, 0.2, 1.0)
		_:
			return Color(0.31, 0.97, 0.85, 1.0)


func _refresh_online_rooms_view() -> void:
	if online_public_room_buttons.is_empty():
		return

	_refresh_online_stat_display()

	if online_quick_match_button != null:
		var quick_room: Dictionary = _find_open_public_room_for_capacity(5)
		var quick_players: int = 0
		if not quick_room.is_empty():
			var quick_room_players: Array = quick_room.get("players", [])
			quick_players = quick_room_players.size()
		online_quick_match_button.text = "QUICK PARTY\n5 PLAYER BATTLE | %d/5 READY" % quick_players

	for human_capacity in [2, 3, 4, 5]:
		var button: Button = online_public_room_buttons.get(human_capacity, null) as Button
		if button == null:
			continue
		var room: Dictionary = _find_open_public_room_for_capacity(human_capacity)
		if room.is_empty():
			button.text = "%dP PARTY\nOPEN NOW" % human_capacity
		else:
			var players: Array = room.get("players", [])
			button.text = "%dP PARTY\n%d/%d READY" % [human_capacity, players.size(), human_capacity]

	_refresh_online_live_rooms_list()
	_refresh_online_players_list()
	_refresh_online_friends_list()
	_refresh_online_friend_requests_list()

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var room_data: Dictionary = {}
	if online != null and online.has_method("get_room"):
		room_data = online.call("get_room")

	if online_current_room_label != null:
		online_current_room_label.text = _describe_online_room(room_data)

	_refresh_online_party_slot_display(room_data)

	if online_start_button != null:
		var is_joined: bool = not room_data.is_empty()
		var is_host: bool = online != null and online.has_method("is_host") and bool(online.call("is_host"))
		online_start_button.visible = is_joined
		online_start_button.disabled = not is_host or _get_online_room_human_count(room_data) < 2
		online_start_button.text = "START GAME" if is_host else "WAITING FOR HOST"

	_refresh_online_currency_display()


func _refresh_online_party_slot_display(room_data: Dictionary) -> void:
	if online_party_slot_name_labels.is_empty() or online_party_slot_status_labels.is_empty():
		return

	var players: Array = []
	var capacity: int = online_party_slot_name_labels.size()
	if not room_data.is_empty():
		players = room_data.get("players", [])
		capacity = clampi(int(room_data.get("human_capacity", room_data.get("max_players", capacity))), 1, online_party_slot_name_labels.size())

	for slot_index in range(online_party_slot_name_labels.size()):
		var name_label: Label = online_party_slot_name_labels[slot_index] as Label
		var status_label: Label = online_party_slot_status_labels[slot_index] as Label
		if name_label == null or status_label == null:
			continue

		if slot_index >= capacity:
			name_label.text = "SLOT %d" % (slot_index + 1)
			status_label.text = "LOCKED"
			name_label.add_theme_color_override("font_color", Color(0.58, 0.68, 0.78, 0.62))
			status_label.add_theme_color_override("font_color", Color(0.58, 0.68, 0.78, 0.62))
			continue

		if slot_index < players.size():
			var player_name: String = "Player %d" % (slot_index + 1)
			var is_host_player: bool = slot_index == 0
			var player_data = players[slot_index]
			if typeof(player_data) == TYPE_DICTIONARY:
				var player_dict: Dictionary = player_data as Dictionary
				player_name = str(player_dict.get("name", player_name)).strip_edges()
				is_host_player = bool(player_dict.get("is_host", is_host_player))
			else:
				player_name = str(player_data).strip_edges()
			if player_name == "":
				player_name = "Player %d" % (slot_index + 1)
			name_label.text = player_name.to_upper()
			status_label.text = "HOST" if is_host_player else "READY"
			name_label.add_theme_color_override("font_color", Color(0.94, 0.98, 1.0, 0.96))
			status_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.2, 0.96) if is_host_player else Color(0.31, 0.97, 0.85, 0.92))
		else:
			name_label.text = "SLOT %d" % (slot_index + 1)
			status_label.text = "OPEN"
			name_label.add_theme_color_override("font_color", Color(0.82, 0.9, 1.0, 0.76))
			status_label.add_theme_color_override("font_color", Color(0.31, 0.97, 0.85, 0.82))


func _refresh_online_stat_display() -> void:
	if online_stat_amount_labels.is_empty():
		return
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var online_players: int = 0
	var open_parties: int = online_latest_rooms.size()
	var running_parties: int = 0
	if online != null:
		if online.has_method("get_online_player_count"):
			online_players = int(online.call("get_online_player_count"))
		else:
			online_players = _count_players_in_online_rooms(online_latest_rooms)
		if online.has_method("get_open_party_count"):
			open_parties = int(online.call("get_open_party_count"))
		if online.has_method("get_running_party_count"):
			running_parties = int(online.call("get_running_party_count"))
	if online_players <= 0:
		online_players = _get_online_players_snapshot().size()
	var values: Dictionary = {
		"players": online_players,
		"open": open_parties,
		"running": running_parties
	}
	for key in values.keys():
		var label: Label = online_stat_amount_labels.get(key, null) as Label
		if label != null:
			label.text = str(int(values[key]))


func _refresh_online_currency_display() -> void:
	if online_currency_amount_labels.is_empty():
		return

	var coin_balance: int = _get_online_currency_amount("coins")
	var gold_balance: int = _get_online_currency_amount("gold")
	var values: Dictionary = {
		"coins": coin_balance,
		"gold": gold_balance
	}
	for key in values.keys():
		var amount_label: Label = online_currency_amount_labels.get(key, null) as Label
		if amount_label != null:
			var prefix: String = "G" if key == "gold" else "S"
			amount_label.text = "%s %s" % [prefix, _format_online_amount(int(values[key]))]


func _get_online_currency_amount(currency_key: String) -> int:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	var currency_manager: Node = get_node_or_null("/root/CurrencyManager")
	match currency_key:
		"gold":
			if customization != null and customization.has_method("get_gold_balance"):
				return int(customization.call("get_gold_balance"))
			if currency_manager != null and currency_manager.has_method("get_gold"):
				return int(currency_manager.call("get_gold"))
		_:
			if customization != null and customization.has_method("get_coin_balance"):
				return int(customization.call("get_coin_balance"))
			if currency_manager != null and currency_manager.has_method("get_coins"):
				return int(currency_manager.call("get_coins"))
	return 0


func _format_online_amount(value: int) -> String:
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


func _on_online_currency_changed(_coins: int, _gold: int) -> void:
	_refresh_online_currency_display()


func _find_open_public_room_for_capacity(human_capacity: int) -> Dictionary:
	for room in online_latest_rooms:
		if typeof(room) != TYPE_DICTIONARY:
			continue
		var data: Dictionary = room as Dictionary
		if bool(data.get("is_private", false)):
			continue
		if bool(data.get("started", false)):
			continue
		var capacity: int = int(data.get("human_capacity", data.get("max_players", 2)))
		var players: Array = data.get("players", [])
		if capacity == human_capacity and players.size() < capacity:
			return data
	return {}


func _count_players_in_online_rooms(rooms: Array) -> int:
	var total_players: int = 0
	for room in rooms:
		if typeof(room) != TYPE_DICTIONARY:
			continue
		var room_data: Dictionary = room as Dictionary
		if room_data.has("connected_count"):
			total_players += int(room_data.get("connected_count", 0))
		elif room_data.has("player_count"):
			total_players += int(room_data.get("player_count", 0))
		else:
			var players_value = room_data.get("players", [])
			if typeof(players_value) == TYPE_ARRAY:
				total_players += (players_value as Array).size()
	return total_players


func _refresh_online_live_rooms_list() -> void:
	if online_live_rooms_stack == null:
		return
	_clear_node_children(online_live_rooms_stack)

	var shown_count: int = 0
	for room in online_latest_rooms:
		if typeof(room) != TYPE_DICTIONARY:
			continue
		var room_data: Dictionary = room as Dictionary
		if bool(room_data.get("started", false)):
			continue
		var players: Array = room_data.get("players", [])
		var capacity: int = int(room_data.get("human_capacity", room_data.get("max_players", 2)))
		if capacity < 2:
			continue
		var is_private: bool = bool(room_data.get("is_private", false))
		if players.is_empty() and not is_private:
			continue
		var room_code: String = _get_online_room_code(room_data)
		var can_join: bool = room_code != "" and players.size() < capacity
		var room_button: Button = Button.new()
		room_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		room_button.custom_minimum_size = Vector2(0, 66)
		var room_kind: String = "PRIVATE" if is_private else "PUBLIC"
		var join_note: String = "ENTER CODE" if is_private and room_code == "" else ("FULL" if players.size() >= capacity else "JOIN")
		var player_names: PackedStringArray = PackedStringArray()
		for player in players:
			if typeof(player) != TYPE_DICTIONARY:
				continue
			var player_name: String = str((player as Dictionary).get("name", "Player")).strip_edges()
			if player_name == "":
				player_name = "Player"
			player_names.append(player_name)
			if player_names.size() >= 3:
				break
		var people_text: String = ", ".join(player_names) if not player_names.is_empty() else "Waiting for players"
		room_button.text = "%s %dP PARTY  |  %d/%d PLAYERS\n%s" % [
			room_kind,
			capacity,
			players.size(),
			capacity,
			"%s | %s" % [join_note, people_text]
		]
		room_button.disabled = not can_join
		_style_online_button(room_button, _get_online_room_accent(capacity), 15)
		if can_join:
			room_button.pressed.connect(_on_online_listed_room_pressed.bind(room_code, capacity, is_private))
		online_live_rooms_stack.add_child(room_button)
		shown_count += 1
		if shown_count >= 6:
			break

	if shown_count > 0:
		_bind_online_touch_scroll_children(online_live_rooms_stack)
		return

	var empty_label: Label = Label.new()
	empty_label.text = "No live parties yet. Pick a public party or create a private code."
	empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	empty_label.add_theme_font_override("font", ui_font)
	empty_label.add_theme_font_size_override("font_size", 14)
	empty_label.add_theme_color_override("font_color", Color(0.82, 0.9, 1.0, 0.86))
	online_live_rooms_stack.add_child(empty_label)
	_bind_online_touch_scroll_children(online_live_rooms_stack)


func _refresh_online_players_list() -> void:
	if online_players_list_stack == null:
		return
	_clear_node_children(online_players_list_stack)

	var players: Array = _get_online_players_snapshot()
	if players.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No online players found yet."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.add_theme_font_override("font", ui_font)
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", Color(0.82, 0.9, 1.0, 0.86))
		online_players_list_stack.add_child(empty_label)
		_bind_online_touch_scroll_children(online_players_list_stack)
		return

	var shown_count: int = 0
	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = player as Dictionary
		online_players_list_stack.add_child(_create_online_player_row(player_data))
		shown_count += 1
		if shown_count >= 18:
			break
	_bind_online_touch_scroll_children(online_players_list_stack)


func _refresh_online_friends_list() -> void:
	if online_friends_list_stack == null:
		return
	_clear_node_children(online_friends_list_stack)

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var friends: Array = []
	if online != null and online.has_method("get_online_friends"):
		var friends_value = online.call("get_online_friends")
		if typeof(friends_value) == TYPE_ARRAY:
			friends = friends_value as Array

	if friends.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No friends yet. Add players from the online tab."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.add_theme_font_override("font", ui_font)
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", Color(0.82, 0.9, 1.0, 0.86))
		online_friends_list_stack.add_child(empty_label)
		_bind_online_touch_scroll_children(online_friends_list_stack)
		return

	for friend in friends:
		if typeof(friend) != TYPE_DICTIONARY:
			continue
		var friend_data: Dictionary = (friend as Dictionary).duplicate(true)
		friend_data["is_friend"] = true
		friend_data["can_invite"] = bool(friend_data.get("connected", true))
		online_friends_list_stack.add_child(_create_online_player_row(friend_data, true))
	_bind_online_touch_scroll_children(online_friends_list_stack)


func _refresh_online_friend_requests_list() -> void:
	if online_friend_requests_list_stack == null:
		return
	_clear_node_children(online_friend_requests_list_stack)

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var incoming: Array = []
	var outgoing: Array = []
	if online != null and online.has_method("get_incoming_friend_requests"):
		var incoming_value = online.call("get_incoming_friend_requests")
		if typeof(incoming_value) == TYPE_ARRAY:
			incoming = incoming_value as Array
	if online != null and online.has_method("get_outgoing_friend_requests"):
		var outgoing_value = online.call("get_outgoing_friend_requests")
		if typeof(outgoing_value) == TYPE_ARRAY:
			outgoing = outgoing_value as Array

	if incoming.is_empty() and outgoing.is_empty():
		var empty_label: Label = Label.new()
		empty_label.text = "No friend requests."
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		empty_label.add_theme_font_override("font", ui_font)
		empty_label.add_theme_font_size_override("font_size", 14)
		empty_label.add_theme_color_override("font_color", Color(0.82, 0.9, 1.0, 0.86))
		online_friend_requests_list_stack.add_child(empty_label)
		_bind_online_touch_scroll_children(online_friend_requests_list_stack)
		return

	for request in incoming:
		if typeof(request) != TYPE_DICTIONARY:
			continue
		var request_data: Dictionary = (request as Dictionary).duplicate(true)
		request_data["incoming_friend_request"] = true
		online_friend_requests_list_stack.add_child(_create_online_player_row(request_data, false))

	for request in outgoing:
		if typeof(request) != TYPE_DICTIONARY:
			continue
		var outgoing_data: Dictionary = (request as Dictionary).duplicate(true)
		outgoing_data["outgoing_friend_request"] = true
		online_friend_requests_list_stack.add_child(_create_online_player_row(outgoing_data, false))
	_bind_online_touch_scroll_children(online_friend_requests_list_stack)


func _get_online_players_snapshot() -> Array:
	var entries: Array = []
	var seen_ids: Dictionary = {}
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("get_online_players"):
		var manager_players_value = online.call("get_online_players")
		if typeof(manager_players_value) == TYPE_ARRAY:
			_append_online_player_entries(entries, seen_ids, manager_players_value as Array)
	_append_online_player_entries(entries, seen_ids, online_latest_players)
	_append_online_player_entries(entries, seen_ids, _collect_players_from_online_rooms())
	return entries


func _get_online_local_player_name() -> String:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("get_local_player_name"):
		var online_name: String = str(online.call("get_local_player_name")).strip_edges()
		if online_name != "":
			return online_name
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_player_name"):
		return str(customization.call("get_player_name")).strip_edges()
	return ""


func _get_online_local_player_login_id() -> String:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("get_local_player_login_id"):
		var online_login_id: String = str(online.call("get_local_player_login_id")).strip_edges()
		if online_login_id != "":
			return online_login_id
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_player_login_id"):
		return str(customization.call("get_player_login_id")).strip_edges()
	return ""


func _get_online_local_player_age() -> int:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("get_local_player_age"):
		return int(online.call("get_local_player_age"))
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_player_age"):
		return int(customization.call("get_player_age"))
	return 0


func _normalize_online_identity_value(value: String) -> String:
	return value.strip_edges().to_lower()


func _append_unique_online_identity_key(keys: Array, key: String) -> void:
	var clean_key: String = key.strip_edges()
	if clean_key == "" or keys.has(clean_key):
		return
	keys.append(clean_key)


func _get_online_player_seen_keys(player_data: Dictionary, player_id: String, player_name: String, is_local_player: bool) -> Array:
	var keys: Array = []
	for id_key in ["id", "client_id", "player_id", "peer_id"]:
		var id_value: String = _normalize_online_identity_value(str(player_data.get(id_key, "")))
		if id_value != "":
			_append_unique_online_identity_key(keys, "id:%s" % id_value)
	var login_id: String = _normalize_online_identity_value(str(player_data.get("login_id", player_data.get("player_login_id", ""))))
	if login_id != "":
		_append_unique_online_identity_key(keys, "login:%s" % login_id)
	if is_local_player:
		_append_unique_online_identity_key(keys, "local")
	if keys.is_empty():
		var name_key: String = _normalize_online_identity_value(player_name)
		if name_key != "":
			_append_unique_online_identity_key(keys, "name:%s" % name_key)
	return keys


func _online_player_seen(seen_ids: Dictionary, identity_keys: Array) -> bool:
	for key in identity_keys:
		if seen_ids.has(str(key)):
			return true
	return false


func _mark_online_player_seen(seen_ids: Dictionary, identity_keys: Array) -> void:
	for key in identity_keys:
		seen_ids[str(key)] = true


func _append_online_player_entries(entries: Array, seen_ids: Dictionary, players: Array) -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var local_id: String = ""
	if online != null and online.has_method("get_local_client_id"):
		local_id = str(online.call("get_local_client_id"))
	var local_login_id: String = _get_online_local_player_login_id()
	var local_name: String = _get_online_local_player_name()
	var normalized_local_login_id: String = _normalize_online_identity_value(local_login_id)
	var normalized_local_name: String = _normalize_online_identity_value(local_name)
	var current_room_code: String = ""
	if online != null and online.has_method("get_room"):
		var current_room_data: Dictionary = online.call("get_room")
		current_room_code = _get_online_room_code(current_room_data)
	var friend_ids: Dictionary = _get_online_social_id_lookup("get_online_friends")
	var incoming_request_ids: Dictionary = _get_online_social_id_lookup("get_incoming_friend_requests")
	var outgoing_request_ids: Dictionary = _get_online_social_id_lookup("get_outgoing_friend_requests")

	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = (player as Dictionary).duplicate(true)
		if bool(player_data.get("is_ai", false)):
			continue
		var player_id: String = str(player_data.get("id", player_data.get("client_id", ""))).strip_edges()
		var player_name: String = str(player_data.get("name", "Player")).strip_edges()
		if player_name == "":
			player_name = "Player"
		var player_login_id: String = str(player_data.get("login_id", player_data.get("player_login_id", ""))).strip_edges()
		var normalized_player_login_id: String = _normalize_online_identity_value(player_login_id)
		var normalized_player_name: String = _normalize_online_identity_value(player_name)
		var is_local_player: bool = player_id != "" and player_id == local_id
		if not is_local_player and normalized_local_login_id != "" and normalized_player_login_id == normalized_local_login_id:
			is_local_player = true
		if not is_local_player and normalized_local_name != "" and normalized_player_name == normalized_local_name and (normalized_player_login_id == "" or normalized_local_login_id == "" or normalized_player_login_id == normalized_local_login_id):
			is_local_player = true
		var seen_keys: Array = _get_online_player_seen_keys(player_data, player_id, player_name, is_local_player)
		if seen_keys.is_empty():
			continue
		if _online_player_seen(seen_ids, seen_keys):
			continue
		player_data["id"] = player_id
		player_data["name"] = player_name
		if player_login_id != "":
			player_data["login_id"] = player_login_id
		player_data["is_local"] = is_local_player
		player_data["is_friend"] = player_id != "" and friend_ids.has(player_id)
		player_data["incoming_friend_request"] = player_id != "" and incoming_request_ids.has(player_id)
		player_data["outgoing_friend_request"] = player_id != "" and outgoing_request_ids.has(player_id)
		var player_room_code: String = str(player_data.get("room_code", "")).strip_edges().to_upper()
		player_data["in_current_room"] = player_room_code != "" and current_room_code != "" and player_room_code == current_room_code
		player_data["can_invite"] = player_id != "" and not is_local_player and not bool(player_data.get("in_current_room", false))
		_mark_online_player_seen(seen_ids, seen_keys)
		entries.append(player_data)


func _get_online_social_id_lookup(method_name: String) -> Dictionary:
	var lookup: Dictionary = {}
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method(method_name):
		return lookup
	var value = online.call(method_name)
	if typeof(value) != TYPE_ARRAY:
		return lookup
	for entry in (value as Array):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var player_id: String = str((entry as Dictionary).get("id", (entry as Dictionary).get("client_id", ""))).strip_edges()
		if player_id != "":
			lookup[player_id] = true
	return lookup


func _collect_players_from_online_rooms() -> Array:
	var players: Array = []
	for room in online_latest_rooms:
		if typeof(room) != TYPE_DICTIONARY:
			continue
		var room_data: Dictionary = room as Dictionary
		var room_players: Array = room_data.get("players", [])
		var room_code: String = _get_online_room_code(room_data)
		var capacity: int = int(room_data.get("human_capacity", room_data.get("max_players", 2)))
		for player in room_players:
			if typeof(player) != TYPE_DICTIONARY:
				continue
			var player_data: Dictionary = (player as Dictionary).duplicate(true)
			player_data["room_code"] = room_code
			player_data["room_capacity"] = capacity
			player_data["in_room"] = true
			player_data["is_private"] = bool(room_data.get("is_private", false))
			player_data["party_state"] = str(room_data.get("party_state", "lobby"))
			players.append(player_data)
	return players


func _create_online_player_row(player_data: Dictionary, force_friend_actions: bool = false) -> Panel:
	var is_friend: bool = bool(player_data.get("is_friend", false)) or force_friend_actions
	var can_message: bool = is_friend and not bool(player_data.get("is_local", false)) and str(player_data.get("id", "")).strip_edges() != ""
	var accent: Color = Color(0.31, 0.97, 0.85, 0.88) if can_message or bool(player_data.get("can_invite", false)) else Color(0.72, 0.36, 1.0, 0.72)
	var row: Panel = Panel.new()
	row.custom_minimum_size = Vector2(0, 96)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_stylebox_override("panel", _make_online_card_style(Color(0.015, 0.03, 0.06, 0.76), accent, 10))

	var margin: MarginContainer = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 9)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_bottom", 9)
	row.add_child(margin)

	var line: HBoxContainer = HBoxContainer.new()
	line.add_theme_constant_override("separation", 10)
	margin.add_child(line)

	var player_name: String = str(player_data.get("name", "Player")).strip_edges()
	if player_name == "":
		player_name = "Player"
	var avatar: Label = _create_online_text_label(player_name.substr(0, 1).to_upper(), 24, Color(0.98, 0.99, 1.0, 1.0), ui_font)
	avatar.custom_minimum_size = Vector2(44, 48)
	avatar.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	avatar.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	avatar.add_theme_stylebox_override("normal", _make_online_card_style(Color(0.05, 0.04, 0.12, 0.78), accent, 8))
	line.add_child(avatar)

	var text_stack: VBoxContainer = VBoxContainer.new()
	text_stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_stack.add_theme_constant_override("separation", 0)
	line.add_child(text_stack)

	var name_label: Label = _create_online_text_label(player_name, 17, Color(0.98, 0.99, 1.0, 1.0), ui_font)
	name_label.clip_text = true
	text_stack.add_child(name_label)

	var status_label: Label = _create_online_text_label(_format_online_player_status(player_data), 12, Color(0.82, 0.9, 1.0, 0.86), ui_font)
	status_label.clip_text = true
	text_stack.add_child(status_label)

	var player_id: String = str(player_data.get("id", ""))
	var actions_stack: VBoxContainer = VBoxContainer.new()
	actions_stack.custom_minimum_size = Vector2(92, 0)
	actions_stack.add_theme_constant_override("separation", 6)
	line.add_child(actions_stack)

	var social_button: Button = Button.new()
	social_button.custom_minimum_size = Vector2(92, 34)
	social_button.text = _get_online_social_button_text(player_data, force_friend_actions)
	social_button.disabled = _online_social_button_disabled(player_data, force_friend_actions)
	_style_online_button(social_button, accent, 11)
	actions_stack.add_child(social_button)
	if not social_button.disabled:
		if bool(player_data.get("incoming_friend_request", false)):
			social_button.pressed.connect(_on_online_accept_friend_pressed.bind(player_id, player_name))
		elif can_message:
			social_button.pressed.connect(_on_online_message_friend_pressed.bind(player_id, player_name))
		else:
			social_button.pressed.connect(_on_online_request_friend_pressed.bind(player_id, player_name))

	var invite_button: Button = Button.new()
	invite_button.custom_minimum_size = Vector2(92, 34)
	invite_button.text = "YOU" if bool(player_data.get("is_local", false)) else "INVITE"
	invite_button.disabled = not bool(player_data.get("can_invite", false))
	_style_online_button(invite_button, accent, 11)
	actions_stack.add_child(invite_button)
	if not invite_button.disabled:
		invite_button.pressed.connect(_on_online_invite_player_pressed.bind(player_id, player_name))
	return row


func _get_online_social_button_text(player_data: Dictionary, force_friend_actions: bool = false) -> String:
	if bool(player_data.get("is_local", false)):
		return "YOU"
	if bool(player_data.get("incoming_friend_request", false)):
		return "ACCEPT"
	if bool(player_data.get("outgoing_friend_request", false)):
		return "PENDING"
	if bool(player_data.get("is_friend", false)) or force_friend_actions:
		return "CHAT"
	return "FRIEND"


func _online_social_button_disabled(player_data: Dictionary, force_friend_actions: bool = false) -> bool:
	if bool(player_data.get("is_local", false)):
		return true
	var player_id: String = str(player_data.get("id", "")).strip_edges()
	if player_id == "":
		return true
	if bool(player_data.get("outgoing_friend_request", false)):
		return true
	if bool(player_data.get("incoming_friend_request", false)):
		return false
	if bool(player_data.get("is_friend", false)) or force_friend_actions:
		return false
	return false


func _format_online_player_status(player_data: Dictionary) -> String:
	if bool(player_data.get("is_local", false)):
		return "Your account"
	if bool(player_data.get("incoming_friend_request", false)):
		return "Wants to be friends"
	if bool(player_data.get("outgoing_friend_request", false)):
		return "Friend request sent"
	if bool(player_data.get("is_friend", false)):
		return "Friend - %s" % ("online" if bool(player_data.get("connected", true)) else "offline")
	var code: String = str(player_data.get("room_code", "")).strip_edges()
	var party_state: String = str(player_data.get("party_state", "lobby")).capitalize()
	if bool(player_data.get("in_room", false)) and code != "":
		return "%s party %s" % [party_state, code]
	if bool(player_data.get("in_room", false)):
		return "%s party" % party_state
	return "Online"


func _on_online_invite_player_pressed(player_id: String, player_name: String) -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("invite_player"):
		if online_status_label != null:
			online_status_label.text = "Invites need the updated online service."
		return
	var error: Error = online.call("invite_player", player_id)
	if error == OK:
		online_invite_room_hold_active = true
		if online_status_label != null:
			online_status_label.text = "Invite sent to %s. Waiting for them to accept." % player_name
		if online_loading_panel != null:
			online_loading_panel.hide()
		_set_online_rooms_content_visible(true)
	else:
		if online_status_label != null:
			online_status_label.text = "Could not invite %s yet." % player_name


func _on_online_request_friend_pressed(player_id: String, player_name: String) -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("request_friend"):
		if online_status_label != null:
			online_status_label.text = "Friends need the updated online service."
		return
	var error: Error = online.call("request_friend", player_id)
	if online_status_label != null:
		online_status_label.text = "Friend request sent to %s." % player_name if error == OK else "Could not send friend request."


func _on_online_accept_friend_pressed(player_id: String, player_name: String) -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("accept_friend_request"):
		if online_status_label != null:
			online_status_label.text = "Friends need the updated online service."
		return
	var error: Error = online.call("accept_friend_request", player_id)
	if online_status_label != null:
		online_status_label.text = "%s is now your friend." % player_name if error == OK else "Could not accept friend request."


func _on_online_message_friend_pressed(player_id: String, player_name: String) -> void:
	_open_online_chat_for_friend(player_id, player_name)


func _open_online_chat_for_friend(player_id: String, player_name: String) -> void:
	online_chat_target_id = player_id.strip_edges()
	online_chat_target_name = player_name.strip_edges()
	if online_chat_target_name == "":
		online_chat_target_name = "Friend"
	online_chat_expanded = true
	_sync_online_chat_visibility()
	_refresh_online_chat_log()
	if online_chat_input != null:
		online_chat_input.grab_focus()


func _open_online_party_chat() -> void:
	online_chat_target_id = ""
	online_chat_target_name = ""
	online_chat_expanded = true
	_sync_online_chat_visibility()
	_refresh_online_chat_log()
	if online_chat_input != null:
		online_chat_input.grab_focus()


func _toggle_online_chat() -> void:
	var was_expanded: bool = online_chat_expanded
	online_chat_expanded = not online_chat_expanded
	if online_chat_expanded and not was_expanded:
		online_chat_target_id = ""
		online_chat_target_name = ""
	_sync_online_chat_visibility()
	if online_chat_expanded and online_chat_input != null:
		online_chat_input.grab_focus()


func _sync_online_chat_visibility() -> void:
	var loading_screen_active: bool = online_loading_panel != null and online_loading_panel.visible
	if online_chat_popup_panel != null:
		online_chat_popup_panel.visible = online_chat_expanded and not loading_screen_active
	if online_chat_expanded:
		online_chat_toast_timer = 0.0
		if online_chat_toast_panel != null:
			online_chat_toast_panel.hide()
	if online_chat_title_label != null:
		if online_chat_target_id != "":
			online_chat_title_label.text = "CHAT // %s" % online_chat_target_name.to_upper()
		else:
			online_chat_title_label.text = "PARTY CHAT"
	if online_chat_bubble_button != null:
		online_chat_bubble_button.visible = not loading_screen_active
		online_chat_bubble_button.text = "HIDE" if online_chat_expanded else "CHAT"
		online_chat_bubble_button.tooltip_text = "Hide party chat" if online_chat_expanded else "Open party chat"


func _on_online_chat_send_pressed() -> void:
	if online_chat_input == null:
		return
	_send_online_chat_message(online_chat_input.text)


func _on_online_chat_submitted(text_value: String) -> void:
	_send_online_chat_message(text_value)


func _on_online_loading_chat_send_pressed() -> void:
	if online_loading_chat_input == null:
		return
	_send_online_chat_message(online_loading_chat_input.text, true)


func _on_online_loading_chat_submitted(text_value: String) -> void:
	_send_online_chat_message(text_value, true)


func _send_online_chat_message(raw_text: String, force_party_chat: bool = false) -> void:
	var clean_text: String = _sanitize_online_chat_text(raw_text)
	if clean_text == "":
		return

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null or not online.has_method("send_chat_message"):
		if online_status_label != null:
			online_status_label.text = "Chat needs the updated online service."
		return
	var target_id: String = "" if force_party_chat else online_chat_target_id
	if target_id == "" and online.has_method("get_room"):
		var room_data: Dictionary = online.call("get_room")
		if room_data.is_empty():
			if online_status_label != null:
				online_status_label.text = "Join a party or select a friend to chat."
			return

	var error: Error = online.call("send_chat_message", clean_text, target_id)
	if error == OK:
		if online_chat_input != null:
			online_chat_input.clear()
		if online_loading_chat_input != null:
			online_loading_chat_input.clear()
	else:
		if online_status_label != null:
			online_status_label.text = "Chat message could not be sent."


func _on_online_chat_message_received(message: Dictionary) -> void:
	_append_online_chat_message(message)


func _append_online_chat_message(message: Dictionary) -> void:
	var clean_text: String = _sanitize_online_chat_text(str(message.get("text", "")))
	if clean_text == "":
		return
	var entry: Dictionary = message.duplicate(true)
	entry["text"] = clean_text
	if str(entry.get("sender_name", "")).strip_edges() == "":
		entry["sender_name"] = "Player"
	online_chat_history.append(entry)
	while online_chat_history.size() > 24:
		online_chat_history.pop_front()
	_refresh_online_chat_log()
	if not bool(entry.get("is_local", false)):
		_show_online_chat_toast(entry)


func _refresh_online_chat_log() -> void:
	_refresh_online_chat_stack(online_chat_log_stack, true)
	_refresh_online_chat_stack(online_loading_chat_log_stack, false)


func _refresh_online_chat_stack(target_stack: VBoxContainer, include_direct_messages: bool) -> void:
	if target_stack == null:
		return
	_clear_node_children(target_stack)

	var visible_history: Array = []
	for entry in online_chat_history:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var entry_data: Dictionary = entry as Dictionary
		var is_direct: bool = bool(entry_data.get("is_direct", false))
		if not include_direct_messages and is_direct:
			continue
		if include_direct_messages and online_chat_target_id != "":
			if not is_direct:
				continue
			var sender_id: String = str(entry_data.get("sender_id", ""))
			var target_id: String = str(entry_data.get("target_id", ""))
			if sender_id != online_chat_target_id and target_id != online_chat_target_id:
				continue
		elif include_direct_messages and is_direct:
			continue
		visible_history.append(entry_data)

	if visible_history.is_empty():
		var empty_text: String = "No messages with %s yet." % online_chat_target_name if include_direct_messages and online_chat_target_id != "" else "No party messages yet."
		var empty_label: Label = _create_online_text_label(empty_text, 12, Color(0.82, 0.9, 1.0, 0.72), ui_font)
		empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		target_stack.add_child(empty_label)
		return

	var lines: PackedStringArray = PackedStringArray()
	for entry in visible_history:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var message_data: Dictionary = entry as Dictionary
		var sender_text: String = str(message_data.get("sender_name", "Player")).to_upper()
		if bool(message_data.get("is_direct", false)):
			sender_text = "DM // %s" % sender_text
		lines.append("%s: %s" % [sender_text, str(message_data.get("text", ""))])

	var page_label: Label = _create_online_text_label("\n".join(lines), 13, Color(0.94, 0.98, 1.0, 0.96), ui_font)
	page_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	target_stack.add_child(page_label)


func _show_online_chat_toast(message_data: Dictionary) -> void:
	if online_chat_expanded and online_chat_popup_panel != null and online_chat_popup_panel.visible:
		return
	if online_chat_toast_panel == null:
		_build_online_chat_toast()
	if online_chat_toast_panel == null:
		return

	var sender_name: String = str(message_data.get("sender_name", "Player")).strip_edges()
	if sender_name == "":
		sender_name = "Player"
	var message_text: String = _sanitize_online_chat_text(str(message_data.get("text", "")))
	var is_direct: bool = bool(message_data.get("is_direct", false))
	if online_chat_toast_sender_label != null:
		online_chat_toast_sender_label.text = "%s FROM %s" % ["DM" if is_direct else "PARTY", sender_name.to_upper()]
	if online_chat_toast_text_label != null:
		online_chat_toast_text_label.text = message_text
	online_chat_toast_target_id = str(message_data.get("sender_id", "")) if is_direct else ""
	online_chat_toast_target_name = sender_name if is_direct else ""
	online_chat_toast_timer = ONLINE_CHAT_TOAST_SECONDS
	online_chat_toast_panel.modulate = Color(1, 1, 1, 1)
	online_chat_toast_panel.show()


func _process_online_chat_toast(delta: float) -> void:
	if online_chat_toast_timer <= 0.0:
		return
	online_chat_toast_timer -= delta
	if online_chat_toast_timer <= 0.0:
		online_chat_toast_timer = 0.0
		if online_chat_toast_panel != null:
			online_chat_toast_panel.hide()


func _on_online_chat_toast_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event as InputEventMouseButton
		if not mouse_event.pressed or mouse_event.button_index != MOUSE_BUTTON_LEFT:
			return
		if online_chat_toast_target_id != "":
			_open_online_chat_for_friend(online_chat_toast_target_id, online_chat_toast_target_name)
		else:
			_open_online_party_chat()
		online_chat_toast_timer = 0.0
		if online_chat_toast_panel != null:
			online_chat_toast_panel.hide()


func _sanitize_online_chat_text(text_value: String) -> String:
	var clean_text: String = text_value.strip_edges()
	clean_text = clean_text.replace("\n", " ").replace("\r", " ").replace("\t", " ")
	while clean_text.contains("  "):
		clean_text = clean_text.replace("  ", " ")
	return clean_text.left(160)


func _get_online_room_code(room_data: Dictionary) -> String:
	return str(room_data.get("code", room_data.get("room_code", room_data.get("party_code", "")))).strip_edges().to_upper()


func _on_online_listed_room_pressed(room_code: String, human_capacity: int, is_private: bool) -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null:
		return
	if room_code == "":
		if online_status_label != null:
			online_status_label.text = "Enter a private code to join that party."
		return
	if online_status_label != null:
		var join_kind: String = "private" if is_private else "%d-player public" % human_capacity
		online_status_label.text = "Joining %s party %s..." % [join_kind, room_code]
	var error: Error = ERR_UNAVAILABLE
	if online.has_method("join_private_room"):
		error = online.call("join_private_room", room_code)
	elif online.has_method("join_room"):
		error = online.call("join_room", room_code)
	if error != OK and online_status_label != null:
		online_status_label.text = "Could not join party %s. Refresh and try again." % room_code


func _describe_online_room(room_data: Dictionary) -> String:
	if room_data.is_empty():
		return "No party joined yet."
	var players: Array = room_data.get("players", [])
	var capacity: int = int(room_data.get("human_capacity", room_data.get("max_players", 2)))
	var room_kind: String = "PRIVATE" if bool(room_data.get("is_private", false)) else "OPEN"
	var code: String = str(room_data.get("room_code", room_data.get("party_code", "")))
	var code_text: String = " | CODE %s" % code if code != "" else ""
	var authority_text: String = " | SERVER AUTHORITY" if bool(room_data.get("server_authoritative", false)) else ""
	return "%s PARTY | %d/%d PLAYERS%s%s" % [room_kind, players.size(), capacity, code_text, authority_text]


func _show_online_match_loading(room: Dictionary, auto_start_if_public_host: bool) -> void:
	if online_loading_panel == null:
		return
	if not _online_room_has_human_player(room):
		if online_status_label != null:
			online_status_label.text = "Waiting for the server to place you in the party..."
		return
	online_loading_panel.show()
	_set_online_rooms_content_visible(false)
	online_match_start_requested = false

	var is_private: bool = bool(room.get("is_private", false))
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var is_host: bool = online != null and online.has_method("is_host") and bool(online.call("is_host"))
	online_match_start_timer = -1.0
	online_start_fallback_timer = -1.0
	if is_private:
		_configure_online_loading_screen("PRIVATE PARTY", "Party ready. Share the code, then start when at least 2 players are in.", 24.0, is_host)
	else:
		_configure_online_loading_screen("PUBLIC PARTY", "Finding players. Host can start once 2 players are in.", 18.0, is_host)
	_update_online_loading_start_button(room)
	_update_online_loading_panel(room)


func _online_room_has_human_player(room: Dictionary) -> bool:
	var players: Array = room.get("players", [])
	if not players.is_empty():
		return true
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("get_players"):
		var manager_players: Array = online.call("get_players")
		return not manager_players.is_empty()
	return false


func _get_online_room_human_count(room: Dictionary) -> int:
	var players: Array = room.get("players", [])
	if not players.is_empty():
		return players.size()
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("get_players"):
		var manager_players: Array = online.call("get_players")
		return manager_players.size()
	return 0


func _update_online_loading_panel(room: Dictionary) -> void:
	if online_loading_panel == null:
		return

	var code: String = str(room.get("code", room.get("room_code", room.get("party_code", ""))))
	var room_kind: String = "PRIVATE PARTY" if bool(room.get("is_private", false)) else "OPEN PARTY"
	if online_loading_title_label != null:
		online_loading_title_label.text = room_kind if code == "" else "%s %s" % [room_kind, code]

	if online_loading_marble_label != null:
		online_loading_marble_label.text = "Your marble: %s" % _get_selected_marble_display_name()
		online_loading_marble_label.show()

	_update_online_loading_slots(room)
	if online_loading_slots_grid != null:
		online_loading_slots_grid.show()

	if online_loading_players_label != null:
		online_loading_players_label.text = _format_online_loading_players(room)
		online_loading_players_label.show()
	_update_online_loading_start_button(room)
	_update_online_waiting_status(room)
	_sync_online_loading_chat_visibility(room)


func _update_online_loading_start_button(room: Dictionary) -> void:
	if online_loading_start_button == null:
		return
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var is_host: bool = online != null and online.has_method("is_host") and bool(online.call("is_host"))
	var human_count: int = _get_online_room_human_count(room)
	online_loading_start_button.visible = is_host
	online_loading_start_button.disabled = human_count < 2
	online_loading_start_button.text = "START GAME" if human_count >= 2 else "WAITING FOR PLAYERS"


func _update_online_waiting_status(room: Dictionary) -> void:
	if online_loading_status_label == null:
		return
	var players: Array = room.get("players", [])
	var capacity: int = int(room.get("human_capacity", room.get("max_players", 5)))
	var found_count: int = players.size()
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var is_host: bool = online != null and online.has_method("is_host") and bool(online.call("is_host"))
	if bool(room.get("is_private", false)):
		if found_count < 2:
			online_loading_status_label.text = "%d/%d players in party. Need 2 players to start." % [found_count, capacity]
		else:
			online_loading_status_label.text = "%d/%d players in party. Host can start." % [found_count, capacity]
		if online_loading_progress_bar != null:
			online_loading_progress_bar.value = clampf(lerpf(12.0, 72.0, float(found_count) / maxf(float(capacity), 1.0)), 0.0, 100.0)
		return
	if found_count >= capacity:
		online_loading_status_label.text = "Party full. Preparing field..."
	elif found_count >= 2 and is_host:
		online_loading_status_label.text = "%d/%d players found. Start now or wait for more players." % [found_count, capacity]
	elif found_count >= 2:
		online_loading_status_label.text = "%d/%d players found. Waiting for host to start." % [found_count, capacity]
	else:
		online_loading_status_label.text = "%d/%d players found. Need one more player." % [found_count, capacity]
	if online_loading_progress_bar != null:
		online_loading_progress_bar.value = clampf(lerpf(12.0, 92.0, float(found_count) / maxf(float(capacity), 1.0)), 0.0, 100.0)


func _update_online_loading_slots(room: Dictionary) -> void:
	if online_loading_slot_name_labels.is_empty() or online_loading_slot_status_labels.is_empty():
		return

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var local_id: String = ""
	if online != null and online.has_method("get_local_client_id"):
		local_id = str(online.call("get_local_client_id"))

	var players: Array = room.get("players", [])
	var human_capacity: int = clampi(int(room.get("human_capacity", room.get("max_players", 5))), 1, 5)
	var entries: Array = []
	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = player as Dictionary
		var player_id: String = str(player_data.get("id", ""))
		var player_name: String = str(player_data.get("name", "Player"))
		var status_text: String = "PLAYER"
		if player_id == local_id and bool(player_data.get("is_host", false)):
			status_text = "YOU / HOST"
		elif player_id == local_id:
			status_text = "YOU"
		elif bool(player_data.get("is_host", false)):
			status_text = "HOST"
		entries.append({
			"name": player_name,
			"status": status_text,
			"color": Color(0.96, 0.99, 1.0, 1.0),
			"status_color": Color(0.31, 0.97, 0.85, 0.98)
		})

	var room_started: bool = bool(room.get("started", false)) or online_match_start_requested
	var searching_slots: int = 0 if room_started else max(human_capacity - entries.size(), 0)
	for _index in range(searching_slots):
		entries.append({
			"name": "SEARCHING",
			"status": "FINDING PLAYER",
			"color": Color(0.72, 0.9, 1.0, 0.92),
			"status_color": Color(0.31, 0.97, 0.85, 0.9)
		})

	for slot_index in range(5):
		var name_label: Label = online_loading_slot_name_labels[slot_index] as Label
		var status_label: Label = online_loading_slot_status_labels[slot_index] as Label
		if name_label == null or status_label == null:
			continue
		if slot_index < entries.size():
			var entry: Dictionary = entries[slot_index] as Dictionary
			name_label.text = str(entry.get("name", "OPEN"))
			status_label.text = str(entry.get("status", "WAITING"))
			name_label.add_theme_color_override("font_color", entry.get("color", Color(0.96, 0.99, 1.0, 1.0)))
			status_label.add_theme_color_override("font_color", entry.get("status_color", Color(0.31, 0.97, 0.85, 0.95)))
		else:
			name_label.text = "OPEN"
			status_label.text = "WAITING"
			name_label.add_theme_color_override("font_color", Color(0.72, 0.9, 1.0, 0.7))
			status_label.add_theme_color_override("font_color", Color(0.72, 0.9, 1.0, 0.7))


func _get_ai_slot_name(ai_index: int, ai_players: Array) -> String:
	if ai_index >= 0 and ai_index < ai_players.size() and typeof(ai_players[ai_index]) == TYPE_DICTIONARY:
		return str((ai_players[ai_index] as Dictionary).get("name", "AI %d" % (ai_index + 1)))
	return "AI %d" % (ai_index + 1)


func _format_online_loading_players(room: Dictionary) -> String:
	var players: Array = room.get("players", [])
	var human_capacity: int = clampi(int(room.get("human_capacity", room.get("max_players", 5))), 1, 5)
	var searching_count: int = max(human_capacity - players.size(), 0)
	if bool(room.get("started", false)) or online_match_start_requested:
		return "%d players ready" % players.size()
	if searching_count > 0:
		return "%d/%d players found | %d open" % [players.size(), human_capacity, searching_count]
	return "%d/%d players ready" % [players.size(), human_capacity]


func _get_selected_marble_display_name() -> String:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("get_selected_marble_preset"):
		var preset: Dictionary = customization.call("get_selected_marble_preset")
		return str(preset.get("name", "Selected Marble"))
	return "Selected Marble"


func _on_host_lan_pressed() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("has_player_name") and not customization.call("has_player_name"):
		_show_player_name_popup()
		return

	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan == null or not lan.has_method("create_online_room"):
		push_error("LanMultiplayer autoload is missing.")
		return

	_configure_online_create_popup()
	_show_lan_popup()


func _on_join_lan_pressed() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("has_player_name") and not customization.call("has_player_name"):
		_show_player_name_popup()
		return

	_configure_online_join_popup()
	if lan_popup != null:
		_show_lan_popup()
	if lan_ip_input != null and not OS.has_feature("mobile"):
		lan_ip_input.grab_focus()


func _on_lan_connect_pressed() -> void:
	var address: String = lan_ip_input.text.strip_edges() if lan_ip_input != null else ""
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan == null:
		return

	if lan_connect_button != null:
		lan_connect_button.disabled = true

	var error: Error = OK
	match lan_popup_mode:
		"online_create":
			if lan_status_label != null:
				lan_status_label.text = "Creating online party..."
			if lan_connect_button != null:
				lan_connect_button.text = "CREATING"
			if lan.has_method("create_online_room"):
				error = lan.call("create_online_room")
			else:
				error = ERR_UNAVAILABLE
		"online_join":
			if lan_status_label != null:
				lan_status_label.text = "Joining party %s..." % address.to_upper()
			if lan.has_method("join_online_room"):
				error = lan.call("join_online_room", address)
			else:
				error = ERR_UNAVAILABLE
		_:
			error = ERR_UNAVAILABLE

	if error != OK and lan_connect_button != null:
		lan_connect_button.disabled = false
		lan_connect_button.text = "JOIN PARTY" if lan_popup_mode == "online_join" else "CREATE PARTY"


func _on_lan_ip_submitted(_text_value: String) -> void:
	_on_lan_connect_pressed()


func _on_lan_port_submitted(_text_value: String) -> void:
	_on_lan_connect_pressed()


func _start_main_scene() -> void:
	_stop_menu_music_for_gameplay()
	if main_scene_path != "" and ResourceLoader.exists(main_scene_path):
		get_tree().change_scene_to_file(main_scene_path)
	else:
		push_error("Main scene not found at: %s" % main_scene_path)


func _stop_menu_music_for_gameplay() -> void:
	menu_music_should_play = false
	if menu_music_player != null:
		menu_music_player.stop()

	var root: Window = get_tree().root
	if root != null:
		for child in root.get_children():
			var root_music_player: AudioStreamPlayer = child as AudioStreamPlayer
			if root_music_player != null and str(root_music_player.name).begins_with("MenuMusicPlayer"):
				root_music_player.stop()

	var game_manager: Node = get_node_or_null("/root/GameManager")
	if game_manager != null and game_manager.has_method("stop_menu_music"):
		game_manager.call("stop_menu_music")


func _bind_lan_signals() -> void:
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan == null:
		return
	if lan.has_signal("host_started") and not lan.host_started.is_connected(_on_lan_host_started):
		lan.host_started.connect(_on_lan_host_started)
	if lan.has_signal("joined_server") and not lan.joined_server.is_connected(_on_lan_joined_server):
		lan.joined_server.connect(_on_lan_joined_server)
	if lan.has_signal("connection_failed") and not lan.connection_failed.is_connected(_on_lan_connection_failed):
		lan.connection_failed.connect(_on_lan_connection_failed)
	if lan.has_signal("connection_status_changed") and not lan.connection_status_changed.is_connected(_on_lan_status_changed):
		lan.connection_status_changed.connect(_on_lan_status_changed)
	if lan.has_signal("discovery_status_changed") and not lan.discovery_status_changed.is_connected(_on_lan_discovery_status_changed):
		lan.discovery_status_changed.connect(_on_lan_discovery_status_changed)
	if lan.has_signal("host_discovered") and not lan.host_discovered.is_connected(_on_lan_host_discovered):
		lan.host_discovered.connect(_on_lan_host_discovered)
	if lan.has_signal("online_room_created") and not lan.online_room_created.is_connected(_on_online_room_created):
		lan.online_room_created.connect(_on_online_room_created)
	if lan.has_signal("online_room_ready") and not lan.online_room_ready.is_connected(_on_online_room_ready):
		lan.online_room_ready.connect(_on_online_room_ready)
	if lan.has_signal("online_room_failed") and not lan.online_room_failed.is_connected(_on_online_room_failed):
		lan.online_room_failed.connect(_on_online_room_failed)
	if lan.has_signal("disconnected_from_server") and not lan.disconnected_from_server.is_connected(_on_lan_disconnected):
		lan.disconnected_from_server.connect(_on_lan_disconnected)


func _bind_online_signals() -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null:
		return
	if online.has_signal("connected_to_server") and not online.connected_to_server.is_connected(_on_online_connected):
		online.connected_to_server.connect(_on_online_connected)
	if online.has_signal("connection_status_changed") and not online.connection_status_changed.is_connected(_on_online_status_changed):
		online.connection_status_changed.connect(_on_online_status_changed)
	if online.has_signal("connection_failed") and not online.connection_failed.is_connected(_on_online_connection_failed):
		online.connection_failed.connect(_on_online_connection_failed)
	if online.has_signal("rooms_updated") and not online.rooms_updated.is_connected(_on_online_rooms_updated):
		online.rooms_updated.connect(_on_online_rooms_updated)
	if online.has_signal("online_players_updated") and not online.online_players_updated.is_connected(_on_online_players_updated):
		online.online_players_updated.connect(_on_online_players_updated)
	if online.has_signal("room_created") and not online.room_created.is_connected(_on_online_room_created_new):
		online.room_created.connect(_on_online_room_created_new)
	if online.has_signal("room_joined") and not online.room_joined.is_connected(_on_online_room_joined):
		online.room_joined.connect(_on_online_room_joined)
	if online.has_signal("room_updated") and not online.room_updated.is_connected(_on_online_room_updated):
		online.room_updated.connect(_on_online_room_updated)
	if online.has_signal("invite_sent") and not online.invite_sent.is_connected(_on_online_invite_sent):
		online.invite_sent.connect(_on_online_invite_sent)
	if online.has_signal("room_invite_received") and not online.room_invite_received.is_connected(_on_online_room_invite_received):
		online.room_invite_received.connect(_on_online_room_invite_received)
	if online.has_signal("room_invite_declined") and not online.room_invite_declined.is_connected(_on_online_room_invite_declined):
		online.room_invite_declined.connect(_on_online_room_invite_declined)
	if online.has_signal("chat_message_received") and not online.chat_message_received.is_connected(_on_online_chat_message_received):
		online.chat_message_received.connect(_on_online_chat_message_received)
	if online.has_signal("friends_updated") and not online.friends_updated.is_connected(_on_online_friends_updated):
		online.friends_updated.connect(_on_online_friends_updated)
	if online.has_signal("friend_request_received") and not online.friend_request_received.is_connected(_on_online_friend_request_received):
		online.friend_request_received.connect(_on_online_friend_request_received)
	if online.has_signal("friend_request_sent") and not online.friend_request_sent.is_connected(_on_online_friend_request_sent):
		online.friend_request_sent.connect(_on_online_friend_request_sent)
	if online.has_signal("friend_request_accepted") and not online.friend_request_accepted.is_connected(_on_online_friend_request_accepted):
		online.friend_request_accepted.connect(_on_online_friend_request_accepted)
	if online.has_signal("game_started") and not online.game_started.is_connected(_on_online_game_started):
		online.game_started.connect(_on_online_game_started)
	if online.has_signal("disconnected_from_server") and not online.disconnected_from_server.is_connected(_on_online_disconnected):
		online.disconnected_from_server.connect(_on_online_disconnected)


func _on_online_connected(_client_id: String) -> void:
	if online_status_label != null:
		online_status_label.text = "Connected. Loading always-open parties..."


func _on_online_status_changed(message: String) -> void:
	if online_status_label != null and online_rooms_page != null and online_rooms_page.visible:
		online_status_label.text = message


func _on_online_connection_failed(message: String) -> void:
	startup_server_ready = true
	var startup_probe_active: bool = startup_loading_timer >= 0.0 and startup_loading_panel != null and startup_loading_panel.visible
	if online_status_label != null:
		online_status_label.text = message
	if startup_probe_active:
		return
	if online_rooms_page != null and not online_rooms_page.visible:
		_show_online_rooms_page()
	_refresh_online_rooms_view()


func _on_online_rooms_updated(rooms: Array) -> void:
	startup_server_ready = true
	online_latest_rooms = rooms.duplicate(true)
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("get_online_players"):
		var online_players_value = online.call("get_online_players")
		if typeof(online_players_value) == TYPE_ARRAY:
			online_latest_players = (online_players_value as Array).duplicate(true)
	if online_status_label != null and online_rooms_page != null and online_rooms_page.visible:
		var online_players: int = online.call("get_online_player_count") if online != null and online.has_method("get_online_player_count") else _count_players_in_online_rooms(online_latest_rooms)
		var open_parties: int = online.call("get_open_party_count") if online != null and online.has_method("get_open_party_count") else online_latest_rooms.size()
		online_status_label.text = "%d players online | %d open parties | server authoritative" % [online_players, open_parties]
	_refresh_online_rooms_view()
	_maybe_follow_invite_host(online_latest_players)


func _on_online_players_updated(players: Array) -> void:
	online_latest_players = players.duplicate(true)
	_refresh_online_stat_display()
	_refresh_online_players_list()
	_refresh_online_friends_list()
	_refresh_online_friend_requests_list()
	_maybe_follow_invite_host(online_latest_players)


func _on_online_room_created_new(room: Dictionary, code: String) -> void:
	if online_status_label != null:
		online_status_label.text = "Private party created. Code: %s" % code
	online_chat_history.clear()
	_refresh_online_chat_log()
	_show_online_match_loading(room, false)
	_refresh_online_rooms_view()


func _on_online_room_joined(room: Dictionary) -> void:
	if _should_hold_online_invite_room(room):
		online_accepting_invite_room = false
		online_invite_room_hold_active = true
		online_invite_room_code = _get_online_room_code(room)
		if online_loading_panel != null:
			online_loading_panel.hide()
		_set_online_rooms_content_visible(true)
		online_chat_history.clear()
		_refresh_online_chat_log()
		_update_online_invite_lobby_status(room)
		_refresh_online_rooms_view()
		return

	if online_auto_following_invite_host:
		online_auto_following_invite_host = false
		online_invite_follow_host_id = ""
		online_invite_follow_host_name = ""

	if online_status_label != null:
		if bool(room.get("is_private", false)):
			online_status_label.text = "Private party joined."
		else:
			online_status_label.text = "Joined public party. Waiting for players..."
	online_chat_history.clear()
	_refresh_online_chat_log()
	_show_online_match_loading(room, true)
	_refresh_online_rooms_view()


func _on_online_room_updated(_room: Dictionary) -> void:
	if _should_hold_online_invite_room(_room):
		if online_loading_panel != null:
			online_loading_panel.hide()
		_set_online_rooms_content_visible(true)
		_update_online_invite_lobby_status(_room)
		_refresh_online_rooms_view()
		return
	if online_loading_panel != null and online_loading_panel.visible:
		_update_online_loading_panel(_room)
	_refresh_online_rooms_view()


func _should_hold_online_invite_room(room: Dictionary) -> bool:
	if room.is_empty():
		return false
	if bool(room.get("started", false)):
		return false
	if bool(room.get("invite_room", false)):
		return true
	var code: String = _get_online_room_code(room)
	if online_invite_room_hold_active and bool(room.get("is_private", false)):
		return online_invite_room_code == "" or code == online_invite_room_code
	return online_accepting_invite_room and bool(room.get("is_private", false))


func _update_online_invite_lobby_status(room: Dictionary) -> void:
	if online_status_label == null:
		return
	var players: Array = room.get("players", [])
	var code: String = _get_online_room_code(room)
	if players.size() >= 2:
		online_status_label.text = "Party %s is together. Choose a room or invite more players." % code
	else:
		online_status_label.text = "Party %s is waiting for the invited player." % code


func _release_online_invite_room_hold() -> void:
	online_invite_room_hold_active = false
	online_invite_room_code = ""
	online_accepting_invite_room = false
	online_invite_follow_host_id = ""
	online_invite_follow_host_name = ""
	online_auto_following_invite_host = false


func _maybe_follow_invite_host(players: Array) -> void:
	if online_invite_follow_host_id == "" or online_auto_following_invite_host:
		return

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online == null:
		return

	var current_room: Dictionary = {}
	if online.has_method("get_room"):
		current_room = online.call("get_room")
	if current_room.is_empty() or not _should_hold_online_invite_room(current_room):
		return
	if bool(current_room.get("invite_room", false)):
		return

	var current_code: String = _get_online_room_code(current_room)
	if current_code == "":
		return

	var host_room_code: String = ""
	for player in players:
		if typeof(player) != TYPE_DICTIONARY:
			continue
		var player_data: Dictionary = player as Dictionary
		var player_id: String = str(player_data.get("id", player_data.get("client_id", ""))).strip_edges()
		if player_id != online_invite_follow_host_id:
			continue
		if not bool(player_data.get("in_room", false)):
			return
		host_room_code = str(player_data.get("room_code", "")).strip_edges().to_upper()
		break

	if host_room_code == "" or host_room_code == current_code:
		return

	online_auto_following_invite_host = true
	online_invite_room_hold_active = false
	online_invite_room_code = ""
	online_accepting_invite_room = false
	if online_status_label != null:
		var host_name: String = online_invite_follow_host_name if online_invite_follow_host_name != "" else "party host"
		online_status_label.text = "Following %s to party %s..." % [host_name, host_room_code]

	var error: Error = ERR_UNAVAILABLE
	if online.has_method("join_room"):
		error = online.call("join_room", host_room_code)
	elif online.has_method("join_private_room"):
		error = online.call("join_private_room", host_room_code)

	if error != OK:
		online_auto_following_invite_host = false
		if online_status_label != null:
			online_status_label.text = "Could not follow party host to %s." % host_room_code


func _on_online_invite_sent(_target_id: String, target_name: String, room_code: String) -> void:
	online_invite_room_hold_active = true
	online_invite_room_code = room_code.strip_edges().to_upper()
	if online_loading_panel != null:
		online_loading_panel.hide()
	_set_online_rooms_content_visible(true)
	if online_status_label != null:
		online_status_label.text = "Invite sent to %s. Waiting for them to accept before loading." % target_name
	_refresh_online_rooms_view()


func _on_online_friends_updated(_friends: Array, _incoming_requests: Array, _outgoing_requests: Array) -> void:
	_refresh_online_players_list()
	_refresh_online_friends_list()
	_refresh_online_friend_requests_list()


func _on_online_friend_request_received(request: Dictionary) -> void:
	var player_name: String = str(request.get("name", "Player"))
	if online_status_label != null:
		online_status_label.text = "%s sent you a friend request." % player_name
	_show_online_chat_toast({
		"sender_name": player_name,
		"text": "Friend request received",
		"is_direct": false,
		"is_local": false
	})
	_refresh_online_friend_requests_list()


func _on_online_friend_request_sent(target: Dictionary) -> void:
	var player_name: String = str(target.get("name", "Player"))
	if online_status_label != null:
		online_status_label.text = "Friend request sent to %s." % player_name
	_refresh_online_players_list()
	_refresh_online_friend_requests_list()


func _on_online_friend_request_accepted(friend: Dictionary) -> void:
	var player_name: String = str(friend.get("name", "Player"))
	if online_status_label != null:
		online_status_label.text = "%s is now your friend." % player_name
	_refresh_online_players_list()
	_refresh_online_friends_list()
	_refresh_online_friend_requests_list()


func _on_online_room_invite_received(invite: Dictionary) -> void:
	var inviter_name: String = str(invite.get("from_name", "Player"))
	var room_code: String = str(invite.get("room_code", invite.get("code", ""))).strip_edges().to_upper()
	if online_private_code_input != null and room_code != "":
		online_private_code_input.text = room_code
	if online_status_label != null:
		online_status_label.text = "%s invited you to party %s." % [inviter_name, room_code]
	_show_online_invite_popup(invite)


func _on_online_room_invite_declined(_target_id: String, target_name: String, room_code: String) -> void:
	if online_status_label != null:
		var code_text: String = " for party %s" % room_code if room_code != "" else ""
		online_status_label.text = "%s declined your invite%s." % [target_name, code_text]


func _show_online_invite_popup(invite: Dictionary) -> void:
	if online_rooms_page == null:
		_ensure_online_rooms_page()
	if online_rooms_page == null:
		return
	if online_invite_popup_panel == null or not is_instance_valid(online_invite_popup_panel):
		_build_online_invite_popup()
	if online_invite_popup_panel == null:
		return

	if not online_rooms_page.visible:
		_show_online_rooms_page()

	online_pending_invite = invite.duplicate(true)
	var inviter_name: String = str(invite.get("from_name", "Player")).strip_edges()
	if inviter_name == "":
		inviter_name = "Player"
	var room_code: String = str(invite.get("room_code", invite.get("code", ""))).strip_edges().to_upper()
	if online_invite_popup_title_label != null:
		online_invite_popup_title_label.text = "PARTY INVITE"
	if online_invite_popup_message_label != null:
		var code_text: String = "\nCode: %s" % room_code if room_code != "" else ""
		online_invite_popup_message_label.text = "%s invited you to join their party.%s" % [inviter_name, code_text]
	online_invite_popup_panel.show()


func _hide_online_invite_popup() -> void:
	if online_invite_popup_panel != null:
		online_invite_popup_panel.hide()


func _on_online_invite_accept_pressed() -> void:
	if online_pending_invite.is_empty():
		_hide_online_invite_popup()
		return
	var room_code: String = str(online_pending_invite.get("room_code", online_pending_invite.get("code", ""))).strip_edges().to_upper()
	var inviter_id: String = str(online_pending_invite.get("from_id", "")).strip_edges()
	var inviter_name: String = str(online_pending_invite.get("from_name", "Player")).strip_edges()
	_hide_online_invite_popup()
	if room_code == "":
		if online_status_label != null:
			online_status_label.text = "Invite is missing a party code."
		online_pending_invite.clear()
		return

	if online_private_code_input != null:
		online_private_code_input.text = room_code
	if online_status_label != null:
		online_status_label.text = "Joining invited party %s..." % room_code

	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var error: Error = ERR_UNAVAILABLE
	online_accepting_invite_room = true
	online_invite_follow_host_id = inviter_id
	online_invite_follow_host_name = inviter_name
	if online != null and online.has_method("join_private_room"):
		error = online.call("join_private_room", room_code)
	elif online != null and online.has_method("join_room"):
		error = online.call("join_room", room_code)
	if error != OK and online_status_label != null:
		online_accepting_invite_room = false
		online_invite_follow_host_id = ""
		online_invite_follow_host_name = ""
		online_status_label.text = "Could not join invited party %s." % room_code
	online_pending_invite.clear()


func _on_online_invite_decline_pressed() -> void:
	if online_pending_invite.is_empty():
		_hide_online_invite_popup()
		return
	var inviter_id: String = str(online_pending_invite.get("from_id", "")).strip_edges()
	var room_code: String = str(online_pending_invite.get("room_code", online_pending_invite.get("code", ""))).strip_edges().to_upper()
	var inviter_name: String = str(online_pending_invite.get("from_name", "Player")).strip_edges()
	_hide_online_invite_popup()
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("decline_room_invite") and inviter_id != "":
		online.call("decline_room_invite", inviter_id, room_code)
	if online_status_label != null:
		online_status_label.text = "Declined %s's party invite." % inviter_name
	online_pending_invite.clear()


func _on_online_game_started(_players: Array, _ai_count: int) -> void:
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	var room_data: Dictionary = {}
	if online != null and online.has_method("get_room"):
		room_data = online.call("get_room")
	if online_rooms_page != null:
		online_rooms_page.show()
	if online_loading_panel != null:
		online_loading_panel.show()
	_set_online_rooms_content_visible(false)
	if not room_data.is_empty():
		_update_online_loading_panel(room_data)
	if online_loading_start_button != null:
		online_loading_start_button.hide()
	if online_loading_cancel_button != null:
		online_loading_cancel_button.hide()
	online_match_start_timer = -1.0
	online_start_fallback_timer = -1.0
	_begin_online_scene_loading(ONLINE_SCENE_LOAD_DELAY_SECONDS, "Preparing field...")


func _on_online_disconnected() -> void:
	online_latest_rooms.clear()
	online_latest_players.clear()
	online_chat_history.clear()
	online_pending_invite.clear()
	_release_online_invite_room_hold()
	_hide_online_invite_popup()
	_refresh_online_chat_log()
	_refresh_online_rooms_view()


func _on_lan_host_started(_port: int) -> void:
	_refresh_lan_status()


func _on_lan_joined_server() -> void:
	if lan_popup != null:
		lan_popup.hide()
	_start_main_scene()


func _on_lan_connection_failed(message: String) -> void:
	if lan_connect_button != null:
		lan_connect_button.disabled = false
	if lan_status_label != null:
		lan_status_label.text = message
	if lan_popup != null:
		_show_lan_popup()


func _on_online_room_created(room_code: String) -> void:
	lan_popup_mode = "online_create"
	if lan_popup != null:
		lan_popup.title = "Online Party"
	if lan_heading_label != null:
		lan_heading_label.text = "Share this party code"
	if lan_ip_input != null:
		lan_ip_input.text = room_code
		lan_ip_input.editable = false
		lan_ip_input.show()
	if lan_port_input != null:
		lan_port_input.hide()
	if lan_connect_button != null:
		lan_connect_button.disabled = true
		lan_connect_button.text = "WAITING"
	if lan_status_label != null:
		lan_status_label.text = "Party code: %s. Waiting for your friend..." % room_code


func _on_online_room_ready(_room_code: String, _host_peer_id: int, _guest_peer_id: int) -> void:
	if lan_popup != null:
		lan_popup.hide()
	_start_main_scene()


func _on_online_room_failed(message: String) -> void:
	if lan_connect_button != null:
		lan_connect_button.disabled = false
		lan_connect_button.text = "JOIN PARTY" if lan_popup_mode == "online_join" else "CREATE PARTY"
	if lan_ip_input != null:
		lan_ip_input.editable = lan_popup_mode == "online_join"
		if lan_popup_mode == "online_create":
			lan_ip_input.hide()
	if lan_status_label != null:
		lan_status_label.text = message
	if lan_popup != null:
		_show_lan_popup()


func _on_lan_status_changed(message: String) -> void:
	if lan_status_label != null:
		lan_status_label.text = message


func _on_lan_discovery_status_changed(message: String) -> void:
	if lan_status_label != null:
		lan_status_label.text = message


func _on_lan_host_discovered(address: String, port: int, host_name: String) -> void:
	if lan_ip_input != null:
		lan_ip_input.text = address
	if lan_port_input != null:
		lan_port_input.text = str(port)
	if lan_status_label != null:
		lan_status_label.text = "Found %s. Connecting..." % host_name


func _on_lan_disconnected() -> void:
	if lan_status_label != null:
		lan_status_label.text = "Disconnected from LAN host."


func _refresh_lan_status() -> void:
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan_status_label == null:
		return
	if lan != null and lan.has_method("get_status_text"):
		lan_status_label.text = str(lan.call("get_status_text"))
	else:
		lan_status_label.text = "Host starts the game, friend joins using the host IP."


func _get_lan_port_from_input() -> int:
	if lan_port_input == null:
		return LAN_DEFAULT_PORT
	var port_text: String = lan_port_input.text.strip_edges()
	if port_text.is_valid_int():
		return clampi(int(port_text), 1024, 65535)
	return LAN_DEFAULT_PORT


func _show_lan_popup() -> void:
	if lan_popup == null:
		return
	var viewport_size: Vector2 = get_viewport_rect().size
	var width: int = int(minf(720.0, maxf(360.0, viewport_size.x - 48.0)))
	var height: int = int(minf(460.0, maxf(330.0, viewport_size.y - 36.0)))
	lan_popup.size = Vector2i(width, height)
	lan_popup.popup_centered()
	lan_popup.show()


func _configure_online_create_popup() -> void:
	lan_popup_mode = "online_create"
	if lan_popup != null:
		lan_popup.title = "Create Online Party"
	if lan_heading_label != null:
		lan_heading_label.text = "Create a party code"
	if lan_status_label != null:
		lan_status_label.text = "Tap Create Party. Make sure the online service is available first."
	if lan_ip_input != null:
		lan_ip_input.text = ""
		lan_ip_input.placeholder_text = "Party code"
		lan_ip_input.editable = false
		lan_ip_input.hide()
	if lan_port_input != null:
		lan_port_input.hide()
	if lan_connect_button != null:
		lan_connect_button.text = "CREATE PARTY"
		lan_connect_button.disabled = false
	if lan_cancel_button != null:
		lan_cancel_button.text = "CANCEL"


func _configure_online_join_popup() -> void:
	lan_popup_mode = "online_join"
	if lan_popup != null:
		lan_popup.title = "Join Online Party"
	if lan_heading_label != null:
		lan_heading_label.text = "Enter your friend's party code"
	if lan_status_label != null:
		lan_status_label.text = "Ask your friend for the party code."
	if lan_ip_input != null:
		lan_ip_input.text = ""
		lan_ip_input.placeholder_text = "Party code"
		lan_ip_input.editable = true
		lan_ip_input.show()
	if lan_port_input != null:
		lan_port_input.hide()
	if lan_connect_button != null:
		lan_connect_button.text = "JOIN PARTY"
		lan_connect_button.disabled = false
	if lan_cancel_button != null:
		lan_cancel_button.text = "CANCEL"


func _start_lan_auto_search() -> void:
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan == null or not lan.has_method("start_auto_join_scan"):
		if lan_status_label != null:
			lan_status_label.text = "Auto-find is not available. Type the host IP manually."
		return

	if lan_status_label != null:
		lan_status_label.text = "Searching for a host on this Wi-Fi..."

	var error: Error = lan.call("start_auto_join_scan", _get_lan_port_from_input())
	if error != OK and lan_status_label != null:
		lan_status_label.text = "Auto-find could not start. Type the host IP manually."


func _on_rules_pressed() -> void:
	if rules_popup:
		rules_popup.size = Vector2i(int(get_viewport_rect().size.x), int(get_viewport_rect().size.y))
		rules_popup.popup_centered()
		rules_popup.show()


func _on_credits_pressed() -> void:
	if credits_popup:
		credits_popup.size = Vector2i(int(get_viewport_rect().size.x), int(get_viewport_rect().size.y))
		_rebuild_credits_popup_contents()
		credits_popup.popup_centered()
		credits_popup.show()


func _on_settings_pressed() -> void:
	if settings_popup:
		settings_popup.size = Vector2i(int(get_viewport_rect().size.x), int(get_viewport_rect().size.y))
		_init_audio_sliders()
		_init_shoot_sensitivity_slider()
		_refresh_aim_inversion_button()
		_refresh_shooting_mechanics_button()
		settings_popup.popup_centered()
		settings_popup.show()


func _on_settings_account_pressed() -> void:
	_hide_settings_popup()
	_show_player_name_popup()


func _on_customize_pressed() -> void:
	if customize_scene_path != "" and ResourceLoader.exists(customize_scene_path):
		get_tree().change_scene_to_file(customize_scene_path)
		return

	_init_customize_controls()
	if customize_popup:
		if glass_panel:
			glass_panel.hide()
		if donate_button:
			donate_button.hide()
		if background:
			background.hide()
		if background_overlay:
			background_overlay.hide()
		if top_glow:
			top_glow.hide()
		if bottom_glow:
			bottom_glow.hide()
		_set_neon_backdrop_visible(false)
		customize_popup.show()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _hide_rules_popup() -> void:
	if rules_popup:
		rules_popup.hide()


func _hide_credits_popup() -> void:
	if credits_popup:
		credits_popup.hide()


func _hide_settings_popup() -> void:
	if settings_popup:
		settings_popup.hide()


func _hide_lan_popup() -> void:
	if lan_popup:
		lan_popup.hide()
	if lan_connect_button != null:
		lan_connect_button.disabled = false
	var lan: Node = get_node_or_null("/root/LanMultiplayer")
	if lan != null and lan.has_method("stop_auto_join_scan"):
		lan.call("stop_auto_join_scan")
	if lan != null and lan.has_method("is_online_game") and bool(lan.call("is_online_game")) and lan.has_method("stop_network"):
		lan.call("stop_network")
		return
	if lan != null and lan.has_method("is_client") and bool(lan.call("is_client")) and lan.has_method("stop_network"):
		lan.call("stop_network")


func _hide_online_rooms_page() -> void:
	online_chat_expanded = false
	online_chat_toast_timer = 0.0
	online_pending_invite.clear()
	_release_online_invite_room_hold()
	_hide_online_invite_popup()
	_sync_online_chat_visibility()
	if online_chat_toast_panel != null:
		online_chat_toast_panel.hide()
	if online_rooms_page:
		online_rooms_page.hide()
	if online_loading_panel:
		online_loading_panel.hide()
	_set_online_rooms_content_visible(true)
	online_match_start_timer = -1.0
	online_scene_start_timer = -1.0
	online_start_fallback_timer = -1.0
	online_match_start_requested = false
	var online: Node = get_node_or_null("/root/MultiplayerManager")
	if online != null and online.has_method("disconnect_from_server"):
		online.call("disconnect_from_server", false)
	online_latest_rooms.clear()
	if glass_panel:
		glass_panel.show()
	if donate_button:
		donate_button.show()
	if background:
		background.show()
	if background_overlay:
		background_overlay.show()
	if top_glow:
		top_glow.hide()
	if bottom_glow:
		bottom_glow.hide()
	_set_neon_backdrop_visible(false)


func _hide_customize_popup() -> void:
	if customize_popup:
		customize_popup.hide()
	if glass_panel:
		glass_panel.show()
	if donate_button:
		donate_button.show()
	if background:
		background.show()
	if background_overlay:
		background_overlay.show()
	if top_glow:
		top_glow.hide()
	if bottom_glow:
		bottom_glow.hide()
	_set_neon_backdrop_visible(false)


func _hide_menu_popups() -> void:
	if rules_popup:
		rules_popup.hide()
	if credits_popup:
		credits_popup.hide()
	if settings_popup:
		settings_popup.hide()
	if shooting_mechanics_popup:
		shooting_mechanics_popup.hide()
	if lan_popup:
		lan_popup.hide()
	if online_rooms_page:
		online_rooms_page.hide()
	if customize_popup:
		customize_popup.hide()
	if glass_panel:
		glass_panel.show()
	if donate_button:
		donate_button.show()
	if background:
		background.show()
	if background_overlay:
		background_overlay.show()
	if top_glow:
		top_glow.hide()
	if bottom_glow:
		bottom_glow.hide()
	_set_neon_backdrop_visible(false)


func _set_neon_backdrop_visible(is_visible: bool) -> void:
	var band_root: Control = get_node_or_null("NeonBackdropBands") as Control
	if band_root != null:
		band_root.visible = false


func _init_player_name_controls() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return

	var saved_name: String = ""
	if customization.has_method("get_player_name"):
		saved_name = customization.call("get_player_name")
	var saved_login_id: String = ""
	if customization.has_method("get_player_login_id") and saved_name.strip_edges() != "":
		saved_login_id = str(customization.call("get_player_login_id")).strip_edges()
	var login_suffix: String = ""
	if saved_login_id != "":
		login_suffix = "  ID: %s" % saved_login_id
	var provider_label: String = ""
	if customization.has_method("get_player_auth_provider") and str(customization.call("get_player_auth_provider")) == "google":
		provider_label = " with Google"
	if saved_name.strip_edges() != "" and customization.has_method("has_chosen_shooting_mechanic") and not bool(customization.call("has_chosen_shooting_mechanic")):
		shooting_mechanics_prompt_pending_after_name = true

	if player_name_input:
		player_name_input.text = saved_name
		player_name_panel.visible = false

	if player_name_popup_input:
		player_name_popup_input.text = saved_name
	if player_age_popup_input:
		var saved_age: int = int(customization.call("get_player_age")) if customization.has_method("get_player_age") else 0
		player_age_popup_input.text = str(saved_age) if saved_age > 0 else ""

	var has_name: bool = saved_name.strip_edges() != ""
	play_button.disabled = not has_name
	if glass_panel:
		glass_panel.visible = has_name

	if player_name_status:
		if has_name:
			player_name_status.text = "Logged in%s as %s%s" % [provider_label, saved_name, login_suffix]
		else:
			player_name_status.text = "Create a player login for online parties and leaderboards."
	if coin_balance_label:
		var coin_balance: int = int(customization.call("get_coin_balance")) if customization.has_method("get_coin_balance") else 0
		var gold_balance: int = int(customization.call("get_gold_balance")) if customization.has_method("get_gold_balance") else 0
		coin_balance_label.text = "S coins: %d   Gold: %d" % [coin_balance, gold_balance]
	if player_name_popup_status:
		if has_name:
			player_name_popup_status.text = "Logged in%s as %s%s" % [provider_label, saved_name, login_suffix]
		else:
			player_name_popup_status.text = "Create a login to unlock the main menu."

	if has_name:
		_hide_player_name_popup()
		if _should_prompt_shooting_mechanics():
			call_deferred("_show_shooting_mechanics_prompt_if_needed")
		else:
			_show_startup_loading_once()
	else:
		_show_player_name_popup()


func _refresh_coin_balance_label() -> void:
	if coin_balance_label == null:
		return
	var customization: Node = get_node_or_null("/root/CustomizationState")
	var coin_balance: int = 0
	var gold_balance: int = 0
	if customization != null:
		coin_balance = int(customization.call("get_coin_balance")) if customization.has_method("get_coin_balance") else 0
		gold_balance = int(customization.call("get_gold_balance")) if customization.has_method("get_gold_balance") else 0
	coin_balance_label.text = "S coins: %d   Gold: %d" % [coin_balance, gold_balance]


func _on_player_name_submitted(text_value: String) -> void:
	_save_player_name(text_value)


func _on_player_name_save_pressed() -> void:
	if player_name_input == null:
		return
	_save_player_name(player_name_input.text)


func _on_player_name_popup_submitted(text_value: String) -> void:
	_save_player_name(text_value)


func _on_player_age_popup_submitted(_text_value: String) -> void:
	if player_name_popup_input == null:
		return
	_save_player_name(player_name_popup_input.text)


func _on_player_name_popup_save_pressed() -> void:
	if player_name_popup_input == null:
		return
	_save_player_name(player_name_popup_input.text)


func _on_player_name_popup_close_requested() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("has_player_name") and customization.call("has_player_name"):
		_hide_player_name_popup()
		return
	call_deferred("_show_player_name_popup")


func _save_player_name(raw_name: String) -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return
	var had_player_name: bool = customization.has_method("has_player_name") and bool(customization.call("has_player_name"))

	var cleaned_name: String = raw_name.strip_edges()
	if cleaned_name == "":
		if player_name_status:
			player_name_status.text = "Enter a name first."
		if player_name_popup_status:
			player_name_popup_status.text = "Enter a name first."
		return

	var entered_age: int = _get_player_login_age_value()
	if entered_age <= 0:
		if player_name_status:
			player_name_status.text = "Enter your age."
		if player_name_popup_status:
			player_name_popup_status.text = "Enter a valid age between 1 and 120."
		return

	if not had_player_name and not _player_terms_are_accepted():
		if player_name_status:
			player_name_status.text = "Accept the Terms and Conditions first."
		if player_name_popup_status:
			player_name_popup_status.text = "Please tick the Terms and Conditions checkbox before continuing."
		return

	var applied_google_profile: bool = false
	if not google_auth_pending_profile.is_empty() and customization.has_method("set_google_player_profile"):
		var google_profile: Dictionary = google_auth_pending_profile.duplicate(true)
		google_profile["name"] = cleaned_name
		google_profile["player_age"] = entered_age
		google_profile["auth_token"] = google_auth_pending_auth_token
		customization.call("set_google_player_profile", google_profile)
		google_auth_pending_profile.clear()
		google_auth_pending_auth_token = ""
		applied_google_profile = true
	elif customization.has_method("set_player_name"):
		customization.call("set_player_name", cleaned_name)
	if customization.has_method("set_player_age"):
		customization.call("set_player_age", entered_age)
	if not had_player_name:
		_save_terms_acceptance()
	if not had_player_name:
		shooting_mechanics_prompt_pending_after_name = true
	if applied_google_profile:
		_save_google_profile_progress()

	_init_player_name_controls()
	if shooting_mechanics_prompt_pending_after_name:
		call_deferred("_show_shooting_mechanics_prompt_if_needed")


func _show_player_name_popup() -> void:
	if player_name_popup == null:
		return
	if player_terms_checkbox != null:
		player_terms_checkbox.button_pressed = _terms_already_accepted()
	if google_auth_pending_profile.is_empty() and google_auth_device_code == "":
		_set_google_signin_button_state(false, "SIGN IN WITH GOOGLE")
	var viewport_size: Vector2 = get_viewport_rect().size
	var popup_width: int = maxi(360, mini(760, int(viewport_size.x) - 32))
	var popup_height: int = maxi(460, mini(620, int(viewport_size.y) - 32))
	player_name_popup.size = Vector2i(popup_width, popup_height)
	player_name_popup.popup_centered()
	player_name_popup.show()
	if player_name_popup_input:
		player_name_popup_input.grab_focus()


func _get_player_login_age_value() -> int:
	if player_age_popup_input == null:
		var customization: Node = get_node_or_null("/root/CustomizationState")
		return int(customization.call("get_player_age")) if customization != null and customization.has_method("get_player_age") else 0
	var raw_age: String = player_age_popup_input.text.strip_edges()
	if raw_age == "" or not raw_age.is_valid_int():
		return 0
	var age: int = int(raw_age)
	if age < 1 or age > 120:
		return 0
	return age


func _hide_player_name_popup() -> void:
	if player_name_popup:
		player_name_popup.hide()


func _player_terms_are_accepted() -> bool:
	if _terms_already_accepted():
		return true
	return player_terms_checkbox != null and player_terms_checkbox.button_pressed


func _terms_already_accepted() -> bool:
	if not FileAccess.file_exists(TERMS_ACCEPTANCE_PATH):
		return false
	var file: FileAccess = FileAccess.open(TERMS_ACCEPTANCE_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	var data: Dictionary = parsed
	return str(data.get("version", "")) == TERMS_VERSION and bool(data.get("accepted", false))


func _save_terms_acceptance() -> void:
	var file: FileAccess = FileAccess.open(TERMS_ACCEPTANCE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({
		"accepted": true,
		"version": TERMS_VERSION,
		"accepted_at_unix": Time.get_unix_time_from_system()
	}))


func _init_customize_controls() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return

	selected_customize_marble_id = str(customization.get("selected_marble_id"))
	selected_customize_trail_id = str(customization.get("selected_trail_id"))
	customize_marble_ids = customization.call("get_marble_ids")
	customize_trail_ids = customization.call("get_trail_ids")
	marble_card_buttons.clear()
	trail_card_buttons.clear()

	if selected_customize_marble_id == "" and not customize_marble_ids.is_empty():
		selected_customize_marble_id = str(customize_marble_ids[0])
	if selected_customize_trail_id == "" and not customize_trail_ids.is_empty():
		selected_customize_trail_id = str(customize_trail_ids[0])

	_rebuild_customize_marble_belt()
	_refresh_customize_card_states()
	_refresh_customize_preview()


func _on_customize_selection_changed(_index: int) -> void:
	_refresh_customize_preview()


func _on_customize_prev_marble_pressed() -> void:
	_cycle_customize_marble(-1)


func _on_customize_next_marble_pressed() -> void:
	_cycle_customize_marble(1)


func _on_customize_prev_trail_pressed() -> void:
	_cycle_customize_trail(-1)


func _on_customize_next_trail_pressed() -> void:
	_cycle_customize_trail(1)


func _on_customize_apply_pressed() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return

	if selected_customize_marble_id != "":
		if customization.has_method("is_marble_unlocked") and not customization.call("is_marble_unlocked", selected_customize_marble_id):
			if customization.has_method("can_unlock_marble") and customization.call("can_unlock_marble", selected_customize_marble_id):
				customization.call("unlock_marble", selected_customize_marble_id)
			else:
				if customize_status_label:
					var unlock_cost: int = int(customization.call("get_marble_unlock_cost", selected_customize_marble_id)) if customization.has_method("get_marble_unlock_cost") else 0
					var unlock_currency: String = str(customization.call("get_marble_unlock_currency", selected_customize_marble_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
					var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
					customize_status_label.text = "This marble is locked. Unlock it for %d %s first." % [unlock_cost, currency_name.to_lower()]
				return
		customization.call("set_selected_marble", selected_customize_marble_id)

	if selected_customize_trail_id != "":
		customization.call("set_selected_trail", selected_customize_trail_id)

	_init_player_name_controls()
	if customize_status_label:
		customize_status_label.text = "Marble Applied Successfully"
	_hide_customize_popup()


func _cycle_customize_marble(step: int) -> void:
	if customize_marble_ids.is_empty():
		return

	var current_index: int = customize_marble_ids.find(selected_customize_marble_id)
	if current_index == -1:
		current_index = 0
	current_index = posmod(current_index + step, customize_marble_ids.size())
	selected_customize_marble_id = str(customize_marble_ids[current_index])
	_refresh_customize_card_states()
	_refresh_customize_preview()


func _cycle_customize_trail(step: int) -> void:
	if customize_trail_ids.is_empty():
		return

	var current_index: int = customize_trail_ids.find(selected_customize_trail_id)
	if current_index == -1:
		current_index = 0
	current_index = posmod(current_index + step, customize_trail_ids.size())
	selected_customize_trail_id = str(customize_trail_ids[current_index])
	_refresh_customize_card_states()
	_refresh_customize_preview()


func _refresh_customize_preview() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization == null:
		return

	var marble_id: String = selected_customize_marble_id
	if marble_id == "":
		marble_id = str(customization.get("selected_marble_id"))

	var trail_id: String = selected_customize_trail_id
	if trail_id == "":
		trail_id = str(customization.get("selected_trail_id"))

	var marble_preset: Dictionary = customization.call("get_marble_preset", marble_id)
	var trail_preset: Dictionary = customization.call("get_trail_preset", trail_id)
	var palette: Dictionary = marble_preset.get("palette", {})

	if customize_preview_title:
		var marble_index: int = customize_marble_ids.find(marble_id) + 1
		var marble_total: int = customize_marble_ids.size()
		customize_preview_title.text = "Display %d/%d   %s" % [
			max(marble_index, 1),
			max(marble_total, 1),
			str(marble_preset.get("name", marble_id))
		]

	if customize_preview_text:
		customize_preview_text.text = "%s\n\nTrail finish: %s" % [
			str(marble_preset.get("description", "")),
			str(trail_preset.get("name", trail_id))
		]

	if customize_marble_preview_holder:
		_fill_marble_preview_frame(customize_marble_preview_holder, marble_preset, true)

	if customize_trail_preview_holder:
		_fill_trail_preview_frame(customize_trail_preview_holder, trail_preset, marble_preset, true)

	if customize_color_preview:
		customize_color_preview.color = palette.get("shell_base_color", Color(0.58, 0.8, 1.0, 0.18))

	if customize_accent_preview:
		customize_accent_preview.color = palette.get("shell_swirl_orange", Color(0.94, 0.48, 0.17, 1.0))

	var marble_locked: bool = customization.has_method("is_marble_unlocked") and not bool(customization.call("is_marble_unlocked", marble_id))
	var unlock_cost: int = int(customization.call("get_marble_unlock_cost", marble_id)) if customization.has_method("get_marble_unlock_cost") else 0
	var unlock_currency: String = str(customization.call("get_marble_unlock_currency", marble_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
	var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
	var currency_balance: int = int(customization.call("get_currency_balance", unlock_currency)) if customization.has_method("get_currency_balance") else 0
	var coin_balance: int = int(customization.call("get_coin_balance")) if customization.has_method("get_coin_balance") else 0
	var gold_balance: int = int(customization.call("get_gold_balance")) if customization.has_method("get_gold_balance") else 0
	if customize_status_label:
		if marble_locked:
			var currency_needed: int = max(unlock_cost - currency_balance, 0)
			customize_status_label.text = "Locked marble. Cost: %d %s. %s" % [
				unlock_cost,
				currency_name.to_lower(),
				"Ready to unlock." if currency_needed <= 0 else "%d more needed." % currency_needed
			]
		else:
			customize_status_label.text = "Unlocked. Balance: %d S coins, %d Gold." % [coin_balance, gold_balance]
	if customize_apply_button:
		var can_unlock: bool = marble_locked and customization.has_method("can_unlock_marble") and bool(customization.call("can_unlock_marble", marble_id))
		customize_apply_button.disabled = marble_locked and not can_unlock
		if marble_locked:
			customize_apply_button.text = "UNLOCK" if can_unlock else "LOCKED"
		else:
			customize_apply_button.text = "APPLY"


func _on_marble_card_pressed(marble_id: String) -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customization != null and customization.has_method("is_marble_unlocked") and not customization.call("is_marble_unlocked", marble_id):
		if customization.has_method("can_unlock_marble") and customization.call("can_unlock_marble", marble_id):
			customization.call("unlock_marble", marble_id)
			_init_player_name_controls()
	selected_customize_marble_id = marble_id
	_refresh_customize_card_states()
	_refresh_customize_preview()


func _on_trail_card_pressed(trail_id: String) -> void:
	selected_customize_trail_id = trail_id
	_refresh_customize_card_states()
	_refresh_customize_preview()


func _refresh_customize_card_states() -> void:
	var customization: Node = get_node_or_null("/root/CustomizationState")
	if customize_prev_marble_button:
		customize_prev_marble_button.disabled = customize_marble_ids.size() <= 1
	if customize_next_marble_button:
		customize_next_marble_button.disabled = customize_marble_ids.size() <= 1
	if customize_prev_trail_button:
		customize_prev_trail_button.disabled = customize_trail_ids.size() <= 1
	if customize_next_trail_button:
		customize_next_trail_button.disabled = customize_trail_ids.size() <= 1

	for marble_id in marble_card_buttons.keys():
		var marble_button: Button = marble_card_buttons[marble_id] as Button
		var marble_locked: bool = customization != null and customization.has_method("is_marble_unlocked") and not bool(customization.call("is_marble_unlocked", marble_id))
		_apply_customize_card_style(marble_button, marble_id == selected_customize_marble_id, marble_locked)
		_update_customize_card_lock_state(marble_button, str(marble_id), true)

	for trail_id in trail_card_buttons.keys():
		var trail_button: Button = trail_card_buttons[trail_id] as Button
		_apply_customize_card_style(trail_button, trail_id == selected_customize_trail_id, false)
		_update_customize_card_lock_state(trail_button, str(trail_id), false)

	_schedule_customize_belt_centering()


func _apply_customize_card_style(button: Button, is_selected: bool, is_locked: bool = false) -> void:
	if button == null:
		return

	var fill_color: Color = Color(0.08, 0.12, 0.18, 0.64)
	var border_color: Color = Color(0.88, 0.96, 1.0, 0.22)
	if is_selected:
		fill_color = Color(0.10, 0.20, 0.24, 0.88)
		border_color = Color(0.56, 1.0, 0.82, 0.74)
	if is_locked:
		fill_color = fill_color.darkened(0.14)
		border_color = Color(1.0, 0.76, 0.42, 0.42) if is_selected else Color(0.9, 0.7, 0.42, 0.24)

	button.modulate = Color(1.0, 1.0, 1.0, 1.0) if is_selected else (Color(0.68, 0.68, 0.72, 0.82) if is_locked else Color(0.92, 0.95, 1.0, 0.96))


func _update_customize_card_lock_state(button: Button, preset_id: String, is_marble: bool) -> void:
	if button == null:
		return

	var title_label := button.get_meta("title_label", null) as Label
	var lock_label := button.get_meta("lock_label", null) as Label
	var customization: Node = get_node_or_null("/root/CustomizationState")
	var preset: Dictionary = {}
	if customization != null:
		if is_marble and customization.has_method("get_marble_preset"):
			preset = customization.call("get_marble_preset", preset_id)
		elif not is_marble and customization.has_method("get_trail_preset"):
			preset = customization.call("get_trail_preset", preset_id)

	if title_label != null:
		title_label.text = str(preset.get("name", preset_id))

	if lock_label == null:
		return

	if not is_marble or customization == null or not customization.has_method("is_marble_unlocked"):
		lock_label.visible = false
		button.tooltip_text = str(preset.get("description", ""))
		return

	var marble_locked: bool = not bool(customization.call("is_marble_unlocked", preset_id))
	var unlock_cost: int = int(customization.call("get_marble_unlock_cost", preset_id)) if customization.has_method("get_marble_unlock_cost") else 0
	var unlock_currency: String = str(customization.call("get_marble_unlock_currency", preset_id)) if customization.has_method("get_marble_unlock_currency") else "coins"
	var currency_name: String = str(customization.call("get_currency_display_name", unlock_currency)) if customization.has_method("get_currency_display_name") else unlock_currency.capitalize()
	lock_label.visible = marble_locked
	lock_label.text = "%d %s" % [unlock_cost, currency_name.to_upper()]
	button.tooltip_text = str(preset.get("description", ""))
	if marble_locked:
		button.tooltip_text += "\nUnlock cost: %d %s" % [unlock_cost, currency_name.to_lower()]


func _schedule_customize_belt_centering() -> void:
	call_deferred("_sync_customize_belt_centering")


func _sync_customize_belt_centering() -> void:
	var selected_button := marble_card_buttons.get(selected_customize_marble_id, null) as Control
	if customize_marble_belt_scroll == null or selected_button == null:
		return

	var content: Control = selected_button.get_parent() as Control
	if content == null:
		return

	var viewport_width: float = customize_marble_belt_scroll.size.x
	var content_width: float = content.size.x
	if viewport_width <= 0.0 or content_width <= viewport_width:
		customize_marble_belt_target_scroll = 0.0
		return

	customize_marble_belt_target_scroll = clampf(
		selected_button.position.x + selected_button.size.x * 0.5 - viewport_width * 0.5,
		0.0,
		maxf(content_width - viewport_width, 0.0)
	)


func _create_customize_card(preset: Dictionary, preset_id: String, is_marble: bool) -> Button:
	var button: Button = Button.new()
	button.custom_minimum_size = Vector2(0, 204)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.clip_contents = true
	button.add_theme_font_override("font", ui_font)
	button.add_theme_color_override("font_color", Color(0.94, 0.99, 1.0, 1.0))

	var content: MarginContainer = MarginContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("margin_left", 10)
	content.add_theme_constant_override("margin_top", 10)
	content.add_theme_constant_override("margin_right", 10)
	content.add_theme_constant_override("margin_bottom", 10)
	button.add_child(content)

	var box: VBoxContainer = VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	content.add_child(box)

	var preview_frame: Panel = _create_preview_frame(Vector2(0, 118))
	box.add_child(preview_frame)
	if is_marble:
		_fill_marble_preview_frame(preview_frame, preset, false)
	else:
		var customization: Node = get_node_or_null("/root/CustomizationState")
		var selected_marble: Dictionary = {}
		if customization != null and customization.has_method("get_selected_marble_preset"):
			selected_marble = customization.call("get_selected_marble_preset")
		_fill_trail_preview_frame(preview_frame, preset, selected_marble, false)

	var title_label: Label = Label.new()
	title_label.text = str(preset.get("name", preset_id))
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_override("font", ui_font)
	title_label.add_theme_font_size_override("font_size", 17)
	box.add_child(title_label)
	button.set_meta("title_label", title_label)

	var lock_label: Label = Label.new()
	lock_label.text = ""
	lock_label.visible = false
	lock_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lock_label.add_theme_font_override("font", ui_font)
	lock_label.add_theme_font_size_override("font_size", 13)
	lock_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48, 0.98))
	box.add_child(lock_label)
	button.set_meta("lock_label", lock_label)

	button.tooltip_text = str(preset.get("description", ""))
	if is_marble:
		button.pressed.connect(_on_marble_card_pressed.bind(preset_id))
	else:
		button.pressed.connect(_on_trail_card_pressed.bind(preset_id))
	return button


func _create_preview_frame(minimum_size: Vector2) -> Panel:
	var frame: Panel = Panel.new()
	frame.custom_minimum_size = minimum_size
	frame.clip_contents = true
	frame.add_theme_stylebox_override("panel", _make_button_style(Color(0.98, 0.985, 0.99, 1.0), Color(0.78, 0.84, 0.9, 1.0)))
	return frame


func _fill_marble_preview_frame(frame: Panel, preset: Dictionary, is_large: bool) -> void:
	if frame == null:
		return

	_clear_node_children(frame)
	if is_large:
		customize_preview_marble_node = null
		customize_preview_dragging = false
	var preview_size: Vector2i = Vector2i(180, 118)
	var camera_distance: float = 1.18
	var marble_scale: float = 2.2
	if is_large:
		preview_size = Vector2i(1024, 1024)
		camera_distance = 7.2
		marble_scale = 0.66
	var preview: SubViewportContainer = _create_preview_viewport(preview_size, is_large)
	if is_large:
		_mount_aspect_preview(frame, preview, 1.0)
	else:
		frame.add_child(preview)
		preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	if is_large and not preview.gui_input.is_connected(_on_customize_preview_gui_input):
		preview.gui_input.connect(_on_customize_preview_gui_input)

	var viewport: SubViewport = preview.get_node("PreviewViewport") as SubViewport
	if viewport == null:
		return

	var preview_root: Node3D = _build_preview_stage(
		viewport,
		Vector3(0.0, 1.24, camera_distance),
		Vector3(0.0, 1.02, 0.0),
		is_large
	)
	var palette: Dictionary = preset.get("palette", {})
	var marble: Node3D = _create_preview_marble_node(palette, marble_scale)
	if marble == null:
		return
	_preserve_preview_marble_original_colors(marble, palette)
	var marble_anchor: Vector3 = Vector3(0.0, 1.18 if is_large else 0.0, 0.0)
	if is_large and preview_root.has_meta("marble_anchor"):
		marble_anchor = preview_root.get_meta("marble_anchor", marble_anchor)
		marble_anchor += Vector3(0.0, -1.35, 0.0)
	marble.position = marble_anchor
	marble.rotation_degrees = Vector3(-5, 18, 0)
	preview_root.add_child(marble)
	if is_large:
		customize_preview_marble_node = marble


func _fill_trail_preview_frame(frame: Panel, trail_preset: Dictionary, marble_preset: Dictionary, is_large: bool) -> void:
	if frame == null:
		return

	_clear_node_children(frame)
	var preview_size: Vector2i = Vector2i(180, 118)
	var camera_distance: float = 1.34
	var marble_scale: float = 1.9
	if is_large:
		preview_size = Vector2i(320, 240)
		camera_distance = 1.78
		marble_scale = 2.35
	var preview: SubViewportContainer = _create_preview_viewport(preview_size)
	frame.add_child(preview)
	preview.set_anchors_preset(Control.PRESET_FULL_RECT)

	var viewport: SubViewport = preview.get_node("PreviewViewport") as SubViewport
	if viewport == null:
		return

	var preview_root: Node3D = _build_preview_stage(
		viewport,
		Vector3(0.0, 0.12, camera_distance),
		Vector3(0.06, -0.03, 0.0),
		is_large
	)
	preview_root.rotation_degrees = Vector3(0, -24, 0)
	_add_preview_floor(preview_root, is_large)

	var palette: Dictionary = marble_preset.get("palette", {})
	var marble: Node3D = _create_preview_marble_node(palette, marble_scale)
	if marble != null:
		_preserve_preview_marble_original_colors(marble, palette)
		marble.position = Vector3(0.44, -0.02, 0.0)
		marble.rotation_degrees = Vector3(-8, 18, 0)
		preview_root.add_child(marble)

	_add_trail_preview_geometry(preview_root, trail_preset, is_large)


func _create_preview_viewport(preview_size: Vector2i, capture_input: bool = false) -> SubViewportContainer:
	var container: SubViewportContainer = SubViewportContainer.new()
	container.stretch = true
	container.mouse_filter = Control.MOUSE_FILTER_STOP if capture_input else Control.MOUSE_FILTER_IGNORE
	container.custom_minimum_size = Vector2(preview_size.x, preview_size.y)

	var viewport: SubViewport = SubViewport.new()
	viewport.name = "PreviewViewport"
	viewport.size = preview_size
	viewport.disable_3d = false
	viewport.transparent_bg = false
	viewport.own_world_3d = true
	viewport.msaa_3d = Viewport.MSAA_DISABLED
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if capture_input else SubViewport.UPDATE_ONCE
	container.add_child(viewport)

	return container


func _mount_aspect_preview(frame: Control, preview: Control, aspect_ratio: float) -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	frame.add_child(margin)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_child(center)

	var aspect := AspectRatioContainer.new()
	aspect.ratio = aspect_ratio
	aspect.stretch_mode = AspectRatioContainer.STRETCH_FIT
	aspect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	aspect.size_flags_vertical = Control.SIZE_EXPAND_FILL
	center.add_child(aspect)

	preview.set_anchors_preset(Control.PRESET_FULL_RECT)
	aspect.add_child(preview)


func _rebuild_customize_marble_belt() -> void:
	if customize_marble_belt == null:
		return

	_clear_node_children(customize_marble_belt)
	marble_card_buttons.clear()

	var customization: Node = get_node_or_null("/root/CustomizationState")
	for marble_id_variant in customize_marble_ids:
		var marble_id: String = str(marble_id_variant)
		var preset: Dictionary = {}
		if customization != null and customization.has_method("get_marble_preset"):
			preset = customization.call("get_marble_preset", marble_id)
		var belt_button := _create_customize_belt_button(preset, marble_id)
		customize_marble_belt.add_child(belt_button)
		marble_card_buttons[marble_id] = belt_button


func _create_customize_belt_button(preset: Dictionary, preset_id: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(116, 114)
	button.clip_contents = true
	button.focus_mode = Control.FOCUS_NONE

	var content := MarginContainer.new()
	content.set_anchors_preset(Control.PRESET_FULL_RECT)
	content.add_theme_constant_override("margin_left", 8)
	content.add_theme_constant_override("margin_top", 8)
	content.add_theme_constant_override("margin_right", 8)
	content.add_theme_constant_override("margin_bottom", 8)
	button.add_child(content)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 6)
	content.add_child(box)

	var icon := TextureRect.new()
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.custom_minimum_size = Vector2(82, 60)
	icon.texture = _get_marble_preview_texture(preset_id, preset)
	box.add_child(icon)

	var title_label := Label.new()
	title_label.text = str(preset.get("name", preset_id))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_override("font", ui_font)
	title_label.add_theme_font_size_override("font_size", 12)
	box.add_child(title_label)
	button.set_meta("title_label", title_label)

	var lock_label := Label.new()
	lock_label.visible = false
	lock_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lock_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lock_label.add_theme_font_override("font", ui_font)
	lock_label.add_theme_font_size_override("font_size", 10)
	lock_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48, 0.98))
	box.add_child(lock_label)
	button.set_meta("lock_label", lock_label)

	button.pressed.connect(_on_marble_card_pressed.bind(preset_id))
	return button


func _on_customize_preview_gui_input(event: InputEvent) -> void:
	if customize_preview_marble_node == null:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		customize_preview_dragging = event.pressed
		customize_preview_last_pointer = event.position
		if event.pressed:
			get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseMotion and customize_preview_dragging:
		var delta: Vector2 = event.position - customize_preview_last_pointer
		customize_preview_last_pointer = event.position
		customize_preview_marble_node.rotate_y(-delta.x * 0.01)
		var tilt := customize_preview_marble_node.rotation_degrees.x - delta.y * 0.08
		customize_preview_marble_node.rotation_degrees.x = clampf(tilt, -28.0, 12.0)
		get_viewport().set_input_as_handled()


func _build_preview_stage(viewport: SubViewport, camera_position: Vector3, look_target: Vector3, is_large: bool) -> Node3D:
	_clear_node_children(viewport)

	var environment_resource: Environment = Environment.new()
	environment_resource.background_mode = Environment.BG_COLOR
	environment_resource.background_color = Color(0.01, 0.012, 0.02, 1.0) if is_large else Color(0.07, 0.1, 0.16, 1.0)
	environment_resource.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment_resource.ambient_light_color = Color(1.0, 1.0, 1.0, 1.0)
	environment_resource.ambient_light_energy = 1.24
	environment_resource.background_energy_multiplier = 0.72 if is_large else 1.0
	environment_resource.fog_enabled = false
	environment_resource.glow_enabled = false
	environment_resource.tonemap_mode = Environment.TONE_MAPPER_LINEAR
	if is_large:
		environment_resource.ambient_light_energy = 1.18

	var environment: WorldEnvironment = WorldEnvironment.new()
	environment.environment = environment_resource
	viewport.add_child(environment)

	var preview_root: Node3D = Node3D.new()
	preview_root.name = "PreviewRoot"
	viewport.add_child(preview_root)

	var resolved_camera_position: Vector3 = camera_position
	var resolved_look_target: Vector3 = look_target
	var marble_anchor: Vector3 = Vector3.ZERO
	if is_large:
		var room_setup: Dictionary = _add_customize_room_scene(preview_root)
		if not room_setup.is_empty():
			resolved_camera_position = room_setup.get("camera_position", resolved_camera_position)
			resolved_look_target = room_setup.get("look_target", resolved_look_target)
			marble_anchor = room_setup.get("marble_position", marble_anchor)

	var camera: Camera3D = Camera3D.new()
	camera.current = true
	camera.fov = 30.0
	if is_large:
		camera.fov = 27.0
	camera.position = resolved_camera_position
	camera.look_at(resolved_look_target, Vector3.UP)
	preview_root.add_child(camera)
	preview_root.set_meta("marble_anchor", marble_anchor)

	if not is_large:
		var key_light: DirectionalLight3D = DirectionalLight3D.new()
		key_light.rotation_degrees = Vector3(-46, 24, 0)
		key_light.light_energy = 2.0
		key_light.shadow_enabled = false
		preview_root.add_child(key_light)

	var fill_light: OmniLight3D = OmniLight3D.new()
	if is_large:
		fill_light.position = resolved_look_target + Vector3(-2.1, 0.65, 2.6)
	else:
		fill_light.position = Vector3(-1.2, 0.95, 1.1)
	fill_light.light_color = Color(0.98, 0.99, 1.0, 1.0)
	fill_light.light_energy = 1.0
	if is_large:
		fill_light.light_color = Color(1.0, 1.0, 1.0, 1.0)
		fill_light.light_energy = 0.68
	fill_light.omni_range = 10.0 if is_large else 5.0
	preview_root.add_child(fill_light)

	if is_large:
		var rim_light: OmniLight3D = OmniLight3D.new()
		rim_light.position = resolved_look_target + Vector3(0.0, 1.0, 1.6)
		rim_light.light_color = Color(0.96, 0.98, 1.0, 1.0)
		rim_light.light_energy = 0.24
		rim_light.omni_range = 9.5
		preview_root.add_child(rim_light)

		var top_light: OmniLight3D = OmniLight3D.new()
		top_light.position = resolved_look_target + Vector3(0.0, 2.1, 0.7)
		top_light.light_color = Color(1.0, 0.96, 0.84, 1.0)
		top_light.light_energy = 0.22
		top_light.omni_range = 8.5
		preview_root.add_child(top_light)

	return preview_root


func _load_customize_room_scene() -> PackedScene:
	if not ResourceLoader.exists(CUSTOMIZE_ROOM_SCENE_PATH):
		return null
	var loaded_resource: Resource = load(CUSTOMIZE_ROOM_SCENE_PATH)
	return loaded_resource as PackedScene


func _add_customize_room_scene(parent: Node3D) -> Dictionary:
	var room_scene: PackedScene = _load_customize_room_scene()
	if room_scene == null:
		_add_preview_room(parent)
		return {}

	var room_instance: Node = room_scene.instantiate()
	var room_root: Node3D = room_instance as Node3D
	if room_root == null:
		if room_instance:
			room_instance.queue_free()
		_add_preview_room(parent)
		return {}

	parent.add_child(room_root)
	var marble_anchor_node: Node3D = room_root.find_child("SelectedMarbleSlot", true, false) as Node3D
	if marble_anchor_node == null:
		marble_anchor_node = room_root.find_child("MarbleAnchor", true, false) as Node3D
	var look_target_node: Node3D = room_root.find_child("LookTarget", true, false) as Node3D
	var camera_anchor_node: Node3D = room_root.find_child("CameraAnchor", true, false) as Node3D
	if marble_anchor_node != null and look_target_node != null and camera_anchor_node != null:
		var glow: OmniLight3D = OmniLight3D.new()
		glow.position = marble_anchor_node.global_position + Vector3(0.0, 0.35, 0.0)
		glow.light_color = Color(0.9, 0.96, 1.0, 1.0)
		glow.light_energy = 0.0
		glow.omni_range = 9.0
		parent.add_child(glow)
		return {
			"marble_position": marble_anchor_node.global_position,
			"look_target": look_target_node.global_position,
			"camera_position": camera_anchor_node.global_position
		}

	var initial_bounds: AABB = _get_node_3d_bounds(room_root)
	if initial_bounds.size.length() <= 0.001:
		return {}
	var initial_center: Vector3 = initial_bounds.position + initial_bounds.size * 0.5
	room_root.position -= Vector3(initial_center.x, initial_bounds.position.y, initial_center.z)
	var initial_span: float = max(initial_bounds.size.x, initial_bounds.size.z)
	if initial_span > 0.001:
		var uniform_scale: float = clampf(8.0 / initial_span, 0.18, 2.0)
		room_root.scale = Vector3.ONE * uniform_scale

	var room_bounds: AABB = _get_node_3d_bounds(room_root)
	if room_bounds.size.length() <= 0.001:
		return {}

	var room_center: Vector3 = room_bounds.position + room_bounds.size * 0.5
	var room_span: float = max(room_bounds.size.x, room_bounds.size.z)
	var room_height: float = room_bounds.size.y
	var marble_position := Vector3(
		room_center.x,
		room_bounds.position.y + room_height + maxf(room_height * 0.08, 0.65),
		room_center.z
	)
	var look_target := marble_position + Vector3(0.0, -0.08, 0.0)
	var camera_position := marble_position + Vector3(0.0, maxf(room_height * 0.22, 0.9), maxf(room_span * 0.95, 5.2))

	var glow: OmniLight3D = OmniLight3D.new()
	glow.position = marble_position + Vector3(0.0, 0.45, 0.0)
	glow.light_color = Color(0.9, 0.96, 1.0, 1.0)
	glow.light_energy = 0.0
	glow.omni_range = 9.0
	parent.add_child(glow)

	return {
		"marble_position": marble_position,
		"look_target": look_target,
		"camera_position": camera_position
	}


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
		var corners := [
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
	return combined if has_bounds else AABB()


func _add_preview_room(parent: Node3D) -> void:
	_add_preview_floor(parent, true)

	var back_wall: MeshInstance3D = MeshInstance3D.new()
	var back_wall_mesh: QuadMesh = QuadMesh.new()
	back_wall_mesh.size = Vector2(8.8, 4.2)
	back_wall.mesh = back_wall_mesh
	back_wall.position = Vector3(0.0, 2.02, -3.1)
	var wall_material: StandardMaterial3D = StandardMaterial3D.new()
	wall_material.albedo_color = Color(0.06, 0.06, 0.12, 1.0)
	wall_material.emission_enabled = false
	wall_material.emission_energy_multiplier = 0.0
	wall_material.roughness = 0.96
	back_wall.material_override = wall_material
	parent.add_child(back_wall)

	var side_panel_left: MeshInstance3D = MeshInstance3D.new()
	var side_panel_mesh: QuadMesh = QuadMesh.new()
	side_panel_mesh.size = Vector2(5.8, 3.9)
	side_panel_left.mesh = side_panel_mesh
	side_panel_left.position = Vector3(-4.05, 1.9, -0.85)
	side_panel_left.rotation_degrees = Vector3(0.0, 58.0, 0.0)
	var side_material: StandardMaterial3D = StandardMaterial3D.new()
	side_material.albedo_color = Color(0.05, 0.05, 0.1, 1.0)
	side_material.emission_enabled = false
	side_material.emission_energy_multiplier = 0.0
	side_material.roughness = 0.96
	side_panel_left.material_override = side_material
	parent.add_child(side_panel_left)

	var side_panel_right: MeshInstance3D = MeshInstance3D.new()
	side_panel_right.mesh = side_panel_mesh
	side_panel_right.position = Vector3(4.05, 1.9, -0.85)
	side_panel_right.rotation_degrees = Vector3(0.0, -58.0, 0.0)
	side_panel_right.material_override = side_material
	parent.add_child(side_panel_right)

	var ceiling: MeshInstance3D = MeshInstance3D.new()
	var ceiling_mesh: BoxMesh = BoxMesh.new()
	ceiling_mesh.size = Vector3(9.4, 0.16, 6.0)
	ceiling.mesh = ceiling_mesh
	ceiling.position = Vector3(0.0, 4.1, -0.8)
	var ceiling_material: StandardMaterial3D = StandardMaterial3D.new()
	ceiling_material.albedo_color = Color(0.06, 0.06, 0.1, 1.0)
	ceiling_material.roughness = 0.98
	ceiling.material_override = ceiling_material
	parent.add_child(ceiling)

	var pedestal: MeshInstance3D = MeshInstance3D.new()
	var pedestal_mesh: CylinderMesh = CylinderMesh.new()
	pedestal_mesh.top_radius = 1.55
	pedestal_mesh.bottom_radius = 1.55
	pedestal_mesh.height = 0.12
	pedestal.mesh = pedestal_mesh
	pedestal.position = Vector3(0.0, 0.06, 0.0)
	var pedestal_material: StandardMaterial3D = StandardMaterial3D.new()
	pedestal_material.albedo_color = Color(0.04, 0.04, 0.06, 1.0)
	pedestal_material.metallic = 0.18
	pedestal_material.roughness = 0.18
	pedestal.material_override = pedestal_material
	parent.add_child(pedestal)

	var halo: OmniLight3D = OmniLight3D.new()
	halo.position = Vector3(0.0, 2.4, 0.9)
	halo.light_color = Color(0.28, 0.42, 1.0, 1.0)
	halo.light_energy = 0.0
	halo.omni_range = 8.0
	parent.add_child(halo)

	for index in range(6):
		var spot: MeshInstance3D = MeshInstance3D.new()
		var spot_mesh: BoxMesh = BoxMesh.new()
		spot_mesh.size = Vector3(0.12, 0.06, 0.12)
		spot.mesh = spot_mesh
		spot.position = Vector3(-3.2 + float(index) * 1.28, 3.98, -1.0)
		var spot_material: StandardMaterial3D = StandardMaterial3D.new()
		spot_material.albedo_color = Color(0.08, 0.08, 0.08, 1.0)
		spot.material_override = spot_material
		parent.add_child(spot)

	for star_index in range(40):
		var star: MeshInstance3D = MeshInstance3D.new()
		var star_mesh: SphereMesh = SphereMesh.new()
		var radius := randf_range(0.015, 0.05)
		star_mesh.radius = radius
		star_mesh.height = radius * 2.0
		star.mesh = star_mesh
		star.position = Vector3(
			randf_range(-4.0, 4.0),
			randf_range(0.8, 3.7),
			randf_range(-3.4, 0.8)
		)
		var star_material: StandardMaterial3D = StandardMaterial3D.new()
		star_material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		star_material.emission_enabled = false
		star_material.emission_energy_multiplier = 0.0
		star_material.albedo_color = Color(1, 1, 1, 1)
		star.material_override = star_material
		parent.add_child(star)

	for orb_index in range(4):
		var orb: MeshInstance3D = MeshInstance3D.new()
		var orb_mesh: SphereMesh = SphereMesh.new()
		orb_mesh.radius = randf_range(0.22, 0.42)
		orb_mesh.height = orb_mesh.radius * 2.0
		orb.mesh = orb_mesh
		orb.position = Vector3(
			randf_range(-3.5, 3.5),
			randf_range(1.2, 3.2),
			randf_range(-2.8, -0.6)
		)
		var orb_material: StandardMaterial3D = StandardMaterial3D.new()
		orb_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		orb_material.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
		orb_material.albedo_color = Color(0.2, 0.4, 1.0, 0.08) if orb_index % 2 == 0 else Color(0.7, 0.3, 1.0, 0.08)
		orb_material.emission_enabled = false
		orb_material.emission_energy_multiplier = 0.0
		orb.material_override = orb_material
		parent.add_child(orb)


func _create_preview_marble_node(palette: Dictionary, model_scale: float) -> Node3D:
	var scene_instance: Node = GLASS_MARBLE_MODEL_SCENE.instantiate()
	var marble: Node3D = scene_instance as Node3D
	if marble == null:
		return null

	if marble.has_method("set_palette"):
		marble.call("set_palette", palette)
	marble.scale = Vector3.ONE * model_scale
	return marble


func _preserve_preview_marble_original_colors(marble: Node3D, palette: Dictionary) -> void:
	var allow_flame_effects := _palette_uses_flame_effects(palette)
	var stack: Array[Node] = [marble]
	while not stack.is_empty():
		var current: Node = stack.pop_back()
		for child in current.get_children():
			stack.append(child)

		if current != marble and _is_preview_marble_illumination_node(current, allow_flame_effects):
			current.queue_free()
			continue

		var mesh_instance: MeshInstance3D = current as MeshInstance3D
		if mesh_instance == null:
			continue

		var override_shader: ShaderMaterial = mesh_instance.material_override as ShaderMaterial
		if override_shader != null:
			var preserved_shader: ShaderMaterial = override_shader.duplicate(true) as ShaderMaterial
			if preserved_shader != null:
				preserved_shader.set_shader_parameter("emission_strength", 0.0)
				preserved_shader.set_shader_parameter("glow_strength", 0.0)
				preserved_shader.set_shader_parameter("rim_strength", 0.0)
				preserved_shader.set_shader_parameter("alpha_strength", 1.0)
				mesh_instance.material_override = preserved_shader

		var override_standard: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
		if override_standard != null:
			var preserved_standard: StandardMaterial3D = override_standard.duplicate(true) as StandardMaterial3D
			if preserved_standard != null:
				_preserve_visible_preview_color(preserved_standard)
				preserved_standard.emission_enabled = false
				preserved_standard.emission_energy_multiplier = 0.0
				preserved_standard.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
				preserved_standard.albedo_color.a = 1.0
				mesh_instance.material_override = preserved_standard

		if mesh_instance.mesh == null:
			continue

		for surface_index in range(mesh_instance.mesh.get_surface_count()):
			var surface_material: Material = mesh_instance.get_surface_override_material(surface_index)
			if surface_material == null:
				surface_material = mesh_instance.mesh.surface_get_material(surface_index)
			var surface_shader: ShaderMaterial = surface_material as ShaderMaterial
			if surface_shader != null:
				var preserved_surface_shader: ShaderMaterial = surface_shader.duplicate(true) as ShaderMaterial
				if preserved_surface_shader != null:
					preserved_surface_shader.set_shader_parameter("emission_strength", 0.0)
					preserved_surface_shader.set_shader_parameter("glow_strength", 0.0)
					preserved_surface_shader.set_shader_parameter("rim_strength", 0.0)
					preserved_surface_shader.set_shader_parameter("alpha_strength", 1.0)
					mesh_instance.set_surface_override_material(surface_index, preserved_surface_shader)
				continue

			var surface_standard: StandardMaterial3D = surface_material as StandardMaterial3D
			if surface_standard != null:
				var preserved_surface_standard: StandardMaterial3D = surface_standard.duplicate(true) as StandardMaterial3D
				if preserved_surface_standard != null:
					_preserve_visible_preview_color(preserved_surface_standard)
					preserved_surface_standard.emission_enabled = false
					preserved_surface_standard.emission_energy_multiplier = 0.0
					preserved_surface_standard.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
					preserved_surface_standard.albedo_color.a = 1.0
					mesh_instance.set_surface_override_material(surface_index, preserved_surface_standard)


func _preserve_visible_preview_color(material: StandardMaterial3D) -> void:
	if material == null:
		return
	if material.albedo_texture == null and material.emission_texture != null:
		material.albedo_texture = material.emission_texture
	if not material.emission_enabled:
		return
	var emission_color: Color = material.emission
	if _preview_color_luminance(emission_color) <= _preview_color_luminance(material.albedo_color) + 0.04:
		return
	var alpha: float = material.albedo_color.a
	if _preview_color_luminance(material.albedo_color) < 0.16:
		material.albedo_color = Color(emission_color.r, emission_color.g, emission_color.b, alpha)
	else:
		material.albedo_color = material.albedo_color.lerp(Color(emission_color.r, emission_color.g, emission_color.b, alpha), 0.35)


func _preview_color_luminance(color: Color) -> float:
	return color.r * 0.2126 + color.g * 0.7152 + color.b * 0.0722


func _is_preview_marble_illumination_node(node: Node, allow_flame_effects: bool) -> bool:
	var lowered_name := str(node.name).to_lower()
	if node is Light3D or node is WorldEnvironment or node is ReflectionProbe:
		return true
	if node is GPUParticles3D or node is CPUParticles3D:
		return not (allow_flame_effects and lowered_name.find("flame") != -1)
	if lowered_name.find("flamecrown") != -1:
		return not allow_flame_effects
	return false


func _palette_uses_flame_effects(palette: Dictionary) -> bool:
	var scene_path: String = str(palette.get("marble_scene_path", "")).to_lower()
	var marble_type: String = str(palette.get("marble_type", "")).to_lower()
	var pattern_name: String = str(palette.get("pattern_name", "")).to_lower()
	return scene_path.find("flame") != -1 or marble_type == "flame" or pattern_name == "flame"


func _add_preview_floor(parent: Node3D, is_large: bool) -> void:
	var floor: MeshInstance3D = MeshInstance3D.new()
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(1.2, 0.78)
	if is_large:
		quad.size = Vector2(10.0, 6.6)
	floor.mesh = quad
	floor.rotation_degrees = Vector3(-90, 0, 0)
	floor.position = Vector3(0.0, 0.0, -0.4 if is_large else 0.0)

	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = Color(0.18, 0.24, 0.18, 1.0) if not is_large else Color(0.03, 0.03, 0.05, 1.0)
	material.metallic = 0.0
	material.roughness = 0.95 if not is_large else 0.72
	floor.material_override = material
	parent.add_child(floor)


func _add_trail_preview_geometry(parent: Node3D, trail_preset: Dictionary, is_large: bool) -> void:
	var enabled: bool = bool(trail_preset.get("enabled", false))
	if not enabled:
		_add_disabled_trail_preview(parent)
		return

	var primary_color: Color = trail_preset.get("color", Color(0.42, 0.92, 1.0, 0.34))
	var secondary_color: Color = trail_preset.get("secondary_color", primary_color)
	var emission_color: Color = trail_preset.get("emission", Color(0.18, 0.8, 1.0, 1.0))
	var shape: String = str(trail_preset.get("shape", "comet"))
	var segment_count: int = 4
	if is_large:
		segment_count = 6

	if shape == "dust":
		for index in range(segment_count + 2):
			var dust: MeshInstance3D = MeshInstance3D.new()
			var dust_mesh: SphereMesh = SphereMesh.new()
			var dust_scale: float = lerpf(0.14, 0.05, float(index) / float(max(segment_count + 1, 1)))
			dust_mesh.radius = dust_scale
			dust_mesh.height = dust_scale * 2.0
			dust.mesh = dust_mesh
			dust.material_override = _make_trail_preview_material(
				primary_color.lerp(secondary_color, float(index) / float(max(segment_count + 1, 1))),
				emission_color,
				lerpf(0.7, 0.22, float(index) / float(max(segment_count + 1, 1)))
			)
			dust.position = Vector3(lerpf(-0.72, 0.12, float(index) / float(max(segment_count + 1, 1))), -0.01 + sin(float(index) * 0.9) * 0.03, 0.0)
			parent.add_child(dust)
		return

	for index in range(segment_count):
		var t: float = float(index) / float(max(segment_count - 1, 1))
		var beam: MeshInstance3D = MeshInstance3D.new()
		var beam_mesh: BoxMesh = BoxMesh.new()
		var width: float = lerpf(0.34, 0.12, t)
		if is_large:
			width = lerpf(0.42, 0.14, t)
		var height: float = 0.06
		if shape == "ribbon":
			height = 0.11
		elif shape == "spark":
			height = 0.04
		beam_mesh.size = Vector3(width, height, height)
		beam.mesh = beam_mesh
		beam.material_override = _make_trail_preview_material(primary_color.lerp(secondary_color, t), emission_color, lerpf(0.78, 0.26, t))
		beam.position = Vector3(lerpf(-0.62, 0.16, t), -0.02, 0.0)
		if shape == "ribbon":
			beam.position.y += sin(t * PI) * 0.05
			beam.rotation_degrees = Vector3(0, 0, lerpf(26.0, -18.0, t))
		elif shape == "spark":
			if index % 2 == 0:
				beam.position.y += 0.045
				beam.rotation_degrees = Vector3(0, 0, -18.0)
			else:
				beam.position.y -= 0.018
				beam.rotation_degrees = Vector3(0, 0, 12.0)
		parent.add_child(beam)
		if shape == "ribbon":
			var accent: MeshInstance3D = MeshInstance3D.new()
			var accent_mesh: BoxMesh = BoxMesh.new()
			accent_mesh.size = Vector3(width * 0.86, height * 0.42, height * 0.42)
			accent.mesh = accent_mesh
			accent.material_override = _make_trail_preview_material(secondary_color, emission_color.lightened(0.1), lerpf(0.55, 0.18, t))
			accent.position = beam.position + Vector3(0.02, 0.045, 0.05)
			accent.rotation_degrees = beam.rotation_degrees
			parent.add_child(accent)

	var flare: MeshInstance3D = MeshInstance3D.new()
	var flare_mesh: SphereMesh = SphereMesh.new()
	flare_mesh.radius = 0.08
	flare_mesh.height = 0.16
	flare.mesh = flare_mesh
	flare.material_override = _make_trail_preview_material(secondary_color, emission_color, 0.92)
	flare.position = Vector3(0.2, -0.01, 0.0)
	parent.add_child(flare)


func _add_disabled_trail_preview(parent: Node3D) -> void:
	var ring: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.1
	mesh.bottom_radius = 0.1
	mesh.height = 0.03
	ring.mesh = mesh
	ring.position = Vector3(0.1, -0.08, 0.0)
	ring.material_override = _make_trail_preview_material(Color(0.42, 0.46, 0.52, 1.0), Color(0.18, 0.18, 0.2, 1.0), 0.42)
	parent.add_child(ring)


func _make_trail_preview_material(base_color: Color, emission_color: Color, alpha: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(base_color.r, base_color.g, base_color.b, alpha)
	material.emission_enabled = true
	material.emission = emission_color
	material.emission_energy_multiplier = 2.2
	material.roughness = 0.18
	return material


func _clear_node_children(target: Node) -> void:
	for child in target.get_children():
		target.remove_child(child)
		child.queue_free()


func _get_marble_preview_texture(marble_id: String, preset: Dictionary) -> Texture2D:
	if marble_preview_cache.has(marble_id):
		return marble_preview_cache[marble_id] as Texture2D

	var texture: Texture2D = _make_marble_preview_texture(preset)
	marble_preview_cache[marble_id] = texture
	return texture


func _get_trail_preview_texture(trail_id: String, preset: Dictionary) -> Texture2D:
	if trail_preview_cache.has(trail_id):
		return trail_preview_cache[trail_id] as Texture2D

	var texture: Texture2D = _make_trail_preview_texture(preset)
	trail_preview_cache[trail_id] = texture
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
				var stripe_mask: float = 1.0 if sin((uv.y + uv.x * 0.4) * 28.0) > 0.0 else 0.0
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
	var width: int = 156
	var height: int = 92
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	var primary_color: Color = preset.get("color", Color(0.42, 0.92, 1.0, 0.34))
	var secondary_color: Color = preset.get("secondary_color", primary_color.lightened(0.2))
	var emission_color: Color = preset.get("emission", Color(0.18, 0.8, 1.0, 1.0))
	var shape: String = str(preset.get("shape", "comet"))

	for y in range(height):
		for x in range(width):
			var uv: Vector2 = Vector2(x, y) / Vector2(width - 1.0, height - 1.0)
			var curve_center: float = 0.68 - uv.x * 0.34 + sin(uv.x * TAU * 1.5) * 0.06
			var core: float = _band_mask(abs(uv.y - curve_center), 0.09, 0.02)
			var glow: float = _band_mask(abs(uv.y - curve_center), 0.18, 0.04)
			var flare: float = pow(max(0.0, 1.0 - ((uv.x - 0.18) * (uv.x - 0.18) + (uv.y - (curve_center - 0.02)) * (uv.y - (curve_center - 0.02))) * 42.0), 2.6)
			var streak: float = core
			if shape == "ribbon":
				streak = max(streak, _band_mask(abs(uv.y - (curve_center + 0.08)), 0.1, 0.03) * 0.72)
			elif shape == "spark":
				streak = max(streak, _band_mask(abs(uv.y - (curve_center - 0.12 * sin(uv.x * TAU * 5.0))), 0.05, 0.012) * 0.95)
			elif shape == "dust":
				streak = max(streak, pow(max(0.0, sin((uv.x * 10.0 + uv.y * 6.0) * TAU)), 14.0) * glow * 0.55)

			var mix_color: Color = primary_color.lerp(secondary_color, clampf(uv.x * 0.9 + uv.y * 0.2, 0.0, 1.0))
			var final_color: Color = mix_color.lerp(emission_color, flare * 0.6 + core * 0.2)
			var alpha: float = clampf(streak * 0.95 + glow * 0.24 + flare * 0.55, 0.0, 1.0)
			image.set_pixel(x, y, Color(final_color.r, final_color.g, final_color.b, alpha))

	return ImageTexture.create_from_image(image)


func _band_mask(distance: float, outer_radius: float, inner_radius: float) -> float:
	if distance >= outer_radius:
		return 0.0
	if distance <= inner_radius:
		return 1.0
	return clampf((outer_radius - distance) / maxf(outer_radius - inner_radius, 0.0001), 0.0, 1.0)


func _create_menu_button(button_name: String, button_text: String) -> Button:
	var button: Button = Button.new()
	button.name = button_name
	button.text = button_text
	return button


func _create_shooting_mechanic_preview_texture(mechanic_id: String) -> Texture2D:
	var width: int = 260
	var height: int = 148
	var image: Image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.015, 0.02, 0.055, 1.0))
	_preview_draw_rect(image, Rect2i(8, 8, width - 16, height - 16), Color(0.035, 0.06, 0.13, 1.0))
	_preview_draw_line(image, Vector2(16, height - 20), Vector2(width - 16, height - 20), Color(0.42, 0.25, 0.9, 0.72), 2)
	_preview_draw_line(image, Vector2(16, 18), Vector2(width - 16, 18), Color(0.1, 0.9, 1.0, 0.22), 1)
	var half_width: int = int(width * 0.5)

	if mechanic_id == "split":
		_preview_draw_rect(image, Rect2i(10, 10, half_width - 10, height - 20), Color(0.02, 0.16, 0.17, 0.62))
		_preview_draw_rect(image, Rect2i(half_width, 10, half_width - 10, height - 20), Color(0.13, 0.04, 0.18, 0.62))
		_preview_draw_line(image, Vector2(half_width, 14), Vector2(half_width, height - 16), Color(0.92, 0.95, 1.0, 0.42), 2)
		_preview_draw_circle(image, Vector2(62, 88), 14, Color(0.35, 0.96, 0.92, 1.0))
		_preview_draw_line(image, Vector2(62, 88), Vector2(104, 54), Color(0.35, 0.96, 0.92, 1.0), 4)
		_preview_draw_circle(image, Vector2(194, 92), 14, Color(1.0, 0.82, 0.2, 1.0))
		_preview_draw_line(image, Vector2(194, 92), Vector2(194, 42), Color(1.0, 0.82, 0.2, 1.0), 5)
		_preview_draw_ring(image, Vector2(194, 92), 31, Color(0.75, 0.34, 1.0, 0.75), 3)
	elif mechanic_id == "press":
		_preview_draw_circle(image, Vector2(64, 88), 14, Color(0.35, 0.96, 0.92, 1.0))
		_preview_draw_line(image, Vector2(64, 88), Vector2(148, 50), Color(0.35, 0.96, 0.92, 1.0), 4)
		_preview_draw_ring(image, Vector2(202, 92), 38, Color(0.75, 0.34, 1.0, 0.9), 6)
		_preview_draw_ring(image, Vector2(202, 92), 24, Color(1.0, 0.82, 0.2, 0.95), 5)
		_preview_draw_circle(image, Vector2(202, 92), 10, Color(0.96, 0.99, 1.0, 1.0))
		for index in range(5):
			var y: int = 118 - index * 16
			_preview_draw_rect(image, Rect2i(24, y, 10 + index * 6, 7), Color(1.0, 0.82, 0.2, 0.35 + float(index) * 0.1))
	else:
		_preview_draw_circle(image, Vector2(72, 92), 14, Color(0.35, 0.96, 0.92, 1.0))
		_preview_draw_line(image, Vector2(72, 92), Vector2(172, 46), Color(0.35, 0.96, 0.92, 1.0), 4)
		_preview_draw_line(image, Vector2(72, 92), Vector2(128, 120), Color(1.0, 0.82, 0.2, 1.0), 5)
		_preview_draw_ring(image, Vector2(172, 46), 22, Color(0.75, 0.34, 1.0, 0.8), 3)
		_preview_draw_ring(image, Vector2(128, 120), 18, Color(1.0, 0.82, 0.2, 0.72), 3)

	return ImageTexture.create_from_image(image)


func _preview_draw_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(maxi(rect.position.y, 0), mini(rect.position.y + rect.size.y, image.get_height())):
		for x in range(maxi(rect.position.x, 0), mini(rect.position.x + rect.size.x, image.get_width())):
			image.set_pixel(x, y, color)


func _preview_draw_line(image: Image, start: Vector2, end: Vector2, color: Color, thickness: int) -> void:
	var steps: int = maxi(int(ceil(start.distance_to(end))), 1)
	for index in range(steps + 1):
		var point: Vector2 = start.lerp(end, float(index) / float(steps))
		_preview_draw_circle(image, point, thickness, color)


func _preview_draw_circle(image: Image, center: Vector2, radius: int, color: Color) -> void:
	var radius_squared: int = radius * radius
	for y in range(int(center.y) - radius, int(center.y) + radius + 1):
		for x in range(int(center.x) - radius, int(center.x) + radius + 1):
			var dx: int = x - int(center.x)
			var dy: int = y - int(center.y)
			if dx * dx + dy * dy <= radius_squared and x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


func _preview_draw_ring(image: Image, center: Vector2, radius: int, color: Color, thickness: int) -> void:
	var inner_radius: int = maxi(radius - thickness, 0)
	var outer_squared: int = radius * radius
	var inner_squared: int = inner_radius * inner_radius
	for y in range(int(center.y) - radius, int(center.y) + radius + 1):
		for x in range(int(center.x) - radius, int(center.x) + radius + 1):
			var dx: int = x - int(center.x)
			var dy: int = y - int(center.y)
			var dist_squared: int = dx * dx + dy * dy
			if dist_squared <= outer_squared and dist_squared >= inner_squared and x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
				image.set_pixel(x, y, color)


func _create_settings_label(text_value: String) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.add_theme_font_override("font", ui_font)
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color(0.88, 0.95, 1.0, 0.96))
	return label


func _create_volume_slider(slider_name: String) -> HSlider:
	var slider: HSlider = HSlider.new()
	slider.name = slider_name
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	return slider


func _create_sensitivity_slider(slider_name: String) -> HSlider:
	var slider: HSlider = HSlider.new()
	slider.name = slider_name
	slider.min_value = 0.5
	slider.max_value = 1.5
	slider.step = 0.05
	return slider


func _make_menu_panel_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 30
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 30
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 28
	style.shadow_offset = Vector2(0, 10)
	style.content_margin_left = 18.0
	style.content_margin_top = 18.0
	style.content_margin_right = 18.0
	style.content_margin_bottom = 18.0
	style.anti_aliasing = true
	return style


func _make_menu_button_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 22
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 8)
	style.content_margin_left = 16.0
	style.content_margin_top = 14.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 14.0
	style.anti_aliasing = true
	return style


func _make_neon_menu_button_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.6)
	style.shadow_size = 18
	style.shadow_offset = Vector2.ZERO
	style.content_margin_left = 0.0
	style.content_margin_top = 0.0
	style.content_margin_right = 0.0
	style.content_margin_bottom = 0.0
	style.anti_aliasing = true
	return style


func _make_settings_outer_panel_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.006, 0.002, 0.022, 0.62)
	style.border_color = Color(0.62, 0.08, 0.98, 0.86)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 18
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 18
	style.shadow_color = Color(0.78, 0.12, 1.0, 0.5)
	style.shadow_size = 28
	style.shadow_offset = Vector2.ZERO
	style.content_margin_left = 18
	style.content_margin_top = 18
	style.content_margin_right = 18
	style.content_margin_bottom = 18
	style.anti_aliasing = true
	return style


func _make_settings_control_style(fill_color: Color, border_color: Color, corner_radius: int) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_color = border_color
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = corner_radius
	style.corner_radius_top_right = corner_radius
	style.corner_radius_bottom_right = corner_radius
	style.corner_radius_bottom_left = corner_radius
	style.shadow_color = Color(border_color.r, border_color.g, border_color.b, 0.32)
	style.shadow_size = 16
	style.shadow_offset = Vector2.ZERO
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	style.anti_aliasing = true
	return style


func _make_settings_hex_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = _make_settings_control_style(fill_color, border_color, 12)
	style.corner_radius_top_left = 18
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 18
	style.corner_radius_bottom_left = 8
	return style


func _make_settings_slider_track_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.01, 0.18, 0.72)
	style.border_color = Color(0.52, 0.08, 0.92, 0.82)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_right = 4
	style.corner_radius_bottom_left = 4
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style


func _make_settings_slider_fill_style() -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.25, 1.0, 0.95)
	style.border_color = Color(1.0, 0.82, 1.0, 0.95)
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.corner_radius_top_left = 5
	style.corner_radius_top_right = 5
	style.corner_radius_bottom_right = 5
	style.corner_radius_bottom_left = 5
	style.shadow_color = Color(0.92, 0.12, 1.0, 0.9)
	style.shadow_size = 8
	style.shadow_offset = Vector2.ZERO
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	return style


func _create_settings_slider_grabber_texture(color: Color) -> Texture2D:
	var size: int = 26
	var image: Image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	_preview_draw_circle(image, Vector2(size * 0.5, size * 0.5), 12, Color(0.78, 0.12, 1.0, 0.32))
	_preview_draw_circle(image, Vector2(size * 0.5, size * 0.5), 9, color)
	_preview_draw_circle(image, Vector2(size * 0.5, size * 0.5), 4, Color(0.74, 0.08, 1.0, 1.0))
	return ImageTexture.create_from_image(image)


func _make_button_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_right = 24
	style.corner_radius_bottom_left = 24
	style.shadow_color = Color(0.01, 0.03, 0.05, 0.28)
	style.shadow_size = 18
	style.shadow_offset = Vector2(0, 8)
	style.content_margin_left = 16.0
	style.content_margin_top = 14.0
	style.content_margin_right = 16.0
	style.content_margin_bottom = 14.0
	style.anti_aliasing = true
	return style


func _make_glow_style(glow_color: Color) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(glow_color.r, glow_color.g, glow_color.b, glow_color.a * 0.28)
	style.corner_radius_top_left = 220
	style.corner_radius_top_right = 220
	style.corner_radius_bottom_right = 220
	style.corner_radius_bottom_left = 220
	style.shadow_color = glow_color
	style.shadow_size = 120
	style.shadow_offset = Vector2.ZERO
	return style
