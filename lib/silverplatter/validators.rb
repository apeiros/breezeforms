#--
# Copyright 2008 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/validationerror'



module SilverPlatter
	module Validators
		Validators = Hash.new { |h,k| raise "No validator for #{k} available" }
		def Validators.[]=(key,value)
			raise "Already registered key #{key}" if has_key?(key)
			super
		end
	end
end



# must be required after due to initializing Validators::Validators
require 'silverplatter/validators/validatefloat'
require 'silverplatter/validators/validateinteger'
require 'silverplatter/validators/validaterange'
require 'silverplatter/validators/validatestring'
