#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/breezeforms/dsl/withfields'
require 'silverplatter/breezeforms/dsl/onerrororvalid'
require 'silverplatter/breezeforms/generator'
require 'silverplatter/breezeforms/input'
require 'silverplatter/breezeforms/textarea'
require 'silverplatter/breezeforms/button'
require 'silverplatter/breezeforms/select'




module SilverPlatter
	module BreezeForms
		# === Attributes:
		# * name: the name by which the form can be accessed. The same page should not
		#   use multiple forms of the same name as the form processor won't be able
		#   to distinguish them (see BreezeForms#process_form)
		# 
		# === Flags:
		# * prevent_multipost: prevents a form to be processed multiple times, this can
		#   e.g. happen if the latency is too high so the user thinks the form hasn't been
		#   sent after he pressed the submit button and presses it again. But in fact the
		#   form has been processed the first time already. Prevent_multipost now sends
		#   a hidden hash value to the server along the form, if that hash value is received
		#   again, it is ignored
		# * sessionized: all form values are stored in the session, so when the form
		#   is opened again during the same session, those values are used instead of
		#   the default values
		# * 
		# 
		# == Example
		#   class MyForm < SilverPlatter::BreezeForms::Form
		#     name   "myform"
		#     action '/process/myform'
		#     method :post
		#     prevent_multipost
		#     
		#     with_fields do
		#       on_error do
		#         add_class 'error' # add 'error' to the 'class' attribute on errors
		#       end
		#     
		#       hidden :sid do
		#         value { request.session_id } # use a dynamic value
		#       end
		#     
		#       text :mail do
		#         validates_if String, :valid_email
		#       end
		#   
		#       select :item do
		#         options [
		#           ['item1_value', 'item1_text'],
		#           ['item2_value', 'item2_text'],
		#           ['item3_value', 'item3_text'],
		#         ]
		#         # will validate that the submitted value is one of the option-values
		#         validate_options
		#       end
		#     
		#       checkbox :agree do
		#         required # the input must be submitted
		#         value "yes"
		#         validates_if String, :is => "yes"
		#       end
		#     end
		#   end
		class Form
			class <<self
				def inherited(by) # :nodoc:
					by.init
				end
				
				# The form name
				attr_reader :name
				
				# The fields of the form
				attr_reader :fields

				# The prefix of this form (used for the names of fields)
				attr_reader :prefix

				# Called on inheritance (by Form.inherited)
				# Initializes the forms data
				attr_reader :ignore
				
				def init # :nodoc:
					@attributes        = {
						:method => :post,
					}
					@fields            = {}
					@prevent_multipost = false
					@sessionized       = false
					@on_valid          = {}
					@on_error          = {}
					@ignore            = []
					@names             = {}
				end
				
				# Set a field
				# Name must be a Symbol
				# Field should be an instance of a Field subclass
				def []=(name, field)
					@fields[name.to_sym] = field
					@names[name.to_s]    = true
				end
				
				# Access a field
				# Name must be a Symbol
				def [](name)
					@fields[name]
				end
				
				# Test whether a field is present. Name can be a String
				# or a Symbol
				def has_field?(name)
					@names[name.to_s]
				end

				def add_ignore(*fields)
					@ignore |= fields
				end

				def on_valid(&block)
					@on_valid = DSL::OnErrorOrValid.new(&block).__hash__ if block
					@on_valid
				end
				
				def on_error(&block)
					@on_error = DSL::OnErrorOrValid.new(&block).__hash__ if block
					@on_error
				end
	
				# Define the fields this form has
				def with_fields(&block)
					DSL::WithFields.new(self, &block)
				end
				
				def prevent_multipost(val = true)
					@prevent_multipost = val
				end
				
				def prevent_multipost?
					@prevent_multipost
				end
				
				def sessionized(val=true)
					@sessionized=val
				end
				
				def sessionized?
					@sessionized
				end
				
				def attributes(*args)
					until args.empty?
						@attributes[args.shift] = true while args.first.kind_of?(Symbol)
						@attributes.update(args.shift)
						@attributes[:"accept-charset"] = @attributes.delete(:accept_charset) if @attributes.has_key?(:accept_charset)
					end
					@attributes
				end
			end # <<Form

			IndentString    = "\t".freeze

			alias form class
			#MultipostPreventionField = Input.hidden :prevent_multipost do
			#	defaults_to { Digest::MD5.hexdigest("#{Time.now}#{$$}") }
			#end
			
			# The errors this form had
			attr_reader :errors

			def initialize(fieldvalues=nil)
				@fields_left = form.fields.dup
				@attributes  = form.attributes
				@fields      = {}
				@available   = false
				@errors      = []

				validate(fieldvalues) if fieldvalues
			end
			
			# Delegates to the class' has_field?
			def has_field?(name)
				form.has_field?(name)
			end

			def [](name)
				@fields[name]
			end
		
			# A form is available if at least one field of it was submitted
			def available?
				@available
			end
			
			# A form is valid if all of the following conditions are met:
			# * available
			# * all required fields are submitted
			# * all submitted values are valid
			def valid?
				@available && @errors.empty?
			end
			
			# A form is erroneous if the form is all of the following:
			# * Available (= at least 1 field was submitted)
			# * At least one value is invalid or at least one required field was not submitted
			# This means that a form that hasn't yet been submitted is NOT erroneous.
			# This is useful for e.g. displaying a text like 'Please correct the faulty fields'
			# if the user entered wrong data, but not displaying it the first time the form is
			# shown.
			def erroneous?
				@available && !@errors.empty?
			end

			def validate(fields)
				form.ignore.each { |name| fields.delete(name) }
				fields.each { |name, value| validate_field(name, value) }
				process
			end

			def process
				@fields_left.each { |name,_| validate_field(name, nil) }
			end

			def validate_field(name, value)
				# raising instead of invalidating since this most likely means
				# either a bug (typo?) in the form definition or somebody tries
				# to hack the form (web)
				raise "Unknown field #{name.inspect}" unless field = form[name]
				field         = field.new(value)
				@fields[name] = field
				@available    = true unless value.nil?
				@errors.concat(field.errors)
				@fields_left.delete(name)
			end
			
			def to_hash
				@hash ||= begin
					hash = {}
					@fields.each { |k,f| hash[k] = f.value }
					hash
				end
			end

			# Render this form as HTML
			def to_html(indent=0, indent_str=IndentString)
				attributes = form.attributes.dup
				if erroneous? then
					if form.on_error[:attributes] then
						attributes.update(input.on_error[:attributes])
					end
					if form.on_error[:add_class] then
						attributes[:class] = "#{attributes[:class]} #{input.on_error[:add_class]}".strip
					end
				elsif valid? then # a field can be neither (when it's loaded the first time)
					if form.on_valid[:attributes] then
						attributes.update(input.on_valid[:attributes])
					end
					if form.on_valid[:add_class] then
						attributes[:class] = "#{attributes[:class]} #{input.on_valid[:add_class]}".strip
					end
				end
				attributes = attributes.map { |key, value| "#{key}=\"#{value.to_s.escape_html}\"" }.join(" ")
				start_tag  = "#{indent_str*indent if indent}<form #{attributes}>"
				if block_given? then
					start_tag + yield(Generator.new(self, indent+1)) + "</form>"
				else
					start_tag
				end
			end
			alias to_s to_html
		end # Form
	end # BreezeForms
end # SilverPlatter
