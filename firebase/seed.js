const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();
const db = admin.firestore();

const TEACHER = {
  email: "prof@episign.test",
  password: "EpiSign2024!",
  displayName: "Dr. Martin",
  role: "teacher",
};

const STUDENT = {
  email: "etudiant@episign.test",
  password: "EpiSign2024!",
  displayName: "Alice Dupont",
  role: "student",
};

async function createOrGetUser(config) {
  try {
    const existing = await auth.getUserByEmail(config.email);
    console.log(`✅ User already exists: ${config.email} (${existing.uid})`);
    return existing;
  } catch {
    const user = await auth.createUser({
      email: config.email,
      password: config.password,
      displayName: config.displayName,
    });
    console.log(`✅ Created user: ${config.email} (${user.uid})`);
    return user;
  }
}

async function setRole(uid, role) {
  await auth.setCustomUserClaims(uid, { role });
  await db.collection("users").doc(uid).set(
    { role, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
    { merge: true }
  );
  console.log(`✅ Role "${role}" set for uid: ${uid}`);
}

async function createLectures(teacherId, studentId) {
  // Delete existing lectures first
  const existing = await db.collection("lectures").get();
  const batch = db.batch();
  existing.forEach(doc => batch.delete(doc.ref));
  await batch.commit();

  const now = new Date();
  
  // 1. Lecture en cours (CHECK-IN OPEN)
  const lecture1 = db.collection("lectures").doc();
  await lecture1.set({
    title: "Probabilités et statistique",
    subject: "DEV2_1",
    room: "Amphi A",
    teacherId,
    studentIds: [studentId],
    scheduledAt: admin.firestore.Timestamp.fromDate(now),
  });

  // 2. Lecture à venir aujourd'hui (UPCOMING)
  const lecture2 = db.collection("lectures").doc();
  const laterToday = new Date(now.getTime() + 2 * 60 * 60 * 1000); // +2h
  await lecture2.set({
    title: "Intelligence Artificielle",
    subject: "DEV2_1",
    room: "Room 402B",
    teacherId,
    studentIds: [studentId],
    scheduledAt: admin.firestore.Timestamp.fromDate(laterToday),
  });

  // 3. Lecture demain (UPCOMING)
  const lecture3 = db.collection("lectures").doc();
  const tomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000); // +24h
  await lecture3.set({
    title: "Architecture Réseaux",
    subject: "DEV2_1",
    room: "Cisco Lab",
    teacherId,
    studentIds: [studentId],
    scheduledAt: admin.firestore.Timestamp.fromDate(tomorrow),
  });

  console.log("✅ Lectures initialized: 1 Open, 2 Upcoming");
}

async function main() {
  console.log("\n🚀 EPISIGN — Seeding Firebase...\n");

  const teacher = await createOrGetUser(TEACHER);
  const student = await createOrGetUser(STUDENT);

  await setRole(teacher.uid, "teacher");
  await setRole(student.uid, "student");

  await createLectures(teacher.uid, student.uid);

  console.log("\n───────────────────────────────────────");
  console.log("📋 Test credentials:");
  console.log(`   Teacher  → ${TEACHER.email} / ${TEACHER.password}`);
  console.log(`   Student  → ${STUDENT.email} / ${STUDENT.password}`);
  console.log("───────────────────────────────────────\n");

  process.exit(0);
}

main().catch((err) => {
  console.error("❌ Seed failed:", err);
  process.exit(1);
});
