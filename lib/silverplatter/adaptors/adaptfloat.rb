#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module Adaptors
		module AdaptFloat
			Adaptors[Float] = self
			
			def adapt(value, ignore=/[',_ ]/)
				return value if Float === value
				Float(value.gsub(ignore,""))
			rescue => e
				AdaptionError.new(:not_adaptable, value, :exception => e.inspect)
			end
		end
	end
end
