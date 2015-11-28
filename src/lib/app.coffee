NotifyDaemon = require './server'
window.$ = window.jQuery = $ = require 'jquery'

daemon = new NotifyDaemon()

$(window).ready ->
	console.log $
	console.log $('body')
	daemon.on 'message', (message) ->
		console.log message
		$('body').html(message[0])

daemon.start()
