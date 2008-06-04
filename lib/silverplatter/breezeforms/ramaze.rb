#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/breezeforms'



module SilverPlatter
	module BreezeForms
		# process the form with the given name
		# instanciates the Form class, sets the values and performs the validation
		def process_form(name)
			name   = name.to_sym
			prefix = /#{name}\./
			form   = @breezeforms[name].new
			request.params.each do |key, value|
				if key =~ prefix then
					name = key.sub(prefix, EmptyString)
					name = name.to_sym if form.has_field?(name)
					form.validate_field(name, value)
				end
			end
			form.process
			form
		end
	end
end

module Ramaze
	Controller.extend SilverPlatter::BreezeForms
	class <<Controller
		alias breezeforms_inherited inherited
		def inherited(by)
			by.instance_variable_set(:@breezeforms, {})
			breezeforms_inherited(by)
		end
	end
end
