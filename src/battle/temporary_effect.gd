class_name TemporaryEffect extends Feature

enum ExpiresAt {
	END_OF_TURN
}

var expires_at: ExpiresAt

func _init(_display_name: String, _expires_at: ExpiresAt):
	expires_at = _expires_at
	super(_display_name)
