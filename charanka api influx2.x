[
    {
        "id": "28015afcd02899f0",
        "type": "influxdb in",
        "z": "d542d02f57c3a7d6",
        "influxdb": "c006a6cbdf4a6746",
        "name": "charanka read",
        "query": "",
        "rawOutput": false,
        "precision": "",
        "retentionPolicy": "",
        "org": "largeutilitylakeasia",
        "x": 720,
        "y": 160,
        "wires": [
            [
                "59b7e4e9aabfbfec"
            ]
        ]
    },
    {
        "id": "408a53a8e015255a",
        "type": "cronplus",
        "z": "d542d02f57c3a7d6",
        "name": "",
        "outputField": "payload",
        "timeZone": "",
        "persistDynamic": false,
        "commandResponseMsgOutput": "output1",
        "outputs": 1,
        "options": [
            {
                "name": "schedule1",
                "topic": "topic1",
                "payloadType": "date",
                "payload": "",
                "expressionType": "cron",
                "expression": "0 */10 * * * *",
                "location": "",
                "offset": "0",
                "solarType": "all",
                "solarEvents": "sunrise,sunset"
            }
        ],
        "x": 100,
        "y": 160,
        "wires": [
            [
                "20ba7bbedd8c5226"
            ]
        ]
    },
    {
        "id": "9c396b8e25ac45e6",
        "type": "function",
        "z": "d542d02f57c3a7d6",
        "name": "function 115",
        "func": "var plant = msg.payload.plant; \n//var iid = msg.payload.iid;\nvar device = msg.payload.device;\nvar field = msg.payload.field;\nvar measurement = msg.payload.measurement;\nvar factor = msg.payload.factor;\n\n var $today = new Date();\n var d = new Date($today);\n d.setDate($today.getDate());\n d.setHours(0,0,0,0);\n var d1=new Date($today);\n var tstart=new Date(d).toISOString();\n var tend= new Date(d1).toISOString();\n\n\n\n\nvar q = ' from(bucket: \"kiran\") |> range(start: ' + tstart + ')  |>filter(fn: (r)=>r[\"_measurement\"]== \\\"' + measurement + '\\\")|>filter(fn:(r)=>r[\"p\"]== \\\"' + plant + '\\\")|>filter(fn:(r)=>r[\"dt\"]== \\\"' + device + '\\\")|>filter(fn:(r)=>r[\"f\"]== \\\"' + field + '\\\")|>filter(fn:(r)=>r[\"_field\"]==\"value\")|> map(fn: (r) => ({r with _value: r._value /  ' + factor +' }))  |> aggregateWindow(every: 10m, fn: last, createEmpty: false)|>yield(name:\"last\")'\n//var q = ' from(bucket: \"techniquesolar\")|> range(start: ' + tstart + ', stop: ' + tend + ') |> filter(fn: (r) => r[\"_measurement\"] == \"v\") |> filter(fn: (r) => r[\"p\"] == \\\"'+plant+'\\\") |> filter(fn: (r) => r[\"d\"] == \\\"'+device+'\\\") |> filter(fn: (r) => r[\"f\"] == \\\"'+field+'\\\") |> filter(fn: (r) => r[\"_field\"] == \"value\") |> yield(name: \"last\")'\n\nmsg.query = q\n//msg.payload={d,d1}\nreturn msg;\n\n\n\n\n",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 550,
        "y": 160,
        "wires": [
            [
                "28015afcd02899f0"
            ]
        ]
    },
    {
        "id": "25480b3f5090c831",
        "type": "csv",
        "z": "d542d02f57c3a7d6",
        "name": "",
        "sep": ",",
        "hdrin": true,
        "hdrout": "once",
        "multi": "one",
        "ret": "\\n",
        "temp": "",
        "skip": "0",
        "strings": false,
        "include_empty_strings": "",
        "include_null_values": "",
        "x": 410,
        "y": 160,
        "wires": [
            [
                "9c396b8e25ac45e6"
            ]
        ]
    },
    {
        "id": "59b7e4e9aabfbfec",
        "type": "join",
        "z": "d542d02f57c3a7d6",
        "name": "",
        "mode": "auto",
        "build": "object",
        "property": "payload",
        "propertyType": "msg",
        "key": "topic",
        "joiner": "\\n",
        "joinerType": "str",
        "accumulate": true,
        "timeout": "",
        "count": "",
        "reduceRight": false,
        "reduceExp": "",
        "reduceInit": "",
        "reduceInitType": "",
        "reduceFixup": "",
        "x": 890,
        "y": 160,
        "wires": [
            [
                "05372ec90cbc5082"
            ]
        ]
    },
    {
        "id": "20ba7bbedd8c5226",
        "type": "template",
        "z": "d542d02f57c3a7d6",
        "name": "CSV data",
        "field": "payload",
        "fieldType": "msg",
        "format": "handlebars",
        "syntax": "mustache",
        "template": "plant,measurement,device,field,factor\ncharanka,v,INV,EDC_DAY,1.0\ncharanka,v,INV,EAE_DAY,1.0\n\n\n\n",
        "output": "str",
        "x": 280,
        "y": 160,
        "wires": [
            [
                "25480b3f5090c831"
            ]
        ]
    },
    {
        "id": "08e100d974cffd3b",
        "type": "debug",
        "z": "d542d02f57c3a7d6",
        "name": "debug 133",
        "active": true,
        "tosidebar": true,
        "console": false,
        "tostatus": false,
        "complete": "false",
        "statusVal": "",
        "statusType": "auto",
        "x": 1110,
        "y": 220,
        "wires": []
    },
    {
        "id": "e52cbc1abef1469a",
        "type": "function",
        "z": "d542d02f57c3a7d6",
        "name": "set_flow",
        "func": "msg.payload = flow.get(\"inv_api\")\n\nreturn msg;\n",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 620,
        "y": 380,
        "wires": [
            [
                "2f2fc152d14ea2a3"
            ]
        ]
    },
    {
        "id": "24eccc7e57b63495",
        "type": "http response",
        "z": "d542d02f57c3a7d6",
        "name": "",
        "statusCode": "",
        "headers": {
            "content-type": "application/json"
        },
        "x": 910,
        "y": 380,
        "wires": []
    },
    {
        "id": "2f2fc152d14ea2a3",
        "type": "json",
        "z": "d542d02f57c3a7d6",
        "name": "",
        "property": "payload",
        "action": "str",
        "pretty": false,
        "x": 770,
        "y": 380,
        "wires": [
            [
                "24eccc7e57b63495",
                "1c517274020140fe"
            ]
        ]
    },
    {
        "id": "05372ec90cbc5082",
        "type": "function",
        "z": "d542d02f57c3a7d6",
        "name": "function 116",
        "func": "let plantObj\nplantObj = []\n\n\nfor (var i = 0; i < msg.payload[0].length; i++)\n{\n    var dctime = new Date(msg.payload[0][i]._time).getTime();\n     var actime = new Date(msg.payload[1][i]._time).getTime();\n    //var time3 = new Date(msg.payload[2][i]._time).getTime();\n    //var httime = new Date(msg.payload[3][i].time).getTime(); \n  var number = msg.payload[0][i].d.split(\"INV\")\n  var date = new Date().toISOString().slice(0, 10);\n  var time = new Date(dctime).toLocaleString('en-GB', { hour12: false, timeZone: 'Asia/Kolkata' });\n  var time_stamp = date + time.slice(10, 20)\n  var time2 = time_stamp.split(\",\")\n  if (i != 0){\n    var energy_input_dc_kwh_units = Number(((msg.payload[0][i]._value) - (msg.payload[0][i - 1]._value)).toFixed(2))\n    var energy_output_ac_kwh_units = Number(((msg.payload[1][i]._value) - (msg.payload[1][i - 1]._value)).toFixed(2))\n  }\n  else{\n    energy_input_dc_kwh_units=0\n    energy_output_ac_kwh_units=0\n  }\n  if (dctime == actime)\n  {\n      var energy_input_dc_kwh_reading = msg.payload[0][i]._value\n      var d = msg.payload[0][i].d.split(\"INV\")\n      var energy_output_ac_kwh_reading = msg.payload[1][i]._value\n      var ht_panel_ac_kwh_reading = \"\"\n      var ht_panel_ac_kwh_units = \"\"\n\n      var captivel_consumption_ac_kwh_reading = \"\"\n      var captivel_consumption_ac_kwh_units = \"\"\n      var plant_code = \"SEPL\"\n\nvar obj={\n  time2,\n  number,\n  energy_input_dc_kwh_reading,\n  energy_input_dc_kwh_units,\n  energy_output_ac_kwh_reading,\n  energy_output_ac_kwh_units,\n  ht_panel_ac_kwh_reading,\n  ht_panel_ac_kwh_units,\n  captivel_consumption_ac_kwh_reading,\n  captivel_consumption_ac_kwh_units,\n  plant_code\n \n}\n  }\nplantObj.push(obj)  \n}\n \nmsg.payload =plantObj\n\n\nreturn msg;",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 1030,
        "y": 160,
        "wires": [
            [
                "8576f1bc3cc58b2a"
            ]
        ]
    },
    {
        "id": "8576f1bc3cc58b2a",
        "type": "function",
        "z": "d542d02f57c3a7d6",
        "name": "function 14",
        "func": "let plantObj\n\nplantObj = []\nfor (var i = 0; i < msg.payload.length; i++) \n{\n    var time_stamp = msg.payload[i].time2[0] + msg.payload[i].time2[1]\n    //.toLocaleString(undefined, { timeZone: 'Asia/Kolkata' })\n    var inverter_number = msg.payload[i].number[0] + msg.payload[i].number[1]\n    \n    var energy_input_dc_kwh_reading = (msg.payload[i].energy_input_dc_kwh_reading).toString()\n    var energy_input_dc_kwh_units = (msg.payload[i].energy_input_dc_kwh_units).toString()\n    var energy_output_ac_kwh_reading = (msg.payload[i].energy_output_ac_kwh_reading).toString()\n    var energy_output_ac_kwh_units = (msg.payload[i].energy_output_ac_kwh_units).toString()\n\n    var ht_panel_ac_kwh_reading = msg.payload[i].ht_panel_ac_kwh_reading\n    var ht_panel_ac_kwh_units = msg.payload[i].ht_panel_ac_kwh_units\n\n    var captivel_consumption_ac_kwh_reading = msg.payload[i].captivel_consumption_ac_kwh_reading\n    var captivel_consumption_ac_kwh_units = msg.payload[i].captivel_consumption_ac_kwh_units\n    var plant_code = msg.payload[i].plant_code\n    \n\n\n    var obj = {\n       \n        time_stamp,\n        inverter_number,\n        energy_input_dc_kwh_reading,\n        energy_input_dc_kwh_units,\n        energy_output_ac_kwh_reading,\n        energy_output_ac_kwh_units,\n        ht_panel_ac_kwh_reading,\n        ht_panel_ac_kwh_units,\n        captivel_consumption_ac_kwh_reading,\n        captivel_consumption_ac_kwh_units,\n        plant_code\n\n    }\n\n\nplantObj.push(obj)\n   }\nmsg.payload = plantObj\nflow.set(\"inv_api\", msg.payload);\n\nreturn msg;",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 1190,
        "y": 160,
        "wires": [
            [
                "08e100d974cffd3b"
            ]
        ]
    },
    {
        "id": "1c517274020140fe",
        "type": "debug",
        "z": "d542d02f57c3a7d6",
        "name": "debug 280",
        "active": false,
        "tosidebar": true,
        "console": false,
        "tostatus": false,
        "complete": "false",
        "statusVal": "",
        "statusType": "auto",
        "x": 950,
        "y": 340,
        "wires": []
    },
    {
        "id": "6dd4692bcc90af75",
        "type": "http in",
        "z": "d542d02f57c3a7d6",
        "name": "",
        "url": "/lulasia/charankaAPI",
        "method": "get",
        "upload": false,
        "swaggerDoc": "",
        "x": 390,
        "y": 380,
        "wires": [
            [
                "e52cbc1abef1469a"
            ]
        ]
    },
    {
        "id": "c006a6cbdf4a6746",
        "type": "influxdb",
        "hostname": "http://34.93.63.75",
        "port": "8086",
        "protocol": "http",
        "database": "database",
        "name": "",
        "usetls": false,
        "tls": "",
        "influxdbVersion": "2.0",
        "url": "http://lulasia.influx.svc.cluster.local",
        "rejectUnauthorized": true
    }
]
