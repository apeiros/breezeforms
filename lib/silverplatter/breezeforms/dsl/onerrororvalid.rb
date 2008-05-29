#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module BreezeForms
		module DSL
			class OnErrorOrValid
				attr_reader :__hash__
				
				def initialize(&block)
					@__hash__ = {
						:attributes => {},
						:add_class  => {},
					} # I would prefer a constant here but there's no deep_dup...
					instance_eval(&block)
				end
			
				def attributes(*args)
					@__hash__[:attributes] = args
				end
				
				def add_class(string)
					@__hash__[:add_class] = string
				end
			end
		end
	end
end
