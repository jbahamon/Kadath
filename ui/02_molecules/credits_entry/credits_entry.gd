extends MarginContainer

func set_item(credits_item):
	$CreditsEntry/AssetUsage.text = credits_item.asset_usage
	$CreditsEntry/AssetName.text = "\t[color=light_sky_blue][url=%s]%s[/url][/color]" % [
		credits_item.asset_url,
		credits_item.asset_name,
	]
	
	if credits_item.get("author_literal", false):
		$CreditsEntry/AuthorName.text = "\t[color=light_sky_blue][url=%s]%s[/url][/color]" % [
			credits_item.author_url,
			credits_item.author_name,
		]
	else:
		$CreditsEntry/AuthorName.text = "\tBy [color=light_sky_blue][url=%s]%s[/url][/color]" % [
			credits_item.author_url,
			credits_item.author_name,
		]

func url_clicked(meta):
	OS.shell_open(str(meta))
