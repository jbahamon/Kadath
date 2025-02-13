extends MarginContainer

func set_item(credits_item):
	$CreditsEntry/AssetUsage.text = credits_item.asset_usage
	$CreditsEntry/AssetName.text = "\t%s ([color=light_sky_blue][url]%s[/url][/color])" % [
		credits_item.asset_name, 
		credits_item.asset_url
	]
	
	if credits_item.get("author_literal", false):
		$CreditsEntry/AuthorName.text = "\t%s ([color=light_sky_blue][url]%s[/url][/color])" % [
			credits_item.author_name,
			credits_item.author_url,
		]
	else:
		$CreditsEntry/AuthorName.text = "\tBy %s ([color=light_sky_blue][url]%s[/url][/color])" % [
			credits_item.author_name,
			credits_item.author_url,
		]

func url_clicked(meta):
	OS.shell_open(str(meta))
