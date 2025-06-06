/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
const { Timestamp } = require('firebase-admin/firestore');

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
admin.initializeApp();
const db = admin.firestore();

exports.createListing = onRequest(async (req, res) => {
    try {
        const data = req.body;

        if (!data.userID) {
            return res.status(400).send("Missing userID");
        }

        const doc = await db.collection("listings").add({
            ...data,
            createdAt: new Date() // optional: timestamp
        });

        res.status(200).send({ id: doc.id });
    } catch (e) {
        res.status(500).send("Error: " + e.message);
    }
});

exports.getListings = onRequest(async (req, res) => {
    try {
        const snapshot = await db.collection("listings").get();
        const listings = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(listings);
    } catch (e) {
        res.status(500).send("Error: " + e.message);
    }
  });

exports.getUserListings = onRequest(async (req, res) => {
    const userID = req.query.userID;
    if (!userID) {
      return res.status(400).json({ error: "Missing userID" });
    }
  
    try {
      const snapshot = await db
        .collection("listings")
        .where("userID", "==", userID)
        .get();
  
        const listings = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(listings);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

exports.getUserEmail = onRequest(async (req, res) => {
    const userID = req.query.userID;
    if (!userID) {
        return res.status(400).send("Missing userID");
    }

    try {
        const userRecord = await admin.auth().getUser(userID);
        const email = userRecord.email;
        res.status(200).json({ email });
    } catch (e) {
        res.status(500).send("Error fetching user: " + e.message);
    }
});

exports.getUserName = onRequest(async (req, res) => {
    const userID = req.query.userID;
    if (!userID) {
        return res.status(400).send("Missing userID");
    }

    try {
        const userRecord = await admin.auth().getUser(userID);
        const name = userRecord.displayName;
        res.status(200).json({ name });
    } catch (e) {
        res.status(500).send("Error fetching user: " + e.message);
    }
});

exports.deleteListing = onRequest(async (req, res) => {
    const id = req.query.id;
    if (!id) {
        return res.status(400).send("Missing listing ID");
    }

    try {
        const listingRef = db.collection("listings").doc(id);
        const listingSnap = await listingRef.get();

        if (!listingSnap.exists) {
            return res.status(404).send("Listing not found");
        }

        const listingData = listingSnap.data();
        const storageID = listingData.storageID; // 🔥 you stored this earlier

        if (!storageID) {
            console.log("No storageID found, deleting document only.");
            await listingRef.delete();
            return res.status(200).send("Listing deleted without images");
        }

        // Delete images in Firebase Storage under /listings/{storageID}/
        const bucket = admin.storage().bucket();
        const folder = `listings/${storageID}`;

        // List all files in the folder
        const [files] = await bucket.getFiles({ prefix: folder });

        const deletePromises = files.map(file => file.delete());
        await Promise.all(deletePromises);

        console.log(`Deleted ${files.length} images from storage folder ${folder}`);

        // Now delete the listing document
        await listingRef.delete();

        res.status(200).send("Listing and images deleted successfully");

    } catch (e) {
        console.error("Error deleting listing:", e);
        res.status(500).send("Error: " + e.message);
    }
});

exports.updateListing = onRequest(async (req, res) => {
    console.log("Received updateListing request with body:", JSON.stringify(req.body));

    try {
        const {
            id,
            userID,
            title,
            price,
            address,
            latitude,
            longitude,
            totalNumberOfBedrooms,
            totalNumberOfBathrooms,
            totalSquareFootage,
            numberOfBedroomsAvailable,
            startDateAvailible,
            lastDateAvailible,
            description,
            storageID
        } = req.body;

        if (!id || !userID) {
            console.error("Missing id or userID in request body");
            return res.status(400).send("Missing id or userID");
        }

        const listingRef = db.collection("listings").doc(id);
        console.log("Fetched listing reference for ID:", id);

        const listingDoc = await listingRef.get();
        console.log("Fetched listing document. Exists:", listingDoc.exists);

        if (!listingDoc.exists) {
            console.error("Listing not found for ID:", id);
            return res.status(404).send("Listing not found");
        }

        const listingData = listingDoc.data();
        console.log("Listing document data:", listingData);

        if (listingData.userID !== userID) {
            console.error(`Unauthorized update attempt. Owner: ${listingData.userID}, Requestor: ${userID}`);
            return res.status(403).send("Unauthorized");
        }

        console.log("Updating listing with new data...");
        await listingRef.update({
            title,
            price,
            address,
            latitude,
            longitude,
            totalNumberOfBedrooms, 
            totalNumberOfBathrooms,
            totalSquareFootage,
            numberOfBedroomsAvailable,
            startDateAvailible: startDateAvailible,
            lastDateAvailible: lastDateAvailible,
            description,
            storageID,
        });
        

        console.log("Listing updated successfully for ID:", id);
        res.status(200).send("Listing updated successfully");
    } catch (error) {
        console.error("Error occurred during updateListing:", error);
        res.status(500).send("Internal Server Error: " + error.message);
    }
});
