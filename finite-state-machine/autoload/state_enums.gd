extends Node
class_name StateEnums

enum PlayerStateType {
	IDLE,
	WALK,
	RUN,
	SLIDE,
	JUMP,
	FALL,
	HURT, #FIX: why does removing hurt mess with the swithing to dash state?
	DASH,
	UNDEFINED,
}
