class GK_LevelInit : LevelCompatibility
{
	protected void apply(name checksum, string mapName)
	{
		if (mapname ~== "TITLEMAP") return;

		console.printf("GK: Initializing level %i (%s)",
			level.levelnum, mapName);
		
		let config = GK_Config.create("GATEKEEP", mapName);
		
		// build the dungeon
		GK.getGame().prepareDungeon(level.levelnum, self, config);
		
		console.printf("GK: Done initializing level");
	}
	
	void moveVertex(int index, int x, int y) {
		setVertex(index, x, y);
	}
	
	protected void SetWallTexture(int line, int side, int texpart, TextureID texture)
	{
		if (!level.Lines[line].sidedef[side]) return;
		level.Lines[line].sidedef[side].SetTexture(texpart, texture);
	}
	
	void hideLine(int index) {
		setLineFlags(index, Line.ML_DONTDRAW);
	}
	
	void _addLineId(int a, int b) {
		addLineId(a, b);
	}
}
