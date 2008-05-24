#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module Silverplatter
	class Validator
		class Error
			attr_reader :reason
			attr_reader :values
			attr_reader :value
	
			def initialize(reason, value, values={})
				raise ArgumentError, "#{reason} is not a symbol" unless reason.kind_of?(Symbol)
				@reason = reason
				@value  = value
				@values = values
			end
			
			def to_s
				@reason
			end
		end
	end
end
