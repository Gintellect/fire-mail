path = require 'path'
fs = require 'fs'
nconf = require 'nconf'
_ = require 'underscore'

nconf.file path.resolve(__dirname, '../config.json')

nodemailer = require "nodemailer"
Firebase = require 'firebase'
FirebaseTokenGenerator = require 'firebase-token-generator'

tokenGenerator = new FirebaseTokenGenerator nconf.get('FIREBASE_SECRET')
configRequestRef = new Firebase nconf.get('FIREBASE_URI')

watchedLocations = []

generateToken = () ->
  tokenGenerator.createToken({id: "admin"})

generateHTMLEmail = (record, fields) ->
  result = ""
  if fields?
    _.each fields, (value, key) ->
      result = result + "<p>" + value + ": " +
      record[key] + "</p>"
  else
    result = "no fields to capture defined in your config"
  result

processRecord = (config, snapshot) ->
  record = snapshot.val()
  if (record.status isnt 'Failed') and (record.status isnt 'Delivered')
    config.mailOptions.html = generateHTMLEmail record, config.fields
    smtpTransport = nodemailer.createTransport "SMTP", config.transport

    smtpTransport.sendMail config.mailOptions, (err, result) ->
      if err
        snapshot.ref().update {status: 'Failed', message: err}
      else
        snapshot.ref().update {status: 'Delivered', message: result.message}

readConfigAndListen = (record) ->
  config = 
    mailOptions:
      from: record.mailFrom
      to: record.mailTo
      subject: record.mailSubject
    transport:
      auth:
        user: record.smtpUser
        pass: record.smtpPass
    fields: record.fields
 
  if record.smtpService?
    config.transport.service = record.smtpService
  else
    config.transport.host = record.smtpHost
    config.transport.port = record.smtpPort

  ref = new Firebase record.firebaseLocation
  ref.on 'child_added', (snapshot) ->
    processRecord config, snapshot
  watchedLocations.push ref
  return

onConfigAuthComplete = (err, auth) ->
  if err
    console.log 'auth error ' + err
  else
    console.log 'Logged into firebase config.'
    console.log auth
    configRequestRef.on 'child_added', (snapshot) ->
      readConfigAndListen snapshot.val()

onAuthCancel = (err) ->
  console.log 'auth cancelled ' + err
  console.log 'retrying auth'
  contactRequestRef.auth generateToken(), onAuthComplete, onAuthCancel

onConfigAuthCancel = (err) ->
  console.log 'config auth cancelled ' + err
  console.log 'retrying auth'

  #detach all firebase location listeners
  watchedLocations.forEach (location) ->
    location.off()

  watchedLocations = []

  configRequestRef.auth generateToken(), onConfigAuthComplete, onConfigAuthCancel

module.exports =
  listen: (options) ->
    configRequestRef.auth generateToken(), onConfigAuthComplete, onConfigAuthCancel