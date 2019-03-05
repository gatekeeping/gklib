// config loader
class GK_Config
{
	string mapName;
	
	// things that can set in config file
	
	int zoneSize; // Width and height of each zone.
	int playfieldSize; // Playfield zone grid rows/cols.
	int gatewayLines; // Max portals in a gateway. Must be odd.
	
	// things computed based on the values above
	
	int templateSize; // template zone grid rows/cols
	int maxZones;
	
	static GK_Config create(string lumpName, string mapName) {
		let p = new();
		
		p.zoneSize = GK.ZONE_SIZE;
		p.playfieldSize = GK.PLAYFIELD_SIZE;
		p.gatewayLines =  GK.MAX_GATEWAY_LINES;
		p.mapName = mapName;
		
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
		// nothing to do here yet
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
		
		console.printf("%s, %s, %s", section, title, value);
		
		if (title ~== "zoneSize") {
			zoneSize = value.toInt();
		} else if (title ~== "playfieldSize") {
			playfieldSize = value.toInt();
		} else if (title ~== "gatewayLines") {
			gatewayLines = value.toInt();
		}
	}
}