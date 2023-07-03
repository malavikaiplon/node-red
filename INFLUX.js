const http = require('http');
const { InfluxDB, Point } = require('@influxdata/influxdb-client');


/**
* Environment variables
*/
const port = "3011";
const q1_get_req_url = "/api/grafana-api-server-influxdb/q1-get";
const q1_get_influx_query = 'from(bucket: "grafana") |> range(start: -1h)';
const q1_post_req_url = "/api/grafana-api-server-influxdb/q1-post";

const INFLUXDB_URL = "http://localhost:8086";
const INFLUXDB_TOKEN = "brAL09ULE767r5Hr_kAoezz2fFDimwuzUbF48cyprBI-KwTERsaK-qtPm306FZyGOMGi-zESOgxHbR1Pvf_QWQ==";
const INFLUXDB_ORG = "iplon";
const INFLUXDB_BUCKET = "test";

/**
* Create InfluxDB client
*/
const influxDB = new InfluxDB({
 url: INFLUXDB_URL,
 token: INFLUXDB_TOKEN,
});

/**
* Cre ate   Server
*/
const server = http.createServer(async function (req, res) {
 /**
  * Set CORS headers
  */
 res.setHeader('Access-Control-Allow-Origin', '*');
 res.setHeader('Access-Control-Request-Method', '*');
 res.setHeader('Access-Control-Allow-Methods', 'OPTIONS, GET, POST, PUT, PATCH');
 res.setHeader('Access-Control-Allow-Headers', '*');
 if (req.method === 'OPTIONS') {
    res.writeHead(200);
   res.end();
   return;
 }

 // print URL
 console.log(req.url);

 /**
  * GET
  */
 if (req.method === 'GET') {
   /**
    * Get values from InfluxDB
    */
   // q1 GET FEEDBACKS
   if (q1_get_req_url.indexOf(req.url)) {
     influxDB
       .queryRows(q1_get_influx_query, { org: INFLUXDB_ORG, bucket: INFLUXDB_BUCKET })
       .then((result) => {
         const values = [];
         result.forEach((row) => {
           const value = row['_value'];
           values.push(value);
         });

         res.writeHead(200, { 'Content-Type': 'application/json' });
         res.write(JSON.stringify(values));
         res.end();

         console.log('Requested', values);
         console.log('q1_get_req_url InfluxDB query completed successfully!');
       })
       .catch((err) => {
         console.error('Error in q1_get_req_url InfluxDB query:', err);
       });
   }
 }

 /**
  * POST, PUT or PATCH
  */
 if (req.method === 'POST' || req.method === 'PUT' || req.method === 'PATCH') {
   let body = '';
   req.on('data', function (chunk) {
     body += chunk;
   });

   req.on('end', async function () {
     res.writeHead(200, { 'Content-Type': 'text/plain' });
     res.write(`${req.method}: Success!`);
     res.end();

     const values = JSON.parse(body);
     console.log('Updated', values);

     /**
      * Write data to InfluxDB
      */
     // q1 POST FEEDBACKS
     if (req.url === q1_post_req_url) {
       const writeApi = influxDB.getWriteApi(INFLUXDB_ORG, INFLUXDB_BUCKET);
       const point = new Point('feedbacks')
         .tag('plant', values['PLANT'])
         .tag('device', values['DEVICE'])
         .tag('field', values['FIELD'])
         .floatField('value', values['VALUE'])
         .timestamp(new Date());

       writeApi.writePoint(point);
       writeApi
         .close()
         .then(() => {
           console.log('q1_post_req_url InfluxDB write completed successfully!');
         })
         .catch((err) => {
           console.error('Error in q1_post_req_url InfluxDB write:', err);
         });
     }
   });
 }
});

/**
* Listen on port
*/
server.listen(port);
console.log(`Server for InfluxDB is running on port ${port}...`);