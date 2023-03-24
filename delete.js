const express = require("express");
const mongoose = require ("mongoose");
const MongoClient = require("mongodb").MongoClient;

const app = express();
const uri="mongodb+srv://malavika:iplon321@iploncluster.rrnysbd.mongodb.net/?retryWrites=true&w=majority"
const client = new MongoClient(uri);
// delete a filter from database
async function run() {

    try {
  
      const database = client.db("iplondb");
  
      const collection = database.collection("iplon_test");
  
  const deleteResult = await collection.deleteMany({ status:"Available" });
  console.log('Deleted documents =>', deleteResult);
  
  } finally {
  
    await client.close();
  
  }
  
  }
  
  run().catch(console.dir);