return unless process.platform is 'win32'

fs = require 'fs'

str = "function basename(filename, ext) { filename = filename.replace(/\\\\/g, '/'); return path.basename(filename, ext);}"
path = __dirname + "/../node_modules/derby/lib/components.js"

file = fs.readFileSync path, {encoding: 'utf8'}

if file.indexOf(str) == -1
  file = file.replace /path.basename/g, 'basename'
  fs.writeFileSync path, file + str