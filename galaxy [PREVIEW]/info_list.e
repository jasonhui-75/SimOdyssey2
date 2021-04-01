note
	description: "Summary description for {INFO_LIST}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	INFO_LIST

create {I_L_ACCESS}
	make

feature{NONE}
	make
		do
			create moves.make (10)
			create deaths.make(10)
		end

feature{GALAXY_MODEL}	--Data structure
	moves:ARRAYED_LIST[STRING]
	deaths:ARRAYED_LIST[STRING]

feature {GALAXY_MODEL, GALAXY}	--Operation
	clear
			-- clear movement list
		do
			moves.make (10)
		end
	add (s:STRING)
			-- add string s into the movement list
		do
			moves.extend (s)
		end

	clear_d
			-- clear death list
		do
			deaths.make(10)
		end
	add_d(s:STRING)
			-- add string s into death list
		do
			deaths.extend (s)
		end
end
