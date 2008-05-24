#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module Silverplatter
	class Validator
		class Omitted < Error
			attr_reader :reason
			attr_reader :values
			attr_reader :value
	
			def initialize(value)
				@reason = "Value was omitted"
				@value  = value
				@values = {}
			end
			
			def to_s
				@reason
			end
		end
	end
end
