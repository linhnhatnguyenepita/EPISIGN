const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getAuth } = require("firebase-admin/auth");
const { initializeApp } = require("firebase-admin/app");
const { v4: uuidv4 } = require("uuid");

initializeApp();

const db = getFirestore();
const SESSION_TTL_SECONDS = 600;

exports.startSession = onCall({ region: "europe-west1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Vous devez être connecté.");
  }

  const uid = request.auth.uid;
  const { lectureId } = request.data;

  if (!lectureId) {
    throw new HttpsError("invalid-argument", "lectureId manquant.");
  }

  if (request.auth.token.role !== "teacher") {
    throw new HttpsError("permission-denied", "Seuls les professeurs peuvent démarrer une session.");
  }

  const lectureRef = db.collection("lectures").doc(lectureId);
  const lectureSnap = await lectureRef.get();
  if (!lectureSnap.exists) {
    throw new HttpsError("not-found", "Ce cours n'existe pas.");
  }
  if (lectureSnap.data().teacherId !== uid) {
    throw new HttpsError("permission-denied", "Vous n'êtes pas le professeur de ce cours.");
  }

  const existingSessions = await db
    .collection("sessions")
    .where("lectureId", "==", lectureId)
    .where("active", "==", true)
    .get();

  const batch = db.batch();
  existingSessions.forEach((doc) => batch.update(doc.ref, { active: false }));
  await batch.commit();

  const sessionId = uuidv4();
  const now = new Date();
  const expiresAt = new Date(now.getTime() + SESSION_TTL_SECONDS * 1000);

  await db.collection("sessions").doc(sessionId).set({
    sessionId,
    lectureId,
    createdBy: uid,
    createdAt: FieldValue.serverTimestamp(),
    expiresAt,
    active: true,
  });

  return { sessionId };
});

exports.checkin = onCall({ region: "europe-west1" }, async (request) => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "Vous devez être connecté.");
  }

  const uid = request.auth.uid;
  const { sessionId, lectureId } = request.data;

  if (!sessionId || !lectureId) {
    throw new HttpsError("invalid-argument", "sessionId ou lectureId manquant.");
  }

  if (request.auth.token.role !== "student") {
    throw new HttpsError("permission-denied", "Seuls les étudiants peuvent pointer leur présence.");
  }

  const sessionRef = db.collection("sessions").doc(sessionId);
  const sessionSnap = await sessionRef.get();

  if (!sessionSnap.exists || !sessionSnap.data().active) {
    throw new HttpsError("not-found", "Session introuvable ou expirée. Demandez à votre professeur de redémarrer la session.");
  }

  const sessionData = sessionSnap.data();

  if (sessionData.lectureId !== lectureId) {
    throw new HttpsError("invalid-argument", "Ce tag NFC ne correspond pas à ce cours.");
  }

  const now = new Date();
  const expiresAt = sessionData.expiresAt.toDate();
  if (now > expiresAt) {
    await sessionRef.update({ active: false });
    throw new HttpsError("deadline-exceeded", "La session a expiré (10 minutes). Demandez à votre professeur de redémarrer.");
  }

  const lectureSnap = await db.collection("lectures").doc(lectureId).get();
  if (!lectureSnap.exists) {
    throw new HttpsError("not-found", "Ce cours n'existe pas.");
  }

  const studentIds = lectureSnap.data().studentIds || [];
  if (!studentIds.includes(uid)) {
    throw new HttpsError("permission-denied", "Vous n'êtes pas inscrit à ce cours.");
  }

  const presenceRef = db
    .collection("presence")
    .doc(lectureId)
    .collection("records")
    .doc(uid);

  const presenceSnap = await presenceRef.get();
  if (presenceSnap.exists) {
    return { success: false, message: "Vous avez déjà signé votre présence pour ce cours." };
  }

  await db.runTransaction(async (transaction) => {
    const freshPresence = await transaction.get(presenceRef);
    if (freshPresence.exists) {
      throw new HttpsError("already-exists", "Vous avez déjà signé votre présence pour ce cours.");
    }
    transaction.set(presenceRef, {
      studentId: uid,
      lectureId,
      sessionId,
      checkedInAt: FieldValue.serverTimestamp(),
    });
  });

  return { success: true, message: "Présence enregistrée avec succès !" };
});

exports.setUserRole = onCall({ region: "europe-west1" }, async (request) => {
  if (!request.auth || request.auth.token.role !== "admin") {
    throw new HttpsError("permission-denied", "Accès refusé.");
  }

  const { targetUid, role } = request.data;
  if (!targetUid || !["student", "teacher"].includes(role)) {
    throw new HttpsError("invalid-argument", "targetUid ou rôle invalide.");
  }

  await getAuth().setCustomUserClaims(targetUid, { role });
  await db.collection("users").doc(targetUid).set({ role }, { merge: true });

  return { success: true };
});
