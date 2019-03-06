// config loader
class GK_Config
{
	string mapName;
	
	const DEFAULT_ZONE_SIZE = 4096;
	const DEFAULT_PLAYFIELD_SIZE = 128;
	const DEFAULT_GATEWAY_LINES = 15;
	const DEFAULT_FIRST_LINE_ID = 11000;
	const DEFAULT_PORTAL_TYPE = 3;
	
	const MAP_QUADRANT_SIZE = 32768;
	
	// things that can set in config file
	
	int zoneSize; // Width and height of each zone.
	int playfieldSize; // Playfield zone grid rows/cols.
	int gatewayLines; // Max portals in a gateway. Must be odd.
	int firstLineId;  // reserves line ids beginning with this number
	int portalType;  // portal type 2 = normal, 3 = static
	
	// things computed based on the values above
	
	int templateSize; // template zone grid rows/cols
	
	static GK_Config create(string lumpName, string mapName) {
		let p = new();
		
		p.mapName = mapName;
		
		p.zoneSize = DEFAULT_ZONE_SIZE;
		p.playfieldSize = DEFAULT_PLAYFIELD_SIZE;
		p.gatewayLines = DEFAULT_GATEWAY_LINES;
		p.firstLineId = DEFAULT_FIRST_LINE_ID;
		p.portalType = DEFAULT_PORTAL_TYPE;
		
		return p.parse(lumpName).finalize();
	}
	
	GK_Config parse(string lumpName) {
		let data = loadLump(lumpName);
		
		array<string> lines;
		array<string> parts;
		let section = "";
		
		lines.clear();
		
		data.split(lines, "\n");
		
		for (let i = 0; i < lines.size(); i++) {
			parts.clear();
			lines[i].split(parts, "=");
			if (parts.size() < 2) {
				parts.clear();
				trim(lines[i]).split(parts, " ", TOK_SKIPEMPTY);
				if (parts.size() >= 1 && trim(parts[0]) ~== "DefaultMap") {
					section = "DefaultMap";
				} else if (parts.size() >= 2 && trim(parts[0]) ~== "Map") {
					section = parts[1];
				}
				continue;
			}
			let k = trim(parts[0]);
			let v = trim(before(parts[1], "//"));
			setOption(section, k, v);
		}
		
		return self;
	}
	
	GK_Config finalize() {
		templateSize = MAP_QUADRANT_SIZE / zoneSize;
		return self;
	}
	
	static string trim(string s) {
		let left = 0;
		let right = s.length();
		
		for (let i = left; i < right; i++) {
			if (s.charCodeAt(i) <= 32) ++left; else break;
		}
		
		for (let i = right; i-- > left;) {
			if (s.charCodeAt(i) <= 32) --right; else break;
		}
		
		return s.mid(left, right - left);
	}
	
	static string before(string s, string delim) {
		array<string> a;
		s.split(a, delim);
		return a[0];
	}
	
	static string loadLump(string lumpName) {
		let index = Wads.findLump(lumpName, 0, Wads.anyNamespace);
		if (index < 0) {
			console.printf("GK: Can't find config lump %s", lumpName);
			return "";
		}
		console.printf("GK: Found config lump %s at index %i", lumpName, index);
		return Wads.readLump(index);
	}

	void setOption(string section, string title, string value) {
		if (!(section ~== mapName || section ~== "DefaultMap")) return;
		
		if (title ~== "zoneSize") {
			zoneSize = value.toInt();
		} else if (title ~== "playfieldSize") {
			playfieldSize = value.toInt();
		} else if (title ~== "gatewayLines") {
			gatewayLines = value.toInt();
		} else if (title ~== "firstLineId") {
			firstLineId = value.toInt();
		} else if (title ~== "portalType") {
			portalType = value.toInt();
		}
	}
}