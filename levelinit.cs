class GK_LevelInit : LevelCompatibility
{
	protected void apply(name checksum, string mapname)
	{
		if (mapname ~== "TITLEMAP") return;

		console.printf("GK: Initializing level %i (%s)",
			level.levelnum, mapname);
		
		let conf = GK_Config.create("GATEKEEP");
		
		// build the dungeon
		GK.getGame().prepareDungeon(level.levelnum, self);
		
		console.printf("GK: Done initializing level");
	}
	
	void moveVertex(int index, int x, int y) {
		setVertex(index, x, y);
	}
	
	void hideLine(int index) {
		setLineFlags(index, Line.ML_DONTDRAW);
	}
	
	void _addLineId(int a, int b) {
		addLineId(a, b);
	}
}
