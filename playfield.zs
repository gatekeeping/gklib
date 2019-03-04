// A Playfield stores the position of Zones in the generated dungeon.
class GK_Playfield play
{
	GK_Dungeon dungeon;

	GK_Zone grid[GK.PLAYFIELD_SIZE][GK.PLAYFIELD_SIZE];
	
	GK_Gateway todo[GK.MAX_GATEWAYS];
	int todoCount;
	
	GK_Gateway shuffled[GK.MAX_GATEWAYS];
	int shuffledCount;
	
	static GK_Playfield create(GK_Dungeon d) {
		let p = new();
		p.dungeon = d;
		p.init();
		return p;
	}
	
	// put all gateways in an array and shuffle it
	void shuffle() {
		let t = dungeon.template;
		shuffledCount = 0;
		
		// put all gateways in an array
		for (int x = 0; x < GK.TEMPLATE_SIZE; x++) {
		for (int y = 0; y < GK.TEMPLATE_SIZE; y++) {
			let zone = t.grid[x][y];
			if (zone == null) continue;
			for (int face = 0; face < 4; face++) {
				let gate = zone.templateGates[face];
				if (gate == null) continue;
				shuffled[shuffledCount++] = gate;
			}
		}}
		
		// shuffle it
		let i = shuffledCount - 1;
		while (--i > 0) {
			let j = random[GK_random](0, i), k = shuffled[i];
			shuffled[i] = shuffled[j];
			shuffled[j] = k;
		}
	}
	
	GK_Gateway pickTodo(void) {
		let last = todoCount - 1;
		let i = random[GK_random](0, last);
		let result = todo[i];
		todo[i] = todo[last];
		todo[last] = null;
		--todoCount;
		return result;
	}
	
	// Put a gateway on one face of a cell,
	// and put all other gateways in the zone into the cell

	bool putCell(int x, int y, int face, GK_Gateway g) {
		if (x < 0 || x >= GK.PLAYFIELD_SIZE) return false;
		if (y < 0 || y >= GK.PLAYFIELD_SIZE) return false;
		if (grid[x][y] != null) return false;
		
		// FIXME // if (!checkAdjacent(x, y, edge, line)) return false;
		
		grid[x][y] = g.zone;
		
		g.zone.x = x;
		g.zone.y = y; 
		
		g.zone.face = (face + 4 - g.templateFace) % 4;
		
		// console.printf("f %i, t %i, g.zone.face %i", face, g.templateFace, g.zone.face);
		
		for (let i = 0; i < 4; i++) {
			let f = (i + face) % 4;
			let neighbor = g.getNeighbor(i);
			if (neighbor == null) continue;
			g.zone.gates[f] = neighbor;
			neighbor.face = f;
			neighbor.placed = true;
			todo[todoCount++] = neighbor;
		}
		
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
		for (int x = 0; x < GK.PLAYFIELD_SIZE; x++) {
		for (int y = 0; y < GK.PLAYFIELD_SIZE; y++) {
		for (int e = 0; e < 4; e++) {
			int x2 = x, y2 = y;
			switch (e) {
				case GK.EAST: x2 += 1; break;
				case GK.NORTH: y2 -= 1; break;
				case GK.WEST: x2 -= 1; break;
				case GK.SOUTH: y2 += 1; break;
			}
			if (grid[x][y] == null) continue;
			let a = grid[x][y].gates[e];
			if (a == null) continue;
			if (x2 >= 0 && x2 < GK.PLAYFIELD_SIZE &&
				y2 >=0 && y2 < GK.PLAYFIELD_SIZE) {
				if (grid[x2][y2] == null) continue;
				let b = grid[x2][y2].gates[(e + 2) % 4];
				if (GK_Gateway.checkMatch(a, b))
					a.assign(b);
			}
		}}}
	}
		// POINT MOVING SHIT

	// Rotates a point counterclockwise around origin, 90 deg * rotation.
	Vector2 rotatePoint(Vector2 point, Vector2 origin, int rotation) {
		let v = point - origin;  // translate origin to 0,0
		
		// TODO: Are these correct?
		
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
		int gx = p.x / GK.ZONE_SIZE, gy = p.y / GK.ZONE_SIZE;
		return dungeon.template.grid[gx][gy];
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
	
	private static bool isAssigned(GK_Zone z, int d) {
		let g = z.templateGates[d];
		return g && g.assigned;
	}
	
	bool isBehindPortal(Vector2 p) {
		let zone = getZone(p);
		if (zone == null) return false;
		let c = zone.templateCenter;
		let s = GK.ZONE_SIZE * 0.25;
		
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
			if (isBehindPortal((s.x, s.y))) {
				a.destroy();
				continue;
			}
			let q = rotateInZone((s.x, s.y));
			a.setOrigin((q.x, q.y, s.z), false);
		}
	}
	
	
	void hideLines() {
		for (int i = 0; i < level.lines.size(); i++) {
			if (isBehindPortal((level.lines[i].v2.p + level.lines[i].v1.p) * 0.5)) {
				dungeon.levelInit.hideLine(i);
			}
		}
	}
	
	// all the LevelCompatibility stuff needed to generate or rehydrate a map
	void finalize() {
		linkMorePortals();
		hideLines();
		rotateVertices();
	}
	
	// try to place the starting zone.
	bool placeStartingZone() {
		let x = GK.PLAYFIELD_SIZE / 2, y = GK.PLAYFIELD_SIZE / 2;
		let z = dungeon.template.grid[0][0];
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
		} until (todoCount < 1);

		finalize();
		
	}  
	 
}

