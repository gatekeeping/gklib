
# Gatekeeper Library

Composition Overview

	Game
		Dungeon
			Template
				Zone
					Gateway
			Playfield
				Zone
					Gateway

The Game singleton holds a list of Dungeons.
A Dungeon has a Template and a Playfield, each containing a grid of Zones.
A Template stores the position of Zones as they appear on the level map.
A Playfield stores the position of Zones in the generated dungeon.
A Zone has four Gateways, one facing each cardinal direction.
A Gateway is a set of portal lines on one edge of a Zone.
