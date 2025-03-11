import argparse
import re

if __name__ == "__main__":

	parser = argparse.ArgumentParser(
		prog="InsertAnimation",
		description="offset all animations in a tscn after a certain y sprite coord value",
	)

	parser.add_argument('input_file')
	parser.add_argument('inserted_index', type=int)
	parser.add_argument('output_file')

	args = parser.parse_args()

	with open(args.input_file, 'r') as in_file:
		with open(args.output_file, 'w') as out_file:
			for line in in_file:
				if line.startswith('"values": [Vector2i('):

					matches = re.findall(r'\(([0-9]+), ([0-9]+)\)', line)

					vectors = []

					for match in matches:
						i = int(match[1])
						if i > args.inserted_index:
							vectors.append('Vector2i(%s, %d)' % (match[0], i + 1))
						else:
							vectors.append('Vector2i(%s, %s)' % match)

					out_file.write(
						'"values": [%s]' % ", ".join(vectors)
					)

				else:
					out_file.write(line)
