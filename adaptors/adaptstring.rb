#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module Silverplatter
	module Adaptors
		module AdaptString
			Adaptors[String] = self
			
			def adapt(value)
				value.to_str
			rescue
				AdaptionError.new(:not_adaptable, value)
			end
		end
	end
end
