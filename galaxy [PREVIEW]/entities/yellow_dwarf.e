note
	description: "class representing a yellow dwarf in the galaxy"
	author: "Jason Hui"
	date: "$Date$"
	revision: "$Revision$"

class
	YELLOW_DWARF

inherit
	STAR

create{GALAXY, SECTOR}
	make

feature{GALAXY, SECTOR}	-- Constructor
	make(arow:INTEGER;acolumn:INTEGER;sid:INTEGER)
		do
			row := arow
			column := acolumn
			id := sid
			create alphabet.make('Y')
			luminosity := 2
		end
invariant
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	correct_id: id < -1
	correct_luminosity: luminosity = 2

end
