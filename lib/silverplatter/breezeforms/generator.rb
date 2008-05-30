#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module BreezeForms

		# Generator is used by SilverPlatter::BreezeForms::Form#to_html when
		# issued with a block. It will yield a Generator instance to comfortably
		# render fields.
		class Generator

			# The indent Elements will use when rendered using this Generator
			attr_accessor :indent
			
			def initialize(form, indent=nil)
				@form   = form
				@indent = indent || 1
			end
			
			# Render a form field, use this if a fieldname collides with an existing
			# method.
			def render(name, *args, &block)
				indent = args.shift
				field.to_html(indent || @indent, *args, &block)
			end
			
			def method(name) # :nodoc:
				return super if (!(field = @form[name]) || has_method?(name))
				method(:render)
			end
				
			alias has_method? respond_to? # :nodoc:
			def respond_to?(name, *a) # :nodoc:
				!!@form[name] || super
			end
			
			def method_missing(name, *args, &block) # :nodoc:
				if field = @form[name] then
					indent = args.shift
					field.to_html(indent || @indent, *args, &block)
				else
					super
				end
			end
		end # Generator
	end # BreezeForms
end # SilverPlatter
