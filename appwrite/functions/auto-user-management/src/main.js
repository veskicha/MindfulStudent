import { Client, Databases } from 'node-appwrite';

// ** CONSTANTS **
const ID_DATABASE = 'database';
const ID_COLLECTION_USERS = 'users';

const CREATE_RE = /^users\.\w+\.create$/
const DELETE_RE = /^users\.\w+\.delete$/


const client = new Client()
  .setEndpoint(process.env.APPWRITE_ENDPOINT)
  .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
  .setKey(process.env.APPWRITE_FUNCTION_API_KEY);

const databases = new Databases(client);


export default async ({ req, res, log, error }) => {
  const event = req.headers['x-appwrite-event'];
  const uid = req.body['$id'];
  const name = req.body["name"];

  if (CREATE_RE.test(event)) {
    log(`Creating user document ${uid} for user ${name}`);
  
    const resp = await databases.createDocument(
      ID_DATABASE,
      ID_COLLECTION_USERS,
      uid,
      {
        "username": name
      }
    );
    log(resp);
  } else if (DELETE_RE.test(event)) {
    log(`Deleting user document ${uid}`);
    
    const resp = await databases.deleteDocument(
      ID_DATABASE,
      ID_COLLECTION_USERS,
      uid
    )
    log(resp);
  } else {
    error(`Unknown event: ${event}`);
  }

  return res.empty();
};
