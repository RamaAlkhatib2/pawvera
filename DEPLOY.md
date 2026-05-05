Deployment & Local Development

1) Flutter setup

```bash
flutter pub get
```

2) Firebase rules & indexes deploy

```bash
# deploy firestore rules and storage rules
firebase deploy --only firestore:rules,storage

# deploy indexes
firebase deploy --only firestore:indexes
```

3) Functions

```bash
cd functions
npm install
firebase deploy --only functions
```

4) Emulator (recommended for testing everything locally)

```bash
firebase emulators:start
```
