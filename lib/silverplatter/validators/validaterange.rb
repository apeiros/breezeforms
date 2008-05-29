#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module Validators
		module ValidateRange
			def kind_of(value, klass)
				unless value.begin.kind_of?(klass) and value.end.kind_of?(klass) then
					raise ValidationError.new(:invalid_class, value, 'class' => klass)
				end
				value
			end
	
			def min_begin(value, min)
				raise ValidationError.new(:too_small_begin, value, 'min_begin' => min) if value.begin < min
				value
			end
	
			def min_begin_exclusive(value, min)
				raise ValidationError.new(:too_small_begin, value, 'min_begin' => min) if value.begin <= min
				value
			end
			
			def max_begin(value, max)
				raise ValidationError.new(:too_big_begin, value, 'max_begin' => max) if value.begin > max
				value
			end
	
			def max_begin_exclusive(value, max)
				raise ValidationError.new(:too_big_begin, value, 'max_begin' => max) if value.begin >= max
				value
			end

			def min_end(value, min)
				raise ValidationError.new(:too_small_end, value, 'min_end' => min) if value.end < min
				value
			end
	
			def min_end_exclusive(value, min)
				raise ValidationError.new(:too_small_end, value, 'min_end' => min) if value.end <= min
				value
			end
			
			def max_end(value, max)
				raise ValidationError.new(:too_big_end, value, 'max_end' => max) if value.end > max
				value
			end
	
			def max_end_exclusive(value, max)
				raise ValidationError.new(:too_big_end, value, 'max_end' => max) if value.end >= max
				value
			end
		end
		
		Validators[Range] = ValidateRange
	end
end
