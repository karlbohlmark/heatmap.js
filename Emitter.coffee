class Emitter
    constructor: ->
        @handlers = {}
    on: (event, handler)=>
        @handlers[event] = [] if not (event of @handlers)
        @handlers[event].push handler
    trigger: (event, data)=>
        handler(data) for handler in (@handlers[event] || [])
    emit: => @trigger.apply this, [].slice.call arguments

module.exports = Emitter