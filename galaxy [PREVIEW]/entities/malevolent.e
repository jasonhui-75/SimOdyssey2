note
	description: "class representing a malevolent in the galaxy"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MALEVOLENT
inherit
	MOVABLE

create {GALAXY, SECTOR}
	make

feature{GALAXY, SECTOR}		--Constructor
	make(arow:INTEGER;acolumn:INTEGER;aid:INTEGER;aturn:INTEGER)
		do
			row := arow
			column := acolumn
			create alphabet.make('M')
			create death_message.make_empty
			id := aid
			turn := aturn
			fuel := 3
			reproduction_interval := 1
		end

feature	-- Command
	decrease_r_i
		do
			reproduction_interval := reproduction_interval - 1
		end

	increase_fuel(i:INTEGER)
		do
			if(fuel + i < 3) then
				fuel := fuel + i
			else
				fuel := 3
			end
		end
	decrease_fuel
		do
			fuel:= fuel - 1
		end
	decrease_turn
		do
			turn := turn - 1
		end
	randomize_turn (i:INTEGER)
		do
			turn := i
		end
	reset_reproduction_interval
	do
		reproduction_interval := 1
	end
feature	-- Attribute
	fuel: INTEGER
	reproduction_interval: INTEGER

invariant
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	correct_id: id > 0
	turn_limit: turn >= 0 and turn <= 2
	fuel_limit: fuel >= 0 and fuel <= 3
end
