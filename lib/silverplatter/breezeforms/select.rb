#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++






module SilverPlatter
	module BreezeForms

		class Select < Field
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
						:options            => [],
					}.merge(opt || {}) # I would prefer a constant, but no deep_dup.

					@options      = opt.delete(:options)
					super(name, opt, &block)
					
					@field_type   = "Select".freeze
				end
				
				def options(*args)
					@options = args.first unless args.empty?
					@options
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
			
			def initialize(*args)
				super
				@options = definition.options
			end

			def options(*args)
				@options = args.first unless args.empty?
				@options
			end
				
			# Create an HTML tag for this Input.
			# Also see html_value.
			def to_html(indent=0, indent_str=IndentString)
				if indent then
					if indent < 0 then
						start_indent  = 0
						end_indent    = indent.abs-1
						indent        = indent.abs
					else
						start_indent  = indent
						end_indent    = indent
						indent       += 1
					end
				else
					start_indent = 0
					end_indent   = 0
					indent       = 0
				end

				"#{indent_str*start_indent}<select#{attributes.tag_attributes}>\n"+
				options.map { |lab, val|
					"#{indent_str*indent}" \
					"<option value=\"#{val.to_s.escape_html}\">" \
					"#{lab.to_s.escape_html}" \
					"</option>"
				}.join("\n") +
				"\n#{indent_str*end_indent}</select>"
			end
		end
	end
end
