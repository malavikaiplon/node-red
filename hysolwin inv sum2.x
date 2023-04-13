[
    {
        "id": "202746a15c1b5e18",
        "type": "function",
        "z": "f2584ebd4d8b04a8",
        "name": "multiple measurement points",
        "func": "\nfor (var i = 0; i < msg.payload.length; i++) {\n    var inv_sum = msg.payload[i].inv_sum\n    var time = new Date(msg.payload[i].TIME).getTime()\n    var obj = {};\n    obj.payload =\n\n        [\n            {\n                measurement: \"INV_SUM1\",\n\n                fields: {\n\n                    value: inv_sum\n                },\n                tags: {\n                \n\n                },\n\n                timestamp: time\n            }\n        ];\n\n    //plantObj.push(obj)\n    node.send(obj);\n}\n\n//msg.payload = plantObj\n\n//return msg;\nreturn null;\n",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 720,
        "y": 880,
        "wires": [
            [
                "f99d8c4af31870b0"
            ]
        ]
    },
    {
        "id": "b14954fb859aa1fa",
        "type": "cronplus",
        "z": "f2584ebd4d8b04a8",
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
                "payloadType": "default",
                "payload": "",
                "expressionType": "cron",
                "expression": "0 */5 * * * *",
                "location": "",
                "offset": "0",
                "solarType": "all",
                "solarEvents": "sunrise,sunset"
            }
        ],
        "x": 180,
        "y": 640,
        "wires": [
            [
                "20ba7bbedd8c5226"
            ]
        ]
    },
    {
        "id": "f99d8c4af31870b0",
        "type": "influxdb batch",
        "z": "f2584ebd4d8b04a8",
        "influxdb": "c0dc6fb5c257728c",
        "precision": "",
        "retentionPolicy": "",
        "name": "",
        "database": "database",
        "precisionV18FluxV20": "ms",
        "retentionPolicyV18Flux": "",
        "org": "microgridfivelakeasia",
        "bucket": "hysolwin",
        "x": 1020,
        "y": 880,
        "wires": []
    },
    {
        "id": "9c396b8e25ac45e6",
        "type": "function",
        "z": "f2584ebd4d8b04a8",
        "name": "function 115",
        "func": "\nvar plant = msg.payload.plant;\n//var iid = msg.payload.iid;\nvar device = msg.payload.device;\nvar field = msg.payload.field;\nvar measurement = msg.payload.measurement;\nvar factor = msg.payload.factor;\n\nvar $today = new Date();\nvar d = new Date($today);\nd.setDate($today.getDate()-10);\nd.setHours(0, 0, 0, 0);\nvar d1 = new Date($today);\nvar tstart = new Date(d).toISOString();\nvar tend = new Date(d1).toISOString();\n\n\n\n//var q = ' from(bucket: \"hysolwin\") |> range(start:-10d)  |>filter(fn: (r)=>r[\"_measurement\"]== \\\"' + measurement + '\\\")|>filter(fn:(r)=>r[\"p\"]== \\\"' + plant + '\\\")|>filter(fn:(r)=>r[\"dt\"]== \\\"' + device + '\\\")|>filter(fn:(r)=>r[\"f\"]== \\\"' + field + '\\\") |> aggregateWindow(every: 5m, fn: last, createEmpty: false)|>yield(name:\"last\")'\nvar q = ' from(bucket: \"hysolwin\")|> range(start: -10d) |> filter(fn: (r) => r[\"_measurement\"] == \"v\") |> filter(fn: (r) => r[\"p\"] == \\\"' + plant + '\\\") |> filter(fn: (r) => r[\"d\"] == \\\"' + device + '\\\") |> filter(fn: (r) => r[\"f\"] == \\\"' + field +'\\\") |> filter(fn: (r) => r[\"_field\"] == \"value\")  |> aggregateWindow(every: 5m,fn: last,)|> fill(column: \"_value\", usePrevious: true) |> yield(name: \"last\")'\n\nmsg.query = q\n//msg.payload={d,d1}\nreturn msg;\n",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 510,
        "y": 720,
        "wires": [
            [
                "a5a394a6d710e783"
            ]
        ]
    },
    {
        "id": "25480b3f5090c831",
        "type": "csv",
        "z": "f2584ebd4d8b04a8",
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
        "x": 370,
        "y": 720,
        "wires": [
            [
                "9c396b8e25ac45e6"
            ]
        ]
    },
    {
        "id": "20ba7bbedd8c5226",
        "type": "template",
        "z": "f2584ebd4d8b04a8",
        "name": "CSV data",
        "field": "payload",
        "fieldType": "msg",
        "format": "handlebars",
        "syntax": "mustache",
        "template": "plant,measurement,iid,device,field,factor\nhysolwin,v,5231,INV01,TOTAL_INV_EAE_DAY,1.0\nhysolwin,v,5231,INV22,TOTAL_INV_EAE_DAY,1.0\nhysolwin,v,5231,INV08,TOTAL_INV_EAE_DAY,1.0\nhysolwin,v,5231,INV14,TOTAL_INV_EAE_DAY,1.0",
        "output": "str",
        "x": 240,
        "y": 720,
        "wires": [
            [
                "25480b3f5090c831"
            ]
        ]
    },
    {
        "id": "a5a394a6d710e783",
        "type": "influxdb in",
        "z": "f2584ebd4d8b04a8",
        "influxdb": "c0dc6fb5c257728c",
        "name": "hysolwin",
        "query": "",
        "rawOutput": false,
        "precision": "",
        "retentionPolicy": "",
        "org": "microgridfivelakeasia",
        "x": 700,
        "y": 720,
        "wires": [
            [
                "b94488143284fa59"
            ]
        ]
    },
    {
        "id": "3ba055c71fd1e474",
        "type": "debug",
        "z": "f2584ebd4d8b04a8",
        "name": "",
        "active": true,
        "tosidebar": true,
        "console": false,
        "tostatus": false,
        "complete": "false",
        "statusVal": "",
        "statusType": "auto",
        "x": 1130,
        "y": 720,
        "wires": []
    },
    {
        "id": "b94488143284fa59",
        "type": "join",
        "z": "f2584ebd4d8b04a8",
        "name": "",
        "mode": "auto",
        "build": "object",
        "property": "payload",
        "propertyType": "msg",
        "key": "topic",
        "joiner": "\\n",
        "joinerType": "str",
        "accumulate": "false",
        "timeout": "",
        "count": "",
        "reduceRight": false,
        "x": 850,
        "y": 720,
        "wires": [
            [
                "01bc2d9d9ed192e7"
            ]
        ]
    },
    {
        "id": "01bc2d9d9ed192e7",
        "type": "function",
        "z": "f2584ebd4d8b04a8",
        "name": "function 9",
        "func": "let plantObj\n\nplantObj = []\n\n//for (var j = 0; j < msg.payload[0].length; j++)\nfor (var i = 1; i < msg.payload[0].length; i++)\n// for (var k = 0; k < msg.payload[2].length; k++) \n//for (var l = 0; k < msg.payload[3].length; l++) \n{\n    var time0 = (msg.payload[0][i]._time).slice(0,16)\n    var time1 = (msg.payload[1][i]._time).slice(0,16)\n    var time2 = (msg.payload[2][i]._time).slice(0,16)\n    var time3 = (msg.payload[3][i]._time).slice(0,16)\n    var inv01 = msg.payload[0][i]._value\n    var inv22 = msg.payload[1][i]._value\n    var inv08 = msg.payload[2][i]._value\n    var inv14 = msg.payload[3][i]._value\n\n    if ((time0 == time1 && time2 && time3)) {\n        {\n            var inv_sum = inv01 + inv22 + inv08 + inv14\n\n            // if (inv01&&inv22&&inv08&&inv14== \"null\")\n\n            //  {inv_sum=\"null\"}\n            //node.send(obj);\n            var obj = {\n                TIME: msg.payload[0][i]._time,time0,\n                inv01,\n                inv08,\n                inv14,\n                inv22,\n                inv_sum\n\n            }\n\n            plantObj.push(obj)\n        }\n    }\n}\nmsg.payload = plantObj\n//return null;\nreturn msg;",
        "outputs": 1,
        "noerr": 0,
        "initialize": "",
        "finalize": "",
        "libs": [],
        "x": 980,
        "y": 720,
        "wires": [
            [
                "3ba055c71fd1e474",
                "202746a15c1b5e18"
            ]
        ]
    },
    {
        "id": "3464d098fc7cccc9",
        "type": "catch",
        "z": "f2584ebd4d8b04a8",
        "name": "",
        "scope": [
            "f99d8c4af31870b0"
        ],
        "uncaught": false,
        "x": 590,
        "y": 1020,
        "wires": [
            []
        ]
    },
    {
        "id": "c0dc6fb5c257728c",
        "type": "influxdb",
        "hostname": "127.0.0.1",
        "port": "8086",
        "protocol": "http",
        "database": "database",
        "name": "mglasia",
        "usetls": false,
        "tls": "c563e3c6072c32be",
        "influxdbVersion": "2.0",
        "url": "http://mglasia5.influx.svc.cluster.local",
        "rejectUnauthorized": true
    },
    {
        "id": "c563e3c6072c32be",
        "type": "tls-config",
        "name": "",
        "cert": "",
        "key": "",
        "ca": "",
        "certname": "",
        "keyname": "",
        "caname": "",
        "servername": "",
        "verifyservercert": false,
        "alpnprotocol": ""
    }
]
