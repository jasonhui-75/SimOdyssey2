note
	description: "class representing a wormhole in the galaxy"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WORMHOLE

inherit
	STATIONARY

create
	make

feature	-- Constructor
	make(arow:INTEGER;acolumn:INTEGER;sid:INTEGER)
		do
			row := arow
			column := acolumn
			id := sid
			create alphabet.make('W')
		end
invariant
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	correct_id: id < -1

end

