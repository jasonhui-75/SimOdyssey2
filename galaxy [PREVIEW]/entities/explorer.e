note
	description: "class representing an explorer giant in the galaxy"
	author: "Jason Hui"
	date: "$Date$"
	revision: "$Revision$"

class
	EXPLORER

inherit
	MOVABLE
--		redefine
--			out
--		end

create
		make

feature	--Constructor
	make(arow:INTEGER;acolumn:INTEGER;aid:INTEGER)
	do
		id := aid
		fuel := 3
		life := 3
		create death_message.make_empty
		create alphabet.make('E')
		row := arow
		column := acolumn
		landed := False
		die_from := -1	--0 = fuel, 1 = bh, 2= ast, 3 = mal
	end
feature	-- command
	decrease_fuel
		do
			fuel := fuel - 1
		end
	increase_fuel(i:INTEGER)
		do
			if(fuel + i < 3) then
				fuel := fuel + i
			else
				fuel := 3
			end
		end
	land
		do
			landed := True
		end
	liftoff
		do
			landed := False
		end

	die(i:INTEGER)
		do
			die_from :=i
			life := 0
		end
	decrease_life
		do
			life:= life - 1
		end

feature	--Attribute
fuel,life, die_from:INTEGER
landed:BOOLEAN



invariant
	life_limit: life >= 0 and life <= 3
	fuel_limit: fuel >= 0 and fuel <= 3
	in_the_board: row >= 1 and row <= 5 and column >= 1 and column <= 5
	correct_id: id = 0
end
