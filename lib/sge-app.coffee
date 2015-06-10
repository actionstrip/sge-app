url = require 'url'
{CompositeDisposable} = require 'atom'

referObj={};
referArr=[];
fs = require('fs');
os = require('os');
url = require('url');
jpath = require('path');

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
    @subscriptions.add atom.commands.add 'atom-workspace', "sge-app:tscompile" , tscompile
    @subscriptions.add atom.commands.add ".tree-view .file .name", "sge-app:tscompilefile" , tscompilefile
    @subscriptions.add atom.commands.add 'atom-workspace', "sge-app:createtagts" , createtagts
    @subscriptions.add atom.commands.add ".tree-view .file .name", "sge-app:createtagtsfile" , createtagtsfile




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


 tscompilefile = ({target}) ->
  path = target.dataset.path
  return unless path
  tscompileRun path

 tscompile = (path) ->
   editor = atom.workspace.getActiveTextEditor()
   return unless editor?
   path = editor.getPath()
   tscompileRun path

 tscompileRun = (path) ->
  path = String(path)
  console.log("tscompile path",path)
  tsRootPath = path.substring 0 , (path.lastIndexOf "\\") + 1
  console.log("tsRootPath",tsRootPath)

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

  #projectPath = atom.project.getPath()
  projectPath = atom.project.path
  console.log("projectPath",projectPath)
  packagesPath = atom.packages.getPackageDirPaths()[0]
  console.log("packagesPath",packagesPath)
  tscPath=packagesPath + "\\sge-app\\" + "tsc"
  console.log("tscPath",tscPath)


  allTsFiles=""
  for i of projectSpec.files
    fileStr = projectSpec.files[i].substring 0 , (projectSpec.files[i].lastIndexOf '.')
    #tsFilePath = tsRootPath + "//"+ projectSpec.files[i]
    tsFilePath = jpath.resolve(tsRootPath,projectSpec.files[i])
    tsFileDir = jpath.dirname(tsFilePath)
    #tsFileDir = fileStr.substring 0 , ((projectSpec.files[i].lastIndexOf '/') + 1)
    console.log("tsFileDir",tsFileDir)
    allTsFiles +=" " + tsFilePath
    console.log("fileStr",fileStr)

  console.log("allTsFiles",allTsFiles)

  exec = require('child_process').spawn
  #exec 'cmd' , ['/c','C:\\Users\\SM1450\\.atom\\packages\\sge-app\\tsc C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\TeA.ts --out C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\allts.js']
  #exec 'cmd' , ['/c', tscPath + ' C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\TeA.ts --out C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\allts.js']
  #exec 'cmd' , ['/c', tscPath + allTsFiles + ' --out ' + 'C:\\inetpub\\wwwroot\\sge\\app_0.0.1\\test2\\allts.js']
  exec 'cmd' , ['/c', tscPath + allTsFiles + ' --out ' + outPath]
  atom.notifications.addSuccess("SGE : complete complie " + outPath + " \u2665")

 createtagtsfile = ({target}) ->
  path = target.dataset.path
  return unless path
  createtagtsRun path

 createtagts = (path) ->
   editor = atom.workspace.getActiveTextEditor()
   return unless editor?
   path = editor.getPath()
   createtagtsRun path

 createtagtsRun = (path) ->
  path = String(path)
  referObj={};
  referArr=[];
  tsRootPath = path.substring 0 , (path.lastIndexOf "\\") + 1
  console.log("tsRootPath",tsRootPath)

  try
    projectFileTextContent = fs.readFileSync path, 'utf8'
    #console.log("projectFileTextContent ",projectFileTextContent)
  catch ex
    #console.log("projectFileTextContent error",ex)

  try
    projectSpec = JSON.parse projectFileTextContent
  catch



  for i of projectSpec.files
    fileStr = projectSpec.files[i].substring 0 , (projectSpec.files[i].lastIndexOf '.')
    tsFilePath = jpath.resolve(tsRootPath,projectSpec.files[i])
    tsFileDir = jpath.dirname(tsFilePath)
    #여기부턴 참조 연결을위한 ts 파일읽고 데이터 저장
    referObj[fileStr]={name:fileStr};
    referObj[fileStr].tag="<script src='" + fileStr + ".js'></script>"
    referObj[fileStr].refers=[];
    referArr.push referObj[fileStr]
    console.log("referArr--",referArr)
    tsBuf = fs.readFileSync (tsFilePath), 'utf8'
    tsTxt = tsBuf.toString();
    tslines = tsTxt.split "\n";
    for n of tslines
      tsline = tslines[n]
      #console.log("tsline",tsline,(tsline.indexOf "reference"))
      if ((tsline.indexOf "<reference") > -1)
        referPath = tsline.substring (tsline.indexOf '"')+1 , (tsline.lastIndexOf '"')
        referPath = referPath.replace /.ts/,"" #jquery.d.ts 예외처리
        resolvePath = jpath.resolve(tsFileDir,referPath) # ./child , ../TeA  -> ./TeA
        relativePath = jpath.relative(tsRootPath,resolvePath)
        finalPath = "./" + relativePath.replace(/\\/g,"/")
        #resolevPath = "./" + jpath.join(tsFileDir,referPath) # ./child , ../TeA  -> ./TeA
        console.log("resolvePath",resolvePath)
        console.log("relativePath",relativePath)
        console.log("finalPath",finalPath)
        referObj[fileStr].refers.push finalPath;


  console.log("arr_pre", referArr);
  chkSort(referArr);
  console.log("arr_after", referArr);

  htmlTags="<html>\n<head>\n\nscriptTags\n</head>\n<body>\nTagTemplete\n</body>\n</html>"
  scriptTags=""
  for m of referArr
    scriptTags += referArr[m].tag + "\n"


  console.log("scriptTags", scriptTags);
  htmlTags = htmlTags.replace /scriptTags/,scriptTags
  console.log("htmlTags", htmlTags);

  outPathTail = projectSpec.compilerOptions.outDir || ""
  writePath =jpath.resolve(tsRootPath,outPathTail,'scriptTags.html')
  console.log("writePath", writePath);
  try
    fs.writeFile writePath,htmlTags,'utf8', (-> atom.notifications.addSuccess("SGE : create complete scriptTags.html \u2665"))
  catch ex



getObj = (str) ->
  return referObj[str]

chkSort = (arr) ->
  isEdit=false;
  for i of arr
    curObj = arr[i];
    if curObj.name
      if curObj.refers
        for k of curObj.refers
          otherName= curObj.refers[k];
          otherObj = getObj otherName
          otherIndex =arr.indexOf otherObj
          curIndex = i;
          if sortFunc(curObj,otherObj) == 1 #otherObj 가 왼쪽에 있어야 하는데
            if curIndex < otherIndex #otherObj 가 오른쪽에 있다면.
              #자리를 바꿔라.
              arr.splice otherIndex,1 #잘라내고
              arr.splice i,0,otherObj #curObj 위치에 밀어넣는다.
              isEdit=true;
              break;

    if isEdit
      break;
  if isEdit
    chkSort(arr);


sortFunc = (a,b) ->
  #console.log("param",a,b)
  bFirst=Boolean(a.refers && ((a.refers.indexOf b.name) > -1));
  aFirst=Boolean(b.refers && ((b.refers.indexOf a.name) > -1));
  #console.log("name=" + a.name + "/" + b.name  )
  #console.log("bool=" + aFirst + "/" + bFirst  )
  if (bFirst && aFirst)
    return 0 ;
  else if(bFirst)
    return 1;
  else if(aFirst)
    return -1;
  else
    return 0
