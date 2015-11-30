NotifyDaemon = require './lib/server'
NotifyWindow = require './lib/window'
$ = require 'jquery'
Gui = require 'nw.gui'

NWIN = new NotifyWindow(Gui, 'body')
daemon = new NotifyDaemon()

_handle_debug = () ->
	pre = $('<pre>')
	pre.append(JSON.stringify NWIN.win)
	for i in ['isTransparent']
		pre.append("\n")
		pre.append(i)
		pre.append(": ")
		pre.append(JSON.stringify NWIN.win[i])
		pre.append("\nWINDOW PID: #{NWIN.PID}")
		pre.append("\nWINDOW PID: #{NWIN.WID}")
	return pre

$ ->
	daemon.on 'message', (args) ->
		if args[0] is 'debug'
			NWIN.showFor 2000, _handle_debug()
		else
			console.error "unhandled command", args[0]

daemon.start()
