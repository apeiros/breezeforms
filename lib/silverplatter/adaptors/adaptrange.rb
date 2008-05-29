#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module Adaptors
		module AdaptRange
			Adaptors[Range] = self
			
			def adapt(value)
				return value if Range === value
				ValidationError.new(:not_adaptable, value)
			end
		end
	end
end
