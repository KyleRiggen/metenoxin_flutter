// import 'package:cloud_firestore/cloud_firestore.dart';

// class FirebaseService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   Future<void> saveListMap_challengers({
//     required List<Map<String, dynamic>> data,
//     required String region,
//   }) async {
//     try {
//       // Initialize a batch
//       WriteBatch batch = _firestore.batch();

//       // Create a single document to store all entries
//       final docRef = _firestore.collection("challengers").doc(region);

//       // Add all entries as a field under this document
//       batch.set(docRef, {
//         "region_in_batch": data,
//       });

//       // Commit the batch (single write operation)
//       await batch.commit();
//     } catch (e) {
//       throw Exception('Error saving challenger data to Firestore: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> getChallengers({
//     required String region,
//   }) async {
//     try {
//       // Get the document reference for the specific region
//       final docRef = _firestore.collection("challengers").doc(region);
//       final docSnapshot = await docRef.get();

//       // Check if the document exists
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data() as Map<String, dynamic>;
//         final challengersData = data["region_in_batch"];

//         // If the challengers data exists, return it
//         if (challengersData != null) {
//           return List<Map<String, dynamic>>.from(challengersData);
//         } else {
//           throw Exception("Challenger data not found in Firestore.");
//         }
//       } else {
//         throw Exception("Region document does not exist in Firestore.");
//       }
//     } catch (e) {
//       throw Exception('Error reading challenger data from Firestore: $e');
//     }
//   }

//   Future<void> savePuuids({
//     required List<Map<String, String>> puuids,
//   }) async {
//     try {
//       // Get the document reference for the region
//       final docRef = _firestore.collection("players").doc("puuids");

//       // Save the PUUIDs as a field in the document
//       await docRef.set({
//         "puuids": puuids,
//       });
//     } catch (e) {
//       throw Exception('Error saving PUUIDs to Firestore: $e');
//     }
//   }

//   Future<List<Map<String, String>>> getPuuids() async {
//     try {
//       // Get the document reference for the PUUIDs
//       final docRef = _firestore.collection("players").doc("puuids");
//       final docSnapshot = await docRef.get();

//       // Check if the document exists
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data() as Map<String, dynamic>;

//         // Extract the "puuids" field
//         final puuidsData = data["puuids"];

//         // Ensure the "puuids" field is not null and is a List
//         if (puuidsData != null && puuidsData is List) {
//           // Convert each entry to Map<String, String>
//           return puuidsData.map<Map<String, String>>((entry) {
//             final entryMap =
//                 Map<String, String>.from(entry as Map<String, dynamic>);
//             return entryMap;
//           }).toList();
//         } else {
//           throw Exception("Field 'puuids' is missing or not a list.");
//         }
//       } else {
//         throw Exception("Document 'puuids' does not exist in Firestore.");
//       }
//     } catch (e) {
//       throw Exception('Error reading PUUIDs from Firestore: $e');
//     }
//   }

//   Future<void> saveMatchIds({
//     required List<String> matchIds,
//   }) async {
//     try {
//       // Get the document reference for the match IDs
//       final docRef = _firestore.collection("players").doc("matchIds");

//       // Save the match IDs as a field in the document
//       await docRef.set({
//         "matchIds": matchIds,
//       });
//     } catch (e) {
//       throw Exception('Error saving match IDs to Firestore: $e');
//     }
//   }

//   Future<List<String>> getMatchIds() async {
//     try {
//       // Get the document reference for the match IDs
//       final docRef = _firestore.collection("players").doc("matchIds");
//       final docSnapshot = await docRef.get();

//       // Check if the document exists
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data() as Map<String, dynamic>;

//         // Extract the "matchIds" field
//         final matchIdsData = data["matchIds"];

//         // Ensure the "matchIds" field is not null and is a List
//         if (matchIdsData != null && matchIdsData is List) {
//           return List<String>.from(matchIdsData);
//         } else {
//           throw Exception("Field 'matchIds' is missing or not a list.");
//         }
//       } else {
//         throw Exception("Document 'matchIds' does not exist in Firestore.");
//       }
//     } catch (e) {
//       throw Exception('Error retrieving match IDs from Firestore: $e');
//     }
//   }

//   Future<void> saveCompared({
//     required List<Map<String, dynamic>> data,
//   }) async {
//     try {
//       // Reference to the main document
//       final docRef = _firestore.collection("new-style-champs").doc("compared");

//       // Save the list and metadata to the document
//       await docRef.set({
//         "metadata": "Champ data collection",
//         "savedAt": FieldValue.serverTimestamp(), // Add server timestamp
//         "data": data, // Store the entire list as a field
//       });
//     } catch (e) {
//       throw Exception('Error saving champion data to Firestore: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> getCompared() async {
//     try {
//       // Reference to the document
//       final docRef = _firestore.collection("new-style-champs").doc("compared");

//       // Fetch the document
//       final docSnapshot = await docRef.get();

//       if (docSnapshot.exists) {
//         // Extract the 'data' field from the document
//         final data = docSnapshot.data()?['data'];
//         if (data != null && data is List) {
//           return List<Map<String, dynamic>>.from(data);
//         } else {
//           throw Exception('No valid data field found in the document.');
//         }
//       } else {
//         throw Exception('Document does not exist.');
//       }
//     } catch (e) {
//       throw Exception('Error retrieving champion data from Firestore: $e');
//     }
//   }

//   Future<void> saveListMap_setup({
//     required List<Map<String, dynamic>> data,
//     required String document,
//   }) async {
//     try {
//       // Reference to the main document
//       final docRef = _firestore.collection("new-style-champs").doc(document);

//       // Save the list and metadata to the document
//       await docRef.set({
//         "metadata": "Champ data collection",
//         "savedAt": FieldValue.serverTimestamp(), // Add server timestamp
//         "data": data, // Store the entire list as a field
//       });
//     } catch (e) {
//       throw Exception('Error saving champion data to Firestore: $e');
//     }
//   }

//   Future<void> saveIndividualChamps({
//     required List<Map<String, dynamic>> data,
//     required String collectionName,
//   }) async {
//     try {
//       // Reference to the Firestore collection
//       final collectionRef = _firestore.collection(collectionName);

//       for (var champ in data) {
//         // Generate a unique document ID for each champ
//         final champId = champ['name'] ??
//             _firestore
//                 .collection(collectionName)
//                 .doc()
//                 .id; // Use 'id' if provided or auto-generate one.

//         // Save each champ as a separate document
//         await collectionRef.doc(champId).set({
//           ...champ,
//           "savedAt": FieldValue.serverTimestamp(), // Add server timestamp
//         });
//       }
//     } catch (e) {
//       throw Exception('Error saving individual champion data to Firestore: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> fetchIndividualChamps({
//     required String collectionName,
//   }) async {
//     try {
//       // Reference to the Firestore collection
//       final collectionRef = _firestore.collection(collectionName);

//       // Get all documents in the collection
//       final querySnapshot = await collectionRef.get();

//       // Convert each document into a Map<String, dynamic>
//       List<Map<String, dynamic>> champs = querySnapshot.docs.map((doc) {
//         return {
//           "id": doc.id, // Include the document ID
//           ...doc.data(), // Document data
//         };
//       }).toList();

//       return champs;
//     } catch (e) {
//       throw Exception('Error fetching champion data from Firestore: $e');
//     }
//   }

//   // Update a single document in Firestore
//   Future<void> updateDocument({
//     required String collectionName,
//     required String documentId,
//     required Map<String, dynamic> data,
//   }) async {
//     try {
//       // Reference to the document in the collection
//       final docRef = _firestore.collection(collectionName).doc(documentId);

//       // Update the document with new data
//       await docRef.update(data);
//     } catch (e) {
//       throw Exception("Error updating document: $e");
//     }
//   }

//   Future<void> deleteDocument({required String document}) async {
//     try {
//       // Reference to the main document
//       final docRef = _firestore.collection("new-style-champs").doc(document);

//       // Delete the document
//       await docRef.delete();

//       print("Document '$document' successfully deleted from Firestore.");
//     } catch (e) {
//       throw Exception("Error deleting document '$document' from Firestore: $e");
//     }
//   }

//   Future<List<Map<String, dynamic>>> getListMap_setup({
//     required String document,
//   }) async {
//     try {
//       // Reference to the main document
//       final docRef = _firestore.collection("new-style-champs").doc(document);

//       // Get the document snapshot
//       final docSnapshot = await docRef.get();

//       // Retrieve and return the 'data' field as a List<Map<String, dynamic>>
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data()?['data'] as List<dynamic>?;

//         if (data != null) {
//           return List<Map<String, dynamic>>.from(
//             data.map((item) => Map<String, dynamic>.from(item)),
//           );
//         }
//       }

//       return [];
//     } catch (e) {
//       throw Exception('Error retrieving champion data from Firestore: $e');
//     }
//   }

//   Future<List<Map<String, dynamic>>> getListMap_setup_old({
//     required String document,
//   }) async {
//     try {
//       // Reference to the main document
//       final docRef = _firestore.collection("new-style-champs").doc(document);

//       // Get the document snapshot
//       final docSnapshot = await docRef.get();

//       // Retrieve and return the 'data' field as a List<Map<String, dynamic>>
//       if (docSnapshot.exists) {
//         final data = docSnapshot.data()?['data'] as List<dynamic>?;

//         if (data != null) {
//           return List<Map<String, dynamic>>.from(
//             data.map((item) => Map<String, dynamic>.from(item)),
//           );
//         }
//       }

//       return [];
//     } catch (e) {
//       throw Exception('Error retrieving champion data from Firestore: $e');
//     }
//   }
// }
