import { Elm } from './Main.elm'
import { Encryptor, Decryptor, Buffer } from 'triplesec'
import firebase from 'firebase/app'
import _ from 'firebase/database'
import firebaseConfig from './firebase.js'

firebase.initializeApp(firebaseConfig)

const db = firebase.database()

Elm.Main.init({
  node: document.querySelector('main')
})
