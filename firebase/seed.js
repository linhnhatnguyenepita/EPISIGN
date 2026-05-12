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

async function createSampleLecture(teacherId, studentId) {
  const lectureRef = db.collection("lectures").doc();
  await lectureRef.set({
    title: "Algorithmique Avancée",
    subject: "INF-301",
    teacherId,
    studentIds: [studentId],
    scheduledAt: admin.firestore.Timestamp.fromDate(new Date()),
  });
  console.log(`✅ Sample lecture created: ${lectureRef.id}`);
  return lectureRef.id;
}

async function main() {
  console.log("\n🚀 EPISIGN — Seeding Firebase...\n");

  const teacher = await createOrGetUser(TEACHER);
  const student = await createOrGetUser(STUDENT);

  await setRole(teacher.uid, "teacher");
  await setRole(student.uid, "student");

  const lectureId = await createSampleLecture(teacher.uid, student.uid);

  console.log("\n───────────────────────────────────────");
  console.log("📋 Test credentials:");
  console.log(`   Teacher  → ${TEACHER.email} / ${TEACHER.password}`);
  console.log(`   Student  → ${STUDENT.email} / ${STUDENT.password}`);
  console.log(`   Lecture  → ${lectureId}`);
  console.log("───────────────────────────────────────\n");

  process.exit(0);
}

main().catch((err) => {
  console.error("❌ Seed failed:", err);
  process.exit(1);
});
