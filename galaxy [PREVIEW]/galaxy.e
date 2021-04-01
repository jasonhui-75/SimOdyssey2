note
	description: "Galaxy represents a game board in simodyssey."
	author: "JH"
	date: "$Date$"
	revision: "$Revision$"

class
	GALAXY

inherit ANY
	redefine
		out
	end

create {GALAXY_MODEL}
	make

feature -- attributes

	grid: ARRAY2 [SECTOR]
			-- the board

	gen: RANDOM_GENERATOR_ACCESS



	shared_info_access : SHARED_INFORMATION_ACCESS

	shared_info: SHARED_INFORMATION
		attribute
			Result:= shared_info_access.shared_info
		end

	movable: ARRAY[ENTITY]	--for movement
	entities:ARRAYED_LIST[ENTITY]	-- for description


	ilist:INFO_LIST
		attribute
			Result := i_l_access.list
		end


	cur_row, cur_col: INTEGER	-- new location of player
feature {NONE}	-- auxiliary attribute
	aentities:ARRAY[ENTITY]	-- used for sorting
	old_row, old_col:INTEGER	-- old location of playr
	i_l_access:I_L_ACCESS

feature {GALAXY_MODEL} --constructor

	make
		-- creates a dummy of galaxy grid
		local
			row : INTEGER
			column : INTEGER
			comparator: ENTITY_COMPARATOR
			sorter: DS_ARRAY_QUICK_SORTER[ENTITY]
		do
			cur_row := 1
			cur_col := 1
			shared_info.reset_ids
			ilist.clear
			ilist.clear_d
			create grid.make_filled (create {SECTOR}.make_dummy, shared_info.number_rows, shared_info.number_columns)
			from
				row := 1
			until
				row > shared_info.number_rows
			loop

				from
					column := 1
				until
					column > shared_info.number_columns
				loop
					grid[row,column] := create {SECTOR}.make(row,column,create{ENTITY_ALPHABET}.make ('E'))
					column:= column + 1;
				end
				row := row + 1
			end
			set_stationary_items
			create movable.make_empty

			create aentities.make_empty
			across grid is sec
			loop
				across sec.quadrants is e
				loop
					if attached {MOVABLE} e as am then
						movable.force (e, movable.count + 1)
					end
					aentities.force(e, aentities.count + 1)
				end
			end
			create comparator
			create sorter.make(comparator)
			sorter.sort(movable)
			sorter.sort (aentities)
			create entities.make_from_array (aentities)

	end

feature{NONE} --auxiliary featuers for board generation
	set_stationary_items
			-- distribute stationary items amongst the sectors in the grid.
			-- There can be only one stationary item in a sector
		local
			loop_counter: INTEGER
			check_sector: SECTOR
			temp_row: INTEGER
			temp_column: INTEGER
			ea:ENTITY_ALPHABET
			temp:INTEGER
		do
			from
				loop_counter := 1
			until
				loop_counter > shared_info.number_of_stationary_items
			loop

				temp_row :=  gen.rchoose (1, shared_info.number_rows)
				temp_column := gen.rchoose (1, shared_info.number_columns)
				check_sector := grid[temp_row,temp_column]
				if (not check_sector.has_stationary) and (not check_sector.is_full) then
					ea := create_stationary_item
					if(ea.item ~ '*') then
					temp :=	grid[temp_row,temp_column].put_quadrant (create {BLUE_GIANT}.make(temp_row, temp_column, shared_info.next_stationary_id))
						shared_info.decrement_stationary_id
					elseif(ea.item ~ 'Y') then
					temp :=	grid[temp_row,temp_column].put_quadrant (create {YELLOW_DWARF}.make(temp_row, temp_column, shared_info.next_stationary_id))
						shared_info.decrement_stationary_id
					elseif(ea.item ~ 'W') then
					temp :=	grid[temp_row,temp_column].put_quadrant (create {WORMHOLE}.make(temp_row, temp_column, shared_info.next_stationary_id))
						shared_info.decrement_stationary_id
					end
					loop_counter := loop_counter + 1
				end -- if
			end -- loop
		end -- feature set_stationary_items

	create_stationary_item: ENTITY_ALPHABET
			-- this feature randomly creates one of the possible types of stationary actors
		local
			chance: INTEGER
		do
			chance := gen.rchoose (1, 3)
			inspect chance
			when 1 then
				create Result.make('Y')
			when 2 then
				create Result.make('*')
			when 3 then
				create Result.make('W')
			else
				create Result.make('Y') -- create more yellow dwarfs this will never happen, but create by default
			end -- inspect
		end

feature	--commnds
	move_explorer(dir:INTEGER)
			-- moves the exploerer toward direaction dir
		require
			not_landed:
				not check_landed
			not_full:
				not check_sector_full(dir)
		local
			row: INTEGER
			col: INTEGER
			nrow, ncol: INTEGER
			ni:INTEGER
			oi:INTEGER
			explorer: ENTITY
		do
			across grid[cur_row, cur_col].quadrants.lower |..| grid[cur_row, cur_col].quadrants.upper is i
			loop
				if(grid[cur_row, cur_col].quadrants[i].alphabet.item ~ 'E') then
					row := cur_row
					col := cur_col
					explorer := grid[cur_row, cur_col].quadrants[i]
					oi := i
				end
			end
			if dir = 1 then	--N
				if(row = 1) then
					nrow := shared_info.number_rows
				else
					nrow := row - 1
				end
				ncol := col
			elseif dir = 2 then	--NE
				if(row = 1) then
					nrow := shared_info.number_rows
				else
					nrow := row - 1
				end
				if(col = shared_info.number_columns) then
					ncol := 1
				else
					ncol := col + 1
				end
			elseif dir = 3 then	--E
				if(col = shared_info.number_columns) then
					ncol := 1
				else
					ncol := col + 1
				end
					nrow := row
			elseif dir = 4 then	--SE
				if(row = shared_info.number_rows) then
					nrow := 1
				else
					nrow := row + 1
				end
				if(col = shared_info.number_columns) then
					ncol := 1
				else
					ncol := col + 1
				end
			elseif dir = 5 then	--S
				if(row = shared_info.number_rows) then
					nrow := 1
				else
					nrow := row + 1
				end
				ncol := col
			elseif dir = 6 then	--SW
				if(row = shared_info.number_rows) then
					nrow := 1
				else
					nrow := row + 1
				end
				if(col = 1) then
					ncol := shared_info.number_columns
				else
					ncol := col -1
				end
			elseif dir = 7 then	--W
				if(col = 1) then
					ncol := shared_info.number_columns
				else
					ncol := col - 1
				end
				nrow := row
			elseif dir = 8 then	--NW
				if(row = 1) then
					nrow := shared_info.number_rows
				else
					nrow := row -1
				end
				if(col = 1) then
					ncol := shared_info.number_columns
				else
					ncol := col -1
				end
			end
			if attached {EXPLORER} explorer as ae and not grid[nrow,ncol].quadrants_full then
				ni :=	grid[nrow, ncol].put_quadrant (ae)
				put_dummy(row,col,oi)
				ae.update (nrow, ncol)
				old_row := row
				old_col := col
				cur_row := nrow
				cur_col := ncol
				ilist.add (ae.out+":["+old_row.out+","+old_col.out+","+oi.out+"]->["+cur_row.out+","+cur_col.out+","+ni.out+"]")
			end
		ensure
			moved: cur_row /= old_row or cur_col /= old_col
		end

	wormhole(ent: ENTITY)
			-- Entity ent will use wormhole to teleport to a location
		require
			has_wormhole:
				sector_has_wormhole (ent.row, ent.column)
			explorer_not_landed:
				not is_explorer(ent) or not check_landed

		local
			orow, ocol,index:INTEGER
			temp_row:INTEGER
			temp_col:INTEGER
			ni:INTEGER
			entity: ENTITY
		do
			if grid[ent.row,ent.column].has_wormhole then
				across grid[ent.row,ent.column].quadrants.lower |..| grid[ent.row,ent.column].quadrants.upper is i
				loop
					if(grid[ent.row,ent.column].quadrants[i].alphabet.item ~ ent.alphabet.item and
						grid[ent.row,ent.column].quadrants[i].id = ent.id ) then
						entity := grid[ent.row,ent.column].quadrants[i]
						index := i
						orow := ent.row
						ocol := ent.column
					end
				end
				from
					temp_row := gen.rchoose (1, 5)
					temp_col := gen.rchoose (1, 5)
				until
					not sector_full(temp_row, temp_col)
				loop
					temp_row := gen.rchoose (1, 5)
					temp_col := gen.rchoose (1, 5)
				end
				if temp_row /= orow or temp_col /= ocol or ( temp_row = orow and temp_col = ocol and index > quadrant_next_free_space (orow, ocol))  then
					if attached {MOVABLE} entity as aent  then
						ni :=grid[temp_row,temp_col].put_quadrant (aent)
						put_dummy(ent.row, ent.column, index)
						aent.update (temp_row, temp_col)
						if attached {EXPLORER} entity as ae then
							old_row := cur_row
							old_col := cur_col
							cur_row := temp_row
							cur_col := temp_col
						end
						ilist.add (aent.out+":["+orow.out+","+ocol.out+","+index.out+"]->["+temp_row.out+","+temp_col.out+","+ni.out+"]")
					end
				else
					if attached {MOVABLE} entity as ae then
						ilist.add (ae.out+":["+orow.out+","+ocol.out+","+index.out+"]")
					end
				end
			end
		end

	explorer_land:INTEGER
			-- land exploerer on the unvisited planet with the lowest id
		require
			not_landed:
				not check_landed
			has_yellow_planet:
				sector_has_yellow_dwarf (cur_row, cur_col)
			has_planet:
				sector_has_planet (cur_row, cur_col)
			has_unvisited_planet:
				sector_has_unvisited_planet (cur_row, cur_col)
		local
			index:INTEGER
			found:BOOLEAN
		do

			from
				index := 1
			until
				index > movable.count or found
			loop
				if(attached {PLANET} movable[index] as ap) then
					if (ap.row = cur_row and ap.column = cur_col and not ap.visited) then
						ap.visit
						found := True
						across grid[cur_row, cur_col].quadrants is e
						loop
							if(attached {EXPLORER} e as ae and e.alphabet.item ~ 'E') then
								ae.land
							end
						end
						Result := ap.id
					end
				end
				index := index + 1
			end
		ensure
			landed: check_landed
		end

	explorer_liftoff
			-- liftoff the explorer
		require
			landed:
				check_landed

		do
			across grid[cur_row, cur_col].quadrants is e
			loop
				if(attached {EXPLORER} e as ae and e.alphabet.item ~ 'E') then
					ae.liftoff
				end
			end
		ensure
				liftoff: not check_landed
			end
feature{GALAXY, GALAXY_MODEL}	--auxiliary command

	put_dummy(arow,acol,i:INTEGER)
			-- put a dummy in the grid[arow, acol].quadrants[i]
		require
			correct_location:
				arow >= 1 and arow <= 5 and acol >= 1 and acol <=5 and i >= 1 and i <= 4
		do
			grid[arow,acol].quadrants[i] := create {DUMMY}.make(arow,acol)
		ensure
			dummy_put: attached {DUMMY} grid[arow,acol].quadrants[i]
		end
	move_entity (ent: ENTITY)
			-- moves any movable entitiy other than the explorer
		require
			is_movable:
				attached {MOVABLE} ent
		local
			ro: INTEGER
			co: INTEGER
			nrow, ncol: INTEGER
			entity:ENTITY
			dir:INTEGER
			index, ni:INTEGER
		do
			across grid[ent.row, ent.column].quadrants.lower |..| grid[ent.row, ent.column].quadrants.upper is i
			loop
				if(grid[ent.row, ent.column].quadrants[i].alphabet.item ~ ent.alphabet.item and grid[ent.row, ent.column].quadrants[i].id = ent.id) then
					index := i
				end
			end

			if attached {PLANET} ent as ap or attached {MALEVOLENT} ent as am or attached {BENIGN} ent as ab or
				attached {JANITAUR} ent as aj or attached {ASTEROID} ent as aa then
				entity := ent
				ro := entity.row
				co := entity.column
				dir := gen.rchoose (1, 8)
				if dir = 1 then	--N
					if(ro = 1) then
						nrow := shared_info.number_rows
					else
						nrow := ro - 1
					end
					ncol := co
				elseif dir = 2 then	--NE
					if(ro = 1) then
						nrow := shared_info.number_rows
					else
						nrow := ro - 1
					end
					if(co = shared_info.number_columns) then
						ncol := 1
					else
						ncol := co + 1
					end
				elseif dir = 3 then	--E
					if(co = shared_info.number_columns) then
						ncol := 1
					else
						ncol := co + 1
					end
						nrow := ro
				elseif dir = 4 then	--SE
					if(ro = shared_info.number_rows) then
						nrow := 1
					else
						nrow := ro + 1
					end
					if(co = shared_info.number_columns) then
						ncol := 1
					else
						ncol := co + 1
					end
				elseif dir = 5 then	--S
					if(ro = shared_info.number_rows) then
						nrow := 1
					else
						nrow := ro + 1
					end
					ncol := co
				elseif dir = 6 then	--SW
					if(ro = shared_info.number_rows) then
						nrow := 1
					else
						nrow := ro + 1
					end
					if(co = 1) then
						ncol := shared_info.number_columns
					else
						ncol := co -1
					end
				elseif dir = 7 then	--W
					if(co = 1) then
						ncol := shared_info.number_columns
					else
						ncol := co - 1
					end
					nrow := ro
				elseif dir = 8 then	--NW
					if(ro = 1) then
						nrow := shared_info.number_rows
					else
						nrow := ro -1
					end
					if(co = 1) then
						ncol := shared_info.number_columns
					else
						ncol := co -1
					end
				end
			end
			if attached {PLANET} entity as ap then
				if not grid[nrow,ncol].quadrants_full then
					put_dummy(ro,co,index)
					ni := grid[nrow, ncol].put_quadrant (entity)
					ap.update (nrow, ncol)
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]->["+nrow.out+","+ncol.out+","+ni.out+"]")
				else
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]")
				end
			elseif attached {MALEVOLENT} entity as am then
				if not grid[nrow,ncol].quadrants_full then
					put_dummy(ro,co,index)
					ni := grid[nrow, ncol].put_quadrant (entity)
					am.update (nrow, ncol)
					am.decrease_fuel
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]->["+nrow.out+","+ncol.out+","+ni.out+"]")
				else
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]")
				end
			elseif attached {BENIGN} ent as ab then
					if not grid[nrow,ncol].quadrants_full then
						put_dummy(ro,co,index)
						ni := grid[nrow, ncol].put_quadrant (ab)
						ab.update (nrow, ncol)
						ab.decrease_fuel
						ilist.add (ent.out+":["+ro.out+","+co.out+","+index.out+"]->["+nrow.out+","+ncol.out+","+ni.out+"]")
					else
						ilist.add (ent.out+":["+ro.out+","+co.out+","+index.out+"]")
					end

			elseif attached {ASTEROID} entity as aa then
				if not grid[nrow,ncol].quadrants_full then
					put_dummy(ro,co,index)
					ni := grid[nrow, ncol].put_quadrant (entity)
					aa.update (nrow, ncol)
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]->["+nrow.out+","+ncol.out+","+ni.out+"]")
				else
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]")
				end
			elseif attached {JANITAUR} entity as aj then
				if not grid[nrow,ncol].quadrants_full then
					put_dummy(ro,co,index)
					ni := grid[nrow, ncol].put_quadrant (entity)
					aj.update (nrow, ncol)
					aj.decrease_fuel
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]->["+nrow.out+","+ncol.out+","+ni.out+"]")
				else
					ilist.add (entity.out+":["+ro.out+","+co.out+","+index.out+"]")
				end
			end
		end

	use_fuel
		-- decrease fuel of the explorer
		do
			across grid is sec
			loop
				across sec.quadrants.lower |..| sec.quadrants.upper is i
				loop
					if(sec.quadrants[i].alphabet.item ~ 'E') and attached {EXPLORER}sec.quadrants[i] as ap then
						ap.decrease_fuel
					end
				end
			end
		end
	check_explorer:BOOLEAN
			--check if explorer is dead, return true if explorer is dead
		local
			dm:STRING
			removed: BOOLEAN
		do
			Result := False
			removed := False
			across grid[cur_row, cur_col].quadrants.lower |..| grid[cur_row, cur_col].quadrants.upper is i
			loop
				if(grid[cur_row, cur_col].has_star) then
					across grid[cur_row, cur_col].quadrants.lower |..| grid[cur_row, cur_col].quadrants.upper is j
					loop
						if(((grid[cur_row, cur_col].quadrants[i].alphabet.item ~ 'E') and attached {EXPLORER} grid[cur_row, cur_col].quadrants[i] as ap) and
						(grid[cur_row, cur_col].quadrants[j].alphabet.item ~ '*' or grid[cur_row, cur_col].quadrants[j].alphabet.item ~ 'Y')) then
							if(attached {STAR} grid[cur_row, cur_col].quadrants[j] as astar) then
								ap.increase_fuel(astar.luminosity)
							end
						end
					end
				end
				if not removed then
					if((grid[cur_row, cur_col].quadrants[i].alphabet.item ~ 'E') and attached {EXPLORER}grid[cur_row, cur_col].quadrants[i] as ap )then
						if(ap.fuel = 0 or (grid[cur_row, cur_col].row = 3 and grid[cur_row, cur_col].column = 3)) then
							create dm.make_empty
							put_dummy (cur_row, cur_col, i)
							entities.prune_all (ap)
							Result := True
							if(ap.fuel = 0) then
								removed := True
								ap.die(0)
								dm.append (ap.out+"->fuel:"+ap.fuel.out+"/3, life:"+ap.life.out+"/3, landed?:")
								if (ap.landed) then
									dm.append ("T,%N")
								else
									dm.append ("F,%N")
								end
								dm.append ("      Explorer got lost in space - out of fuel at Sector:")
								dm.append (ap.row.out+":"+ap.column.out)
							else
								removed := True
								ap.die (1)
								dm.append (ap.out+"->fuel:"+ap.fuel.out+"/3, life:"+ap.life.out+"/3, landed?:")
								if (ap.landed) then
									dm.append ("T,%N")
								else
									dm.append ("F,%N")
								end
								dm.append ("      Explorer got devoured by blackhole (id: -1) at Sector:3:3")
							end
							ilist.add_d (dm)
						end
					end
				end
			end

		end

	check_planet(ent:ENTITY): BOOLEAN
			--check if ent is dead
		local
			dm:STRING
		do
			Result := False
			if(sector_has_blackhole(ent.row,ent.column)) then
				across grid[ent.row, ent.column].quadrants.lower |..| grid[ent.row, ent.column].quadrants.upper is i
				loop
					if grid[ent.row, ent.column].quadrants[i] = ent and attached {PLANET}ent as ap then
						create dm.make_empty
					 	grid[ent.row, ent.column].quadrants.prune_all (ent)
					 	entities.prune_all (ap)
						Result := True
						dm.append (ap.out+"->attached?:")
						if(ap.attach) then
							dm.append ("T, support_life?:")
						else
							dm.append ("F, support_life?:")
						end
						if(ap.support_life) then
							dm.append ("T, visited?:")
						else
							dm.append ("F, visited?:")
						end
						if(ap.visited) then
							dm.append ("T, turns_left:N/A,%N")
						else
							dm.append ("F, turns_left:N/A,%N")
						end
						dm.append ("      Planet got devoured by blackhole (id: -1) at Sector:3:3")
						ilist.add_d (dm)
					end
				end
			end
		end

	check_ne(ent:ENTITY): BOOLEAN
			-- check entity that are not explorer and planet if they are dead
		local
			tmp : SECTOR
			dm: STRING
			dead: BOOLEAN
		do
			Result := False
			tmp := grid[ent.row,ent.column]
			dead := False
			across tmp.quadrants.lower |..| tmp.quadrants.upper is i
			loop
				if tmp.has_star then
					across tmp.quadrants.lower |..| tmp.quadrants.upper is j
					loop
						if attached {STAR} tmp.quadrants[j] as astar and
							ent.alphabet.is_equal (tmp.quadrants[i].alphabet) then
							if attached {MALEVOLENT} tmp.quadrants[i] as am  and ent.id = tmp.quadrants[i].id then
									am.increase_fuel (astar.luminosity)
							elseif attached {BENIGN} tmp.quadrants[i] as ab and ent.id = tmp.quadrants[i].id then
									ab.increase_fuel (astar.luminosity)
							elseif attached {JANITAUR} tmp.quadrants[i] as aj and ent.id = tmp.quadrants[i].id then
									aj.increase_fuel (astar.luminosity)
							end
						end
					end
				end
				create dm.make_empty
				if attached {MALEVOLENT} tmp.quadrants[i] as am  and ent.id = tmp.quadrants[i].id then
					dm.append (am.out+"->fuel:"+am.fuel.out+"/3, actions_left_until_reproduction:"+am.reproduction_interval.out+
								"/1, turns_left:N/A,%N")
					if am.fuel = 0 then
						dead := True
						put_dummy (ent.row, ent.column, i)
						entities.prune_all (ent)
						dm.append ("      Malevolent got lost in space - out of fuel at Sector:"+ am.row.out+":"+am.column.out)
					elseif am.row = 3 and am.column = 3 then
						dead := True
						put_dummy (ent.row, ent.column, i)
						entities.prune_all (ent)
						dm.append ("      Malevolent got devoured by blackhole (id: -1) at Sector:3:3")
					end
				elseif attached {BENIGN} tmp.quadrants[i] as ab and ent.id = tmp.quadrants[i].id then
					dm.append (ab.out+"->fuel:"+ab.fuel.out+"/3, actions_left_until_reproduction:"+ab.reproduction_interval.out+
								"/1, turns_left:N/A,%N")
					if ab.fuel = 0 then
						dead := True
						put_dummy (ent.row, ent.column, i)
						entities.prune_all (ent)
						dm.append ("      Benign got lost in space - out of fuel at Sector:"+ ab.row.out+":"+ab.column.out)
					elseif ab.row = 3 and ab.column = 3 then
						dead := True
						put_dummy (ent.row, ent.column, i)
						entities.prune_all (ent)
						dm.append ("      Benign got devoured by blackhole (id: -1) at Sector:3:3")
					end
				elseif attached {JANITAUR} tmp.quadrants[i] as aj and ent.id = tmp.quadrants[i].id then
					dm.append (aj.out+"->fuel:"+aj.fuel.out+"/5, load:"+aj.load.out+"/2, actions_left_until_reproduction:"+aj.reproduction_interval.out+
								"/2, turns_left:N/A,%N")
					if aj.fuel = 0 then
						dead := True
						put_dummy (ent.row, ent.column, i)
						entities.prune_all (ent)
						dm.append ("      Janitaur got lost in space - out of fuel at Sector:"+ aj.row.out+":"+aj.column.out)
					elseif aj.row = 3 and aj.column = 3 then
						dead := True
						put_dummy (ent.row, ent.column, i)
						entities.prune_all (ent)
						dm.append ("      Janitaur got devoured by blackhole (id: -1) at Sector:3:3")
					end
				elseif attached {ASTEROID} tmp.quadrants[i] as aa and ent.id = tmp.quadrants[i].id then
					if aa.row = 3 and aa.column = 3 then
						dead := True
						dm.append (aa.out+"->turns_left:N/A,%N")
						put_dummy (ent.row, ent.column, i)
						entities.prune_all (ent)
						dm.append ("      Asteroid got devoured by blackhole (id: -1) at Sector:3:3")
					end
				end
				if dead then
--					update
					Result := True
					ilist.add_d (dm)
				end

			end
		end
	reproduce (ent: ENTITY)
			--	generate another ent if conidtions are met
		local
			eturn, tmp: INTEGER
		do
			if attached {MALEVOLENT} ent as am then
				if not sector_full (ent.row, ent.column) and
					am.reproduction_interval = 0 then
					eturn := gen.rchoose (0, 2)
					tmp:= grid[ent.row,ent.column].put_quadrant(create {MALEVOLENT}.make(am.row,am.column, shared_info.next_movable_id, eturn))
					grid[am.row,am.column].shared_info.increment_movable_id
					ilist.add ("  reproduced "+ grid[ent.row,ent.column].quadrants[tmp].out+" at ["+ent.row.out+","+ent.column.out+","+tmp.out+"]")
					am.reset_reproduction_interval
					update
				else
					if am.reproduction_interval /= 0 then
						am.decrease_r_i
					elseif sector_full(ent.row,ent.column) then

					end
				end
			elseif attached {BENIGN} ent as ab then
				if not sector_full (ent.row, ent.column) and
					ab.reproduction_interval = 0 then
					eturn := gen.rchoose (0, 2)
					tmp:= grid[ent.row,ent.column].put_quadrant(create {BENIGN}.make(ent.row,ent.column, shared_info.next_movable_id, eturn))
					ilist.add ("  reproduced "+ grid[ent.row,ent.column].quadrants[tmp].out+" at ["+ent.row.out+","+ent.column.out+","+tmp.out+"]")
					grid[ent.row,ent.column].shared_info.increment_movable_id
					ab.reset_reproduction_interval
					update
				else
					if ab.reproduction_interval /= 0 then
						ab.decrease_r_i
					elseif sector_full(ent.row,ent.column) then

					end
				end
			elseif attached {JANITAUR} ent as aj then
				if not sector_full (ent.row, ent.column) and
					aj.reproduction_interval = 0 then
					eturn := gen.rchoose (0, 2)
					tmp:= grid[ent.row,ent.column].put_quadrant(create {JANITAUR}.make(ent.row,ent.column, shared_info.next_movable_id, eturn))
					grid[ent.row,ent.column].shared_info.increment_movable_id
					ilist.add ("  reproduced "+ grid[ent.row,ent.column].quadrants[tmp].out+" at ["+ent.row.out+","+ent.column.out+","+tmp.out+"]")
					aj.reset_reproduction_interval
					update
				else
					if aj.reproduction_interval /= 0 then
						aj.decrease_r_i
					elseif sector_full(ent.row,ent.column) then

					end
				end
			end

		end

	update
			-- update the movable and entities list
		local
			ar_entities : ARRAY[ENTITY]
			comparator: ENTITY_COMPARATOR
			sorter: DS_ARRAY_QUICK_SORTER[ENTITY]
		do
			create movable.make_empty

			create ar_entities.make_empty
			across grid is sec
			loop
				across sec.quadrants is e
				loop
					if attached {MOVABLE} e as am then
						movable.force (e, movable.count + 1)
					end
					if not attached {DUMMY} e then
						ar_entities.force(e, ar_entities.count + 1)
					end
				end
			end
			create comparator
			create sorter.make(comparator)
			sorter.sort(movable)
			sorter.sort (ar_entities)
			create entities.make_from_array (ar_entities)
		end

--	delete_entity(ent:ENTITY)
--			--delete from entities list
--		do
--			across entities is e
--			loop
--				if(e.alphabet.is_equal (ent.alphabet)) then
--					entities.prune_all (e)
--			end
--		end

feature {GALAXY_MODEL, GALAXY}	--auxiliary query
	quadrant_next_free_space (r,c: INTEGER): INTEGER
			-- return the next free space of the quadrants, -1 if no free space
		local
			ri :INTEGER
			found: BOOLEAN
		do
			found := False
			ri := -1
			across grid[r, c].quadrants.lower |..| grid[r, c].quadrants.upper is i
			loop
				if(not found) then
					if( attached {DUMMY} grid[r, c].quadrants[i]) then
						ri := i
						found := True
					end
				end
			end
			if( grid[r, c].quadrants.count < 4 and not found) then
				ri := grid[r, c].quadrants.count + 1
			end
			Result := ri
		end




feature -- query
	is_explorer (ent: ENTITY): BOOLEAN
			--check ifent is of type explorer
		do
			Result:= attached{EXPLORER} ent
		end
	check_sector_full (dir:INTEGER):BOOLEAN
			--returns true if the target sector is full
		local
			row,col:INTEGER
			nrow,ncol:INTEGER
		do
			row := cur_row
			col := cur_col
			Result:= False
			if dir = 1 then	--N
				if(row = 1) then
					nrow := shared_info.number_rows
				else
					nrow := row - 1
				end
				ncol := col
			elseif dir = 2 then	--NE
				if(row = 1) then
					nrow := shared_info.number_rows
				else
					nrow := row - 1
				end
				if(col = shared_info.number_columns) then
					ncol := 1
				else
					ncol := col + 1
				end
			elseif dir = 3 then	--E
				if(col = shared_info.number_columns) then
					ncol := 1
				else
					ncol := col + 1
				end
					nrow := row
			elseif dir = 4 then	--SE
				if(row = shared_info.number_rows) then
					nrow := 1
				else
					nrow := row + 1
				end
				if(col = shared_info.number_columns) then
					ncol := 1
				else
					ncol := col + 1
				end
			elseif dir = 5 then	--S
				if(row = shared_info.number_rows) then
					nrow := 1
				else
					nrow := row + 1
				end
				ncol := col
			elseif dir = 6 then	--SW
				if(row = shared_info.number_rows) then
					nrow := 1
				else
					nrow := row + 1
				end
				if(col = 1) then
					ncol := shared_info.number_columns
				else
					ncol := col -1
				end
			elseif dir = 7 then	--W
				if(col = 1) then
					ncol := shared_info.number_columns
				else
					ncol := col - 1
				end
				nrow := row
			elseif dir = 8 then	--NW
				if(row = 1) then
					nrow := shared_info.number_rows
				else
					nrow := row -1
				end
				if(col = 1) then
					ncol := shared_info.number_columns
				else
					ncol := col -1
				end
			end
			Result := grid[nrow, ncol].quadrants_full

		end
	sector_full(row:INTEGER;col:INTEGER): BOOLEAN
			-- return true if grid[row, col].quadrant is full
		do
			Result := grid[row,col].quadrants_full
		end
		-- all features that star with sector_has_... checks if the sector has certain type of entities
	sector_has_planet(row:INTEGER;col:INTEGER): BOOLEAN
		do
			Result := False
			across grid[row, col].quadrants is entity
			loop
				if(entity.alphabet.is_equal(create {ENTITY_ALPHABET}.make ('P'))) then
					Result := True
				end
			end
		end
	sector_has_unvisited_planet(row:INTEGER;col:INTEGER): BOOLEAN
		do
			Result := False
			across grid[row, col].quadrants is entity
			loop
				if(entity.alphabet.is_equal(create {ENTITY_ALPHABET}.make ('P')) and attached {PLANET}entity as ae) then
					if not ae.visited and ae.attach then
						Result := True
					end
				end
			end
		end
	sector_has_blackhole(row:INTEGER;col:INTEGER): BOOLEAN
		do
			Result := False
			across grid[row, col].quadrants is entity
			loop
				if(entity.alphabet.item = 'O') then
					Result := True
				end
			end
		end

	sector_has_wormhole(row:INTEGER;col:INTEGER): BOOLEAN
		do
			Result := False
			across grid[row, col].quadrants is entity
			loop
				if(entity.alphabet.item = 'W') then
					Result := True
				end
			end
		end

	sector_has_yellow_dwarf(row:INTEGER;col:INTEGER): BOOLEAN
		do
			Result := False
			across grid[row, col].quadrants is entity
			loop
				if(entity.alphabet.item = 'Y') then
					Result := True
				end
			end
		end
	sector_has_star(row:INTEGER;col:INTEGER): BOOLEAN
		do
			Result := False
			across grid[row, col].quadrants is entity
			loop
				if(entity.alphabet.item = 'Y' or entity.alphabet.item = '*') then
					Result := True
				end
			end
		end
	sector_has_benign(row:INTEGER;col:INTEGER): BOOLEAN
		do
			Result := False
			across grid[row, col].quadrants is entity
			loop
				if(entity.alphabet.item = 'B') then
					Result := True
				end
			end
		end
	check_landed:BOOLEAN
			--returns true if explorer is landed
		do
			across grid[cur_row,cur_col].quadrants is e
			loop
				if (e.alphabet.item ~ 'E'and attached {EXPLORER}e as ae) then
					Result := ae.landed
				end
			end
		end
	out: STRING
	--Returns grid in string form
	local
		string1: STRING
		string2: STRING
		row_counter: INTEGER
		column_counter: INTEGER
		quadrants_counter: INTEGER
		temp_sector: SECTOR
		temp_entity:ENTITY
		printed_symbols_counter: INTEGER
	do
		create Result.make_empty
		create string1.make(7*shared_info.number_rows)
		create string2.make(7*shared_info.number_columns)
		string1.append("%N")

		from
			row_counter := 1
		until
			row_counter > shared_info.number_rows
		loop
			string1.append("    ")
			string2.append("    ")

			from
				column_counter := 1
			until
				column_counter > shared_info.number_columns
			loop
				temp_sector:= grid[row_counter, column_counter]
			    string1.append("(")
            	string1.append(temp_sector.prints)
                string1.append(")")
			    string1.append("  ")
				from
					quadrants_counter := 1
					printed_symbols_counter:=0
				until
					quadrants_counter > temp_sector.quadrants.count
				loop
					temp_entity := temp_sector.quadrants[quadrants_counter]
					if attached temp_entity as character then
						string2.append_character(character.alphabet.item)
					else
						string2.append("-")
					end -- if
					printed_symbols_counter:=printed_symbols_counter+1
					quadrants_counter := quadrants_counter + 1
				end -- loop

				from
				until (shared_info.max_capacity - printed_symbols_counter)=0
				loop
						string2.append("-")
						printed_symbols_counter:=printed_symbols_counter+1

				end
				string2.append("   ")
				column_counter := column_counter + 1
			end -- loop
			string1.append("%N")
			if not (row_counter = shared_info.number_rows) then
				string2.append("%N")
			end
			Result.append (string1.twin)
			Result.append (string2.twin)

			row_counter := row_counter + 1
			string1.wipe_out
			string2.wipe_out
		end

	end


end
