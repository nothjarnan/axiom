os.loadAPI("Axiom/libraries/edge")

if not fs.exists("Axiom/programs/stdgui.app") then
  edge.windowAlert(30,10,"It appears that store is not installed",true,colors.red)
else
  shell.run("Axiom/programs/stdgui.app")
end