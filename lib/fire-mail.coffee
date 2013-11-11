Firebase = require 'firebase'
FirebaseTokenGenerator = require 'firebase-token-generator'
tokenGenerator = new FirebaseTokenGenerator(process.env.FIREBASE_SECRET)
token = tokenGenerator.createToken({username: "admin"})
contactRequestRef = new Firebase(process.env.FIREBASE_URI  + '/contactRequest')

onAuthComplete = (err, auth) ->
  if err
    console.log 'auth error ' + err
  else
    console.log 'auth sucessful'
    console.log auth

    contactRequestRef.on 'child_added', (snapshot) ->
      console.log 'Someone added a record'
      console.log snapshot

onAuthCancel = (err) ->
  console.log 'auth cancelled ' + err
  console.log 'trying auth'
  contactRequestRef.auth token, onAuthComplete, onAuthCancel

module.exports =
  listen: () ->
    contactRequestRef.auth token, onAuthComplete, onAuthCancel