#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/adaptors'
require 'silverplatter/breezeforms/field'
require 'silverplatter/validators'



module SilverPlatter
	module BreezeForms

		# == Example
		#   MyInput = Input.text do
		#     attributes    :size => 3
		#     named         "port"
		#     expecting     Integer
		#     with_default  "80"
		#     validates_if  :natural, :less_than => 65535
		#     falls_back_to :userinput
		#   end
		#   
		#   input = MyInput.new(submitted_value)
		#   input.valid?
		#   input.value
		class Input < Field
			class <<self
				InspectClass = "#<%s %s %p, default=%p, fallback=%p expects=%p, restrictions=%p>".freeze

				# The input type (e.g. :text, :hidden, :password etc.) of this field
				attr_reader :type

				# Used by Input::create
				def init(type=nil, name=nil, opt=nil, &block) # :nodoc:
					@type         = type
					@field_type   = "Input:#{@type}".freeze
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
				attributes = attributes().update({
					"type"  => definition.type,
					"name"  => definition.html_name,
					"value" => html_value
				}).map { |key, value|
					"#{key}=\"#{value.to_s.escape_html}\""
				}.join(" ")
				"#{indent_str*indent if indent}<input #{attributes} />"
			end
			alias to_s to_html
		end
	end
end
