note
	description: "class representing a planet in the galaxy"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PLANET
inherit
	MOVABLE

create{GALAXY, SECTOR}
	make

feature{GALAXY, SECTOR}		--Constructor
	make(arow:INTEGER;acolumn:INTEGER;aid:INTEGER;aturn:INTEGER)
		do
			row := arow
			column := acolumn
			create alphabet.make('P')
			create death_message.make_empty
			id := aid
			turn := aturn
			support_life := False
			visited := False
			generated := False
		end

feature	--attribute
	support_life:BOOLEAN
	attach :BOOLEAN
	visited:BOOLEAN
	generated:BOOLEAN

feature	--command
	supports_life
		do
			support_life := True
		end
	decrease_turn
		do
			turn := turn - 1
		end
	randomize_turn (i:INTEGER)
		do
			turn := i
		end
	set_attach
		do
			attach := True
		end
	generate
		do
			generated := True
		end
	visit
		do
			visited := True
		end

invariant
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	correct_id: id > 0
	turn_limit: turn >= 0 and turn <= 2
end
