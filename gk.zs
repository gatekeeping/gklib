
class GK_Config
{
	array<string> numberNames;
	array<double> numberValues;
	
	array<string> stringNames;
	array<string> stringValues;
	
	static string trim(string s, string delim = " ") {
		array<string> a;
		s.split(a, delim, TOK_SKIPEMPTY);
		return a[0];
	}
	
	static GK_Config create(string lumpName) {
		let p = new();
		let data = p.loadLump(lumpName);
		array<string> lines; data.split(lines, "\n", TOK_SKIPEMPTY);
		for (let i = lines.size() - 1; i > 0; i--) {
			array<string> parts; lines[i].split(parts, "=");
			if (parts.size() < 2) continue;
			p.stringNames.push(trim(parts[0]));
			p.stringValues.push(trim(trim(parts[1], "//")));
		}
		return p;
	}
	
	string loadLump(string lumpName) {
		let index = Wads.FindLump(lumpName, 0, Wads.anyNamespace);
		if (index < 0) {
			console.printf("can't find lump %s", lumpName);
			return "";
		}
		console.printf("found lump %s at index %i", lumpName, index);
		return Wads.ReadLump(index);
	}
	
	string xloadLump(string fromLump, string afterLump, string beforeLump) {
		let index = 0;
		let foundIndex = -1;
		
		if (afterLump != "") {
			index = Wads.FindLump(afterLump, index, Wads.anyNamespace);
			if (index < 0) {
				console.printf("can't find lump %s (1)", afterLump);
				return "";
			}
			console.printf("found lump %s at index %i", afterLump, index);
		}
		
		foundIndex = Wads.FindLump(fromLump, index, Wads.anyNamespace);
		
		if (foundIndex < 0) {
			console.printf("can't find lump %s (2)", fromLump);
			return "";
		}
		
		if (beforeLump != "")
			index = Wads.FindLump(beforeLump, foundIndex, Wads.anyNamespace);
			
		if (index > -1 && index < foundIndex) {
			console.printf("can't find lump %s (3)", fromLump);
			return "";
		}
		
		return Wads.ReadLump(foundIndex);
	}
}


// constants and static stuff
class GK play
{
	// portal type 2 = normal, 3 = static
	const PORTAL_TYPE = 3;

	// Directional
	enum Direction4 { EAST, NORTH, WEST, SOUTH };
	
	// TODO: parameterize some of these
	const MAX_LEVELS = 100;
	const PLAYFIELD_SIZE = 128; // playfield zone grid rows/cols
	const TEMPLATE_SIZE = 8; // template zone grid rows/cols
	const ZONE_SIZE = 4096; // width and height of each zone
	const MAX_ZONES = TEMPLATE_SIZE * TEMPLATE_SIZE;
	const MAX_GATEWAYS = MAX_ZONES * 4;
	const MAX_GATEWAY_LINES = 15; // must be odd
	const FIRST_LINE_ID = 11000; // reserves line ids beginning with this number
	
	class<GK_Dungeon> Dungeon;

	// get custom udmf fields
	static int getLineStyle(int lineIndex) {
		return level.GetUDMFInt(LevelLocals.UDMF_Line, lineIndex, "user_style");
	}

	// get the Game singleton
	play static GK_Game getGame() {
		return GK_Game.getInstance();
	}

}
