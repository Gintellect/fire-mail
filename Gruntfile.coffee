module.exports = (grunt) ->
  grunt.initConfig
    clean:
      reset:
        src: ['bin']
      temp:
        src: ['temp']
    
    template:
      dev:
        dest: 'bin/client/index.html'
        src: 'client/index.template'
        environment: 'dev'
      prod:
        dest: 'temp/client/index.html'
        src: '<%= template.dev.src %>'
        environment: 'prod'
      test:
        dest: '<%= template.prod.dest %>'
        src: '<%= template.dev.src %>'
        environment: 'test'      
   
    #minifies html file
    minify:
      prod:
        files:
          'bin/client/index.html': 'temp/client/index.html'

    # optimizes files managed by RequireJS
    requirejs:
      scripts:
        options:
          baseUrl: 'temp/client/js/'
          findNestedDependencies: true
          logLevel: 0
          mainConfigFile: 'temp/client/js/main.js'
          name: 'main'
          onBuildWrite: (moduleName, path, contents) ->
            modulesToExclude = ['main']
            shouldExcludeModule = modulesToExclude.indexOf(moduleName) >= 0

            if (shouldExcludeModule)
              return ''

            return contents
          optimize: 'uglify'
          out: 'bin/client/js/scripts.min.js'
          preserveLicenseComments: false
          skipModuleInsertion: true
          uglify:
            no_mangle: false
      styles:
        options:
          baseUrl: './temp/client/css/'
          cssIn: './temp/client/css/styles.css'
          logLevel: 0
          optimizeCss: 'standard'
          out: 'bin/client/css/styles.min.css'

    connect:
      server:
        options:
          port: 9001
          base: 'bin/client'
          hostname: '*'
          keepalive: true
      testServer:
        options:
          port: 9002
          base: 'bin/client'
          hostname: '*'
          keepalive: false
      devServer:
        options:
          port: 9001
          base: 'bin/client'
          hostname: '*'
          keepalive: false
    
    coffeeLint: 
      scripts:
        files: [
          {
            expand: true
            src: ['client/**/*.coffee', '!client/js/components/**']
          }
          {
            expand: true
            src: ['server/**/*.coffee']
          }
        ]
        options:
          indentation:
            value: 2
            level: 'error'
          no_plusplus: 
            level: 'error'
      tests:
        files: [
          {
            expand: true
            src: ['test/**/*.coffee']
          }
        ]
        options:
          indentation:
            value: 2
            level: 'error'
          no_plusplus: 
            level: 'error'
    
    coffee:
      scripts:
        expand: true
        cwd: 'client/coffee'
        src: ['**/*.coffee']
        dest: 'temp/client/js/'
        ext: '.js'
        options:
          bare: true

    less:
      styles:
        dest: 'temp/client/css/styles.css'
        src: 'client/less/styles.less'

    concat:
      bootstrap:
        src: [
          'bower_modules/bootstrap/js/transition.js'
          'bower_modules/bootstrap/js/collapse.js'
          'bower_modules/bootstrap/js/dropdown.js'
          'bower_modules/bootstrap/js/modal.js'
          'bower_modules/bootstrap/js/carousel.js'
        ]
        dest: 'temp/client/js/libs/bootstrap.js'

    copy:       
      img:
        expand: true
        cwd: 'client/'
        src: ['img/*']
        dest: 'bin/client'
      fonts:
        expand: true
        cwd: 'bower_modules/bootstrap/'
        src: ['fonts/*']
        dest: 'bin/client'
      components:
        flatten: true
        expand: true
        cwd: 'bower_modules'
        src: [
          'jquery/jquery.js'
          'angular/angular.js'
          'angular-route/angular-route.js'
          'html5shiv/dist/html5shiv.js'
          'respond/respond.min.js'
          'requirejs/require.js'
          'firebase/firebase.js'
          'angular-fire/angularFire.js'
        ]
        dest: 'temp/client/js/libs'                    
      scripts:
        expand: true
        cwd: 'temp/client/js/'
        src: ['**']
        dest: 'bin/client/js'
      index:
        expand: true
        cwd: 'temp/client/'
        dest: 'bin/client/'
        src: 'index.html'
      styles:
        expand: true
        cwd: 'temp/client/css/'
        src: ['styles.css']
        dest: 'bin/client/css'
    
    ngTemplateCache:
      views:
        files:
          './temp/client/js/views.js': './client/views/*.html'
        options:
          trim: './client'
          module: 'juj'

    compress:
      scripts:
        options:
          mode: 'gzip'
        expand: true
        cwd: 'bin/client/'
        ext: '.min.js'
        src: ['js/*.min.js']
        dest: 'bin/client_gzip/'
      html:
        options:
          mode: 'gzip'
        expand: true
        cwd: 'bin/client/'
        ext: '.html'
        src: ['*.html']
        dest: 'bin/client_gzip/'
      css:
        options:
          mode: 'gzip'
        expand: true
        cwd: 'bin/client/'
        ext: '.min.css'
        src: ['css/*.min.css']
        dest: 'bin/client_gzip/'

    aws_s3:
      options:
        access: 'public-read'
        region: 'eu-west-1'
      test:
        options:
          bucket: 'juj.gintellect.com'
        files: [
          { cwd: 'bin/client/', dest: '/', src: ['**'],  action: 'delete', differential: true},
          { expand: true, cwd: 'bin/client_gzip/', src: ['**'],  action: 'upload', differential: true, params: {ContentEncoding: 'gzip'}}
          { expand: true, cwd: 'bin/client/fonts/', dest: 'fonts/', src: ['**'],  action: 'upload', differential: true}
          { expand: true, cwd: 'bin/client/img/', dest: 'img/', src: ['**'],  action: 'upload', differential: true}
        ]
      prod:
        options:
          bucket: 'www.juliausherjewellery.com'
        files: [
          { cwd: 'bin/client/', dest: '/', src: ['**'],  action: 'delete', differential: true},
          { expand: true, cwd: 'bin/client_gzip/', src: ['**'],  action: 'upload', differential: true, params: {ContentEncoding: 'gzip'}}
          { expand: true, cwd: 'bin/client/fonts/', dest: 'fonts/', src: ['**'],  action: 'upload', differential: true}
          { expand: true, cwd: 'bin/client/img/', dest: 'img/', src: ['**'],  action: 'upload', differential: true}
        ]
        
    watch:
      options:
        livereload: true
      dev:
        files: ['client/**/*']
        tasks: ['dev']
      prod:
        files: ['client/**/*']
        tasks: ['prod']

    env:
      test:
        src: 'test.env'
      prod:
        src: 'prod.env'

    cucumberjs:
      e2e:
        src: 'test/e2e'
        options:
          format: "pretty"

    karma:
      unit:
        configFile: "test/unit/client/karma.conf.coffee"
        singleRun: true
        browsers: ["Chrome"]

  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-less'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-copy'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-concat'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-requirejs'
  grunt.loadNpmTasks 'grunt-contrib-compress'
  grunt.loadNpmTasks 'grunt-env'
  grunt.loadNpmTasks 'grunt-aws-s3'
  grunt.loadNpmTasks 'grunt-gint'
  grunt.loadNpmTasks 'grunt-karma'

  grunt.registerTask 'build', [
    'clean'
    'coffeeLint'
    'coffee'
    'less'
    'ngTemplateCache'
    'concat:bootstrap'
    'copy:components'
    'copy:img'
    'copy:fonts'
  ]
 
  grunt.registerTask 'server', [
    'build'
    'connect:server'
  ]

  grunt.registerTask 'deployTest', [
    'buildTest'
    'env:test'
    'aws_s3:test'
  ]

  grunt.registerTask 'deployProd', [
    'buildProd'
    'env:prod'
    'aws_s3:prod'
  ]

  grunt.registerTask 'test', [
    'build'
    'connect:testServer'
    'cucumberjs:e2e'
  ]

  grunt.registerTask 'dev', [
    'buildDev'
    'connect:devServer'
    'watch:dev'
  ]

  grunt.registerTask 'prod', [
    'buildProd'
    'connect:devServer'
    'watch:prod'
  ]

  grunt.registerTask 'buildDev', [
    'build'
    'template:dev'
    'copy:scripts'
    'copy:styles'
    'clean:temp'
  ] 

  grunt.registerTask 'buildProd', [
    'build'
    'template:prod'
    'requirejs'
    'minify'
    'compress'
    'clean:temp'
  ]

  grunt.registerTask 'buildTest', [
    'build'
    'template:test'
    'requirejs'
    'minify'
    'compress'
    'clean:temp'
  ]