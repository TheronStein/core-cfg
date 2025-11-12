League

Name: Redemption
Type: CTF
Color: Red

Wads:

Season List:

All Players:


model CTFWad {
  id String @id @default(cuid())
  name String @unique
  maps MapList[]
  createdAt DateTime @createdAt
  updatedAt DateTime @default(now())
}

model DuelWad {
  id String @id @default(cuid())
  name String @unique
  
  createdAt DateTime @createdAt
  updatedAt DateTime @default(now())
  maps MapList[]
}

Int    @id @default(autoincrement())



model WadList {
  id String @id @default(cuid())
  wadId String
  wad WAD @relation(fields: [wadId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model DuelWadList {
  id String @id @default(cuid())
  wadId String
  wadType 
  wad WAD @relation(fields: [wadId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}


model MapList {
  id String @id @default(cuid())
  mapId String
  map Map @relation(fields: [mapId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  wadId String
  wad WAD @relation(fields: [wadId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}
