root = global ? window

if root.Meteor.is_client
    root.Template.hello.greeting = ->
        "Welcome to firstapp"
    
    root.Template.hello.events = "click input": ->
        console.log("You pressed it.")

    root.Template.navbar.foo = ->
        "Summarize!"
    
    root.Template.navbar.events = "click button": ->
        console.log($('#datasource-url').val())

