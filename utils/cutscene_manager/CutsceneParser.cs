using Godot;
using System;
using System.Text.RegularExpressions;

public class CutsceneParser: Node
{
	private const string FadePattern =  @"TO *(?<Color>.+) IN (?<Time>.+)";

	private const string MovePattern = @"TO *(?<Position>.+) IN (?<Time>.+)";

	private const string WalkPattern = @"(?<NPC>.+) TO *(?<Position>.+) AT (?<Time>.+)";

	private const string ColorPattern = @"\([ ]*(?<R>[^ ,)]+)[ ]*,[ ]*(?<G>[^ ,)]+)[ ]*,[ ]*(?<B>[^ ,)]+)[ ]*,[ ]*(?<A>[^ ,)]+)[ ]*\)";
	private const string PositionPattern = @"\([ ]*(?<X>[^ ,)]+)[ ]*,[ ]*(?<Y>[^ ,)]+)[ ]*\)";
	static GDScript CutsceneInstruction = (GDScript) GD.Load("res://utils/cutscene_manager/cutscene_instruction.gd");
	

	public Godot.Collections.Array ParseCutscene(string cutsceneName)
	{
		Godot.File cutsceneFile = new Godot.File();
		cutsceneFile.Open(cutsceneName, Godot.File.ModeFlags.Read);
		Godot.Collections.Array instructions = (Godot.Collections.Array)new Godot.Collections.Array();

		while (!cutsceneFile.EofReached())
		{
			string line = cutsceneFile.GetLine();
			string[] tokens = line.Trim().Split(new char[] {' '}, 2, StringSplitOptions.RemoveEmptyEntries);

			if (tokens.Length > 0) 
			{
				
				var instructionName = tokens[0];
				var args = (tokens.Length > 1)? tokens[1] : "";
				instructions.Add(this.processLine(tokens[0], args.Trim()));	
			}
		}

		return instructions;
	}
	
	private Godot.Object processLine(string instructionName, string argsString)
	{
		Godot.Collections.Dictionary args = (Godot.Collections.Dictionary )new Godot.Collections.Dictionary();
		Godot.Object instruction = (Godot.Object) CutsceneParser.CutsceneInstruction.New();
		var typeEnum = ((Godot.Collections.Dictionary)instruction.Get("Type"));
		var type = typeEnum[instructionName];
		
		switch(instructionName)
		{
			case "SET_OVERLAY":
				args["Color"] = this.parseColor(argsString.Trim());
				break;
			case "FADE_OVERLAY":
				var fadeMatch = Regex.Match(argsString, CutsceneParser.FadePattern);

				args["Color"] = this.parseColor(fadeMatch.Groups["Color"].Value.Trim());
				args["Time"] = Single.Parse(fadeMatch.Groups["Time"].Value.Trim());

				break;
			case "SET_CAMERA":
				args["Position"] = this.parsePosition(argsString.Trim());
				break;
			case "MOVE_CAMERA":
				
				var moveMatch = Regex.Match(argsString, CutsceneParser.MovePattern);

				args["Position"] = this.parsePosition(moveMatch.Groups["Position"].Value.Trim());
				args["Time"] = Single.Parse(moveMatch.Groups["Time"].Value.Trim());

				break;
			case "NPC_WALK":
				var walkMatch = Regex.Match(argsString, CutsceneParser.WalkPattern);
				
				args["NPC"] = walkMatch.Groups["NPC"].Value.Trim();
				args["Position"] = this.parsePosition(walkMatch.Groups["Position"].Value.Trim());
				args["Time"] = Single.Parse(walkMatch.Groups["Time"].Value.Trim());
				break;
			case "OPEN_DIALOG":
				args["Dialog"] = argsString.Trim();
				break;
			case "SIMULTANEOUS":
				break;
			case "SEQUENTIAL":
				break;
			case "END":
				break;

		}
		
		instruction.Set("type", type);
		instruction.Set("args", args);
		
		return instruction;
	}

	private Godot.Color parseColor(string colorString) 
	{
		
		var match = Regex.Match(colorString, CutsceneParser.ColorPattern);

		return new Godot.Color(
			Single.Parse(match.Groups["R"].Value),
			Single.Parse(match.Groups["G"].Value),
			Single.Parse(match.Groups["B"].Value),
			Single.Parse(match.Groups["A"].Value));
	}

	private Godot.Vector2 parsePosition(string positionString)
	{
		var match = Regex.Match(positionString, CutsceneParser.PositionPattern);
		
		return new Godot.Vector2(
			Single.Parse(match.Groups["X"].Value),
			Single.Parse(match.Groups["Y"].Value));
	}
	
}
