// The Game singleton holds a list of Dungeons.
class GK_Game : Thinker
{
	GK_Dungeon dungeons[GK.MAX_LEVELS];

	static GK_Game getInstance() {
		let p = GK_Game(ThinkerIterator.create("GK_Game", STAT_STATIC).next());
		if (p != null) return p;
		p = new();
		p.changeStatNum(STAT_STATIC); // persist between maps
		return p;
	}
	
	GK_Dungeon getDungeon(int index) {
		return dungeons[index];
	}

	GK_Dungeon setDungeon(int index, GK_Dungeon dungeon) {
		return dungeons[index] = dungeon;
	}
	
	GK_Dungeon prepareDungeon(int index, GK_LevelInit lc) {
		let d = getDungeon(index);
		if (d) {
			d.rehydrate(lc);
			return d;
		}
		return setDungeon(index, GK_Dungeon.create(lc));
	}

}
