const express = require("express");
const mongoose = require ("mongoose");
const MongoClient = require("mongodb").MongoClient;

const app = express();
const uri="mongodb+srv://malavika:iplon321@iploncluster.rrnysbd.mongodb.net/?retryWrites=true&w=majority"
const client = new MongoClient(uri);

// Add a query that returns all the documents in the database
async function run() {

    try {
  
      const database = client.db("iplondb");
  
      const collection = database.collection("iplon_test");

      const findResult = await collection.find({}).toArray();
      console.log('Found documents =>', findResult);
      
    } finally {
  
        await client.close();
      
      }
      
      }
      
      run().catch(console.dir);

// Add a query filter to find only documents which meet the query criteria.
/*async function run() {

    try {
  
      const database = client.db("iplondb");
  
      const collection = database.collection("iplon_test");


      const filteredDocs = await collection.find({ status: "Away"}).toArray();
    console.log('Found documents filtered by {status: "Away"}} =>', filteredDocs);
} finally {
  
    await client.close();
  
  }
  
  }
  
  run().catch(console.dir);*/