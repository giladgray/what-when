Entries = new Meteor.Collection 'entry'

WHAT = 'data-what'
WHEN = 'data-when'
WHERE = 'data-where'
WHY = 'data-why'

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

  # all of the user's entries, sorted by recency
  Template.history.entries = ->
    Entries.find { who: Meteor.userId() },
      sort:
        when: -1

  # at most 3 unique recent whats
  Template.what.recents = ->
    entries = Entries.find { who: Meteor.userId() },
      sort:
        when: -1
    _.uniq(entries.fetch(), false, ((d) -> d.what)).slice(0, 3)

  Template.what.events
    # process WHAT component, getting text string
    'submit form, click .btn-link': (event, template) ->
      event.preventDefault()
      $el = $(event.currentTarget)
      what = ""
      # get value from form input or button text
      if event.currentTarget.nodeName is 'FORM'
        what = template.find('input').value
      else
        what = $el.children('strong').text()
      # only update if a string was entered
      if what
        $el.parents('.active').removeClass('active')
        Session.set WHAT, what

  # an array of quick times to speed up entry
  Template.when.quickTimes = [{
    name: '<strong>now</strong>',
    time: -> moment()
  }, {
    name: 'today',
    time: -> today()
  }, {
    name: 'yesterday',
    time: -> today().subtract('days', 1)
  }, {
    name: 'last weekend'
    time: -> today().startOf('week').subtract('days', 1)
  }]

  Template.when.events
    # process WHEN component, constructing and validating moment
    'submit form, click .btn-link': (event, template) ->
      event.preventDefault()
      $el = $(event.currentTarget)
      time = ""
      # get data from form input or from quick time via function
      if event.currentTarget.nodeName is 'FORM'
        time = moment(template.find('input').value)
      else
        html = $el.html()
        time = _.find(Template.when.quickTimes, (d) -> d.name is html).time()
      # only update if it's a valid time object
      if time and time.isValid()
        $el.parents('.active').removeClass('active')
        Session.set WHEN, time.toDate()

  # TODO: I don't like having all these Session dependencies, feels inefficient
  # provide each question template with access to its session variable
  Template.what.Qwhat = -> Session.get WHAT
  Template.when.Qwhen  = -> Session.get WHEN

  # provide header template with access to all question variables
  Template.header.what  = -> Session.get WHAT
  Template.header.when  = -> Session.get WHEN
  Template.header.where = -> Session.get WHERE
  Template.header.why   = -> Session.get WHY

  # returns true if form is ready to submit
  Template.header.ready = ->
    Session.get(WHAT) and Session.get(WHEN)

  Template.header.events
    # toggle a question component
    'click .btn-question': (event, template) ->
      event.preventDefault()
      $(event.currentTarget).parent().toggleClass('active')

    # create new Entry from form data
    'submit #new-entry': (event, template) ->
      event.preventDefault()
      data =
        who: Meteor.userId()
        what: template.find('#what input').value
        when: new Date template.find('#when input').value
      if data.what and data.when
        console.log data
        Entries.insert data
        template.find('form').reset()
        Session.set WHAT, undefined
        Session.set WHEN, undefined
        Session.set WHERE, undefined
        Session.set WHY, undefined

    'click #and-how': (event, template) ->
      console.log 'and how!'
      event.stopPropagation()
      $(template.find('#how')).slideToggle('fast')
      false

    # clear input text
    'click .close': (event, template) ->
      $(event.currentTarget).siblings('input').val('')

  Template.entry.events
    'click .btn.delete': (event, template) ->
      # smoothly delete an entry from the list
      $(template.firstNode).slideUp 'fast', =>
        Entries.remove @_id

    'click .btn.edit': (event, template) ->

if Meteor.isServer
  # code to run on server at startup
  Meteor.startup ->


