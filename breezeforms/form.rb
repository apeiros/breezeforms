#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/breezeforms/dsl/withfields'
require 'silverplatter/breezeforms/input'
require 'silverplatter/breezeforms/textarea'
require 'silverplatter/breezeforms/button'
require 'silverplatter/breezeforms/select'




module Silverplatter
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
		#   class MyForm < Form
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
				attr_reader :name
				attr_reader :fields
				attr_reader :method # FIXME rename
				attr_reader :action

				def inherited(by)
					by.initialize
				end
				
				# Called on inheritance (by Form.inherited)
				# Initializes the forms data
				def initialize
					@method            = :post
					@action            = ""
					@fields            = {}
					@name              = nil
					@prevent_multipost = false
					@sessionized       = false
				end
	
				# Define the fields this form has
				def with_fields(&block)
					FormFieldsDSL.new(self, &block)
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
				
				def accept_charset(*val)
					@accept_charset = val.first unless val.empty?
					@accept_charset
				end
			end # <<Form

			alias form class
			#MultipostPreventionField = Input.hidden :prevent_multipost do
			#	defaults_to { Digest::MD5.hexdigest("#{Time.now}#{$$}") }
			#end

			def initialize(fieldvalues=nil)
				@method    = form.method
				@action    = form.action
				@fields    = {}
				@value     = value
				@available = fieldvalues && fieldvalues.any? { |k,v| v }
				@errors    = []
				@valid     = @available && @errors.empty?
				if fieldvalues then
					fieldvalues.each { |k,v|
						@fields[k] = form.fields[k].new(v)
					}
					process
				end
			end
			
			# A form is available if at least one field of it was submitted
			def available?
				@available
			end
			
			# A form is unavailable if no field of it was submitted
			def unavailable?
				!@available
			end
			
			# A form is valid if all of the following conditions are met:
			# * available
			# * all required fields are submitted
			# * all submitted values are valid
			def valid?
				@valid
			end
			
			# A form is invalid if any of the following conditions is met:
			# * unavailable
			# * at least one required field was not submitted
			# * at least one value is invalid
			def invalid?
				!@valid
			end
			
			# A form is erroneous if the form is all of the following:
			# * Available (= at least 1 field was submitted)
			# * At least one value is invalid or at least one required field was not submitted
			# This means that a form that hasn't yet been submitted is NOT erroneous.
			# This is useful for e.g. displaying a text like 'Please correct the faulty fields'
			# if the user entered wrong data, but not displaying it the first time the form is
			# shown.
			def erronous?
				@available && !@errors.empty?
			end

			def to_html(indent=0, indent_str=nil)
				raise "to_html with block is not yet supported" if block_given?
				"#{(indent_str || IndentString)*indent}" \
				"<form " \
					"action=\"#{@action}\" " \
					"method=\"#{@method}\"" \
					"#{" accept-charset=\"#{@accept_charset}\"" if @accept_charset}" \
				">"
			end
			alias to_s to_html
		end # Form
	end # BreezeForms
end # Silverplatter
