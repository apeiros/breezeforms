#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++






module SilverPlatter
	module BreezeForms

		class Button < Field
			class <<self
				InspectClass = "#<%s %s %p, default=%p, fallback=%p expects=%p, restrictions=%p>".freeze
				
				# Used by Input::create
				def init(name=nil, opt=nil, &block) # :nodoc:
					opt           = {
						:expecting          => String,
						:prefixed           => "".freeze,
						:defaults_to        => "".freeze,
						:falls_back_to      => :original,
						:validates_if       => {},
						:attributes         => {},
						:on_valid           => {},
						:on_error           => {},
					}.merge(opt || {}) # I would prefer a constant, but no deep_dup.
					
					super(name, opt, &block)
					
					@field_type   = "Button".freeze
					raise ArgumentError.new("Type must be given") unless @type
				end
				
				def inspect # :nodoc:
					sprintf InspectClass,
						@field_type,
						@type,
						html_name,
						@default,
						@fallback,
						@expects,
						@restrictions
					# /sprintf
				end
			end
			
			# Create an HTML tag for this Input.
			# Also see html_value.
			def to_html(indent=0, indent_str=IndentString)
				start_tag = "#{indent_str*indent if indent}<button#{attributes.tag_attributes}>"
				if block_given? then
					start_tag + yield + "</button>"
				else
					start_tag
				end
			end
		end
	end
end
