#--
# Copyright 2007 by Stefan Rusterholz.
# All rights reserved.
# See LICENSE.txt for permissions.
#++



require 'silverplatter/breezeforms/dsl/onerrororvalid'



module SilverPlatter
	module BreezeForms
		module DSL
			class WithFields
				attr_reader :__hash__
				attr_reader :form

				def initialize(form, &block)
					@form     = form
					@on_error = {}
					@on_valid = {}
					instance_eval(&block)
				end
				
				# Tell the form validator to ignore the given fields.
				# Avoids that BreezeForm raises due to unknown fields just because
				# you have some fields that you don't care (usually submit buttons)
				def ignore(*fields)
					@form.add_ignore(*fields)
				end
			
				# Uses DSL::OnErrorOrValid, so those methods are valid within
				# the on_error block.
				# This block is applied to all subsequent field definitions.
				def on_error(&block)
					@on_error = OnErrorOrValid.new(&block).__hash__
				end
				
				# Uses DSL::OnErrorOrValid, so those methods are valid within
				# the on_valid block.
				# This block is applied to all subsequent field definitions.
				def on_valid(&block)
					@on_valid = OnErrorOrSuccess.new(&block).__hash__
				end
				
				# Create a <select> tag
				def select(name, *args, &block)
					select        = Select.create(name, *args, &block)
					select.prefix = @form.prefix
					@form[name]   = select
				end
				
				# Create a <button> tag
				def button
					button        = Button.create(name, *args, &block)
					button.prefix = @form.prefix
					@form[name]   = button.create(name, *args, &block)
				end
				
				# Create a <textarea> tag
				def textarea(name, *args, &block)
					textarea        = Textarea.create(name, *args, &block)
					textarea.prefix = @form.prefix
					@form[name]     = textarea
				end
				
				# ------------------------------------------------------------
				# input tags
				# ------------------------------------------------------------
				
				def input(type, name, *args, &block)
					input        = Input.create(type, name, *args, &block)
					input.prefix = @form.prefix
					@form[name]  = input
				end
				
				# Create an <input type="text" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def text(*args, &block);     input(:text, *args, &block);     end

				# Create an <input type="password" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def password(*args, &block); input(:password, *args, &block); end

				# Create an <input type="checkbox" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def checkbox(*args, &block); input(:checkbox, *args, &block); end

				# Create an <input type="radio" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def radio(*args, &block);    input(:radio, *args, &block);    end

				# Create an <input type="submit" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def submit(*args, &block);   input(:submit, *args, &block);   end

				# Create an <input type="reset" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def reset(*args, &block);    input(:reset, *args, &block);    end

				# Create an <input type="file" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def file(*args, &block);     input(:file, *args, &block);     end

				# Create an <input type="hidden" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def hidden(*args, &block);   input(:hidden, *args, &block);   end

				# Create an <input type="image" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def image(*args, &block);    input(:image, *args, &block);    end

				# Create an <input type="button" /> tag, see SilverPlatter::BreezeForms::Input::new
				# for infos on the arguments and the block.
				def button(*args, &block);   new(:button, *args, &block);     end
			end
		end
	end
end
