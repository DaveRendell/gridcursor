extends Popup

func test():
	var blue_soldier_sprite_sheet = preload("res://img/characters/Soldier-Blue.png")
	var blue_soldier_sprite = PunyCharacterSprite.character_sprite(blue_soldier_sprite_sheet)
	var slime_sprite_sheet = preload("res://img/characters/Slime.png")
	var slime_sprite_1 = PunyCharacterSprite.slime_sprite(slime_sprite_sheet)
	
	var reginald = Character.new("Reginald", blue_soldier_sprite, 3, 2, 1, 1)
	
	var blob1 = Mob.new("Blobber", slime_sprite_1, 0, 0, 0, 0, Attack.new("Slime", 1, 1, [1], 2))
	
	for_attack(Attack.new("Slime", 1, 1, [1], 2), blob1, reginald)
	
	popup()

func _input(event: InputEvent):
	if (event.is_action_pressed("ui_accept")):
		hide()

func for_attack(attack: Attack, attacker: Character, target: Character) -> void:
	$PopupContainer/ContentContainer/Rows/CenterContainer/AttackTitle.text = attack.name
	var attacker_details = $PopupContainer/ContentContainer/Rows/Columns/AttackerDetails
	attacker_details.get_node("AttackerName").text = attacker.display_name
	attacker_details.get_node("CenterContainer/Container/Sprite2D").frames = attacker.sprite.frames
	
	var target_details = $PopupContainer/ContentContainer/Rows/Columns/TargetDetails
	target_details.get_node("TargetName").text = target.display_name
	target_details.get_node("CenterContainer/Container/Sprite2D").frames = target.sprite.frames
	
	var best_stat = -1
	for stat in attack.attacking_stats:
		if attacker.stats[stat] > attacker.stats[best_stat]:
			best_stat = stat
	
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var d1 = rng.randi_range(1, 6)
	var d2 = rng.randi_range(1, 6)
	var roll = d1 + d2 + attacker.stats[best_stat]
	var def = target.defence()
	
	attacker_details.get_node("CenterContainer/ToHitBonus").text = "+%s" % [attacker.stats[best_stat]]
	target_details.get_node("CenterContainer/Defence").text = "%s DEF" % [def]
	var dice_details = $PopupContainer/ContentContainer/Rows/Columns/DiceDetails
	dice_details.get_node("Dice/Container/Dice1").frame = d1
	dice_details.get_node("Dice/Container2/Dice2").frame = d2
	dice_details.get_node("Result").text = "%s to hit" % [roll]
	
	if roll >= def:
		dice_details.get_node("Consequence").text = "%s damage!" % [attack.damage]
	else:
		dice_details.get_node("Consequence").text = "Miss!"
