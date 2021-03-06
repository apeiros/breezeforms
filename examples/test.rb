$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__)+'/../lib'))
require 'silverplatter/breezeforms'

include SilverPlatter::BreezeForms

def i(*args)
	puts(args.map { |e| e.inspect }.join(', '))
end

class MyForm < Form
	attributes(
		:accept_charset => 'utf-8',
		:method         => 'post',
		:action         => '/foo'
	)
	
	with_fields do
		ignore :submit
		
		on_error do
			add_class 'error'
		end
		
		text :first_name
		
		text :last_name
		
		text :birthyear do
			expects Integer
			validates_if :min => (Time.now.year-110), :max => (Time.now.year-5) # proc { Time.now.year - 5 }
		end
		
		select :birthmonth do
			expects Integer
			options [
				["Please select one...", nil],
				["----------", nil],
				["January",    1],
				["February",   2],
				["March",      3],
				["April",      4],
				["May",        5],
				["June",       6],
				["July",       7],
				["August",     8],
				["September",  9],
				["October",   10],
				["November",  11],
				["December",  12],
			]
		end
	end
end

form = MyForm.new
form.validate(
	:first_name => "Joe",
	:last_name  => "Schmock",
	:birthyear  => "1981",
	:birthmonth => "3"
)

i :field_ancestors, *(class <<MyForm[:birthyear];self;end).ancestors.first(3)
i :has_field, MyForm.has_field?("first_name") # avoid memleak by to_sym'ing non-existant fields
i :available, form.available?
i :valid, form.valid?
i :erroneous, form.erroneous?
i :fields, form.to_hash
puts(form.to_html { |e| ["", e.first_name, e.last_name, e.birthyear, e.birthmonth, ""].join("\n") })
# , e.birthmonth