from collections import defaultdict
import json

per_section = defaultdict(list)

labels = {
	"graphics": "Graphics",
	"sounds": "Music and Sounds",
	"code": "Code",
}

with open("CREDITS.json", 'r') as credits_file:
	for item in json.loads(credits_file.read()):
		per_section[labels[item["category"]]].append(item)


with open("out.md", "w") as out_file:
	for section_name, items in per_section.items():
		out_file.write(f"### {section_name}\n\n")

		for item in items:
			out_file.write(f"{item['asset_usage']}:\n")

			if item.get("author_literal", False):
				out_file.write(f"\t[{item['asset_name']}]({item['asset_url']}) - [{item['author_name']}]({item['author_url']})\n\n")
			else:
				out_file.write(f"\t[{item['asset_name']}]({item['asset_url']}) by [{item['author_name']}]({item['author_url']})\n\n")


