note
	description: "Represents a sector in the galaxy."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	SECTOR

create
	make, make_dummy

feature -- attributes
	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

	gen: RANDOM_GENERATOR_ACCESS

--	contents: ARRAYED_LIST [ENTITY_ALPHABET] --holds 4 quadrants

	quadrants: ARRAYED_LIST[ ENTITY]

	row: INTEGER

	column: INTEGER


feature -- constructor
	make(row_input: INTEGER; column_input: INTEGER; a_explorer:ENTITY_ALPHABET)
		--initialization

		require
			valid_row: (row_input >= 1) and (row_input <= shared_info.number_rows)
			valid_column: (column_input >= 1) and (column_input <= shared_info.number_columns)

		local
				temp:INTEGER
		do
			row := row_input
			column := column_input

			create quadrants.make(shared_info.max_capacity)
			quadrants.compare_objects

			if (row = 3) and (column = 3) then
--				put (create {ENTITY_ALPHABET}.make ('O')) -- If this is the sector in the middle of the board, place a black hole
				temp :=	put_quadrant(create {BLACKHOLE}.make(row, column, shared_info.next_stationary_id))
				shared_info.decrement_stationary_id
			else
				if (row = 1) and (column = 1) then
--					put (a_explorer) -- If this is the top left corner sector, place the explorer there
				temp :=	put_quadrant(create {EXPLORER}.make(row, column, shared_info.next_movable_id))
					shared_info.increment_movable_id
				end
				populate -- Run the populate command to complete setup
			end -- if
		end

feature -- commands
	make_dummy
		--initialization without creating entities in quadrants
		do
--			create contents.make (shared_info.max_capacity)
--			contents.compare_objects
			create quadrants.make (shared_info.max_capacity)
			quadrants.compare_objects
		end

	populate
			-- this feature creates 1 to max_capacity-1 components to be intially stored in the
			-- sector. The component may be a planet or nothing at all.
		local
			threshold: INTEGER
			number_items: INTEGER
			loop_counter: INTEGER
			turn :INTEGER
			temp:INTEGER
		do
			number_items := gen.rchoose (1, shared_info.max_capacity-1)  -- MUST decrease max_capacity by 1 to leave space for Explorer (so a max of 3)
			from
				loop_counter := 1
			until
				loop_counter > number_items
			loop
				threshold := gen.rchoose (1, 100) -- each iteration, generate a new value to compare against the threshold values provided by `test` or `play`

				if threshold < shared_info.asteroid_threshold then
					turn:= gen.rchoose (0, 2)
					temp := put_quadrant(create {ASTEROID}.make(row, column, shared_info.next_movable_id, turn))
					shared_info.increment_movable_id
				elseif threshold < shared_info.janitaur_threshold then
					turn:=gen.rchoose (0, 2)
					temp := put_quadrant(create {JANITAUR}.make(row, column, shared_info.next_movable_id, turn))
					shared_info.increment_movable_id
				elseif threshold < shared_info.malevolent_threshold then
					turn:=gen.rchoose (0, 2)
					temp := put_quadrant(create {MALEVOLENT}.make(row, column, shared_info.next_movable_id, turn))
					shared_info.increment_movable_id
				elseif threshold < shared_info.benign_threshold then
					turn:=gen.rchoose (0, 2)
					temp := put_quadrant(create {BENIGN}.make(row, column, shared_info.next_movable_id, turn))
					shared_info.increment_movable_id
				elseif threshold < shared_info.planet_threshold then
					turn:=gen.rchoose (0, 2)
					temp := put_quadrant(create {PLANET}.make(row, column, shared_info.next_movable_id, turn))
					shared_info.increment_movable_id
				end


--				if attached component as entity then
--					put (entity) -- add new entity to the contents list
--					--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--					turn:=gen.rchoose (0, 2) -- Hint: Use this number for assigning turn values to the planet created
--					-- The turn value of the planet created (except explorer) suggests the number of turns left before it can move.
--					--@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
--					temp := put_quadrant(create {PLANET}.make(row, column, shared_info.next_movable_id, turn))
--					shared_info.increment_movable_id
--					component := void -- reset component object
--				end

				loop_counter := loop_counter + 1
			end
		end

feature {GALAXY} --auxiliary opeartion

--	put (new_component: ENTITY_ALPHABET)
--			 put `new_component' in contents array
--		local
--			loop_counter: INTEGER
--			found: BOOLEAN
--		do
--			from
--				loop_counter := 1
--			until
--				loop_counter > quadrants.count or found
--			loop
--				if quadrants [loop_counter].alphabet = new_component then
--					found := TRUE
--				end --if
--				loop_counter := loop_counter + 1
--			end -- loop

--			if not found and not is_full then
--				quadrants.extend (new_component)
--			end

--		ensure
--			component_put: not is_full implies quadrants.has (new_component)
--		end

	put_quadrant(entity: ENTITY):INTEGER
			-- put entity into the quadrant
		local
				loop_counter: INTEGER
				found, dummy: BOOLEAN
			do
				dummy := False
				from
					loop_counter := quadrants.lower
				until
					loop_counter > quadrants.count or found or dummy
				loop
					if  quadrants[loop_counter] = entity then
						found := TRUE
						Result := -1
					end --if
					if is_dummy(quadrants[loop_counter])then
						dummy := True
						Result := loop_counter
						quadrants[loop_counter] := entity
					end
					loop_counter := loop_counter + 1
				end -- loop

				if not found and not quadrants_full and not dummy then
					quadrants.extend(entity)
					Result := quadrants.count
				end


			ensure
				component_put: not quadrants_full implies quadrants.has (entity)
			end

feature -- Queries
	is_dummy(e:ENTITY):BOOLEAN
			-- check if entity e is a dummy
		do
			Result := e.alphabet.is_equal (create {ENTITY_ALPHABET}.make ('-'))
		end

	print_sector: STRING
			-- Printable version of location's coordinates with different formatting
		do
			Result := "["
			Result.append (row.out)
			Result.append (",")
			Result.append (column.out)
			Result.append ("]")
		end
	prints: STRING
		do
			Result := ""
			Result.append (row.out)
			Result.append (":")
			Result.append (column.out)
		end

	is_full: BOOLEAN
			-- Is the location currently full?
		local
			loop_counter: INTEGER
			occupant: ENTITY_ALPHABET
			empty_space_found: BOOLEAN
		do
			if quadrants.count < shared_info.max_capacity then
				empty_space_found := TRUE
			end
			from
				loop_counter := 1
			until
				loop_counter > quadrants.count or empty_space_found
			loop
				occupant := quadrants [loop_counter].alphabet
				if not attached occupant  then
					empty_space_found := TRUE
				end
				loop_counter := loop_counter + 1
			end

			if quadrants.count = shared_info.max_capacity and then not empty_space_found then
				Result := TRUE
			else
				Result := FALSE
			end
		end
		-- all features that start with has_ ... returns true if the quadrant has has a certain type of entity
	has_star:BOOLEAN
		do
			Result := False
			across quadrants is e
			loop
				if(e.alphabet.is_equal(create {ENTITY_ALPHABET}.make ('Y')) or
					e.alphabet.is_equal (create {ENTITY_ALPHABET}.make ('*'))) then
					Result := True
				end
			end
		end
	has_wormhole:BOOLEAN
		do
			Result:= false
			across quadrants is e
			loop
				if e.alphabet.is_equal(create {ENTITY_ALPHABET}.make ('W')) then
					Result := True
				end
			end
		end

	has_explorer:BOOLEAN
		do
			Result:= false
			across quadrants is e
			loop
				if e.alphabet.is_equal(create {ENTITY_ALPHABET}.make ('E')) then
					Result := True
				end
			end
		end

	has_yellow_dwarf:BOOLEAN
		do
			Result:= false
			across quadrants is e
			loop
				if e.alphabet.is_equal(create {ENTITY_ALPHABET}.make ('Y')) then
					Result := True
				end
			end
		end


	quadrants_full:BOOLEAN
		--true if full
		local
			loop_counter: INTEGER
			occupant: ENTITY
			empty_space_found: BOOLEAN
			dummy:BOOLEAN
		do
			dummy := False
			if quadrants.count < shared_info.max_capacity then
				empty_space_found := TRUE
			end
			from
				loop_counter := 1
			until
				loop_counter > quadrants.count or empty_space_found
			loop
				occupant := quadrants[loop_counter]
				if not attached occupant  then
					empty_space_found := TRUE
				end
				if is_dummy(occupant) then
					dummy := True
				end
				loop_counter := loop_counter + 1
			end

			if quadrants.count = shared_info.max_capacity and  (not empty_space_found and not dummy) then
				Result := TRUE
			else
				Result := FALSE
			end
		end
	has_stationary: BOOLEAN
			-- returns whether the location contains any stationary item
		local
			loop_counter: INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > quadrants.count or Result
			loop
				if attached quadrants [loop_counter] as temp_item  then
					Result := temp_item.alphabet.is_stationary
				end -- if
				loop_counter := loop_counter + 1
			end
		end

	last_entity_location:INTEGER
		do
			Result := 0
			across quadrants is e
			loop
				if( attached e and e.alphabet.item /~ '-') then
					Result := Result + 1
				end
			end
		end

invariant
	correct_quadrant_size: quadrants.count <= 4

end
