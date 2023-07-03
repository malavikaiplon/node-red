const http = require('http');
const mysql = require('mysql2');

/**
 * Environment variables
 */
const port = "3010"
const q1_get_req_url ="/api/grafana-api-server-mysql/q1-get"
const q1_get_sql_query = "SELECT PLANT, DEVICE, FIELD, VALUE FROM FEEDBACKS WHERE PLANT = ?"
const q1_post_req_url = "/api/grafana-api-server-mysql/q1-post"
const q1_post_sql_query = "INSERT INTO FEEDBACKS(PLANT, DEVICE, FIELD, VALUE) VALUES(?, ?, ?, ?)"
const q1_post_sql_query_values = "PLANT, DEVICE, FIELD, VALUE".split(', ');


const GRAFANA_API_SERVER_MYSQL_HOST="172.17.0.3:3306"
const GRAFANA_API_SERVER_MYSQL_USER="root"
const GRAFANA_API_SERVER_MYSQL_PASSWORD="iplon321"
const GRAFANA_API_SERVER_MYSQL_DB="grafana"
const WAIT_HOSTS="172.17.0.3:3306"
const WAIT_SLEEP_INTERVAL="30"
const WAIT_HOST_CONNECT_TIMEOUT="30"
/**
 * Connect to Mysql
 */

const pool = mysql.createPool({
  host: '172.17.0.3',
  user: 'root',
  password: 'iplon321',
  database: 'grafana',
  namedPlaceholders: true,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});
// check the connection
pool.getConnection((err, connection) => {
if (err) {
    console.error('Error connecting to database:', err);
} else {
    console.log('Database connection successful!');
    connection.release();
}
})

/**
 * Create Server
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

  // print url
  console.log(req.url);

  /**
   * GET
   */
  if (req.method === 'GET') {
    /**
     * Get values from database
     */
    // q1 GET FEEDBACKS
    if (q1_get_req_url.indexOf(req.url)) {
      // define grafana username
      const req_url_PLANT = req.url.split('?')[1];

       pool.query(q1_get_sql_query, [req_url_PLANT], function (err, results) {
        if (err) {
          console.error('Error in q1_get_req_url sql query: ' + err.stack);
          return;
        }

        const values = results[0];

        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.write(JSON.stringify(values));
        res.end();

        console.log('Requested', values);
        console.log('q1_get_req_url sql query completed successfully!');
        return;
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
       * Update the database
       */
      // q1 POST FEEDBACKS
      if (req.url === q1_post_req_url) {
         pool.query(
          q1_post_sql_query,
          [
            values[q1_post_sql_query_values[0]],
            values[q1_post_sql_query_values[1]],
            values[q1_post_sql_query_values[2]],
            values[q1_post_sql_query_values[3]],
          ],
          function (err) {
            if (err) {
              console.error('Error in q1_post_req_url sql query: ' + err.stack);
              return;
            }

            console.log('q1_post_req_url sql query completed successfully!');
            return;
          }
        );
      }
    });
  }
});

/**
 * Listen on port
 */
server.listen(port);
console.log(`Server for Mysql is running on port ${port}...`);
