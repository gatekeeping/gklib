// A Template stores the position of Zones as they appear on the level map.

class GK_Template play
{
	GK_Dungeon dungeon;
	
	GK_Grid grid;
	
	int _MGL;
	int _ZS;
	
	static GK_Template create(GK_Dungeon d) {
		let p = new();
		p._MGL = d.config.gatewayLines;
		p._ZS = d.config.zoneSize;
		p.grid = GK_Grid.create(d.config.templateSize);
		p.dungeon = d;
		p.scanPortals();
		return p;
	}
	
	void scanPortals() {
		// look at all lines for style.
		for (int i = 0; i < level.lines.size(); i++) {
			let style = GK.getLineStyle(i);
			if (style < 1) continue;
			insertPortal(i);
		}
	}
	
	GK_Zone getZone(int x, int y) {
		let p = grid.get(x, y);
		if (p != null) return p;
		p = GK_Zone.create(dungeon, x, y);
		grid.set(x, y, p);
		return p;
	}
	
	GK_Gateway insertPortal(int lineIndex) {
		let p1 = level.lines[lineIndex].v1.p;
		let p2 = level.lines[lineIndex].v2.p;
		let d = p2 - p1;
		
		// get position of portal line on face of zone
		let face = -1;
		if (d.y < 0) face = GK.EAST;
		else if (d.x > 0) face = GK.NORTH;
		else if (d.y > 0) face = GK.WEST;
		else if (d.x < 0) face = GK.SOUTH;
		
		// get line position in grid
		let x = p1.x / _ZS;
		let y = p1.y / _ZS;
		
		// translate room corner to origin
		let c = (p1 + p2) / 2;
		int cx = c.x % _ZS, cy = c.y % _ZS;
		
		let i = -1;
		switch (face) {
			case GK.EAST: i = _MGL - 1 - (cy * _MGL / _ZS); break;
			case GK.NORTH: i = cx * _MGL / _ZS; break;
			case GK.WEST: i = cy * _MGL / _ZS; break;
			case GK.SOUTH:  i = _MGL - 1 - (cx * _MGL / _ZS); break;
		}
		
		// insert portal into gateway
		let g = getZone(x, y).getGateway(face);
		
		g.portals[i] = lineIndex;
		++dungeon.portalCounter;
		return g;
	}
	
	
}