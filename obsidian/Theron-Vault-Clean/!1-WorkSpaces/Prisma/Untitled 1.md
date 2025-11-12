const fs = require('fs');
const path = require('path');

const schemaDir = './schemas';
const outputSchemaFile = './prisma/schema.prisma';

fs.readdir(schemaDir, (err, files) => {
  if (err) {
    console.error('Could not list the directory.', err);
    process.exit(1);
  }

  let fullSchema = '';
  files.forEach((file, index) => {
    const schema = fs.readFileSync(path.join(schemaDir, file), 'utf8');
    fullSchema += schema + '\n';
  });

  fs.writeFileSync(outputSchemaFile, fullSchema);
});


model LeagueSeasonList {
  id String @id @default(cuid())
  leagueId String
  league League @relation(fields: [leagueId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  seasonId String
  season LeagueSeason @relation(fields: [seasonId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model LeagueSeasonTeamList {
  id String @id @default(cuid())
  leagueId String
  league League @relation(fields: [leagueId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  seasonId String
  season LeagueSeason @relation(fields: [seasonId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  teamId String
  team LeagueTeam @relation(fields: [teamId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model LeaguePlayer {
  id String @id @default(cuid())
  userId String
  user User @relation(fields: [userId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  teamId String
  team LeagueTeam @relation(fields: [teamId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model LeaguePlayerAllTimeRecord {
  id String @id @default(cuid())
  playerId String
  player LeaguePlayer @relation(fields: [playerId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
}

model LeaguePlayerSeasonRecord {
  id String @id @default(cuid())
  playerId String
  player LeaguePlayer @relation(fields: [playerId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  seasonId String
  season LeagueSeason @relation(fields: [seasonId], references: [id], onUpdate: Cascade, onDelete: Cascade)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

}