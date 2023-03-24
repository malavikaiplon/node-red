const express = require("express");
const mongoose = require ("mongoose");
const MongoClient = require("mongodb").MongoClient;

const app = express();
const uri="mongodb+srv://malavika:iplon321@iploncluster.rrnysbd.mongodb.net/?retryWrites=true&w=majority"
const client = new MongoClient(uri);

async function run() {

    try {
  
      const database = client.db("iplondb");
  
      const collection = database.collection("iplon_test");
  
      // create a filter for a movie to update
  
      const filter = {status:"Remote "};
  
      // this option instructs the method to create a document if no documents match the filter
  
      //const options = { upsert: true };
  
      // create a document that sets the plot of the movie
  
      const updateDoc = {
  
        $set: {
  
          status: "Away"
  
        },
  
      };
  
      const result = await collection.updateMany(filter, updateDoc);

    console.log(`Updated ${result.modifiedCount} documents`);

  } finally {

    await client.close();

  }

}

run().catch(console.dir);
