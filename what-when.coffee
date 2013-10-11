Entries = new Meteor.Collection 'entry'

if Meteor.isClient

  # today's date at noon
  today = -> moment().startOf('day').add('hours', 12)

  # removes the given class from all elements (optionally within scope selector)
  # and applies it to this element. useful for singleton class, such as .active
  $.fn.takeClass = (targetClass, scope='') ->
    $(scope + " ." + targetClass).removeClass targetClass
    @addClass targetClass

  # removes the old class and adds the new one
  $.fn.swapClass = (oldClass, newClass) ->
    @removeClass(oldClass).addClass(newClass)

  # executes the block if the given array is empty
  Handlebars.registerHelper 'ifEmpty', (array, options) ->
    console.log array
    if array and (array.length or array.count())
      options.inverse @
    else
      options.fn @

  # time from now string (2 weeks ago)
  Handlebars.registerHelper 'fromNow', (date) ->
    return new Handlebars.SafeString moment(date).fromNow()

  # short localized datetime (Oct 9 2013 6:12 PM)
  Handlebars.registerHelper 'date', (date) -> moment(date).format 'lll'

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


