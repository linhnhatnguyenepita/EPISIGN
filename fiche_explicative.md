# Fiche technique — EPISIGN

## Vue d'ensemble

EPISIGN est une application iOS native de gestion des présences pour EPITA. Elle remplace les feuilles de présence papier par un protocole NFC / QR Code sécurisé, avec signature manuscrite numérique. L'application distingue deux rôles : enseignant (ouvre une session) et étudiant (signe sa présence).

---

## Technologies utilisées

| Domaine | Technologie |
|---|---|
| UI | SwiftUI |
| NFC | CoreNFC |
| Caméra / QR scan | AVFoundation |
| Génération QR code | CoreImage |
| Notifications locales | UserNotifications |
| Animations | DotLottie (Swift package) |
| Typographie | Bricolage Grotesque, DM Sans |

La seule dépendance externe est **DotLottie**, utilisée pour l'animation de l'écran de connexion. Toutes les autres fonctionnalités reposent sur des frameworks Apple natifs.

---

## Features

### Authentification
- Formulaire email / mot de passe
- Animation Lottie sur l'écran de connexion

### Emploi du temps
- Timeline verticale des cours du jour
- Trois statuts visuellement distincts : **CHECK-IN OPEN** (vert), **UPCOMING** (navy), **COMPLETED** (gris)
- Chaque cours affiche : titre, enseignant, salle, groupe, plage horaire
- Côté étudiant, seul un cours dont le check-in est ouvert est accessible

### Session de signature (enseignant)
- Écriture de l'identifiant de session sur un tag NFC en salle
- Compte à rebours de 10 minutes visible en temps réel
- QR code de secours affichable si le NFC est indisponible
- Notification locale envoyée à l'expiration de la session
- Annulation possible à tout moment

### Signature de présence (étudiant)
- Lecture du tag NFC pour valider la présence
- Fallback QR code (caméra live) si NFC indisponible
- Pad de signature manuscrite à compléter avant soumission
- Toast de confirmation après soumission

---

## Schéma de base de données

### Tables

#### `users`
```
users
├── id          UUID        PK
├── email       TEXT        UNIQUE NOT NULL
├── name        TEXT        NOT NULL
├── role        ENUM        ('student', 'teacher')
├── group_id    UUID        FK → groups.id  (NULL pour les enseignants)
└── created_at  TIMESTAMP
```

#### `groups`
```
groups
├── id      UUID    PK
└── name    TEXT    UNIQUE NOT NULL   -- ex: "DEV2_1"
```

#### `lectures`
```
lectures
├── id          UUID        PK
├── title       TEXT        NOT NULL
├── teacher_id  UUID        FK → users.id
├── group_id    UUID        FK → groups.id
├── room        TEXT
├── start_time  TIMESTAMP   NOT NULL
└── end_time    TIMESTAMP   NOT NULL
```

#### `sessions`
Représente une session de signature ouverte par un enseignant pour un cours donné.

```
sessions
├── id              UUID        PK
├── lecture_id      UUID        FK → lectures.id
├── nfc_token       TEXT        UNIQUE NOT NULL   -- UUID écrit sur le tag NFC
├── qr_token        TEXT        UNIQUE NOT NULL   -- UUID encodé dans le QR code
├── opened_at       TIMESTAMP   NOT NULL
├── expires_at      TIMESTAMP   NOT NULL          -- opened_at + 10 min
└── cancelled_at    TIMESTAMP   NULL              -- NULL si toujours active
```

> `nfc_token` et `qr_token` sont distincts pour pouvoir invalider chaque canal indépendamment.

#### `attendances`
```
attendances
├── id              UUID        PK
├── session_id      UUID        FK → sessions.id
├── student_id      UUID        FK → users.id
├── check_in_method ENUM        ('nfc', 'qr')
├── signature_data  BYTEA       -- tracé sérialisé (points SVG ou PNG)
├── signed_at       TIMESTAMP   NOT NULL
└── UNIQUE (session_id, student_id)   -- un étudiant signe une seule fois par session
```

### Relations

```
groups ──< users (students)
users (teacher) ──< lectures
groups ──< lectures
lectures ──< sessions
sessions ──< attendances >── users (students)
```

### Règles métier côté backend

1. **Unicité** : un étudiant ne peut pas signer deux fois la même session — contrainte `UNIQUE (session_id, student_id)`.
2. **Validité temporelle** : vérifier que `NOW() < expires_at` et `cancelled_at IS NULL` avant tout enregistrement.
3. **Appartenance au groupe** : vérifier que l'étudiant appartient bien au groupe du cours avant d'enregistrer sa présence.
4. **Token QR à usage unique** : invalider le `qr_token` après une première utilisation validée pour éviter le partage entre étudiants.
