version "3.8"

#include "gatekeep/gk.zs"
#include "gatekeep/config.zs" // config loader
#include "gatekeep/game.zs" // game singleton
#include "gatekeep/grid.zs" // a grid of zones
#include "gatekeep/dungeon.zs" // holds template and playfield
#include "gatekeep/template.zs" // grid of zones as appearing on map
#include "gatekeep/playfield.zs" // grid of zones as placed in dungeon
#include "gatekeep/zone.zs" // square area with a gateway on each face
#include "gatekeep/gateway.zs" // group of portals on each face of a zone
#include "gatekeep/levelinit.zs" // for manipulating level data early
#include "gatekeep/events.zs" // in-game stuff
