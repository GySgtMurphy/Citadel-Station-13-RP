// Byond direction defines, because I want to put them somewhere.
// #define NORTH 1
// #define SOUTH 2
// #define EAST 4
// #define WEST 8

///All the cardinal direction bitflags.
#define ALL_CARDINALS (NORTH|SOUTH|EAST|WEST)

/// North direction as a string "[1]"
#define TEXT_NORTH "[NORTH]"
/// South direction as a string "[2]"
#define TEXT_SOUTH "[SOUTH]"
/// East direction as a string "[4]"
#define TEXT_EAST "[EAST]"
/// West direction as a string "[8]"
#define TEXT_WEST "[WEST]"

///Returns true if the dir is diagonal, false otherwise
#define ISDIAGONALDIR(d) (d&(d-1))
///True if the dir is north or south, false therwise
#define NSCOMPONENT(d)   (d&(NORTH|SOUTH))
///True if the dir is east/west, false otherwise
#define EWCOMPONENT(d)   (d&(EAST|WEST))
///Flips the dir for north/south directions
#define NSDIRFLIP(d)     (d^(NORTH|SOUTH))
///Flips the dir for east/west directions
#define EWDIRFLIP(d)     (d^(EAST|WEST))
///Turns the dir by 180 degrees
#define DIRFLIP(d)       turn(d, 180)

// NESW with UP | DOWN combined.
#define NORTHUP (NORTH|UP)
#define EASTUP (EAST|UP)
#define SOUTHUP (SOUTH|UP)
#define WESTUP (WEST|UP)
#define NORTHDOWN (NORTH|DOWN)
#define EASTDOWN (EAST|DOWN)
#define SOUTHDOWN (SOUTH|DOWN)
#define WESTDOWN (WEST|DOWN)

/// Create directional subtypes for a path to simplify mapping.
#define MAPPING_DIRECTIONAL_HELPERS(path, offset) ##path/directional/north {\
	dir = NORTH; \
	pixel_y = offset; \
} \
##path/directional/south {\
	dir = SOUTH; \
	pixel_y = -offset; \
} \
##path/directional/east {\
	dir = EAST; \
	pixel_x = offset; \
} \
##path/directional/west {\
	dir = WEST; \
	pixel_x = -offset; \
}

//* Individual bits for storing common directions. Unlike BYOND bits, this can store northeast apart from north.     *//
//* These should **not** be considered safe for serialization; these can change at any time as they sync to BYOND's. *//

// each dir plus diagonals in its own bit
#define NORTH_BIT		NORTH
#define SOUTH_BIT		SOUTH
#define EAST_BIT		EAST
#define WEST_BIT		WEST
/// Not included in cardinal/diagonal direction bits.
#define UP_BIT          UP
/// Not included in cardinal/diagonal direction bits.
#define DOWN_BIT        DOWN
#define NORTHEAST_BIT	(1<<6)
#define NORTHWEST_BIT	(1<<7)
#define SOUTHEAST_BIT	(1<<8)
#define SOUTHWEST_BIT	(1<<9)
/// Not included in cardinal/diagonal direction bits.
#define ONTOP_BIT       (1<<10)
#define CARDINAL_DIAGONAL_DIRECTION_BITS	(NORTH_BIT | SOUTH_BIT | NORTHEAST_BIT | NORTHWEST_BIT | SOUTHEAST_BIT | SOUTHWEST_BIT | WEST_BIT | EAST_BIT)
#define CARDINAL_DIRECTION_BITS	(NORTH_BIT | SOUTH_BIT | EAST_BIT | WEST_BIT)
#define DIAGONAL_DIRECTION_BITS	(NORTHEAST_BIT | NORTHWEST_BIT | SOUTHEAST_BIT | SOUTHWEST_BIT)

#define CONICAL_NORTH_BITS		(NORTH_BIT	|	NORTHEAST_BIT	|	NORTHWEST_BIT	)
#define CONICAL_SOUTH_BITS		(SOUTH_BIT	|	SOUTHEAST_BIT	|	SOUTHWEST_BIT	)
#define CONICAL_EAST_BITS		(EAST_BIT	|	NORTHEAST_BIT	|	SOUTHEAST_BIT	)
#define CONICAL_WEST_BITS		(WEST_BIT	|	NORTHWEST_BIT	|	SOUTHWEST_BIT	)
#define CONICAL_NORTHEAST_BITS	(NORTH_BIT	|	NORTHEAST_BIT	|	EAST_BIT		)
#define CONICAL_NORTHWEST_BITS	(NORTH_BIT	|	WEST_BIT		|	NORTHWEST_BIT	)
#define CONICAL_SOUTHWEST_BITS	(SOUTH_BIT	|	SOUTHWEST_BIT	|	WEST_BIT		)
#define CONICAL_SOUTHEAST_BITS	(SOUTH_BIT	|	SOUTHEAST_BIT	|	EAST_BIT		)
