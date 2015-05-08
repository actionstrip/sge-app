url = require 'url'
{CompositeDisposable} = require 'atom'

module.exports =
  config:
    localRoot:
      type: 'string'
      default: 'C:\\inetpub\\wwwroot'
    siteRoot:
      type: 'string'
      default: 'localhost'
    chromePath:
      type: 'string'
      default: 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
    alltsTojsName:
      type: 'string'
      default: 'all.js'

  activate: (state) ->
	# Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    @subscriptions = new CompositeDisposable
	# Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace','sge-app:chromeopen': => @chromeopen()
    @subscriptions.add atom.commands.add ".tree-view .file .name", "sge-app:chromeopenfile" , chromeopenfile
    @subscriptions.add atom.commands.add ".tree-view .file .name", "sge-app:tscompile" , tscompile




  deactivate: ->


  chromeopen: ->
    editor = atom.workspace.getActiveTextEditor()
    return unless editor?
    path = editor.getPath()
    console.log("path2",path)
    openchrome path
    #path = path.replace "C:\\inetpub\\wwwroot", "localhost"
    #chromePath = 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'
    #exec chromePath , [path]


 chromeopenfile = ({target}) ->
  path = target.dataset.path
  return unless path
  console.log("path1",path)
  openchrome path


 openchrome = (path) ->
  console.log("path",path)
  exec = require('child_process').execFile
  path = String(path).replace atom.config.get('sge-app.localRoot'), atom.config.get('sge-app.siteRoot')
  chromePath = atom.config.get('sge-app.chromePath')
  exec chromePath , [path]
  #path = path.replace "C:\\inetpub\\wwwroot", "localhost"
  #chromePath = 'C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe'


 tscompile = ({target}) ->

  path = target.dataset.path
  return unless path
  console.log("tscompile path",path)

  tsRootPath = path.substring 0 , (path.lastIndexOf "\\") + 1
  console.log("tsRootPath",tsRootPath)


  fs = require('fs');
  os = require('os');

  try
    projectFileTextContent = fs.readFileSync path, 'utf8'
    #console.log("projectFileTextContent ",projectFileTextContent)
  catch ex
    #console.log("projectFileTextContent error",ex)

  try
    projectSpec = JSON.parse projectFileTextContent
  catch

  console.log("projectSpec",projectSpec)

  outPathTail = projectSpec.compilerOptions.outDir || ""
  outPath = tsRootPath + outPathTail + "\\" + atom.config.get('sge-app.alltsTojsName')
  console.log("outPathTail",outPathTail)

  projectPath = atom.project.getPath()
  console.log("projectPath",projectPath)
  packagesPath = atom.packages.getPackageDirPaths()[0]
  console.log("packagesPath",packagesPath)
  tscPath=packagesPath + "\\sge-app\\" + "tsc"
  console.log("tscPath",tscPath)

  allTsFiles=""
  for i of projectSpec.files
    tsFilePath = " " +tsRootPath + "//"+ projectSpec.files[i]
    allTsFiles += tsFilePath
    console.log("file",tsFilePath)

  console.log("allTsFiles",allTsFiles)

  exec = require('child_process').spawn
  #exec 'cmd' , ['/c','C:\\Users\\SM1450\\.atom\\packages\\sge-app\\tsc C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\TeA.ts --out C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\allts.js']
  #exec 'cmd' , ['/c', tscPath + ' C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\TeA.ts --out C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\allts.js']
  #exec 'cmd' , ['/c', tscPath + allTsFiles + ' --out ' + 'C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\allts.js']
  exec 'cmd' , ['/c', tscPath + allTsFiles + ' --out ' + outPath]
