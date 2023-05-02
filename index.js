const express = require("express");
const app = express();
const bodyParser =  require("body-parser")
const swaggerUi = require('swagger-ui-express'),
 swaggerDocument = require('./swagger.json');
const mysql = require('mysql2');
app.use(bodyParser.json());
//app.use(bodyParser.urlencoded({extended:false}));
// create a connection pool
const pool = mysql.createPool({
    host: '172.17.0.2',
    user: 'root',
    password: 'iplon321',
    database: 'mysql_test',
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
// execute a query
app.get('/table/:tablename', async (req, res) => {
  const tablename  = req.params.tablename;
console.log(tablename)
pool.execute(`SELECT * FROM ${tablename}`, (error, results, fields) => {
  if (error) {
      console.error(error);
      return;
  }
  console.log(results);
  res.send(results)
})
});
app.get('/employee/:id', async (req, res) => {
  const id = req.params.id;
  console.log(id)
pool.execute(`SELECT * FROM employee WHERE id = ${id} `, (error, results, fields) => {
  if (error) {
      console.error(error);
      return;
  }
  console.log(results);
  res.send(results)
})
});
// define data to insert into the table
app.post("/addEmployee", (req, res) => {
const employee = {
  id:parseInt(req.body._id), 
  Name:req.body.name, 
  Team:req.body.Team,
};
console.log(employee)
const params = Object.values(employee).map(value => (value !== undefined ? value : null));
// execute a query to insert data into the table
pool.execute(
  'INSERT INTO employee (id,Name,Team) VALUES (?,?,?)',
  params,
  (error, results, fields) => {
    if (error) {
      console.error(error);
      return;
    }
    console.log('Data inserted successfully');
    res.send("data inserted successfully")
})
});

app.put("/update_employee",(req,res)=>{
  // define the data to update
const employeeupdate = {
  id:parseInt(req.body._id), 
  Name:req.body.name, 
  Team:req.body.Team,
};
pool.execute(
  'UPDATE employee SET Name = ?,Team = ? WHERE id = ?',
  [employeeupdate.Name,  employeeupdate.Team, employeeupdate.id],
  (error, results, fields) => {
    if (error) {
      console.error(error);
      return;
    }
    console.log('Data updated successfully');
    res.send("Data updated successfully")
  })
});
// define the data to delete
// execute a query to delete the data
app.delete("/delete_employee",async(req,res)=>{
  const id =req.query.id;
  console.log(id)
  pool.execute(
  'DELETE FROM employee WHERE id = ?',
  [id],
  (error, results, fields) => {
    if (error) {
      console.error(error);
      return;
    }
    console.log('Data deleted successfully');
    res.send('Data deleted successfully')
  })
});
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));

app.listen(4600,() =>{
    console.log("server started on port 4600");
});