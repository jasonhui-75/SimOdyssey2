note
	description: "[
		Common variables such as threshold for planet
		and constants such as number of stationary items for generation of the board.
		]"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SHARED_INFORMATION

create {SHARED_INFORMATION_ACCESS}
	make

feature{NONE}
	make
		do

		end

feature

	number_rows: INTEGER = 5
        	-- The number of rows in the grid

	number_columns: INTEGER = 5
        	-- The number of columns in the  grid

	number_of_stationary_items: INTEGER = 10
			-- The number of stationary_items in the grid

    planet_threshold: INTEGER
		-- used to determine the chance of a planet being put in a location
		attribute
			Result := 50
		end
		-- all threshold determines the chance of a certain enitty spawning at a location
	asteroid_threshold: INTEGER
		attribute
			Result := 3
		end

	janitaur_threshold: INTEGER
		attribute
			Result := 5
		end

	malevolent_threshold: INTEGER
		attribute
			Result := 7
		end

	benign_threshold: INTEGER
		attribute
			Result := 15
		end

	max_capacity: INTEGER = 4
		 -- max number of objects that can be stored in a location

	next_movable_id:INTEGER
		attribute
			Result := 0
		end
	next_stationary_id:INTEGER
		attribute
			Result := -1
		end

feature --commands
		--set threshold commands for each type entities that are being spawned
	set_planet_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			planet_threshold:=threshold
		end

	set_asteroid_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			asteroid_threshold:=threshold
		end

	set_janitaur_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			janitaur_threshold:=threshold
		end
	set_malevolent_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			malevolent_threshold:=threshold
		end

	set_benign_threshold(threshold:INTEGER)
		require
			valid_threshold:
				0 < threshold and threshold <= 101
		do
			benign_threshold:=threshold
		end
	increment_movable_id
			-- increments movable id after spawning a movable object
		do
			next_movable_id := next_movable_id + 1
		end

	decrement_stationary_id
			-- decrements the setationary id after spaning a stationary object
		do
			next_stationary_id := next_stationary_id - 1
		end
	reset_ids
			-- used to reset ids when a new game start. 
		do
			next_stationary_id := -1
			next_movable_id := 0
		end

end
