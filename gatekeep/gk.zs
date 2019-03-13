// constants and static stuff
class GK play
{
	// Directional
	enum Direction4 { EAST, NORTH, WEST, SOUTH };

	// get custom udmf fields
	static int getLineStyle(int lineIndex) {
		return level.GetUDMFInt(LevelLocals.UDMF_Line, lineIndex, "user_style");
	}

	// get the Game singleton
	static GK_Game getGame() {
		return GK_Game.getInstance();
	}
}
