class GK_Events : EventHandler
{
	// override void worldThingSpawned(WorldEvent e) {}
	// override void playerEntered(PlayerEvent e) {}
	
	// move the things here for now.
	// should move to levelinit if possible in future.
	override void worldLoaded(WorldEvent e) {
		let d = GK.getGame().getDungeon(level.levelnum);
		if (d == null) return;
		if (d.isInvalid) {
			console.midPrint(bigfont,
				"MAP ERROR: DUNGEON GENERATION FAILED!", true);
			return;
		}
		if (d.isReady) return;
		d.playfield.prepareActors();
		d.playfield.rotateSectors();
		d.isReady = true;
	}
}
