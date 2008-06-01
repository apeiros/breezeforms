function Field(form, name, description) {
	var field          = this;
	this._form         = form;
	this._name         = name;
	this._valid        = false;
	this._available    = false;
	this._node         = $('[@name="'+form.name()+'.'+name+'"]');
	this._expects      = description.expects;
	this._validates_if = description.validates_if;
	this._value        = null;
	this._special      = new Array();

	this.form          = function() { return(this._form); };
	this.name          = function() { return(this._name); };
	this.errors        = function() { return(this._errors); };
	this.available     = function() { return(this._available); };
	this.node          = function() { return(this._node); };
	this.expects       = function() { return(this._expects); };
	this.validates_if  = function() { return(this._validates_if); };
	this.value         = function() { return(this._value); };
	this.valid         = function() {	return(this._available && this._valid); };
	this.erroneous     = function() {	return(this._available && (!this._valid)); };
	this.on_valid      = description.on_valid;
	this.on_erroneous  = description.on_erroneous;
	this.on_missing    = description.on_missing;
	if (description.confirms) {
		this._special[this._special.length] = {
			test: 'confirm',
			args: description.confirms
		};
	};

	this.adapt         = function() {
		this._value = Adaptors[this._expects](this._value);
	};
	this.validate      = function() {
		var valid = true;
		for (v in this._validates_if) {
			if (this._validates_if.hasOwnProperty(v)) {
				validator = Validators[this._expects][v];
				arg       = this._validates_if[v];
				if (!validator) { throw("No validator "+v+" exists for "+this._expects) };
				if (!validator(this._value, arg)) {
					valid = false;
					break;
				}
			}
		};
		for (i=0; i<this._special.length; i++) {
			test = this._special[i].test;
			args = this._special[i].args;
			if (test == 'confirm') {
				if (this._form.field(args).value() != this._value) {
					valid = false;
					break;
				}
			}
		};
		this._valid = valid;
	};
	this.set_value     = function(value) { this._value = value; };
	this.is_available  = function() { this._available = true; };
	
	this._node.change(function() {
		field.is_available();
		field.set_value(field.node().attr("value"));
		field.adapt();
		field.validate();
		if (field.valid()) {
			if (field.on_valid) {
				field.on_valid();
			}
		} else if (field.erroneous()) {
			if (field.on_erroneous) {
				field.on_erroneous();
			}
		}
	});
}

function Form(name, description) {
	var form        = this;

	this._name      = name;
	this._fields    = new Array()
	this._errors    = new Array();
	this._available = false;

	this.name       = function() { return(this._name); };
	this.fields     = function() { return(this._fields); };
	this.errors     = function() { return(this._errors); };
	this.available  = function() { return(this._available); };
	this.valid      = function() {
		return(this._available && this._errors.empty());
	};
	this.erroneous  = function() {
		return(this._available && !(this._errors.empty()));
	};
	this.field      = function(name) {
		return(this._fields[name]);
	};

	if (description.with_fields) {
		fields       = description.with_fields;
		on_erroneous = description.on_erroneous;
		on_missing   = description.on_missing;
		on_valid     = description.on_valid;
		for (name in fields) {
			desc = fields[name]
			if (!desc.on_erroneous && on_erroneous) {
				desc.on_erroneous = on_erroneous;
			};
			if (!desc.on_missing && on_missing) {
				desc.on_missing = on_missing;
			};
			if (!desc.on_valid && on_valid) {
				desc.on_valid = on_valid;
			};
			form._fields[name] = new Field(form, name, fields[name]);
		};
	};
};

Adaptors = {
	"String": function(value) { return(value); },
	"Integer": function(value) { return(parseInt(value)); },
	"Float": function(value) { return(parseFloat(value)); }
};

Validators = {
	"String": {
		"min": function(value, min) {
			return(value.length >= min);
		},
		"min_exclusive": function(value, min) {
			return(value.length > min);
		},
		"max": function(value, max) {
			return(value.length <= max);
		},
		"max_exclusive": function(value, max) {
			return(value.length < max);
		},
		"not_empty": function(value, arg) {
			return(value.length > 0);
		},
		"is_email": function(value, arg) {
			return(/\A[\x21-\xff]+@[\x21-\xff]+\.[A-Za-z]{2,}\z/.test(value));
		},
		"is_url": function(value, arg) {
			return(false);
		},
		"match": function(value, regexp) {
			return(regexp.test(value));
		},
		"match_not": function(value, regexp) {
			return(!regexp.test(value));
		},
		"begin_of_one_of": function(value, choices) {
			return(false);
		},
		"insensitive_begin_of_one_of": function(value, choices) {
			return(false);
		},
		"one_of": function(value, choices) {
			return(false);
		},
		"none_of": function(value, choices) {
			return(false);
		}
	},
	"Integer": {
		"min": function(value, min) {
			return(value >= min);
		},
		"min_exclusive": function(value, min) {
			return(value > min);
		},
		"max": function(value, max) {
			return(value <= max);
		},
		"max_exclusive": function(value, max) {
			return(value < max);
		},
		"natural": function(value, arg) {
			return(value >= 0);
		},
		"positive": function(value, arg) {
			return(value > 0);
		},
		"negative": function(value, arg) {
			return(value >= 0);
		}
	},
	"Float": {
		"min": function(value, min) {
			return(value >= min);
		},
		"min_exclusive": function(value, min) {
			return(value > min);
		},
		"max": function(value, max) {
			return(value <= max);
		},
		"max_exclusive": function(value, max) {
			return(value < max);
		},
		"natural": function(value, arg) {
			return(value >= 0);
		},
		"positive": function(value, arg) {
			return(value > 0);
		},
		"negative": function(value, arg) {
			return(value >= 0);
		}
	}
};