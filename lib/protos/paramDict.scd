Require("paramList").clone {

	~params = ();

	//Simple one-dimensional key->value storage
	//Go through all keys in params
	//and update them with value from obj if value is not nil
	~setParams = { |obj|
		~params.keysValuesDo { |k, v|
			obj[k] !? { |newVal|
				~params[k].value = newVal;
			}
		}
	};

	~getParams = { |usage|
		var obj=();
		~params.keysValuesDo { |k, cv|
			obj[k] = cv.value;
		};
		obj
	};


};