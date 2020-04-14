import { Elm } from './Main.elm'
import { Encryptor, Decryptor, Buffer, WordArray, hash } from 'triplesec'
import firebase from 'firebase/app'
import _ from 'firebase/database'
import firebaseConfig from './firebase.js'

const sha3 = new hash.SHA3

function makeHash(word) {
  return sha3.update(WordArray.from_buffer(new Buffer(word))).finalize().to_hex()
}

firebase.initializeApp(firebaseConfig)

const db = firebase.database()

const app = Elm.Main.init({
  node: document.querySelector('main')
})

app.ports.makeLogin.subscribe((data) => {
  app.ports.sendUserHash.send(
    makeHash(`${makeHash(data.username)}:${makeHash(data.password)}`)
  )
})