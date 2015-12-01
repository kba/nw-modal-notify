$    = require 'jquery'
Gui  = require 'nw.gui'
Fs   = require 'fs'

NotifyDaemon = require './lib/server'
NotifyWindow = require './lib/window'
CONFIG       = require './lib/config'

NWIN = new NotifyWindow(Gui, CONFIG)
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

plugins = {}
for plugin in Fs.readdirSync "#{CONFIG.libdir}/plugin"
	plugin = plugin.substring(0, plugin.indexOf('.'))
	plugins[plugin] = new(require "#{CONFIG.libdir}/plugin/#{plugin}")(CONFIG)

$ ->
	daemon.on 'message', ([plugin, locals]) ->
		if plugin of plugins
			NWIN.show plugins[plugin], locals
		else
			console.error "Unknown Plugin '#{plugin}'", plugin

daemon.start()
