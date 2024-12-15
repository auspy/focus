"use server";
import { getMongoClient } from "../../adapters/mongodb";

export default async function storeSearchResults({ store }) {
  try {
    if (!store) {
      throw new Error("store is required");
    }
    store.created_at = new Date();
    const input = await (await getMongoClient())
      .collection("search")
      .insertOne(store);
    console.log("inserted search to mdb=>", input);
    return true;
  } catch (error) {
    console.error(error, "error in storeSearchResults.js");
  }
}
