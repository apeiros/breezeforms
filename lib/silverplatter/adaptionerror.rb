#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	class AdaptionError < StandardError
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
			"#{@reason} - #{@value.inspect} could not be adapted. #{@values.inspect}."
		end

		def to_str
			"#{@reason} - #{@value.inspect} could not be adapted. #{@values.inspect}."
		end
	end
end
