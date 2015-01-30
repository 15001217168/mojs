h = require './h'
(->
  lastTime = 0; x = 0
  vendors = ["ms", "moz", "webkit", "o" ]

  while x < vendors.length and not window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"]
    k = window[vendors[x] + "CancelRequestAnimationFrame"]
    window.cancelAnimationFrame = window[vendors[x]+"CancelAnimationFrame"] or k
    ++x
  unless window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element) ->
      currTime = new Date().getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout(->
        callback currTime + timeToCall
        return
      , timeToCall)
      lastTime = currTime + timeToCall
      id
  unless window.cancelAnimationFrame
    window.cancelAnimationFrame = (id) ->
      clearTimeout id
      return
  return
)()

class Tweener
  constructor:(@o={})-> @vars(); @
  vars:-> @tweens = []; @loop = h.bind @loop, @
  loop:->
    return @ if !@isRunning
    time  = Date.now(); @update time
    if !@tweens.length then return @isRunning = false
    # if time >= @endTime then @isRunning = false; return @o.onComplete?.apply @
    requestAnimationFrame @loop
    @
  startLoop:->
    return if @isRunning; @isRunning = true
    requestAnimationFrame @loop
  stopLoop:-> @isRunning = false
  update:(time)->
    i = @tweens.length
    while(i--)
      @remove(@tweens[i]) if @tweens[i].update(time) is true
  add:(tween)-> @tweens.push(tween); @startLoop()
  remove:(tween)->
    index = @tweens.indexOf tween
    if index isnt -1
      @tweens.splice index, 1

t = new Tweener

### istanbul ignore next ###
if (typeof define is "function") and define.amd
  define "tweener", [], -> t
if (typeof module is "object") and (typeof module.exports is "object")
  module.exports = t
### istanbul ignore next ###
window?.mojs ?= {}
window?.mojs.tweener = t