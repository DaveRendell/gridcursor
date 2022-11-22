class_name SongOfFortitude extends Crest

func _init():
	display_name = "Song of Fortitude"

func songs():
	return [Song.new("Song of Fortitude", 3, SongOfFortitudeBuff.new(), "Def + 3", Color.LIGHT_BLUE, Color.LIGHT_BLUE)]

class SongOfFortitudeBuff extends TemporaryEffect:
	func _init():
		super("Buff (Song of Fortitude)", TemporaryEffect.ExpiresAt.END_OF_TURN)

	func defence_boost():
		return 3
