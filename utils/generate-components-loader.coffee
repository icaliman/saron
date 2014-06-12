
fs = require 'fs'
conf = require './../config/modules.js'

app_modules =
    "##\n" +
    "##   THIS IS AUTO GENERATED, MODIFICATIONS WILL BE DELETED\n" +
    "##\n\n" +
    "app = require './index'\n\n" +
    "##INIT COMPONENTS##\n" +
    "{{modules}}" +
    "##END##\n"

str = ""
for m in conf.modules
  if fs.existsSync __dirname + "/../node_modules/saron-#{m}/components"
    str += "app.use require('saron-#{m}/components')\n"

app_modules = app_modules.replace "{{modules}}", str

fs.writeFileSync __dirname + "/../src/app/components.coffee", app_modules