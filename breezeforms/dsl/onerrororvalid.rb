module Silverplatter
	module BreezeForms
		module DSL
			class OnErrorOrValid
				attr_reader :__hash__
				
				Default = {
					:attributes => {},
					:add_class  => {},
				}

				def initialize(&block)
					@form     = form
					@__hash__ = Default
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
