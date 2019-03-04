version "3.8"

#include "gk.zs"
#include "game.zs"	// game singleton
#include "dungeon.zs" // holds template and playfield
#include "template.zs" // grid of zones as appearing on map
#include "playfield.zs" // grid of zones as placed in dungeon
#include "zone.zs"	// square area with a gateway on each face
#include "gateway.zs" // group of portals on each face of a zone
#include "levelinit.zs" // for manipulating level data early
#include "events.zs" // in-game stuff


