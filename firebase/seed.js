const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const auth = admin.auth();
const db = admin.firestore();

const TEACHERS = [
  {
    email: "prof.martin@episign.test",
    password: "EpiSign2024!",
    displayName: "Dr. Martin",
    role: "teacher",
  },
  {
    email: "prof.dubois@episign.test",
    password: "EpiSign2024!",
    displayName: "Pr. Dubois",
    role: "teacher",
  },
  {
    email: "prof.laurent@episign.test",
    password: "EpiSign2024!",
    displayName: "Dr. Laurent",
    role: "teacher",
  },
];

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

async function setRole(uid, role, displayName) {
  await auth.setCustomUserClaims(uid, { role });
  await db.collection("users").doc(uid).set(
    { role, displayName, updatedAt: admin.firestore.FieldValue.serverTimestamp() },
    { merge: true }
  );
  console.log(`✅ Role "${role}" set for uid: ${uid}`);
}

function atHourToday(hour, minute = 0) {
  const d = new Date();
  d.setHours(hour, minute, 0, 0);
  return d;
}

async function createLectures(teacherIds, studentId) {
  const existing = await db.collection("lectures").get();
  const batch = db.batch();
  existing.forEach(doc => batch.delete(doc.ref));
  await batch.commit();

  const lectures = [
    {
      title: "Probabilités et statistique",
      subject: "DEV2_1",
      room: "Amphi A",
      teacherIndex: 0,
      scheduledAt: atHourToday(10, 40),
      durationMinutes: 120,
    },
    {
      title: "Intelligence Artificielle",
      subject: "DEV2_1",
      room: "Room 402B",
      teacherIndex: 1,
      scheduledAt: atHourToday(13, 0),
      durationMinutes: 120,
    },
    {
      title: "Architecture Réseaux",
      subject: "DEV2_1",
      room: "Cisco Lab",
      teacherIndex: 2,
      scheduledAt: atHourToday(16, 0),
      durationMinutes: 90,
    },
  ];

  for (const lecture of lectures) {
    const ref = db.collection("lectures").doc();
    await ref.set({
      title: lecture.title,
      subject: lecture.subject,
      room: lecture.room,
      teacherId: teacherIds[lecture.teacherIndex],
      teacherName: TEACHERS[lecture.teacherIndex].displayName,
      studentIds: [studentId],
      scheduledAt: admin.firestore.Timestamp.fromDate(lecture.scheduledAt),
      durationMinutes: lecture.durationMinutes,
    });
  }

  console.log(`✅ Lectures initialized: ${lectures.length} sessions across the day`);
}

async function main() {
  console.log("\n🚀 EPISIGN — Seeding Firebase...\n");

  const teachers = [];
  for (const t of TEACHERS) {
    const user = await createOrGetUser(t);
    await setRole(user.uid, "teacher", t.displayName);
    teachers.push(user);
  }

  const student = await createOrGetUser(STUDENT);
  await setRole(student.uid, "student", STUDENT.displayName);

  await createLectures(teachers.map(t => t.uid), student.uid);

  console.log("\n───────────────────────────────────────");
  console.log("📋 Test credentials:");
  TEACHERS.forEach(t => {
    console.log(`   Teacher  → ${t.email} / ${t.password}  (${t.displayName})`);
  });
  console.log(`   Student  → ${STUDENT.email} / ${STUDENT.password}`);
  console.log("───────────────────────────────────────\n");

  process.exit(0);
}

main().catch((err) => {
  console.error("❌ Seed failed:", err);
  process.exit(1);
});
