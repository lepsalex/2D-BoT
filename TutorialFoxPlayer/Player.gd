extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export(int) var ACCELERATION = 480
export(int) var MAX_SPEED = 80
export(int) var ROLL_SPEED = 120
export(int) var FRICTION = 520
export(float) var ROLL_COEFFICIENT = 0.8
export(int) var INVINCIBILITY_TIMER = 0.6

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitBoxPivot/SwordHitBox
onready var hurtbox = $HurtBox
onready var blinkAnimPlayer = $BlinkAnimationPlayer

func _ready():
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector


func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK


func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()


func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	# todo: animation cancelling


func move():
	velocity = move_and_slide(velocity)


func roll_anim_finished():
	velocity = velocity * ROLL_COEFFICIENT
	state = MOVE


func attack_anim_finished():
	state = MOVE


func play_hurt_sound():
	get_tree().current_scene.add_child(PlayerHurtSound.instance())


func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(INVINCIBILITY_TIMER)
	hurtbox.create_hit_effect()
	play_hurt_sound()


func _on_HurtBox_invincibility_started():
	blinkAnimPlayer.play("Start")


func _on_HurtBox_invincibility_ended():
	blinkAnimPlayer.play("Stop")