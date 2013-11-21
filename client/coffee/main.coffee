require
  shim:
    'libs/bootstrap': deps: ['libs/jquery']
    'libs/angular': deps: ['libs/bootstrap']
    'libs/angular-route': deps: ['libs/angular']
    'libs/angularFire': 
      deps: [
        'libs/firebase'
        'libs/angular'
      ]
    'app': deps: [
      'libs/angular'
      'libs/angular-route'
      'libs/angularFire'
    ]
    'bootstrap': deps: ['app']
    'controllers/main':
      deps: [
        'app'
      ]
  [
    'require'
    'controllers/main'
  ], (require) ->
    require ['bootstrap']