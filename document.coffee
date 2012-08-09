if typeof document == 'object'
	exports.document = document
else
	r = require
	jsdom = r('jsdom')
