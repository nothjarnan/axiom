for k, v in pairs(fs.list("AxiomUI")) do
    fs.move("AxiomUI/"..v, v)
end
fs.makeDir("home/Desktop")
fs.makeDir("home/Documents")
fs.makeDir("home/User-Programs")
fs.makeDir("firstboot")
fs.makeDir("users/apis")
fs.makeDir("users/program-files")
fs.makeDir("Axiom/logging")
fs.delete("AxiomUI")
fs.delete(".git")
fs.delete("install.lua")