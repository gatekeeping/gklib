// a grid of zones
class GK_Grid play
{
	int width;
	int height;
	array<GK_Zone> cells;
	
	static GK_Grid create(int width, int height = -1) {
		let p = new();
		
		if (height < 0) height = width;
		
		p.width = width;
		p.height = height;
		p.cells.resize(width * height);
		
		return p;
	}
	
	int getIndex(int x, int y) {
		return x + width * y;
	}
	
	GK_Zone get(int x, int y) {
		return cells[getIndex(x, y)];
	}
	
	GK_Zone set(int x, int y, GK_Zone zone) {
		return cells[getIndex(x, y)] = zone;
	}
	
}
