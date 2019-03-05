// constants and static stuff
class GK play
{
	// portal type 2 = normal, 3 = static
	const PORTAL_TYPE = 3;

	// Directional
	enum Direction4 { EAST, NORTH, WEST, SOUTH };
	
	// TODO: parameterize some of these
	const MAX_LEVELS = 100;
	const PLAYFIELD_SIZE = 128; // playfield zone grid rows/cols
	const TEMPLATE_SIZE = 8; // template zone grid rows/cols
	const ZONE_SIZE = 4096; // width and height of each zone
	const MAX_GATEWAY_LINES = 15; // must be odd
	const FIRST_LINE_ID = 11000; // reserves line ids beginning with this number

	// get custom udmf fields
	static int getLineStyle(int lineIndex) {
		return level.GetUDMFInt(LevelLocals.UDMF_Line, lineIndex, "user_style");
	}

	// get the Game singleton
	play static GK_Game getGame() {
		return GK_Game.getInstance();
	}

}
