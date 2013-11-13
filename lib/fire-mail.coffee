fs = require 'fs'
nconf = require 'nconf'

nconf.file './config.json'

nodemailer = require "nodemailer"
Firebase = require 'firebase'
FirebaseTokenGenerator = require 'firebase-token-generator'

tokenGenerator = new FirebaseTokenGenerator nconf.get('FIREBASE_SECRET')
token = tokenGenerator.createToken({username: "admin"})
contactRequestRef = new Firebase nconf.get('FIREBASE_URI')

transportConfig =
  auth:
    user: nconf.get 'SMTP_USER'
    pass: nconf.get 'SMTP_PASS'

if nconf.get('SMTP_SERVICE')?
  transportConfig.service = nconf.get 'SMTP_SERVICE'
else
  transportConfig.host = nconf.get 'SMTP_HOST'
  transportConfig.port = nconf.get 'SMTP_PORT'

smtpTransport = nodemailer.createTransport "SMTP", transportConfig

generateHTMLEmail = (record) ->
  result = ""
  fields = nconf.get 'MAIL_FIELDS'
  fields.forEach (field) ->
    result = result + "<p>" + field.display + ": " +
    record[field.property] + "</p>"

  result

processRecord = (snapshot) ->
  record = snapshot.val()
  if (record.status isnt 'Failed') and (record.status isnt 'Delivered')
    mailOptions =
      from: nconf.get 'MAIL_FROM'
      to: nconf.get 'MAIL_TO'
      subject: nconf.get 'MAIL_SUBJECT'
      html: generateHTMLEmail record

    smtpTransport.sendMail mailOptions, (err, result) ->
      if err
        snapshot.ref().update {status: 'Failed', message: err}
      else
        snapshot.ref().update {status: 'Delivered', message: result.message}

onAuthComplete = (err, auth) ->
  if err
    console.log 'auth error ' + err
  else
    console.log 'Logged into firebase.'
    console.log 'Waiting paitently...'
    contactRequestRef.on 'child_added', (snapshot) ->
      processRecord snapshot

onAuthCancel = (err) ->
  console.log 'auth cancelled ' + err
  console.log 'retrying auth'
  contactRequestRef.auth token, onAuthComplete, onAuthCancel

module.exports =
  listen: (options) ->
    
    contactRequestRef.auth token, onAuthComplete, onAuthCancel