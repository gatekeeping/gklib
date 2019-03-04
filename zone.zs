// A Zone has four Gateways, one facing each cardinal direction.
class GK_Zone play
{
	GK_Dungeon dungeon;
	
	 // location in template
	int templateX;
	int templateY;
	GK_Gateway templateGates[4];
	Vector2 templateCenter;
	
	// location in playfield
	int x;
	int y; 
	GK_Gateway gates[4];
	
	int face;
	
	static GK_Zone create(GK_Dungeon d, int tx, int ty) {
		let p = new();
		p.dungeon = d;
		p.templateX = tx;
		p.templateY = ty;
		int h = GK.ZONE_SIZE / 2;
		p.templateCenter = (tx * GK.ZONE_SIZE + h, ty * GK.ZONE_SIZE + h);
		++d.zoneCounter;
		return p;
	}
	
	GK_Gateway getGateway(int face) {
		let p = templateGates[face];
		if (p != null) return p;
		p = GK_Gateway.create(self, face);
		templateGates[face] = p;
		++dungeon.gatewayCounter;
		return p;
	}
}
