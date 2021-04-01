note
	description: "used to sort array of entities"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ENTITY_COMPARATOR

inherit
	KL_COMPARATOR[ENTITY]
feature
	attached_less_than (u, v: ENTITY): BOOLEAN
		do
			Result := u.id < v.id
		end
end
