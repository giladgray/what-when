Entries = new Meteor.Collection 'entry'

if Meteor.isClient

  Handlebars.registerHelper 'ifEmpty', (array, options) ->
    console.log array
    if array and (array.length or array.count())
      options.inverse @
    else
      options.fn @

  Template.entry.helpers
    date: (date) -> moment(date).format 'lll' # short localized datetime

  Template.history.entries = ->
    Entries.find { who: Meteor.userId() },
      sort:
        when: -1

  Template.header.rendered = ->
    $(@find('#how')).hide()
    $("#when").datetimepicker
      format: 'HH:mm PP, MM/dd/yyyy '

  Template.header.events
    'submit form': (event, template) ->
      event.preventDefault()
      data =
        who: Meteor.userId()
        what: template.find('#what input').value
        when: new Date template.find('#when input').value
        how: template.find('#how textarea').value
      if data.what and data.when
        console.log data
        Entries.insert data
        template.find('form').reset()
    'click #and-how': (event, template) ->
      console.log 'and how!'
      event.stopPropagation()
      $(template.find('#how')).slideToggle('fast')
      false
    'click .close': (event, template) ->
      $(form = template.find('form')).addClass('mini')
      form.reset()
    'focus .mini input': (event, template) ->
      $(template.find('form')).removeClass('mini')

if Meteor.isServer
  # code to run on server at startup
  Meteor.startup ->


