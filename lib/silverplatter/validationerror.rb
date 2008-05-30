#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	class ValidationError < StandardError
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
			@reason.to_s
		end
		
		def to_str
			@reason.to_s
		end
	end
end
