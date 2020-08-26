extends KinematicBody2D

export(int) var ACCELERATION = 300
export(int) var MAX_SPEED = 50
export(int) var FRICTION = 200
export(int) var WANDER_TARGET_BUFFER = 5
export(int) var INVINCIBILITY_TIMER = 0.3

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var state = IDLE

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $HurtBox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkAnimPlayer = $BlinkAnimationPlayer


func _ready():
	state = pick_random_state([IDLE, WANDER])


func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			wander_or_idle_on_timeout()
			
		WANDER:
			seek_player()
			wander_or_idle_on_timeout()
			accelerate_towards(wanderController.target_pos, delta)
			
			if global_position.distance_to(wanderController.target_pos) <= WANDER_TARGET_BUFFER:
				wander_or_idle()
			
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				accelerate_towards(player.global_position, delta)
			else:
				state = IDLE
	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400

	velocity = move_and_slide(velocity)


func accelerate_towards(pos, delta):
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0


func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE


func wander_or_idle():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))


func wander_or_idle_on_timeout():
	if wanderController.get_time_left() == 0:
		wander_or_idle()


func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()


func _on_HurtBox_area_entered(area):
	hurtbox.start_invincibility(INVINCIBILITY_TIMER)
	hurtbox.create_hit_effect()
	knockback = area.knockback_vector * 120
	stats.health -= area.damage


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position


func _on_HurtBox_invincibility_started():
	blinkAnimPlayer.play("Start")


func _on_HurtBox_invincibility_ended():
	blinkAnimPlayer.play("Stop")
