Array.prototype.empty = function() {
	return(this.length == 0);
};
Array.prototype.each = function(yield) {
	for (var i=0; i<this.length; i++) {
		yield(i, this[i]);
	};
	return(this);
};
Object.prototype.each = function(yield) {
	for (property in this) {
		if (this.hasOwnProperty(property)) {
			yield(property, this[property]);
		}
	};
	return(this);
};

function Field(form, name, description) {
	var field          = this;
	this._form         = form;
	this._name         = name;
	this._errors       = new Array();
	this._available    = false;
	this._node         = $('[@name="'+form.name()+'.'+name+'"]');
	this._expects      = description.expects;
	this._validates_if = description.validates_if;

	this.form         = function() { return(this._form); };
	this.name         = function() { return(this._name); };
	this.errors       = function() { return(this._errors); };
	this.available    = function() { return(this._available); };
	this.node         = function() { return(this._node); };
	this.expects      = function() { return(this._expects); };
	this.validates_if = function() { return(this._validates_if); };
	this.valid        = function() {
		return(this._available && this._errors.empty());
	};
	this.erroneous    = function() {
		return(this._available && !(this._errors.empty()));
	};
	this.validate     = function() {
	};
	this.set_value    = function(value) {
		this._value = value;
	};
	
	this._node.change(function() {
		if (field._add_class) {
			field._node.addClass(field._add_class);
		}
	});
}

function Form(name, fields) {
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

	fields.each(function(name, description) {
		form._fields[name] = new Field(form, name, description);
	});
};

Adaptors = {
	"String": function(value) { return(value); },
	"Integer": function(value) { return(parseInt(value)); },
	"Float": function(value) { return(parseFloat(value)); },
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
		"not_empty": function(value) {
			return(value.length > 0);
		},
		"is_email": function(value) {
			return(/\A[\x21-\xff]+@[\x21-\xff]+\.[A-Za-z]{2,}\z/.test(value));
		},
		"is_url": function(value) {
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
		"natural": function(value) {
			return(value >= 0);
		},
		"positive": function(value) {
			return(value > 0);
		},
		"negative": function(value) {
			value >= 0
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
		"natural": function(value) {
			return(value >= 0);
		},
		"positive": function(value) {
			return(value > 0);
		},
		"negative": function(value) {
			value >= 0
		}
	}
};