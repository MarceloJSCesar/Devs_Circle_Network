const functions = require("firebase-functions");
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);

// Me marcelo , just to notice you , I'm getting error when executing firebase deploy --only fucntions

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.onCreateFollower = functions.firestore.document(`/followers/${userId}/followers/${followerId}`).onCreate(async(snap, context) => {
    console.log(`Follower Created: ${snap.data()}`);
    const userId = context.params.userId;
    const followerId = context.params.followerId;

    // 1) create followed users posts reference
    const followedUserPostsRef = admin.firestore().collection('usersPosts').doc(userId).collection('userPosts');

    // 2) created following user's timeline reference
    const timelinePostsRef = admin.firestore().collection('timeline').doc(followerId).collection('timelinePosts');

    // 3) get followed users posts
    const querysnapshot = await followedUserPostsRef.get();

    // 4) add each user post to following user's timeline
    querysnapshot.forEach(doc => {
        if(doc.exists){
          const postId = doc.id;
          const postData = doc.data();
          print(`Doc: ${doc} and postData: ${postData}`);
          timelinePostsRef.doc(postId).set(postData);
        }
    });
});
