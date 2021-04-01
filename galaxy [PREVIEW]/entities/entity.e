note
	description: "the parent class that holds the basic attributes for all entities"
	author: "Jason Hui"
	date: "$Date$"
	revision: "$Revision$"

deferred class
	 ENTITY

inherit
	ANY
		redefine
			out
		end
feature	--attribute
id, row, column:INTEGER
alphabet:ENTITY_ALPHABET

feature	--query
	out:STRING
		do
			create Result.make_empty
			Result.append("["+id.out+","+alphabet.out+"]")
		end


end
