/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

//CloudFunctionsに送る関数
exports.pushTalk = functions.https.onCall(async (data, _response) => {
  const title = data.title;  //通知のタイトル
  const body = data.body;　　//通知の内容
  const token = data.token;　//送り先のトークン

　//通知の内容を作る処理
  const message = {
    notification: {
      title: title,
      body: body
    },
    data: {
      title: title,
      body: body
    },
    android: { 　　//androidの設定
      notification: {
        sound: 'default',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
    },
    apns: {　　　　//iOSの設定
      payload: {
        aps: {
          badge: 1,
          sound: 'default'
        },
      },
    },
    token: token
  };
  pushToDevice(token, message);   //push通知を送る関数に内容を載せて実行
});

//push通知を送る関数
function pushToDevice(token, payload) {
  admin.messaging().send(payload)
    .then(_pushResponse => {
      return {
        text: token
      };
    })
    .catch(error => {
      throw new functions.https.HttpsError('unknown', error.message, error);
    });
}