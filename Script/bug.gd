# bug.gd
# Nodo: CharacterBody2D
# Enemigo básico — persigue al jugador y lo daña al tocarlo.
# Al ser eliminado emite señal para el mundo_inicial.gd
#
# Árbol de nodos:
# Bug (CharacterBody2D)
# ├── AnimatedSprite2D   ← animaciones: idle, walk
# ├── CollisionShape2D
# ├── DetectionArea (Area2D)    ← radio grande, detecta al jugador
# │   └── CollisionShape2D     ← CircleShape2D radio ~120px
# └── HitboxArea (Area2D)      ← daña al jugador al tocar
#     └── CollisionShape2D     ← igual al cuerpo

extends CharacterBody2D

# ── Señal ─────────────────────────────────────────────────────────────────────
signal eliminado   # mundo_inicial.gd escucha esto

# ── Stats ─────────────────────────────────────────────────────────────────────
@export var velocidad : float = 45.0
@export var vida      : int   = 2      # golpes para morir
@export var danio     : int   = 10     # daño al jugador por contacto

# ── Nodos ─────────────────────────────────────────────────────────────────────
@onready var sprite        : AnimatedSprite2D = $AnimatedSprite2D
@onready var detection     : Area2D           = $DetectionArea
@onready var hitbox        : Area2D           = $HitboxArea

# ── Estado ────────────────────────────────────────────────────────────────────
var _objetivo : CharacterBody2D = null   # referencia al jugador
var _vivo     := true

# ── Ciclo de vida ─────────────────────────────────────────────────────────────
func _ready() -> void:
	detection.body_entered.connect(_on_detection_entered)
	detection.body_exited.connect(_on_detection_exited)
	hitbox.body_entered.connect(_on_hitbox_entered)

func _physics_process(_delta: float) -> void:
	if not _vivo or not _objetivo:
		if sprite and sprite.animation != "idle":
			sprite.play("idle")
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Perseguir al jugador
	var dir := (_objetivo.global_position - global_position).normalized()
	velocity = dir * velocidad

	# Voltear sprite según dirección
	if sprite:
		sprite.flip_h = dir.x < 0
		sprite.play("run")

	move_and_slide()

# ── Detección del jugador ─────────────────────────────────────────────────────
func _on_detection_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		_objetivo = body

func _on_detection_exited(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		_objetivo = null

# ── Daño al jugador ───────────────────────────────────────────────────────────
func _on_hitbox_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		GameManager.recibir_danio(danio)

# ── Recibir daño (llamado desde el jugador al atacar) ─────────────────────────
func recibir_golpe() -> void:
	if not _vivo:
		return
	vida -= 1
	# Flash de daño
	modulate = Color(1, 0.3, 0.3)
	await get_tree().create_timer(0.15).timeout
	modulate = Color.WHITE

	if vida <= 0:
		_morir()

func _morir() -> void:
	_vivo = false
	velocity = Vector2.ZERO
	eliminado.emit()
	# Pequeña animación antes de desaparecer
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	await tween.finished
	queue_free()
