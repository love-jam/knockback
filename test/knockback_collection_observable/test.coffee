$(document).ready( ->
  module("knockback_collection_observable.js")
  test("TEST DEPENDENCY MISSING", ->
    ko.utils; _.VERSION; Backbone.VERSION
  )

  ContactViewModel = (model) ->
    @name = kb.observable(model, 'name')
    @number = kb.observable(model, 'number')
    @

  class ContactViewModelClass
    constructor: (model) ->
      @name = kb.observable(model, 'name')
      @number = kb.observable(model, 'number')

  test("Basic Usage: collection observable with ko.dependentObservable", ->
    collection = new ContactsCollection()
    collection_observable = kb.collectionObservable(collection)
    view_model =
      count: ko.dependentObservable(->return collection_observable().length )

    equal(collection.length, 0, "no models")
    equal(view_model.count(), 0, "no count")

    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5556'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5555'}))
    equal(collection.length, 2, "2 models")
    equal(view_model.count(), 2, "2 count")

    collection.add(new Contact({id: 'b3', name: 'Paul', number: '555-555-5557'}))
    equal(collection.length, 3, "3 models")
    equal(view_model.count(), 3, "3 count")

    collection.remove('b2').remove('b3')
    equal(collection.length, 1, "1 model")
    equal(view_model.count(), 1, "1 count")
  )

  test("Basic Usage: collection observable with ko.dependentObservable and view model array", ->
    collection = new ContactsCollection()
    view_models_array = ko.observableArray([])

    collection_observable = kb.collectionObservable(collection, view_models_array, {
      view_model_constructor: ContactViewModel
    })

    view_model =
      count: ko.dependentObservable(->return collection_observable().length )

    equal(collection.length, 0, "no models")
    equal(view_model.count(), 0, "no count")

    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5556'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5555'}))
    equal(collection.length, 2, "2 models")
    equal(view_model.count(), 2, "2 count")

    collection.add(new Contact({id: 'b3', name: 'Paul', number: '555-555-5557'}))
    equal(collection.length, 3, "3 models")
    equal(view_model.count(), 3, "3 count")

    collection.remove('b2').remove('b3')
    equal(collection.length, 1, "1 model")
    equal(view_model.count(), 1, "1 count")
  )

  test("Basic Usage: default view model", ->
    collection = new ContactsCollection()
    view_models_array = ko.observableArray([])

    collection_observable = kb.collectionObservable(collection, view_models_array)

    equal(collection.length, 0, "no models")
    equal(view_models_array().length, 0, "no view models")

    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5555'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5556'}))
    equal(collection.length, 2, "two models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(view_models_array().length, 2, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'Ringo', "Ringo is first")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'George', "George is second")

    collection.remove('b2')
    equal(collection.length, 1, "one models")
    equal(view_models_array().length, 1, "one view models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is left")
    model = kb.vmModel(view_models_array()[0])
    equal(model.get('name'), 'Ringo', "Ringo is left")

    view_model = collection_observable.viewModelByModel(model)
    equal(kb.vmModel(view_model).get('name'), 'Ringo', "Ringo is left")

    view_model_count = 0
    collection_observable.eachViewModel(->view_model_count++)
    equal(view_model_count, 1, "one view model")

    ok(collection_observable.collection()==collection, "collections match")
  )

  test("Basic Usage: no sorting and no callbacks", ->
    collection = new ContactsCollection()
    view_models_array = ko.observableArray([])

    collection_observable = kb.collectionObservable(collection, view_models_array, {
      view_model_create: (model) -> return new ContactViewModel(model)
    })

    equal(collection.length, 0, "no models")
    equal(view_models_array().length, 0, "no view models")

    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5555'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5556'}))
    equal(collection.length, 2, "two models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(view_models_array().length, 2, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'Ringo', "Ringo is first")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'George', "George is second")

    collection.remove('b2')
    equal(collection.length, 1, "one models")
    equal(view_models_array().length, 1, "one view models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is left")
    model = kb.vmModel(view_models_array()[0])
    equal(model.get('name'), 'Ringo', "Ringo is left")

    view_model = collection_observable.viewModelByModel(model)
    equal(kb.vmModel(view_model).get('name'), 'Ringo', "Ringo is left")

    view_model_count = 0
    collection_observable.eachViewModel(->view_model_count++)
    equal(view_model_count, 1, "one view model")

    ok(collection_observable.collection()==collection, "collections match")
  )

  test("Basic Usage: collection sync sorting with sort_attribute", ->
    collection = new ContactsCollection()
    view_models_array = ko.observableArray([])
    view_model_count = 0; view_model_resort_count = 0

    collection_observable = kb.collectionObservable(collection, view_models_array, {
      view_model_constructor:   ContactViewModelClass
      sort_attribute:           'name'
    })
    collection_observable.bind('add', (view_model, view_models_array_array) -> if _.isArray(view_model) then (view_model_count+=view_model.length) else view_model_count++)
    collection_observable.bind('resort', (view_model, view_models_array_array, new_index) -> if _.isArray(view_model) then (view_model_resort_count+=view_model.length) else view_model_resort_count++ )
    collection_observable.bind('remove', (view_model, view_models_array_array) -> if _.isArray(view_model) then (view_model_count-=view_model.length) else view_model_count--)

    equal(collection.length, 0, "no models")
    equal(view_model_count, 0, "no view models")
    equal(view_models_array().length, 0, "no view models")

    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5556'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5555'}))
    equal(collection.length, 2, "two models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(view_model_count, 2, "two view models")
    equal(view_models_array().length, 2, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'George', "George is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'Ringo', "Ringo is second - sorting worked!")

    collection.add(new Contact({id: 'b3', name: 'Paul', number: '555-555-5557'}))
    equal(collection.length, 3, "three models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(collection.models[2].get('name'), 'Paul', "Paul is second")
    equal(view_model_count, 3, "three view models")
    equal(view_models_array().length, 3, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'George', "George is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'Paul', "Paul is second - sorting worked!")
    equal(kb.vmModel(view_models_array()[2]).get('name'), 'Ringo', "Ringo is third - sorting worked!")

    collection.remove('b2').remove('b3')
    equal(collection.length, 1, "one models")
    equal(view_model_count, 1, "one view models")
    equal(view_models_array().length, 1, "one view models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is left")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'Ringo', "Ringo is left")

    collection.reset()
    equal(collection.length, 0, "no models")
    equal(view_model_count, 0, "no view models")
    equal(view_models_array().length, 0, "no view models")
    ok(view_model_resort_count==0, "not resorting happened because everything was inserted once") # TODO: make a rigorous check
  )

  test("Basic Usage: collection sync sorting with sorted_index", ->
    collection = new ContactsCollection()
    view_models_array = ko.observableArray([])
    view_model_count = 0; view_model_resort_count = 0

    class SortWrapper
      constructor: (value) ->
        @parts = value.split('-')
      compare: (that) ->
        return (that.parts.length-@parts.length) if @parts.length != that.parts.length
        for index, part of @parts
          diff = that.parts[index] - Math.parseInt(part, 10)
          return diff unless diff == 0
        return 0

    collection_observable = kb.collectionObservable(collection, view_models_array, {
      view_model_constructor:   ContactViewModelClass
      sorted_index:             kb.siwa('number', SortWrapper)
    })
    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5556'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5555'}))
    equal(collection.length, 2, "two models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(view_models_array().length, 2, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'George', "George is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'Ringo', "Ringo is second - sorting worked!")
  )

  test("Basic Usage: collection sorting with callbacks", ->
    collection = new NameSortedContactsCollection()
    view_models_array = ko.observableArray([])
    view_model_count = 0; view_model_resort_count = 0

    collection_observable = kb.collectionObservable(collection, view_models_array, {
      view_model: ContactViewModel    # view_model is legacy for view_model_constructor, it should be replaced with view_model_constructor or view_model_create
    })
    collection_observable.bind('add', (view_model, view_models_array_array) -> if _.isArray(view_model) then (view_model_count+=view_model.length) else view_model_count++)
    collection_observable.bind('resort', (view_model, view_models_array_array, new_index) -> if _.isArray(view_model) then (view_model_resort_count+=view_model.length) else view_model_resort_count++ )
    collection_observable.bind('remove', (view_model, view_models_array_array) -> if _.isArray(view_model) then (view_model_count-=view_model.length) else view_model_count--)

    equal(collection.length, 0, "no models")
    equal(view_models_array().length, 0, "no view models")

    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5556'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5555'}))
    equal(collection.length, 2, "two models")
    equal(collection.models[0].get('name'), 'George', "George is first")
    equal(collection.models[1].get('name'), 'Ringo', "Ringo is second")
    equal(view_model_count, 2, "two view models")
    equal(view_models_array().length, 2, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'George', "George is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'Ringo', "Ringo is second - sorting worked!")

    collection.add(new Contact({id: 'b3', name: 'Paul', number: '555-555-5557'}))
    equal(collection.length, 3, "three models")
    equal(collection.models[0].get('name'), 'George', "George is first")
    equal(collection.models[1].get('name'), 'Paul', "Paul is second")
    equal(collection.models[2].get('name'), 'Ringo', "Ringo is second")
    equal(view_model_count, 3, "three view models")
    equal(view_models_array().length, 3, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'George', "George is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'Paul', "Paul is second - sorting worked!")
    equal(kb.vmModel(view_models_array()[2]).get('name'), 'Ringo', "Ringo is third - sorting worked!")

    collection.remove('b2').remove('b3')
    equal(collection.length, 1, "one models")
    equal(view_model_count, 1, "one view models")
    equal(view_models_array().length, 1, "one view models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is left")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'Ringo', "Ringo is left")

    collection.reset()
    equal(collection.length, 0, "no models")
    equal(view_model_count, 0, "no view models")
    equal(view_models_array().length, 0, "no view models")
    ok(view_model_resort_count==0, "not resorting happened because everything was inserted once") # TODO: make a rigorous check
  )

  test("Basic Usage: collection sync dynamically changing the sorting function", ->
    collection = new ContactsCollection()
    view_models_array = ko.observableArray([])

    collection_observable = kb.collectionObservable(collection, view_models_array, {
      view_model_constructor: ContactViewModel
    })

    equal(collection.length, 0, "no models")
    equal(view_models_array().length, 0, "no view models")

    collection.add(new Contact({id: 'b1', name: 'Ringo', number: '555-555-5556'}))
    collection.add(new Contact({id: 'b2', name: 'George', number: '555-555-5555'}))
    equal(collection.length, 2, "two models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(view_models_array().length, 2, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'Ringo', "Ringo is first - no sorting")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'George', "George is first - no sorting")

    collection_observable.sortedIndex(((models, model) -> _.sortedIndex(models, model, (test) -> test.get('name'))), 'name')
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'George', "George is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'Ringo', "Ringo is second - sorting worked!")

    collection.add(new Contact({id: 'b3', name: 'Paul', number: '555-555-5554'}))
    equal(collection.length, 3, "three models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(collection.models[2].get('name'), 'Paul', "Paul is second")
    equal(view_models_array().length, 3, "two view models")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'George', "George is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'Paul', "Paul is second - sorting worked!")
    equal(kb.vmModel(view_models_array()[2]).get('name'), 'Ringo', "Ringo is third - sorting worked!")

    collection_observable.sortAttribute('number')
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is first")
    equal(collection.models[1].get('name'), 'George', "George is second")
    equal(collection.models[2].get('name'), 'Paul', "Paul is second")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'Paul', "Paul is first - sorting worked!")
    equal(kb.vmModel(view_models_array()[1]).get('name'), 'George', "Paul is second - sorting worked!")
    equal(kb.vmModel(view_models_array()[2]).get('name'), 'Ringo', "Ringo is third - sorting worked!")

    collection_observable.sortAttribute('name')
    collection.remove('b2').remove('b3')
    equal(collection.length, 1, "one models")
    equal(view_models_array().length, 1, "one view models")
    equal(collection.models[0].get('name'), 'Ringo', "Ringo is left")
    equal(kb.vmModel(view_models_array()[0]).get('name'), 'Ringo', "Ringo is left")

    collection.reset()
    equal(collection.length, 0, "no models")
    equal(view_models_array().length, 0, "no view models")
  )

  test("Error cases", ->
    raises((->kb.collectionObservable()), Error, "CollectionObservable: collection is missing")
    kb.collectionObservable(new ContactsCollection(), ko.observableArray([]))
    kb.collectionObservable(new ContactsCollection(), ko.observableArray([]), {})
  )
)