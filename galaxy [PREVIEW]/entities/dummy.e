note
	description: "used for replacing an entity when it moves or dies."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	DUMMY
inherit
	entity
		redefine
			out
		end
create
	make

feature	--Constructor
	make(arow:INTEGER;acolumn:INTEGER)
		do
			row := arow
			column := acolumn
			id := 999999999
			create alphabet.make('-')
		end

feature	--query
	out:STRING
		do
			create Result.make_empty
			Result := "-"
		end
end
