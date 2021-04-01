note
	description: "class representing an blackhold in the galaxy"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	BLACKHOLE
inherit
	STATIONARY

create {GALAXY, SECTOR}
	make

feature	{GALAXY, SECTOR}-- Constructor
	make(arow:INTEGER;acolumn:INTEGER;aid:INTEGER)
		do
			row := arow
			column := acolumn
			id := aid
			create alphabet.make('O')
		end
invariant
	correct_location: row = 3 and column = 3
	correct_id: id = -1
end

