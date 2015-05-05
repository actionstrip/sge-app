{WorkspaceView} = require 'atom'
RunChromeApp = require '../lib/sge-app'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "RunChromeApp", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('sge-app')

  describe "when the run-chrome-app:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.sge-app')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'sge-app:chromeopen'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.sge-app')).toExist()
        atom.workspaceView.trigger 'sge-app:toggle'
        expect(atom.workspaceView.find('.sge-app')).not.toExist()
