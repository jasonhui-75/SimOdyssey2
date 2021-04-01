note
	description: "class representing a janitaur in the galaxy"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	JANITAUR
inherit
	MOVABLE

create {GALAXY, SECTOR}
	make

feature{GALAXY, SECTOR}	--Constructor
	make(arow:INTEGER;acolumn:INTEGER;aid:INTEGER;aturn:INTEGER)
		do
			row := arow
			column := acolumn
			create alphabet.make('J')
			create death_message.make_empty
			id := aid
			turn := aturn
			fuel := 5
			reproduction_interval := 2
			load := 0
		end
feature	-- Command
	decrease_r_i
		do
			reproduction_interval := reproduction_interval - 1
		end
	decrease_fuel
		do
			fuel:= fuel - 1
		end
	increase_fuel(i:INTEGER)
		do
			if(fuel + i < 5) then
				fuel := fuel + i
			else
				fuel := 5
			end
		end
	clear_load
		do
			load := 0
		end
	load_increment
		do
			load := load + 1
		end
	decrease_turn
		do
			turn := turn - 1
		end
	reset_reproduction_interval
		do
			reproduction_interval := 2
		end
	randomize_turn(i: INTEGER)
		do
			turn:= i
		end
feature	-- Attribute
	fuel: INTEGER
	reproduction_interval: INTEGER
	load: INTEGER
invariant
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	correct_id: id > 0
	turn_limit: turn >= 0 and turn <= 2
	fuel_limit: fuel >= 0 and fuel <= 5
	load_limit: load >= 0 and load <= 2
end
