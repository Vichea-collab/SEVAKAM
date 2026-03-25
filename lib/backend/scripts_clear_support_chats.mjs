import { db } from "./src/config/firebase.js";

async function main() {
  const ticketsSnap = await db.collectionGroup("helpTickets").get();
  let ticketCount = 0;
  let messageCount = 0;

  for (const ticketDoc of ticketsSnap.docs) {
    ticketCount += 1;
    const messagesSnap = await ticketDoc.ref.collection("messages").get();
    messageCount += messagesSnap.size;
    await db.recursiveDelete(ticketDoc.ref);
  }

  process.stdout.write("Support chat cleanup complete.\n");
  process.stdout.write(`Deleted tickets: ${ticketCount}\n`);
  process.stdout.write(`Deleted ticket messages: ${messageCount}\n`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Failed to clear support chats:", error);
    process.exit(1);
  });
