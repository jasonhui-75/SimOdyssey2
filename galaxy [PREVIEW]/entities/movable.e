note
	description: "deferred class representing movable entities in the galaxy"
	author: "Jason Hui"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	MOVABLE
inherit
	ENTITY
feature	--attributes
	turn: INTEGER
	death_message : STRING

feature	--command
	update(arow,acol:INTEGER)
		do
			row := arow
			column := acol
		end
end
