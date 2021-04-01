note
	description: "Summary description for {I_L_ACCESS}."
	author: "Jason Hui"
	date: "$Date$"
	revision: "$Revision$"

expanded class
	I_L_ACCESS

feature -- Query
    list: INFO_LIST
        once
            create Result.make
        end


invariant
	list = list

end
