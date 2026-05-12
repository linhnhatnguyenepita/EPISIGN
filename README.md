# EPISIGN - NFC Attendance Tracking

EPISIGN est une application mobile permettant de gérer la présence des étudiants via des tags NFC et des QR Codes.

## 🚀 Installation & Configuration (Mac)

Le projet utilise Firebase pour l'authentification et la base de données. Pour des raisons de sécurité, certains fichiers ne sont pas inclus dans le dépôt Git.

### 1. Fichier de Configuration Firebase
Demandez le fichier `GoogleService-Info.plist` à l'administrateur du projet.
*   Ouvrez le projet dans Xcode.
*   Glissez-collez le fichier `GoogleService-Info.plist` dans le dossier racine du projet `EPISIGN` au sein de Xcode.

### 2. Dépendances Swift Package Manager
Vérifiez que les packages suivants sont correctement liés à la cible `EPISIGN` :
*   `FirebaseAuth`
*   `FirebaseFirestore`
*   `FirebaseFunctions`

### 3. Capacités NFC
*   Sélectionnez la cible **EPISIGN** dans Xcode.
*   Allez dans l'onglet **Signing & Capabilities**.
*   Vérifiez que la capacité **Near Field Communication Tag Reading** est bien présente.

## 📱 Utilisation & Tests

> [!IMPORTANT]
> **Le NFC ne fonctionne pas sur simulateur.** Vous devez utiliser un iPhone physique pour tester la lecture et l'écriture des tags.

### Identifiants de test
Utilisez ces comptes pour tester les deux interfaces :

| Rôle | Email | Mot de passe |
| :--- | :--- | :--- |
| **Professeur** | `prof@episign.test` | `EpiSign2024!` |
| **Étudiant** | `etudiant@episign.test` | `EpiSign2024!` |

## 🛠 Structure du projet
*   `AppState.swift` : Gestion globale de l'authentification et des rôles.
*   `NFCReaderService.swift` / `NFCWriterService.swift` : Logique de communication NFC.
*   `FirebaseFunctionsService.swift` : Appels aux Cloud Functions pour le démarrage de session et le check-in.