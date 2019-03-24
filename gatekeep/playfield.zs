// A Playfield stores the position of Zones in the generated dungeon.

class GK_Playfield play
{
	GK_Dungeon dungeon;
	
	GK_Grid grid;
	
	array<GK_Gateway> todo;
	array<GK_Gateway> shuffled;
	
	int gridSize;
	int templateSize;
	bool strictPlacement;
	
	static GK_Playfield create(GK_Dungeon d) {
		let p = new();
		p.dungeon = d;
		p.templateSize = d.config.templateSize;
		p.gridSize = d.config.playfieldSize;
		p.strictPlacement = d.config.strictPlacement;
		p.grid = GK_Grid.create(p.gridSize);
		p.init();
		return p;
	}
	
	// put all gateways in an array and shuffle it
	void shuffle() {
		let t = dungeon.template;
		
		// put all gateways in an array
		for (int x = 0; x < templateSize; x++) {
		for (int y = 0; y < templateSize; y++) {
			let zone = t.grid.get(x, y);
			if (zone == null) continue;
			for (int face = 0; face < 4; face++) {
				let gate = zone.templateGates[face];
				if (gate == null) continue;
				shuffled.push(gate);
			}
		}}
		
		// shuffle it
		let i = shuffled.size() - 1;
		while (--i > 0) {
			let j = random[GK_random](0, i), k = shuffled[i];
			shuffled[i] = shuffled[j];
			shuffled[j] = k;
		}
	}
	
	GK_Gateway pickTodo(void) {
		let last = todo.size() - 1;
		let i = random[GK_random](0, last);
		let result = todo[i];
		todo[i] = todo[last];
		todo.pop();
		return result;
	}
	
	
	bool checkStrictPlacement(int x, int y, int face, GK_Gateway g) {
		if (!strictPlacement) return true;
		
		for (let i = 0; i < 4; i++) {
			let f = (i + face) % 4;
			let neighbor = g.getNeighbor(i);

			let x2 = x, y2 = y;
			
			switch (f) {
				case GK.EAST: x2 = x + 1; break;
				case GK.NORTH: y2 = y - 1; break;
				case GK.WEST: x2 = x - 1; break;
				case GK.SOUTH: y2 = y + 1; break;
			}
			
			let z = grid.get(x2, y2);
			if (!z) continue; // no zone there? this gate's okay.
			
			let g2 = z.gates[(f + 2) % 4];
			
			if (!GK_Gateway.checkMatch(neighbor, g2)) return false;
		}
		
		return true;
	}
	
	// Put a gateway on one face of a cell,
	// and put all other gateways in the zone into the cell

	bool putCell(int x, int y, int face, GK_Gateway g) {
		if (x < 0 || x >= gridSize) return false;
		if (y < 0 || y >= gridSize) return false;
		if (grid.get(x, y) != null) return false;
		if (!checkStrictPlacement(x, y, face, g)) return false;
		
		grid.set(x, y, g.zone);
		
		g.zone.x = x;
		g.zone.y = y; 
		
		g.zone.face = (face + 4 - g.templateFace) % 4;
		
		for (let i = 0; i < 4; i++) {
			let f = (i + face) % 4;
			let neighbor = g.getNeighbor(i);
			if (neighbor == null) continue;
			g.zone.gates[f] = neighbor;
			neighbor.face = f;
			neighbor.placed = true;
			todo.push(neighbor);
		}
		
		g.zone.placed = true;
		++dungeon.placedZoneCounter;
		return true;
	}

	// Call putCell on an adjacent cell in the direction specified by `edge`.
	// The edge refers to the cell at the coordinates given,
	// so the gateway will be on the opposite side of the altered cell.

	bool putAdjacent(int x, int y, int face, GK_Gateway g) {
		switch (face) {
			case GK.EAST: x += 1; break;
			case GK.NORTH: y -= 1; break;
			case GK.WEST: x -= 1; break;
			case GK.SOUTH: y += 1; break;
		}
		return putCell(x, y, (face + 2) % 4, g);
	}

	// Check for any adjacent areas with matching portal lines
	// that aren't linked yet, and link them up.
	void linkMorePortals(void) {
		for (int x = 0; x < gridSize; x++) {
		for (int y = 0; y < gridSize; y++) {
		for (int e = 0; e < 4; e++) {
			int x2 = x, y2 = y;
			switch (e) {
				case GK.EAST: x2 += 1; break;
				case GK.NORTH: y2 -= 1; break;
				case GK.WEST: x2 -= 1; break;
				case GK.SOUTH: y2 += 1; break;
			}
			
			let z = grid.get(x, y);
			if (z == null) continue;
			
			let a = z.gates[e];
			if (a == null) continue;
			if (x2 >= 0 && x2 < gridSize && y2 >=0 && y2 < gridSize) {
				let z2 = grid.get(x2, y2);
				if (z2 == null) continue;
				let b = z2.gates[(e + 2) % 4];
				if (GK_Gateway.checkMatch(a, b))
					a.assign(b);
			}
		}}}
	}
		// POINT MOVING SHIT

	// Rotates a point counterclockwise around origin, 90 deg * rotation.
	Vector2 rotatePoint(Vector2 point, Vector2 origin, int rotation) {
		let v = point - origin;  // translate origin to 0,0
		
		// rotate around origin.
		switch(rotation) {
			case GK.NORTH: v = (-v.y, v.x); break;
			case GK.WEST: v = (-v.x, -v.y); break;
			case GK.SOUTH: v = (v.y, -v.x); break;
		}
		
		return v + origin;   // restore origin
	}
	
	GK_Zone getZone(Vector2 p) {
		if (p.x <= 0 || p.y <= 0) return null;
		let zs = dungeon.config.zoneSize;
		int x = p.x / zs, y = p.y / zs;
		return dungeon.template.grid.get(x, y);
	}
	
	Vector2 rotateInZone(Vector2 p) {
		let zone = getZone(p);
		if (zone == null || zone.face == 0) return p;
		return rotatePoint(p, zone.templateCenter, zone.face);
	}
	
	void rotateVertices() {
		for (int i = 0; i < level.vertexes.size(); i++) {
			let q = rotateInZone(level.vertexes[i].p);
			dungeon.levelInit.moveVertex(i, q.x, q.y);
		}
	}
	
	// rotate floor/ceiling textures along with geometry
	void rotateSectors() {
		for (int i = 0; i < level.sectors.size(); i++) {
			Sector s = level.sectors[i];
			if (s.lines.size() < 1) continue;
			
			let zone = getZone(s.lines[0].v1.p);
			if (zone == null) return;
			
			let a = 360.0 - zone.face * 90.0;
			
			s.setAngle(Sector.floor, a + s.getAngle(Sector.floor, a));
			s.setAngle(Sector.ceiling, a + s.getAngle(Sector.ceiling, a));
		}
	}
	
	private static bool isAssigned(GK_Zone z, int d) {
		let g = z.templateGates[d];
		return g && g.assigned;
	}
	
	// check whether a point is behind a portal / in an unplaced zone.
	bool isBehindPortal(Vector2 p) {
		let zone = getZone(p);
		if (zone == null) return false;
		if (!zone.placed) return true;
		
		let c = zone.templateCenter;
		let s = dungeon.config.zoneSize * 0.25;
		
		if (p.x > c.x + s && isAssigned(zone, GK.EAST)) return true;
		if (p.x < c.x - s && isAssigned(zone, GK.WEST)) return true;
		if (p.y > c.y + s && isAssigned(zone, GK.NORTH)) return true;
		if (p.y < c.y - s && isAssigned(zone, GK.SOUTH)) return true;
		
		return false;
	}
	
	// Prepare actors by rotating them with their zones,
	// and removing them if they're hidden behind portals.
	void prepareActors() {
		let it = ThinkerIterator.create("Actor");
		Actor a;
		
		while (a = Actor(it.next())) {		
			let s = a.spawnPoint;
			// remove actors behind portals
			if (isBehindPortal((s.x, s.y))) {
				a.destroy();
				continue;
			}
			// rotate actors with zone geometry
			let q = rotateInZone((s.x, s.y));
			a.setOrigin((q.x, q.y, s.z), false);
			if (a.bSPAWNCEILING)
				a.setOrigin((q.x, q.y, a.ceilingZ), false);
			// ...and set new angle for actors
			// TODO: skip it for actors with special angle handling (dynlights)
			let zone = getZone((s.x, s.y));
			if (!zone) continue;
			let za = zone.face * 90.0;
			a.angle = (a.angle + za) % 360.0;
		}
	}
	
	// check if a line should be hidden
	// because it's a portal, or behind a portal
	bool shouldHideLine(int i) {
		if (GK.getLineStyle(i)) return true;
		let v1 = level.lines[i].v1, v2 = level.lines[i].v2;
		if (isBehindPortal((v2.p + v1.p) * 0.5)) return true;
		return false;
	}
	
	void hideLines() {
		for (int i = 0; i < level.lines.size(); i++) {
			if (shouldHideLine(i)) dungeon.levelInit.hideLine(i);
		}
	}
	
	// all the LevelCompatibility stuff needed to generate or rehydrate a map
	void finalize() {
		linkMorePortals();
		hideLines();
		// rotateSectors();
		rotateVertices();
	}
	
	// try to place the starting zone.
	bool placeStartingZone() {
		let x = gridSize / 2;
		let y = x;
		let z = dungeon.template.grid.get(0, 0);
		let didWork = false;
		
		if (z == null) {
			console.printf("GK: map error - no starting zone");
			return false;
		}
		
		for (int i = 0; i < 4; i++) {
			let g = z.templateGates[i];
			if (!g) continue;
			putCell(x, y, i, g);
			didWork = true;
		}
		
		if (!didWork) {
			console.printf("GK: map error - no gateways in starting zone");
			return false;
		}
		
		return true;
	}
	 
	void init() {
		// cursor x, y, rotation
		int x, y, r;
		
		shuffle();

		if (!placeStartingZone()) return;
		
		// randomly pick gateways out of the todo list
		// and try to link them to unassigned gateways

		do {
			let i = pickTodo();
			if (i.assigned) continue;
			let shuffledCount = shuffled.size();
			for (int k = 0; k < shuffledCount; k++) {
				let j = shuffled[k];

				if (j.assigned || j.placed) continue;
				if (!GK_Gateway.checkMatch(i, j)) continue;

				x = i.zone.x;
				y = i.zone.y;
				r = i.face;
				if (!putAdjacent(x, y, r, j)) continue;
				i.assign(j);
				break;
			}
		} until (todo.size() < 1);

		finalize();
	}  
	 
}

