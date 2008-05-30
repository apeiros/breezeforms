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
			obj.instance_variable_set(:@forms, {})
		end

		# Creates a new formclass with the given specification
		# Returns the new class
		def has_form(name, &block)
			name = name.to_sym
			form = Class.new(Form)
			form.instance_variable_set(:@name, name)
			form.class_eval(&block)
			@forms[name] = form
		end

		# process the form with the given name
		# instanciates the Form class, sets the values and performs the validation
		def process_form(name)
			name   = name.to_sym
			prefix = /#{name}\./
			form   = @forms[name].new
			request.params.each do |key, value|
				form.validate_field(key.sub(prefix, EmptyString), value) if key =~ prefix
			end
			form.process
			form
		end

		# process all known forms and return a hash with
		# { formname => processedform }
		def process_forms
			result = {}
			@forms.each_key { |name| result[name] = process_form(name) }
			result
		end
	end
end
