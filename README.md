Kids reading - word, sentence and fun

#App 


#Installation
Our provided APIs are implemented with vapor and swift and using mongodb or postgreSQL


## Swift and Vapor

todo

## install local postgreSQL database on Mac

###install Postgres.App on Mac
- download from http://postgresapp.com/, install in Applications and run
- see the icon ![Image of Postgres.App](./images/install/Postgres.App.png) and configure
- install postgreSQL locally on Mac. This is needed because vapor - swift code needs C-headers from local Postgres installation

```bash
brew install postgresql
brew link postgresql

//run the following lines if NOT using Postgres.App
//start
brew services start postgresql

//stop
brew services stop postgresql
```
- you do not need to start postgresql if you have Postgres.App running
- for further help see https://github.com/vapor/postgresql

###configure Postgres access in vapor using Fluent
- add postgresql-provider in vapor packages dependencies
- modify Package.swift

```swift
let package = Package(
    ...
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/vapor/postgresql-provider", majorVersion: 1)
    ],
    ...
)
```
- close Xcode
- run vapor xcode to generate and download the needed ressources

```bash
cd vapor/kids-reading-server
vapor xcode
```
- you will see the output

```bash
Fetching Dependencies [Done]
Generating Xcode Project [Done]
Select the `App` scheme to run.
Open Xcode project?
y/n>y
```

- type y to open automatically Xcode
- modify main.swift to add provider

```swift
import VaporPostgreSQL

let drop = Droplet()
drop.preparations.append(Post.self)
try drop.addProvider(VaporPostgreSQL.Provider.self)
```

- add configuration file  in Config/secrets/postgresql.json

```JSON
{
    "host": "127.0.0.1",
    "user": "<your login name on mac>",
    "password": "",
    "database": "<your login name on mac>",
    "port": 5432
}
```

## install local mongodb database
install your mongodb locally on your local machine via [mongodb website](https://www.mongodb.com/) or use apt-get to download any linux packages. Read mongodb download support material how to install on your infrastructure.
every mongdb needs a "data" directory. Out "data" directory for mongodb is already a part of .gitignore.

```bash
cd vapor
mkdir data
cd data
mongod --dbpath `pwd` --port 27018

//port 27018 just to not mess up with any other default 27017 mongodb port
//our database we are connecting to is named "kids-reading"
````

###configure mongodb access in vapor using Fluent

- modify Package.swift

```swift
let package = Package(
    ...
    dependencies: [
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 1, minor: 1),
        .Package(url: "https://github.com/vapor/mongo-provider.git", majorVersion: 1, minor: 1)
    ],
    ...
)
```
- close Xcode
- run vapor xcode to generate and download the needed ressources

```bash
cd vapor/kids-reading-server
vapor xcode
```
- you will see the output

```bash
Fetching Dependencies [Done]
Generating Xcode Project [Done]
Select the `App` scheme to run.
Open Xcode project?
y/n>y
```

- type y to open automatically Xcode
- modify main.swift to add provider

```swift
import VaporMongo
import FluentMongo

let drop = Droplet()
drop.preparations.append(Post.self)
try drop.addProvider(VaporMongo.Provider.self)

```



#  OLD

start another command line / bash to import

```bash
cd rawdata
./run-local.sh any-javascript.js
```

Use the generic "run-local.sh" to call any mongodb javascript file to be executed.
Adapt the run-local.sh if needed to import into your local database. 
"run.sh" script shall only be used to import into our SaaS mongodb on azure - password needed)

Test connection first using local database:
```bash
$ ./run-local.sh test.js
MongoDB shell version: ?.?.?
connecting to: localhost:27018/hackzurich2016-axa
count of customers = 10000
```

Run following script to delete and import all data again - reset

```bash
$ ./run-local.sh import.js
MongoDB shell version: ?.?.?
connecting to: localhost:27018/hackzurich2016-axa
 start collection customers dropping and importing ...
 done. imported 10000 objects
 start collection profiles dropping and importing ...
 done. imported 10000 objects
 start collection trips dropping and importing ...
 done. imported 7 objects
 start collection transactions dropping and importing ...
 done. imported 1100 objects
 start collection trucks dropping and importing ...
 done. imported 388 objects
 start collection cars dropping and importing ...
 done. imported 1789 objects
 start collection insuranceTypes dropping and importing ...
 done. imported 22 objects
 start collection categories dropping and importing ...
 done. imported 23 objects
 start collection risks dropping and importing ...
 done. imported 21 objects
 start collection contacts dropping and importing ...
 done. imported 371 objects
 start collection favorites dropping and importing ...
 done. imported 3 objects
```

use following script files to execute

```bash
$ ./run-local.sh import.js               import all

$ ./run-local.sh import-customer.js      import customers only
$ ./run-local.sh import-profile.js       import profiles  only
$ ./run-local.sh import-favorite.js      import favorites only
$ ./run-local.sh import-no-large.js      import all except large sets

$ ./run-local.sh drop.js                 drop all collections
$ ./run-local.sh count.js                list all counts from any used collection
$ ./run-local.sh test.js                 use to test connection with database
````

## configure local mongodb database

edit the rest-app/app.js file and modify

```js
// uncomment for localhost database
var dbURL = 'localhost:27018/hackzurich2016-axa';
```

##Development support
some features had been developed here to support further locale development or support of hackzurich.

* editing swagger.yaml files for API using local [Swagger Editor](http://swagger.io/swagger-editor/)
* copying automatically swagger.* files to your local distribution to update express
* node monitor to reload automatically if files have been updated
* node debugging tools using [Visual Studio Code](https://code.visualstudio.com/docs#vscode)
* nodejs swagger schema definition generator tool

### Swagger Editor
git repo contains a full instance of the swagger editor "swagger-editor". It is a full nodejs compliant webapplication.
If you are lazy you can use [Swagger Editor online](http://editor.swagger.io/#/) to edit your swagger files

```bash
cd swagger-editor
npm start
```

* your default browser will be automatically opened
* startup time takes a while
* running on http://localhost:8080/#/

### Copy swagger.yaml + swagger.json files
working with localhost or swagger online, the following functions are helping you deploying your swagger.yaml into our hackzurich git repo
* use "File / Import File ..." to load our swagger.yaml from hackzurich2016-axa/rest-app/dist folder

The swagger editor does not allow inplace editing of files because it is running as standalone webserver

* normally files are downloaded into "$HOME/Download" folder
* run the script in hackzurich2016-axa/rest-app/dist folder. This will copy downloaded files into the distribution

```bash
$ cd rest-app/dist
$ ./copySwagger.sh
Listening to changes every 1s in _____/Downloads/swagger.* to move to _____/git/hackzurich2016-axa/rest-app/dist
Sun Aug 14 21:07:41 CEST 2016 - copy swagger.json file to git
Sun Aug 14 21:07:41 CEST 2016 - copy swagger.local.json file to git for localhost
Sun Aug 14 21:07:41 CEST 2016 - copy swagger.yaml file to git
Sun Aug 14 21:07:41 CEST 2016 - copy swagger.local.yaml file to git for localhost
```


### use node monitor to automatically restart node on change
To support a fast edit, compile, test cycle we are using [nodemon](https://www.npmjs.com/package/nodemon). 
Please install it as described and start instead of "npm start"

```bash
$ sudo npm install -g nodemon
$ nodemon -e js,json --watch . --watch routes --exec npm start

//explanations:  
     watch on all changes in file extensions  js, json
     watch on all changes in directory        . & 'routes' 
     restart via command                      npm start

```

interesting to know:

* watch out for compilation errors due to restart!!!!
* from time to time the npm engine is not restarted and node monitor is stucked. Just use "Ctrl-C" several times to stop the npm monitor and start it again.

### node debugging with "Visual Studio Code"
Debugging using "console.log(...)" is very dirty and timeconsuming. Live debugging and stepping into code in real time lets you find bugs much faster. 
I am using [Visual Studio Code](https://code.visualstudio.com/docs#vscode) from Microsoft to edit node applications.

To support debugging within Visual Studio we are using [Debugger for Chrome](https://marketplace.visualstudio.com/items?itemName=msjsdiag.debugger-for-chrome). 
Install it via the IDE at "Extensions" and configure your launcher. See our 'launch.json' settings file in '.vscode' folder (if needed)

* start command "Attach to Process" via the "Debugging" tools to support automatic reloads of ressources with npm
* use "node ./bin/www" process to be attached to
* manage breakpoints within Visual Studio Code
  * use manual breakpoints to halt
  * use [x] "uncaught exceptions" to halt the code :-)
  * use [x] "throwing any exception" to halt too

### node script to generate swagger YAML schema definition
This tools can be used if you have an example JSON result structure to be able to generate a YAML schema definition based on the JSON structure.
the JSON structure can be complex, can contain Arrays, object structures and native types (string, float, integer)

The generated YAML schema definition can be copied into swagger-editor or YAML definition files.
The following schema definitions will be created:

* "name"ResultList
* "name"s (multiple form)
* "name" (single form)


```bash
cd rawdata/_schema-generator
node run-generator.js > out.yaml
```

adapt the run-generator.js to run against your own sample.js (here example with risk)
```bash
$ vi run-generator.js

var g = require("./generator");
var s = require("./sample-risk");
g.generator().swagger("Risk", "Risks", s.sample_profiles().object());
```

generate you own sample.js file with the structure

```js
exports.sample_<name> = function () {
    return {
        object: function () {
            return this.jsonObject;
        },
        jsonObject:

// insert your structure here

        {
            _id: "57ac4099402f9292dc3d0820",
            id: "ACCIDENT",
            value: "Accident",
            lineOfBusiness: "Health"
        }

// end your structure

    }
};
```

This will produc the following YAML output

```yaml
  RiskResultList:
    description: result of Risk search used for paging
    type: object
    properties:
      data:
        $ref: '#/definitions/Risks'
      links:
        $ref: '#/definitions/Link'

  Risks:
    type: array
    items:
      $ref: '#/definitions/Risk'

  Risk:
    description: tbd
    type: object
    properties:
      _id:
        description: tbd
        type: string
      id:
        description: tbd
        type: string
      type:
        description: tbd
        type: number
        format: integer
      factor:
        description: tbd
        type: number
        format: float
      value:
        description: tbd
        type: string
      lineOfBusiness:
        description: tbd
        type: string

```




### Links
interesting addional links

* [REST API tutorial - best practices](http://www.restapitutorial.com/httpstatuscodes.html)
* [Mongodb query docu](https://docs.mongodb.com/manual/tutorial/query-documents/)
* [Mongodb nodejs find docu](https://mongodb.github.io/node-mongodb-native/api-generated/collection.html#find)