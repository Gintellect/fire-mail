angular.module('firemail').controller 'mainController'
, ['$scope', 'angularFire', 'angularFireAuth'
, ($scope, angularFire, angularFireAuth) ->
  $scope.configurations = {}
  fireRef = new Firebase("https://gintellect.firebaseio.com/firemail/conf")
  unbindFireRef = null

  angularFireAuth.initialize(fireRef, {scope: $scope, name: "user"});

  $scope.submitText = "Create Entry"
  $scope.submitFieldText = "Add Field"

  $scope.saveEntry = () ->
    console.log 'saving entry'
    console.log $scope.entry
    console.log $scope.configurations
    $scope.configurations[$scope.entry.name] = $scope.entry
    console.log $scope.configurations

  $scope.saveField = (key, value) ->
    if !$scope.entry.fields?
      $scope.entry.fields = {}
    $scope.entry.fields[key] = value

  $scope.select = (name) ->
    $scope.entry = $scope.configurations[name]
    $scope.submitText = "Update Entry"

  $scope.selectNew = () ->
    $scope.entry =
      fields: {}
    $scope.submitText = "Create Entry"

  $scope.login = () ->
    angularFireAuth.login 'password', $scope.cred

  $scope.logout = () ->
    unbindFireRef()
    $scope.configurations = []
    angularFireAuth.logout()

  $scope.$on "angularFireAuth:login", (evt, user) ->
    $scope.cred = {}
    angularFire(fireRef, $scope, "configurations").then (unbind) ->
      unbindFireRef = unbind

  $scope.$on "angularFireAuth:error", (evt, err) ->
    console.log err
    console.log 'Login failed - TODO: display error'
]