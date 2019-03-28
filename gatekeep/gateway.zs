// A Gateway is a set of portal lines on one edge of a Zone.
class GK_Gateway play
{
	GK_Zone zone;
	int templateFace; // direction it's facing in template
	int face; // direction it's facing on playfield
	
	array<int> portals;
	int gatewayLines;
	int portalType;
	
	bool assigned;
	bool placed;
	
	static GK_Gateway create(GK_Zone z, int f) {
		let p = new();
		p.zone = z;
		p.templateFace = f;
		p.gatewayLines = z.dungeon.config.gatewayLines;
		p.portalType = z.dungeon.config.portalType;
		for (let i = 0; i < p.gatewayLines; i++) p.portals.push(-1);
		return p;
	}
	
	int createLineId(int lineIndex) {
		return zone.dungeon.createLineId(lineIndex);
	}
	
	
	// Get another gateway in the same zone, 
	// n*90 degrees conterclockwise from this gateway.

	GK_Gateway getNeighbor(int n) {
		int first = templateFace - (templateFace % 4);
		int offset = (templateFace + n) % 4;
		return zone.templateGates[first + offset];
	}
	
	// link up portals with another gateway
	void assign(GK_Gateway other, bool dryRun = false) {
		if (other == null) return;
				
		let n = gatewayLines - 1;
		for (let i = 0; i <= n; i++) {
			let iA = self.portals[i];
			let iB = other.portals[n - i];
			
			let sA = GK.getLineStyle(iA);
			let sB = GK.getLineStyle(iB);
			
			if (sA == 0 || sB == 0) continue;
			
			if (sA != sB) continue;
			
			// 156:Line_SetPortal (targetline, thisline, type, planeanchor)
			
			if (!dryRun) {
				let idA = createLineId(iA);
				let idB = createLineId(iB);
				level.Lines[iA].special = Line_SetPortal;
				level.Lines[iA].args[0] = idB;
				level.Lines[iA].args[2] = portalType;
				
				level.Lines[iB].special = Line_SetPortal;
				level.Lines[iB].args[0] = idA;
				level.Lines[iB].args[2] = portalType;
			}
	
			assigned = true;
			other.assigned = true;
		}
	}
	
	// check if two gateways can link up
	static bool checkMatch(GK_Gateway a, GK_Gateway b) {
		if (a == null || b == null) return false;
		
		// same zone
		if (a.zone == b.zone) return false;
		
		// match all portal styles
		let n = a.gatewayLines - 1;
		for (let i = 0; i <= n; i++) {
			let iA = a.portals[i];
			let iB = b.portals[n - i];
			let sA = GK.getLineStyle(iA);
			let sB = GK.getLineStyle(iB);
			if (sA != sB) return false;
		}
		
		return true;
	}
	
}
