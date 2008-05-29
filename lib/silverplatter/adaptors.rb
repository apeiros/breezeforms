#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/adaptionerror'



module SilverPlatter
	module Adaptors
		Adaptors = Hash.new { |h,k| raise "No adaptor for #{k} available" }
		def Adaptors.[]=(key,value)
			raise "Already registered key #{key}" if has_key?(key)
			super
		end
	end
end



# must be required after due to initializing Validators::Validators
require 'silverplatter/adaptors/adaptfloat'
require 'silverplatter/adaptors/adaptinteger'
require 'silverplatter/adaptors/adaptrange'
require 'silverplatter/adaptors/adaptstring'
