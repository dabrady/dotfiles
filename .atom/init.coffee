# Your init script
#
# Atom will evaluate this file each time a new window is opened. It is run
# after packages are loaded/activated and after the previous editor state
# has been restored.
#
# An example hack to log to the console when each text editor is saved.
#
# atom.workspace.observeTextEditors (editor) ->
#   editor.onDidSave ->
#     console.log "Saved! #{editor.getPath()}"

# Add a semicolon to the end of the line
# TODO Support multiple cursors
atom.commands.add 'atom-text-editor', 'custom:semicolonize', ->
  return unless editor = atom.workspace.getActiveTextEditor()
  cursorPos = editor.getCursorBufferPosition()
  editor.moveToEndOfLine()
  editor.insertText(";")
  editor.setCursorBufferPosition(cursorPos)
