Path         = require 'path'
Fs           = require 'fs'
Net          = require 'net'
MkdirP       = require 'mkdirp'
EventEmitter = (require 'events').EventEmitter

USERNAME = 'kb'
SOCKET_PATH = "/tmp/#{USERNAME}/nw-notify.sock"

module.exports = class NotifyDaemon extends EventEmitter

	handle_command: (msg) ->
		@emit 'message', msg

	start : ->
		@_do_start()

	_do_start: (already_retried) ->
		@server = Net.createServer (sock) =>
			@socket = sock
			@socket.on 'data', (data) =>
				str = data.toString().replace /\n/g, ''
				_tokens = str.split /\s+/
				cmd = _tokens[0] or 'debug'
				locals = {}
				for i,kvPair of _tokens.slice(1)
					[k,v] = kvPair.split('=')
					locals[k] = v
				console.log "RECEIVED: [#{cmd}, #{JSON.stringify locals}]"
				@handle_command([cmd, locals])
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
