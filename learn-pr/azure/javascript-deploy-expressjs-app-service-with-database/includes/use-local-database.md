In this unit, set up the local development environment for MongoDB. While it isn't required that you have a local database when using Azure Cosmos DB API for MongoDB, it's a common practice. 

## Local or remote database?

For local development, you can choose to use a locally available MongoDB or create a cloud resource specifically for your development use. Both are valid and each comes with decisions.

* Local MongoDB: Local development allows you to work without a cloud resource, or its authentication requirements. This focuses your development work on the database and code changes. 
* Remote MongoDB: If your code is dependent on the authentication and infrastructure of the database, a remote development server is the best choice. Your security and connectivity to the database would be as necessary as the usage of the database.

## Installing a local MongoDB server

You can use a local MongoDB server as one of the following:

* Install MongoDB on your local computer.
* Use a MongoDB container (with Docker) on your local computer

## Install and run MongoDB locally

You can install MongoDB Community edition locally then connect to the local server from Visual Studio. When you install locally, you may need to start MongoDB manually. You manage all updates and maintenance of the database infrastructure.

## Install and run MongoDB container

The Visual Studio Code **Node.js + MongoDB** dev container allows you to run both the Express.js app and the database in containers. With containers, you don't need to install the dependencies locally because those dependencies are part of the containers. You don't need manage all updates and maintenance of the database infrastructure because that is managed by easy rebuild of the container.

Once the containers are started through Visual Studio Code, you won't need to understand how the containers work in order to develop on top of them Visual Studio Code abstracts and manages the Docker layer for you. 

You can start up the container from Visual Studio Code, with the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension you installed in a previous exercise. 

The dev containers files are available in the `.devcontainer` folder in the sample project. As an added incentive to use the dev containers, the Azure CLI is installed, the ports for both the web app and MongoDB are exposed, and the Visual Studio Code extensions are available in the container.

## Adding MongoDB to an Express.js app

In order to add MongoDB to a Node.js app, such as Express.js, the complete connection requires:

* Connection data: adding the MongoDB connection string, database name and collection name to the app in the `.env` file. The sample project provides the `.env` file for you and the `./.vscode/settings.json` file to ignore the file during deployment. 
* NPM package: Adding an appropriate client npm package, such as **MongoDB** or **mongoose**, to connect to your MongoDB database. This module uses the native [MongoDB driver](https://www.npmjs.com/package/mongodb), specified in the package.json file.  
* JavaScript code: Adding MongoDB API code to your Express.js app. The full MongoDB client code is provided in the [./model/rental.model.js](https://github.com/Azure-Samples/msdocs-javascript-nodejs-server/blob/main/3-Add-cosmosdb-mongodb/model/rental.model.js) file.

## MongoDB connection data

Connection data for this sample app is contained in the `.env` file and includes the following:

* MONGODB_URI_CONNECTION_STRING=mongodb://127.0.0.1:27017
* MONGODB_URI_DATABASE_NAME=js-rentals
* MONGODB_URI_COLLECTION_NAME-rentals
