PawVera Cloud Functions

Quick start:

1. Install dependencies

```bash
cd functions
npm install
```

2. Run emulator (recommended for local testing)

```bash
firebase emulators:start --only functions,firestore,auth
```

3. Deploy to Firebase

```bash
firebase deploy --only functions
```

Notes:
- `index.js` contains starter handlers: `onAuthCreate`, `onRequestCreate`, `onBookingCreate`, and a callable `createPet`.
- Use the Firebase Emulator Suite for integration testing before deploying to dev/staging/prod.
