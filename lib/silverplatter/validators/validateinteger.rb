#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module Validators
		module ValidateInteger
			def min(value, min)
				raise ValidationError.new(:too_small, value, 'min' => min) if value < min
				value
			end
			alias greater_or_equal min
			
			def min_exclusive(value, min)
				raise ValidationError.new(:too_small, value, 'min' => min) if value <= min
				value
			end
			alias greater min_exclusive
	
			def max(value, max)
				raise ValidationError.new(:too_big, value, 'max' => max) if value > max
				value
			end
			alias smaller_or_equal max
	
			def max_exclusive(value, max)
				raise ValidationError.new(:too_big, value, 'max' => max) if value >= max
				value
			end
			alias smaller max_exclusive
			
			def natural(value)
				raise ValidationError.new(:too_small, value, 'max' => max) if value < 0
				value
			end
			
			def positive(value)
				raise ValidationError.new(:too_small, value, 'max' => max) if value <= 0
				value
			end
			
			def negative(value)
				raise ValidationError.new(:too_big, value, 'max' => max) if value >= 0
				value
			end
		end
	
		Validators[Integer] = ValidateInteger
	end
end
