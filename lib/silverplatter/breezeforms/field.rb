#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



module SilverPlatter
	module BreezeForms

		# This is an abstract baseclass for Input, TextArea, Button,
		# Select, OptGroup and Option
		class Field
			class <<self
				alias class_name name unless method_defined?(:class_name)

				EmptyValue     = "".freeze

				# Creates a new Field class
				def create(*args, &block)
					element = Class.new(self)
					element.init(*args, &block)
					element.extend Adaptors::Adaptors[element.expects]
					element.extend Validators::Validators[element.expects]
					element
				end
				
				# The name of this Form Element
				attr_reader :name
				
				# When rendered as html these attributes will be used
				attr_reader :attributes
				
				# The default value for this element
				attr_reader :default
				
				# The fallback is which value is used with FormElement#value if
				# no value was supplied or the supplied value was invalid
				attr_reader :fallback
				
				# The type of this field
				attr_reader :field_type
				
				# :nodoc:	
				attr_reader :validator

				# The prefix (needed for formprocessing to associate the field with a form)
				attr_accessor :prefix
				

				# Used by Field::create
				def init(name=nil, opt=nil, &block) # :nodoc:
					raise "Must not have :required and :optional both set" if opt.has_key?(:required) && opt.has_key?(:optional)
					@name         = name
					@field_type   = "Abstract".freeze
					@required     = true
					if opt.has_key?(:required) then
						@required     = !!opt.delete(:required)
					elsif opt.has_key?(:optional) then
						@required     = !opt.delete(:optional)
					end
					@prefix       = opt.delete(:prefixed)
					@expects      = opt.delete(:expecting) || String
					@default      = opt.delete(:defaults_to)
					@attributes   = opt.delete(:attributes) || {}
					@on_error     = opt.delete(:on_error)
					@on_valid     = opt.delete(:on_valid)
					@fallback     = opt.delete(:falls_back_to)
					@confirms     = opt.delete(:confirms)
					@validates_if = opt.delete(:validates_if) || {}
					@validator    = opt.delete(:validator)

					class_eval(&block) if block
					
					raise ArgumentError, "Name must be given" unless @name
					raise ArgumentError, "Unknown options #{opt.keys.map { |k| k.inspect }.join(', ')}" unless opt.empty?
				end

				# set whether a field is required or not, also see optional
				def required(val = true)
					@required = !!val
				end

				# set whether a field is required or not, also see required
				def optional(val = true)
					@required = !val
				end

				# test whether a field is required or not
				def required?
					@required
				end
				
				# test whether a field is required or not
				def optional?
					!@required
				end

				# 
				def confirms(*field)
					@confirms = field.first unless field.empty?
					@confirms
				end

				def attributes(*args)
					until args.empty?
						@attributes[args.shift] = true while args.first.kind_of?(Symbol)
						@attributes.update(args.shift) if args.first
					end
					@attributes
				end
				
				def on_valid(&block)
					@on_valid = DSL::OnErrorOrValid.new(&block).__hash__ if block
					@on_valid
				end
				
				def on_error(&block)
					@on_error = DSL::OnErrorOrValid.new(&block).__hash__ if block
					@on_error
				end
				
				def named(name)
					@attributes[:name] = name
				end
				
				def defaults_to(value)
					@default = value
				end
	
				def expects(*klass)
					@expects = klass.first unless klass.empty?
					@expects
				end

				def validates_if *args, &block
					until args.empty?
						@validates_if[args.shift] = [] while args.first.kind_of?(Symbol)
						@validates_if.update(args.shift) if args.first
					end
					@validator    = block
					@validates_if
				end

				def fallback_value(value)
					case @fallback
						when :original
							value
						when :default
							@default
						when :empty
							EmptyValue
						when Proc
							@fallback.call(value,self)
					end
				end				

				def new(original) # :nodoc:
					errors    = []
					value     = nil
					available = original && !original.empty? # false is a valid value
					
					if available then
						begin
							value  = adapt(original)
						rescue AdaptionError => error
							errors << error
						else
							@validates_if.each { |m, args|
								begin
									value = __send__(m, value, *args) # fastfail, don't continue validating if one fails
								rescue ValidationError => error
									errors << error
									break
								rescue NoMethodError
									raise "[#{name}] #{m} with #{original.inspect}, #{value.inspect}, #{args.inspect}" if respond_to?(m)
									raise ArgumentError, "Invalid validation #{m} in definition of #{self} (uses #{Validators::Validators[@expects]})"
								end
							}
							if errors.empty? && @validator then
								begin
									value = @validator.call(value)
								rescue AdaptionError, ValidationError => error
									errors << error
								rescue => e
									errors << ValidationError.new(:block_validation_failed, value, :exception => e)
								end
							end
							value = errors.empty? ? value : fallback_value(value)
						end
					end

					super(available, original, value, errors)
				end

				# The html_name of this field
				def html_name
					"#{@prefix}#{@name}"
				end
				
				def inspect # :nodoc:
					sprintf "#<Field(%s):%08x>",
						@field_type,
						object_id>>1
				end
			end #  <<Field

			InspectInstance = "#<%s name=%p %s value=%p, original=%p, default=%p, fallback=%p>".freeze
			IndentString    = "\t".freeze
			
			# The original value supplied (nil means no value was supplied)
			attr_reader :original
			
			# An array with the errors that occurred during adaptation/validation
			attr_reader :errors
			
			# The value this field has (either the adapted value or the default)
			attr_reader :value

			def initialize(available, original, value, errors)
				@original  = original
				@value     = value
				@available = available
				@valid     = available && errors.empty?
				@errors    = errors
			end
			
			alias definition class

			# Whether the field successfully validated
			def valid?
				@valid
			end

			# Whether the field was 
			def available?
				@available
			end

			# A field is erroneous if it is available and not valid
			# or if it is not available and required.
			def erroneous?
				@available && !@valid
			end

			# The html_name of this field as defined in its class
			def html_name
				definition.html_name
			end
			
			# The name of this field as defined in its class
			def name
				definition.name
			end
			
			# The prefix of this field as defined in its class
			def prefix
				definition.prefix
			end
			
			# The default value of this field as defined in its class
			def default
				definition.default
			end

			# This fields fallback as defined in its class
			def fallback
				definition.fallback
			end

			# The value that should be inserted into the HTML tag
			# Also see to_html.
			def html_value
				if @valid then
					@value
				elsif erroneous? && definition.fallback == :original then
					@original
				else
					definition.default
				end
			end

			# The attributes for this field with all modifications by on_error/on_valid etc.
			# applied.
			def attributes
				@attributes ||= begin
					attributes = definition.attributes.dup
					if erroneous? then
						if definition.on_error[:attributes] then
							attributes.update(definition.on_error[:attributes])
						end
						if definition.on_error[:add_class] then
							attributes[:class] = "#{attributes[:class]} #{definition.on_error[:add_class]}".strip
						end
					elsif valid? then # a field can be neither (when it's loaded the first time)
						if definition.on_valid[:attributes] then
							attributes.update(definition.on_valid[:attributes])
						end
						if definition.on_valid[:add_class] then
							attributes[:class] = "#{attributes[:class]} #{definition.on_valid[:add_class]}".strip
						end
					end
					attributes["name"] = definition.html_name
					attributes
				end
			end
			
			def to_html(indent=nil, indent_str=nil)
				raise "not implemented for #{definition.field_type}"
			end

			# Alias for to_html
			def to_s(*args, &block)
				to_html(*args, &block)
			end
			
			def inspect #:nodoc:
				sprintf InspectInstance,
					definition.field_type,
					html_name,
					@valid ? 'valid' : 'invalid',
					value,
					original,
					default,
					fallback
				# /sprintf
			end
		end
	end
end
