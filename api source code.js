const express = require('express');
const app = express();
const swaggerUi = require('swagger-ui-express')
swaggerDocument = require('./Fleet_Swagger.json');
const { InfluxDB, Point } = require('@influxdata/influxdb-client');
const { Client } = require('pg');
const bodyParser = require('body-parser');
const fs = require('fs');
const { Allow_Query } = require('assert');
const { time } = require('console');

const filePath = './config.json';
app.use(express.json());
app.use(express.urlencoded({ extended: true }))

// Read the content of the JSON file
fs.readFile(filePath, 'utf8', (err, data) => {
	if (err) {
		console.error('Error reading the file:', err);
		return;
	}
	const config = JSON.parse(data);
	let FLEET = config.FLEET
    let Allow_Query;
	let config_array;
	let array=[]
	let time;
	// feed PostgreSQL server info below
	const pool = new Client({
		user: config.DB_USER,
		host: config.DB_HOST,
		database: config.DB_NAME,
		password: config.DB_PASS,
		port: config.DB_PORT

	});
	pool.connect((err) => {
		if (err) {
			console.error('connection error', err.stack);
		} else {
			console.log('connected to postgres DB');
		}

		// Protected API endpoint
		app.get(`/${FLEET}`, async (req, res) => {
			
			let result = []
			let fleet = req.query.fleet
			let gateway_id = req.query.gateway_id
			let device = req.query.device
			let field = req.query.field
			let block = req.query.block
			let plant = req.query.plant
			let ZoneInfo = parseInt(req.query.ZoneInfo)
			let start_time = req.query.start_time
			let stop_time = req.query.stop_time
			TABLE = config.TABLE

// Function to compare values
function compareValues(config,plant,block, gateway_id, device, field) {
    for (const node of config.cumulative_nodes) {
		if (node.browsename === plant){
        for (const nodeField of node.fields) {
            if (nodeField.field === field) {
                config_array=[]
                for (const filter of nodeField.uniqueFilter) {
                    config_array.push(filter)
                   
                } 
                    if (
                        (config_array[0].key === "b" && config_array[0].value === block) &&
                        (config_array[1].key === "iid"&& config_array[1].value == gateway_id) &&
                        (config_array[2].key === "d" && config_array[2].value === device) &&
                        (config_array[3].key === "f" && config_array[3].value === field)
                    ) {
                        Allow_Query=true
                        console.log(`Match found Allowing Query`);
						config_array.push(nodeField)
						console.log(config_array)
                        break;
                    } else {
                        Allow_Query=false
                        console.log(`Match not found`);
                        

                    }
                }
            }
        }
    }
}

// Compare values
compareValues(config, plant,block, gateway_id, device, field);
if(Allow_Query==true)
{
			pool.query(`SELECT * FROM ${TABLE} WHERE FLEET = $1`, [fleet], (error, results) => {

				if (error) {
					console.error(error);
					return;
				}
				let org_url = results.rows[0].url;
				let org_token = results.rows[0].token;
				let org_name = results.rows[0].org;
				let fleet = results.rows[0].fleet;

				// Call the function and pass the values
				processDbCredentials(fleet, org_url, org_token, org_name);
			});

			function processDbCredentials(fleet, org_url, org_token, org_name) {
				console.log("info fetched from table")

				{
					let measurement = config.measurement;

					let influx = new InfluxDB({
						url: org_url,
						token: org_token
					})
					let org = org_name
					let Time_Range = req.query.Time_Range
					if (!Time_Range) {
						if (start_time) {
							const start_timestamp = new Date(start_time);
							const start_timestamp1 = start_timestamp.getTime();
							let StartTime1 = new Date((start_timestamp1 - ZoneInfo)).toISOString().slice(0, 19);
							let StartTime = StartTime1 + 'Z';

						}
						console.log(stop_time)
						if (stop_time) {
							console.log("stop", stop_time)
							const stop_timestamp = new Date(stop)
							const stop_timestamp1 = stop_timestamp.getTime();
							let StopTime1 = new Date((stop_timestamp1 - ZoneInfo)).toISOString().slice(0, 19);
							let StopTime = StopTime1 + 'Z';

						}

					}
					const queryApi = influx.getQueryApi(org)

					if (Time_Range) {
						fluxQuery = `from(bucket:"${fleet}") |> range(start: ${Time_Range}) |> filter(fn: (r) => r["_measurement"] == "${measurement}")|> filter(fn: (r) => r["iid"] == "${gateway_id}")|> filter(fn: (r) => r["bd"] == "${plant}")|> filter(fn: (r) => r["b"] == "${block}")|> filter(fn: (r) => r["d"] == "${device}")|> filter(fn: (r) => r["f"] == "${field}")|> filter(fn: (r) => r["_field"] == "value")  |> yield(name: "last")`;
					} else {
						fluxQuery = `from(bucket:"${fleet}")  |> range(start: ${StartTime}, stop: ${StopTime}) |> filter(fn: (r) => r["_measurement"] == "${measurement}")|> filter(fn: (r) => r["iid"] == "${gateway_id}")|> filter(fn: (r) => r["bd"] == "${plant}")|> filter(fn: (r) => r["b"] == "${block}")|> filter(fn: (r) => r["d"] == "${device}")|> filter(fn: (r) => r["f"] == "${field}")|> filter(fn: (r) => r["_field"] == "value")  |> yield(name: "last")`;
					}

					console.log(new Date(), fluxQuery);
					queryApi.queryRows(fluxQuery, {
						next(row, tableMeta) {
							o = tableMeta.toObject(row);
							const date = new Date(o._time);
							const timestamp = date.getTime();
							time = new Date(timestamp + ZoneInfo).toISOString();
							let influxValue=o._value
							//array.push(Array(`time:${s},id:${o.iid},b:${o.b},d:${o.d},f:${o.f},value:${o._value}`))
							
							array.push(time,influxValue)

						},
						error(error) {
							console.log('QUERY FAILED', error)
						},
						complete: () => {
							const final = {
								date: time.slice(0,10),
								datapoints: array,
								"id": "639282b19586988f1b8bb183",
    							"deviceId": "a8af83e4-1462-11ec-a4c6-960000a1d181",
							    "deviceType": "Datasource",
							    "name": config_array[4]['requested_nodeid'],
 							    "unit": 'kwh'
							};
							result.push(final);
							res.send(result);
						}
					})
				}

			}
		
		}
		else{
			res.send("you are not permitted for this query")
		}
		});

		// Route to obtain the access token
		app.post('/Access_Token', async (req, res) => {

			const client_id = req.body.client_id
			const client_secret = req.body.client_secret
			const username = req.body.username
			const password = req.body.password

			// Define the URL where you want to obtain the access token
			const data = new URLSearchParams({
				client_id: client_id,
				username: username,
				password: password,
				grant_type: 'password',
				client_secret: client_secret,
			});

			const config = {
				headers: {
					'Content-Type': 'application/x-www-form-urlencoded',
				},
			};
			const url = config.KEYCLOAK_URL;

			axios.post(url, data, config)
				.then((response) => {
					res.send(response.data)
					console.log('Access Token Generated');
				})
				.catch((error) => {
					console.error('Error:', error.data);
				})
		});
		app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
		// Start the server
		const FLEET_PORT = config.FLEET_PORT
		app.listen(FLEET_PORT, () => {
			console.log('Server started on port', FLEET_PORT);
		});

	})
});
