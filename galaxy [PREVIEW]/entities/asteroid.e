note
	description: "class representing an asteroid in the galaxy"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ASTEROID
inherit
	MOVABLE

create{GALAXY, SECTOR}
	make

feature{GALAXY, SECTOR}		--Constructor
	make(arow:INTEGER;acolumn:INTEGER;aid:INTEGER;aturn:INTEGER)
		do
			row := arow
			column := acolumn
			create alphabet.make('A')
			create death_message.make_empty
			id := aid
			turn := aturn
		end

feature	-- commands
	set_turn(i: INTEGER)
		do
			turn := i
		end
	decrease_turn
		do
			turn := turn - 1
		end
invariant
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	turn_limit: turn >= 0 and turn <= 2
	correct_id: id > 0
end
