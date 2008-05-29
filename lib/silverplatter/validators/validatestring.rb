#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module Validators
		module ValidateString
			MailRegex = /\A[\x21-\xff]+@[\x21-\xff]+\.[A-Za-z]{2,}\z/.freeze

			def min(value, min)
				raise ValidationError.new(:too_short, value, 'min' => min) if value.length < min
				value
			end
			
			def min_exclusive(value, min)
				raise ValidationError.new(:too_short, value, 'min' => min) if value.length <= min
				value
			end
	
			def max(value, max)
				raise ValidationError.new(:too_long, value, 'max' => max) if value.length > max
				value
			end
	
			def max_exclusive(value, max)
				raise ValidationError.new(:too_long, value, 'max' => max) if value.length >= max
				value
			end
			
			def is(value, thing)
				send("is_#{thing}", value)
			end

			# warning, not RFC conform, may reject actually valid mail addresses
			# allows all addresses that don't contain control chars, spaces and
			# have the form a+@b+.tld
			def is_email(value)
				raise ValidationError.new(:invalid_email, value) unless value =~ MailRegex
				value
			end
			
			def is_url(value)
			
			end
			
			def match(value, regexp)
				raise ValidationError.new(:not_matched, value, :regex => regexp) unless value =~ regexp
				value
			end
			
			def match_not(value, regexp)
				raise ValidationError.new(:matched, value, :regex => regexp) if value =~ regexp
				value
			end
			
			def begin_of_one_of(value, *choices)
				regex = /\A#{Regexp.escape(value.value)}/
				choices.grep(regex) { |found| return found }
				raise ValidationError.new(:not_included, value, :choices => choices)
			end
			
			def insensitive_begin_of_one_of(value, *choices)
				regex = /\A#{Regexp.escape(value.value)}/i
				choices.grep(regex) { |found| return found }
				raise ValidationError.new(:not_included, value, :choices => choices)
			end

			def one_of(value, *choices, &block)
				raise ValidationError.new(:not_included, value, :choices => choices) unless choices.include? value
				value
			end
	
			def none_of(value, *choices, &block)
				raise ValidationError.new(:invalid_value, value, :choices => choices) if choices.include? value
				value
			end
		end
	
		Validators[String] = ValidateString
	end
end
