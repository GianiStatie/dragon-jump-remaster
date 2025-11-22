extends Panel


func show_stats(stats: Dictionary) -> void: 
	%TimeLabel.text = str(stats["time"])
	%ResetsLabel.text = str(stats["restarts"])
	%CrownDroppedLabel.text = str(stats["crowns_dropped"])
	self.visible = true
