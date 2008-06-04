#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module BreezeForms
		module DSL
			class Javascript
				IndentRegex = /^[ \t]*/
				attr_reader :__hash__
				
				def initialize(update, &block)
					@__hash__ = update
					instance_eval(&block)
				end
				
				def attributes(data)
					@__hash__[:attributes] = data
				end
			
				def on_ready(script)
					@__hash__[:on_ready] = script.strip.gsub(IndentRegex, "\t")
				end
				
				def on_reset(script)
					@__hash__[:on_reset] = script.strip.gsub(IndentRegex, "\t\t\t")
				end

				def on_valid(script)
					@__hash__[:on_valid] = script.strip.gsub(IndentRegex, "\t\t\t")
				end

				def on_erroneous(script)
					@__hash__[:on_erroneous] = script.strip.gsub(IndentRegex, "\t\t\t")
				end

				def on_missing(script)
					@__hash__[:on_missing] = script.strip.gsub(IndentRegex, "\t\t\t")
				end
			end
		end
	end
end
