#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module BreezeForms
		class Generator

			attr_accessor :indent
			def initialize(form)
				@form   = form
				@indent = 0
			end
			
			def method(name) # :nodoc:
				return super if (!(field = @form[name]) || has_method?(name))
				field.method(:to_html)
			end
				
			alias has_method? respond_to? # :nodoc:
			def respond_to?(name, *a) # :nodoc:
				!!@form[name] || super
			end
			
			def method_missing(name, *args, &block) # :nodoc:
				if field = @form[name] then
					field.to_html(*args, &block)
				else
					super
				end
			end
		end # Generator
	end # BreezeForms
end # SilverPlatter
