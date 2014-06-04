app = require './index'

app.pages =
  admin:
    title: 'Admin'
    href: '/admin'
#  root:
#    title: 'Root'
#    href: '/root'
#  login:
#    title: 'Login'
#    href: '/login'
#  logout:
#    title: 'Logout'
#    href: '/logout'

app.proto.navItems = (current) ->
  items = []
  for name, page of app.pages
    items.push
      title: page.title
      href: page.href
      isCurrent: current == dash(name)
  items[items.length - 1].isLast = true
  return items

app.proto.pageTitle = (current) ->
  return app.pages[current]?.title

dash = (camelName) ->
  return camelName.replace /[a-z][A-Z]/g, (match) ->
    match.charAt(0) + '-' + match.charAt(1).toLowerCase()
