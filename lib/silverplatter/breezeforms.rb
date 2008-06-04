#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/breezeforms/form'
require 'patches' # String methods (escape_html)



module SilverPlatter
	module BreezeForms
		EmptyString = "".freeze

		def self.extended(obj)
			obj.instance_variable_set(:@breezeforms, {})
		end

		# Creates a new formclass with the given specification (the
		# specification is class evaled, basically this is the same as: 
		#   Class.new(Form) do ... end
		# Stores the class in @breezeforms in the receiver and returns
		# the new class.
		def has_form(name, &block)
			name = name.to_sym
			form = Class.new(Form)
			form.instance_eval {
				@name   = name
				@prefix = "#{name}.".freeze
			}
			form.class_eval(&block)
			@breezeforms[name] = form
		end

		unless method_defined?(:process_form) then
			# process the form with the given name
			# instanciates the Form class, sets the values and performs the validation
			def process_form(name)
				raise "You have to require the correct adapter for your framework."
			end
		end

		# process all known forms and return a hash with
		# { formname => processedform }
		def process_forms
			result = {}
			@breezeforms.each_key { |name| result[name] = process_form(name) }
			result
		end
	end
end
