url = require 'url'
{CompositeDisposable} = require 'atom'

module.exports =
  activate: (state) ->
	# Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
	# Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace','sge-app:chromeopen': => @chromeopen()
    @subscriptions.add atom.commands.add ".tree-view .file .name", "sge-app:chromeopenfile" , chromeopenfile
    
 
  
 
  deactivate: ->
    

  chromeopen: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?

    exec = require('child_process').execFile

    
    path = editor.getPath()

    path = path.replace "C:\\inetpub\\wwwroot", "localhost"
    chromePath = 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
    exec chromePath , [path]




 chromeopenfile = ({target}) ->
  path = target.dataset.path
  return unless path
  exec = require('child_process').execFile
  path = String(path).replace "C:\\inetpub\\wwwroot", "localhost"
  chromePath = 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
  exec chromePath , [path]
    
    