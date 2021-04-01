note
	description: "class representing a blue giant in the galaxy"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLUE_GIANT

inherit
	STAR

create
	make

feature	-- Constructor
	make(arow:INTEGER;acolumn:INTEGER;sid:INTEGER)
		do
			row := arow
			column := acolumn
			id := sid
			create alphabet.make('*')
			luminosity := 5
		end
invariant
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	correct_id: id < -1
	correct_luminosity: luminosity = 5

end

