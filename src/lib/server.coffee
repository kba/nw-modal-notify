Path         = require 'path'
Fs           = require 'fs'
Net          = require 'net'
MkdirP       = require 'mkdirp'
ChildProcess = require 'child_process'
EventEmitter = (require 'events').EventEmitter

USERNAME = 'kb'
SOCKET_PATH = "/tmp/#{USERNAME}/nw-notify.sock"

module.exports = class NotifyDaemon extends EventEmitter

	handle_command: ->
		console.log Object.keys(window)
		@emit 'message', arguments

	start : ->
		@_do_start()

	_do_start: (already_retried) ->
		@server = Net.createServer (sock) =>
			@socket = sock
			@socket.on 'data', (data) =>
				str = data.toString().replace /\n/g, ''
				args = str.split /\s+/
				console.log "RECEIVED: [#{args}]"
				@handle_command(args)
		@server.on 'listening', =>
			@is_started = true
			return Fs.chmod(SOCKET_PATH, 0o0777)
		@server.on 'error', =>
			console.log "Socket already exists, probably unclean shutdown. Removing and restarting"
			Fs.unlinkSync SOCKET_PATH
			if not already_retried
				@_do_start(true)
		MkdirP Path.dirname(SOCKET_PATH), (err) =>
			throw "Could not create #{Path.dirname(SOCKET_PATH)}" if err
			@server.listen SOCKET_PATH, () =>
				console.log "Listening on #{SOCKET_PATH}"
