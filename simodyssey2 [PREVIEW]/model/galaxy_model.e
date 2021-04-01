note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	GALAXY_MODEL

inherit
	ANY
		redefine
			out
		end

create {ETF_MODEL_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for `Current'.
		do
			create error.make_empty
			message := "Welcome! Try test(3,5,7,15,30)"
			state := 0
			nt := 0
			create games.make_empty
			gn := 0
			playing := False
			valid := True
			in_game := False
			edead := False
			show_status := False
			elanded := False
		end

feature {NONE} -- model attributes
	error, message : STRING	--strings for printing in out
	state, gn, nt : INTEGER	-- integer that helps displays number of states of the game
	games : ARRAY[GALAXY]
	s_i_a : SHARED_INFORMATION_ACCESS
	s_i : SHARED_INFORMATION
		attribute
			Result := s_i_a.shared_info
		end
	playing, moved, valid, in_game, win:BOOLEAN	--variable that represent what kind of state is the game currently in
	edead, show_status, elanded: BOOLEAN	-- variale that checks if extra information are required to be printed


--	sec : SECTOR

feature -- model operations
	default_update
			-- Perform update to the model state.
		do
			state := state + 1
		end

	abort
			-- abort the current game
		do
			if not in_game then
				valid := False
				nt := nt +1
				error := "Negative on that request:no mission in progress."
			else
--				state := state + 1
				win := False
				in_game := False
				valid := True
				nt := nt + 1
				message := "Mission aborted. Try test(3,5,7,15,30)"
			end
		ensure
			aborted:
				not valid or not in_game
		end

	land
			-- lands the player
		local
			dead:BOOLEAN
			pid:INTEGER
			fl:BOOLEAN
		do
			if(not in_game) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no mission in progress."
			elseif (games.at (gn).check_landed) then
				valid := False
				nt := nt +1
				error := "Negative on that request:already landed on a planet at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			elseif( not games.at (gn).sector_has_yellow_dwarf (games.at (gn).cur_row, games.at (gn).cur_col)) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no yellow dwarf at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			elseif( not games.at (gn).sector_has_planet (games.at (gn).cur_row, games.at (gn).cur_col)) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no planets at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			elseif( not (games.at (gn).sector_has_unvisited_planet (games.at (gn).cur_row, games.at (gn).cur_col))) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no unvisited attached planet at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			else
				state := state + 1
				nt := 0
				valid := True
				pid := games.at (gn).explorer_land
				dead := games.at(gn).check_explorer
				fl := check_win (pid)
				elanded := True
				if not fl  then
					turn
					message := "Explorer found no life as we know it at Sector:"
					message.append (games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
				else
					win := True
					in_game := False
					message := "Tranquility base here - we've got a life!"
				end
			end
		ensure
			explorer_landed : not valid or elanded

		end

	liftoff
			-- lifts off the player
		local
			dead:BOOLEAN
		do
			if(not in_game) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no mission in progress."
			elseif (not games.at (gn).check_landed) then
				valid := False
				nt := nt +1
				error := "Negative on that request:you are not on a planet at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			else
				message := "Explorer has lifted off from planet at Sector:"
				message.append (games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
				state := state + 1
				nt := 0
				valid := True
				games.at (gn).explorer_liftoff
				dead := games.at(gn).check_explorer
				check_dead
				turn
			end
		end

	move(dir: INTEGER_32)
			-- move player towards the direction dir
		local
			dead, pdead:BOOLEAN
			num:INTEGER
		do
			if(not in_game) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no mission in progress."
			elseif (games.at (gn).check_landed) then
				valid := False
				nt := nt +1
				error := "Negative on that request:you are currently landed at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			elseif(games.at (gn).check_sector_full(dir)) then
				valid := False
				nt := nt +1
				error := "Cannot transfer to new location as it is full."
			else
				state := state +1
				nt := 0
				valid := True
				moved := True
				elanded := False
				games.at (gn).move_explorer (dir)
				games.at(gn).use_fuel
				dead := games.at(gn).check_explorer
				check_dead
				turn
			end
		end

	pass
			-- pass a turn
		local
			dead:BOOLEAN
		do
			if(not in_game) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no mission in progress."
			else
				elanded:= False
				games.at (gn).ilist.clear
				games.at (gn).ilist.clear_d
				valid := True
				state := state + 1
				nt := 0
				dead := games.at (gn).check_explorer
				check_dead
				turn
			end
		ensure
			state_increased: not valid or old state + 1 = state
		end
	play
			-- create a game in play mode
		do
			if(in_game) then
				valid := False
				nt := nt +1
				error := "To start a new mission, please abort the current one first."
			else
				s_i.set_asteroid_threshold (3)
				s_i.set_janitaur_threshold (5)
				s_i.set_malevolent_threshold (7)
				s_i.set_benign_threshold (15)
				s_i.set_planet_threshold (30)
				games.force (create {GALAXY}.make, games.upper+1)
				playing := True
				gn := gn+1
				valid := True
				nt := 0
				moved := False
				state := state + 1
				in_game := True
				win := False
				edead := false
				elanded := False
			end
		ensure
			play_mode: not valid or playing
			in_game: not valid or in_game
			explorer_alive:not valid or  not edead
		end

	status
			-- display status
		local
		q:ARRAYED_LIST[ENTITY]
		do
			if not in_game then
				show_status := False
				valid := False
				nt := nt +1
				error := "Negative on that request:no mission in progress."
			else
				show_status := True
				valid := True
				nt := nt + 1
				q := games.at (gn).grid[games.at (gn).cur_row,games.at (gn).cur_col].quadrants
				across q.lower |..| q.upper is i
				loop
					if attached {EXPLORER}q[i] as ae then
						if(not ae.landed) then
							message :="Explorer status report:Travelling at cruise speed at ["
							message.append (ae.row.out+","+ae.column.out+","+i.out+"]")
							message.append ("%N  Life units left:"+ae.life.out+", Fuel units left:"+ae.fuel.out)
						else
							message :="Explorer status report:Stationary on planet surface at ["
							message.append (ae.row.out+","+ae.column.out+","+i.out+"]")
							message.append ("%N  Life units left:"+ae.life.out+", Fuel units left:"+ae.fuel.out)
						end
					end
				end
			end
		ensure
			status: not valid or show_status

		end
	test(a_threshold:INTEGER; j_threshold:INTEGER; m_threshold: INTEGER; b_threshold:INTEGER; p_threshold:INTEGER)
		do
			if(in_game) then
				valid := False
				nt := nt +1
				error := "To start a new mission, please abort the current one first."
			else
				s_i.set_asteroid_threshold (a_threshold)
				s_i.set_janitaur_threshold (j_threshold)
				s_i.set_malevolent_threshold (m_threshold)
				s_i.set_benign_threshold (b_threshold)
				s_i.set_planet_threshold (p_threshold)
				games.force (create {GALAXY}.make, games.upper+1)
				playing := False
				gn := gn+1
				valid := True
				state := state + 1
				nt := 0
				moved := False
				in_game := True
				win := False
				edead := False
				elanded:= False
			end
		ensure
			test_mode: not valid or not playing
			in_game: not valid or  in_game
			explorer_alive: not valid or not edead
		end
	wormhole
		local
			dead:BOOLEAN
		do
			if(not in_game) then
				valid := False
				nt := nt +1
				error := "Negative on that request:no mission in progress."
			elseif games.at (gn).check_landed then
				valid := False
				nt := nt +1
				error := "Negative on that request:you are currently landed at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			elseif not games.at (gn).sector_has_wormhole(games.at (gn).cur_row, games.at (gn).cur_col) then
				valid := False
				nt := nt +1
				error := "Explorer couldn't find wormhole at Sector:"
				error.append(games.at (gn).cur_row.out+":"+games.at (gn).cur_col.out)
			else
				across games.at (gn).grid[games.at (gn).cur_row,games.at (gn).cur_col].quadrants is ent
				loop
					if attached {EXPLORER} ent as ae then
						games.at (gn).wormhole(ent)
					end
				end
				valid := True
				state := state +1
				nt := 0
				dead := games.at(gn).check_explorer
				check_dead
				turn
			end
		end
	reset
			-- Reset model state.
		do
			make
		end

feature {NONE}	--auxiliary operation

--	move_planet(ent: ENTITY)
--		do
--			if is_planet(ent) then
--				direction :=
--		end

	check_dead
			local
				g:GALAXY
			do
				g := games.at (gn)
				across g.movable is ent
				loop
					if (attached {EXPLORER} ent as ae) then
						if(ae.life = 0) then
							if(ae.die_from = 0) then
								edead := true
								message := "Explorer got lost in space - out of fuel at Sector:"
								message.append (ae.row.out+":"+ae.column.out)
								message.append ("%N  The game has ended. You can start a new game.")
							elseif (ae.die_from = 1) then
								edead := true
								message := "Explorer got devoured by blackhole (id: -1) at Sector:3:3"
								message.append ("%N  The game has ended. You can start a new game.")
--							elseif(ae.die_from = 3) then
--								message := "Explorer got lost in space - out of life support at Sector:"+ae.row.out+":"+ae.column.out
--								message.append ("%N  The game has ended. You can start a new game.")
							end
						end
					end
				end
			end
	check_win(aid:INTEGER):BOOLEAN
		local
			temp_g:GALAXY
		do
			temp_g := games.at (gn)
			across temp_g.grid[temp_g.cur_row, temp_g.cur_col].quadrants is ent
			loop
				if( attached {EXPLORER}ent as ae) then
					if ae.landed then
						across temp_g.grid[temp_g.cur_row, temp_g.cur_col].quadrants is p
						loop
							if (attached {PLANET}p as ap and p.id = aid) then
									Result := ap.support_life and ap.attach
							end
						end
					else
						Result := False
					end
				end
			end
		end
	is_planet(ent:ENTITY):BOOLEAN
		do
			Result := ent.alphabet.item ~ 'P'
		end
	is_explorer(ent:ENTITY):BOOLEAN
		do
			Result := ent.alphabet.item ~ 'E'
		end

	turn
		local
			num:INTEGER
			pdead:BOOLEAN
		do
			moved := true
--			games.at (gn).update
			across games.at (gn).movable is ent
			loop
				if attached {MOVABLE} ent as movable and (ent.row /=3 or ent.column /= 3) then
					if movable.turn = 0 then	--check turn left
						if(games.at (gn).sector_has_star (ent.row, ent.column) and
							attached {PLANET} ent as ap) then
							ap.set_attach
							if games.at (gn).sector_has_yellow_dwarf (ap.row, ap.column) and not ap.generated then
								num := games.at (gn).gen.rchoose (1, 2)
								ap.generate
								if(num = 2) then
									ap.supports_life
								end
							end
						elseif games.at (gn).movable.has (ent) then
							 	--no star
							if games.at (gn).sector_has_wormhole (ent.row, ent.column) and
								(attached {MALEVOLENT} ent or attached {BENIGN} ent)  and not attached {EXPLORER} ent then
								games.at (gn).wormhole (ent)
							elseif not attached {EXPLORER} ent then
								games.at (gn).move_entity(ent)
							end
							if attached {PLANET} ent then
								pdead := games.at (gn).check_planet (ent)	--check
							else	--check non planets
								pdead := games.at (gn).check_ne (ent)
							end

							if(not pdead) then	--if did not die
								games.at(gn).reproduce (ent)
								behave(ent)
							end	-- end of dead
						end
					else
						if attached {PLANET} ent as ap then
							ap.decrease_turn
						elseif attached {MALEVOLENT} ent as am then
							am.decrease_turn
						elseif attached {BENIGN} ent as ab then
							ab.decrease_turn
						elseif attached {JANITAUR} ent as aj then
							aj.decrease_turn
						elseif attached {ASTEROID} ent as aa then
							aa.decrease_turn
						end
					end
				end
			end
		end

	behave (ent:ENTITY)
			-- each type of movable entities (excluding explorer) has a unique behaviour when
			-- their turn occurs
		local
			num: INTEGER
			g: GALAXY
			dm: STRING
			qa: ARRAY[ENTITY]
			comparator: ENTITY_COMPARATOR
			sorter: DS_ARRAY_QUICK_SORTER[ENTITY]
		do
			g := games.at (gn)
			create comparator
			create sorter.make (comparator)
			create qa.make_from_array (g.grid[ent.row,ent.column].quadrants.to_array.deep_twin)
			sorter.sort (qa)
			if attached {ASTEROID} ent as aa then
				across qa is a_e
				loop
					if attached {MOVABLE} a_e as a_m then
						across g.grid[ent.row,ent.column].quadrants.lower |..| g.grid[ent.row,ent.column].quadrants.upper is i
						loop
							if   attached {MALEVOLENT} g.grid[ent.row,ent.column].quadrants[i] as am  and g.grid[ent.row,ent.column].quadrants[i].id = a_e.id then
								create dm.make_empty
								dm.append (am.out+"->fuel:"+am.fuel.out+"/3, actions_left_until_reproduction:"+am.reproduction_interval.out+
											"/1, turns_left:N/A,%N")
								g.ilist.add ("  destroyed "+g.grid[ent.row,ent.column].quadrants[i].out+" at ["+ent.row.out+","+ent.column.out+","+i.out+"]")
								g.put_dummy (ent.row, ent.column, i)
								g.entities.prune_all (am)

								dm.append ("      Malevolent got destroyed by asteroid (id: "+ent.id.out+") at Sector:"+ent.row.out+":"+ent.column.out)
								g.ilist.add_d (dm)
							elseif attached {BENIGN} g.grid[ent.row,ent.column].quadrants[i] as ab and g.grid[ent.row,ent.column].quadrants[i].id = a_e.id  then
								create dm.make_empty
								dm.append (ab.out+"->fuel:"+ab.fuel.out+"/3, actions_left_until_reproduction:"+ab.reproduction_interval.out+
											"/1, turns_left:N/A,%N")
								g.ilist.add ("  destroyed "+g.grid[ent.row,ent.column].quadrants[i].out+" at ["+ent.row.out+","+ent.column.out+","+i.out+"]")
								g.put_dummy (ent.row, ent.column, i)
								g.entities.prune_all (ab)
								dm.append ("      Benign got destroyed by asteroid (id: "+ent.id.out+") at Sector:"+ent.row.out+":"+ent.column.out)
								g.ilist.add_d (dm)
							elseif attached{JANITAUR} g.grid[ent.row,ent.column].quadrants[i] as aj and g.grid[ent.row,ent.column].quadrants[i].id = a_e.id  then
								create dm.make_empty
								dm.append (aj.out+"->fuel:"+aj.fuel.out+"/5, load:"+aj.load.out+"/2, actions_left_until_reproduction:"+aj.reproduction_interval.out+
											"/2, turns_left:N/A,%N")
								g.ilist.add ("  destroyed "+g.grid[ent.row,ent.column].quadrants[i].out+" at ["+ent.row.out+","+ent.column.out+","+i.out+"]")
								g.put_dummy (ent.row, ent.column, i)
								g.entities.prune_all (aj)
								dm.append ("      Janitaur got destroyed by asteroid (id: "+ent.id.out+") at Sector:"+ent.row.out+":"+ent.column.out)
								g.ilist.add_d (dm)
							elseif attached {EXPLORER} g.grid[ent.row,ent.column].quadrants[i] as ae and g.grid[ent.row,ent.column].quadrants[i].id = a_e.id  then
								create dm.make_empty
								message.make_empty
								ae.die (2)
								edead := True
								dm.append (ae.out+"->fuel:"+ae.fuel.out+"/3, life:"+ae.life.out+"/3, landed?:")
								if (ae.landed) then
									dm.append ("T,%N")
								else
									dm.append ("F,%N")
								end
								g.ilist.add ("  destroyed "+g.grid[ent.row,ent.column].quadrants[i].out+" at ["+ent.row.out+","+ent.column.out+","+i.out+"]")
								g.put_dummy (ent.row, ent.column, i)
								g.entities.prune_all (ae)
								dm.append ("      Explorer got destroyed by asteroid (id: "+ent.id.out+") at Sector:"+ent.row.out+":"+ent.column.out)
								message.append ("Explorer got destroyed by asteroid (id: "+ent.id.out+") at Sector:"+ent.row.out+":"+ent.column.out)
								message.append ("%N  The game has ended. You can start a new game.")
								g.ilist.add_d (dm)
							end
						end
					end
				end
				num := g.gen.rchoose (0, 2)
				aa.set_turn (num)
				g.update
			elseif attached {JANITAUR} ent as aj  then
				across qa is a_e
				loop
					if attached {ASTEROID} a_e as aa then
						across g.grid[ent.row,ent.column].quadrants.lower |..| g.grid[ent.row,ent.column].quadrants.upper is i
						loop
								if a_e.id = g.grid[ent.row,ent.column].quadrants[i].id and aj.load < 2 then
									create dm.make_empty
									dm.append (aa.out+"->turns_left:N/A,%N")
									g.ilist.add ("  destroyed "+g.grid[ent.row,ent.column].quadrants[i].out+" at ["+ent.row.out+","+ent.column.out+","+i.out+"]")
									g.put_dummy (ent.row, ent.column, i)
									g.entities.prune_all (aa)
									dm.append ("      Asteroid got imploded by janitaur (id: "+ent.id.out+") at Sector:"+ent.row.out+":"+ent.column.out)
									aj.load_increment
									g.ilist.add_d (dm)
								end

						end
					end
				end
				if(g.grid[ent.row,ent.column].has_wormhole) then
					aj.clear_load
				end
				num := games.at (gn).gen.rchoose(0,2)
				aj.randomize_turn(num)
				g.update
			elseif attached {BENIGN} ent as ab then
				across qa is  a_e
				loop
					if attached {MALEVOLENT} a_e as am then
						across g.grid[ent.row,ent.column].quadrants.lower |..| g.grid[ent.row,ent.column].quadrants.count  is i
						loop
							if a_e.id = g.grid[ent.row,ent.column].quadrants[i].id  then
								create dm.make_empty
								dm.append (am.out+"->fuel:"+am.fuel.out+"/3, actions_left_until_reproduction:"+am.reproduction_interval.out+
											"/1, turns_left:N/A,%N")
--								g.grid[ent.row,ent.column].quadrants.prune_all (am)
								g.ilist.add ("  destroyed "+g.grid[ent.row,ent.column].quadrants[i].out+" at ["+ent.row.out+","+ent.column.out+","+i.out+"]")
								g.put_dummy (ent.row, ent.column, i)
								g.entities.prune_all (am)
								dm.append ("      Malevolent got destroyed by benign (id: "+ent.id.out+") at Sector:"+ent.row.out+":"+ent.column.out)
								g.ilist.add_d (dm)

							end
						end
					end
				end

				num := games.at (gn).gen.rchoose(0,2)
				ab.randomize_turn(num)
				g.update
			elseif attached {MALEVOLENT} ent as am then
				across g.grid[ent.row,ent.column].quadrants.lower |..| g.grid[ent.row,ent.column].quadrants.upper is i1
				loop
					if(attached {EXPLORER} g.grid[ent.row,ent.column].quadrants[i1] as ae and
						not games.at (gn).sector_has_benign (ent.row, ent.column)) then
						if not ae.landed then
							ae.decrease_life
							g.ilist.add ("  attacked "+g.grid[ent.row,ent.column].quadrants[i1].out+" at ["+ent.row.out+","+ent.column.out+","+i1.out+"]")
							if ae.life = 0 then
								ae.die (3)
								edead := True
								message := "Explorer got lost in space - out of life support at Sector:"+ae.row.out+":"+ae.column.out
								message.append ("%N  The game has ended. You can start a new game.")
								create dm.make_empty
								dm.append (ae.out+"->fuel:"+ae.fuel.out+"/3, life:"+ae.life.out+"/3, landed?:")
								if (ae.landed) then
									dm.append ("T,%N")
								else
									dm.append ("F,%N")
								end
								g.put_dummy (ent.row, ent.column, i1)
								g.entities.prune_all (ae)

								dm.append ("      Explorer got lost in space - out of life support at Sector:"+ent.row.out+":"+ent.column.out)
								g.ilist.add_d (dm)
							end
						end
					end
				end
				num := games.at (gn).gen.rchoose(0,2)
				am.randomize_turn(num)
			elseif attached {PLANET}ent as ap then
				if(games.at (gn).sector_has_star (ap.row, ap.column)) then --behave
					ap.set_attach
					if games.at (gn).sector_has_yellow_dwarf (ap.row, ap.column) and not ap.generated then
						num := games.at (gn).gen.rchoose (1, 2)
						ap.generate
						if(num = 2) then
							ap.supports_life
						end
					end
				else
					ap.randomize_turn (games.at (gn).gen.rchoose (0, 2))
				end	--end of behave for planet
			end
		end
	reset_win
		do
			if(win) then
				win := False
			end
		end


feature  -- queries
	out : STRING
		do

			create Result.make_empty
			Result.append ("  state:"+state.out+"."+nt.out+", ")

			if(not playing and (in_game or win)) then
				Result.append ("mode:test, ")
			elseif(playing and (in_game or win)) then
				Result.append ("mode:play, ")
			end
			reset_win
			if(valid = True) then
				Result.append("ok")
				if(not in_game or show_status) then
					Result.append ("%N  "+message)
					if(show_status) then
						show_status := False
					end
				elseif (in_game and not show_status) then
					check_dead
					if(edead or elanded) then
						Result.append ("%N  "+message)
					end

					Result.append(print_movement)
					if(not playing) then	--print when only in test mode
						Result.append(print_sectors)
						Result.append(print_descriptions)
						Result.append (print_death)
					end

					Result.append (games.at (gn).out)	--print board
--					Result.append (print_rng)
					if(edead) then
						if not playing then
						Result.append ("%N  "+message)
						end
						in_game := False
					end
					games.at (gn).ilist.clear
					games.at (gn).ilist.clear_d
				end
			elseif(not valid) then
				Result.append("error")
				Result.append ("%N  "+error)
			end


		end
		print_sectors:STRING
			do
				create Result.make_empty
				Result.append ("%N  Sectors:")
				across games.at (gn).grid is sec
				loop
					Result.append ("%N    "+sec.print_sector +"->")
					across sec.quadrants.lower |..| 4 is i
					loop
						if i <= sec.quadrants.count and(attached {ENTITY}sec.quadrants[i] as ae) then
							Result.append (ae.out)
						else
							Result.append("-")
						end
						if( i < 4) then
							Result.append (",")
						end
					end
				end
			end
		print_movement:STRING
			do
				create Result.make_empty
				if(moved = True and in_game) then
					Result.append ("%N  Movement:")
					across games.at (gn).ilist.moves is s
					loop
						Result.append("%N    "+s)
					end
				elseif(not moved and in_game) then
					Result.append("%N  Movement:none")
				end
			end

		print_descriptions:STRING
			do
				create Result.make_empty
				Result.append ("%N  Descriptions:")
				across games.at (gn).entities is e
				loop
					Result.append ("%N    "+e.out+"->")
					if e.alphabet.item ~ 'Y' then
						Result.append ("Luminosity:2")
					elseif e.alphabet.item ~ '*' then
						Result.append ("Luminosity:5")
					elseif e.alphabet.item ~ 'E' and attached {EXPLORER}e as ae then
						Result.append ("fuel:"+ae.fuel.out+"/3, life:"+ae.life.out+"/3, landed?:")
						if(ae.landed) then
							Result.append ("T")
						else
							Result.append ("F")
						end
					elseif e.alphabet.item ~ 'A' and attached {ASTEROID}e as aa then
						Result.append ("turns_left:"+aa.turn.out)
					elseif e.alphabet.item ~ 'J' and attached {JANITAUR}e as aj then
						Result.append ("fuel:"+aj.fuel.out+"/5, load:"+aj.load.out+"/2, actions_left_until_reproduction:"+aj.reproduction_interval.out+"/2, turns_left:"+aj.turn.out)
					elseif e.alphabet.item ~ 'M' and attached {MALEVOLENT}e as am then
						Result.append ("fuel:"+am.fuel.out+"/3, actions_left_until_reproduction:"+am.reproduction_interval.out+"/1, turns_left:"+am.turn.out)
					elseif e.alphabet.item ~ 'B' and attached {BENIGN}e as ab then
						Result.append ("fuel:"+ab.fuel.out+"/3, actions_left_until_reproduction:"+ab.reproduction_interval.out+"/1, turns_left:"+ab.turn.out)
					elseif (e.alphabet.item ~ 'P' and attached {PLANET}e as ap)then
						Result.append ("attached?:")
						if ap.attach then
							Result.append ("T, support_life?:")
						else
							Result.append ("F, support_life?:")
						end
						if ap.support_life then
							Result.append ("T, visited?:")
						else
							Result.append ("F, visited?:")
						end
						if ap.visited then
							Result.append ("T, turns_left:")
						else
							Result.append ("F, turns_left:")
						end
						if ap.attach then
							Result.append ("N/A")
						else
							Result.append (ap.turn.out)
						end

					end
				end
			end
		print_death:STRING
			local
				l:ARRAYED_LIST[STRING]
				s2: STRING
			do
				l := games.at (gn).ilist.deaths
				create Result.make_empty
				Result.append("%N  Deaths This Turn:")
				if l.is_empty then
					Result.append("none")
				else
					across l is s
					loop
						if s.count > 1 then
							Result.append ("%N    "+s)
						end

					end
				end

			end

		print_test:STRING
			do
				create Result.make_empty
				Result.append ("%N Moveable: ")
					across games.at (gn).movable is m
					loop
						if attached {PLANET} m as am then
							if (not am.attach) then
								Result.append("%Nid: "+ am.id.out +"turn:" + am.turn.out +" row:" +am.row.out+" col:"+ am.column.out)
							elseif am.attach then
								Result.append("%Nid: "+ am.id.out +"turn:" + "N/A")
							end
						end
					end
				Result.append ("%N location:" + games.at (gn).cur_row.out + ", " +games.at (gn).cur_col.out)
			end
		print_rng:STRING
			do
				create Result.make_empty
				Result.append ("%N RNG:")
				across games.at (gn).gen.list is s
				loop
					Result.append (s+", ")
				end
				games.at (gn).gen.clear
				Result.append ("%N")
			end

end
