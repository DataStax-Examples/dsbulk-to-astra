# Loading Data Into Apollo with DataStax Bulk Loader
This example will demonstrate how to load data into Apollo two different ways, from a CSV file or from another Cassandra table

Contributors: [Dave Bechberger](https://github.com/bechbd) based on the work of [Brian Hess](https://github.com/brianmhess)

## Objectives

* To demonstrate how to load data into Apollo from a CSV file or from an existing table in a Cassandra keyspace
  
## Project Layout

* [data.csv](data.csv) - The CSV data to load
* [schema.cql](schema.cql) - The CQL schema used for this example

## How this Sample Works
Loading data into Apollo using DS Bulk is much like loading data into other Cassandra databases with the addition of the requirement to specify the secure database bundle as well as the username and password for the database.

The secure database bundle is specified using the `-b <INSERT PATH>` parameter on the command line. [See here for more details](https://docs.datastax.com/en/dsbulk/doc/dsbulk/reference/driverOptions.html#driverOptions__driverBasicCloudSecureConnectBundle)

The username is specified using the `-u <INSERT USERNAME>` parameter on the command line.  [See here for more details](https://docs.datastax.com/en/dsbulk/doc/dsbulk/reference/driverOptions.html#driverOptions__datastaxJavaDriverAdvancedConnectionAuthProviderUsername)

The password is specified using the `-p <INSERT PASSWORD>` parameter on the command line.  [See here for more details](https://docs.datastax.com/en/dsbulk/doc/dsbulk/reference/driverOptions.html#driverOptions__datastaxJavaDriverAdvancedConnectionAuthProviderPassword)

This example only touches on some of the basic functionality for DS Bulk.  DS Bulk has all the functionality to perform complex loading operations to Apollo as it does to other DSE clusters.  To read about some of those scenarios please check the following links below for more information:

* [DataStax Bulk Loader Documentation](https://docs.datastax.com/en/dsbulk/doc/)
* [DataStax Bulk Loader: Introduction and Loading](https://academy.datastax.com/content/datastax-bulk-loader-introduction-and-loading)
* [DataStax Bulk Loader: More loading](https://academy.datastax.com/content/datastax-bulk-loader-more-loading)
* [DataStax Bulk Loader: Common Settings](https://academy.datastax.com/content/datastax-bulk-loader-common-settings)
* [DataStax Bulk Loader: Counting](https://academy.datastax.com/content/datastax-bulk-loader-counting)

## Setup and Running

### Prerequisites

* DS Bulk v1.4.0 or greater
* An Apollo cluster with the schema ([from schema.cql](schema.cql)) loaded and credential information
    **Note** If you need further instruction on how to obtain the secure database bundle for your Apollo instance then please refer to the documentation located [here](https://docs.datastax.com/en/apollo/aws/doc/dscloud/apollo/dscloudObtainingCredentials.html).
* A Cassandra cluster (optional if you want to load from Cassandra)

### Running

To migrate data into Apollo using DS Bulk you first need to ensure that the target Apollo keyspace has had the schema for the `video_ratings_by_user` table created.  This is done via using the DataStax Developer Studio that is embedded in your Apollo instance.  For more information on how to use the embedded Studio instance please check the documentation located [here](https://docs.datastax.com/en/apollo/aws/doc/dscloud/apollo/dscloudConnectStudio.html).

#### Loading from CSV

Here is an example command that will load the data.csv file into the `video_ratings_by_user` table in your Apollo instance.

**Note** This loads the data from the file stored in the github repo so the machine running this command will need access to the internet.

```
./dsbulk load -url https://raw.githubusercontent.com/DataStax-Examples/dsbulk-csv-to-apollo/master/data.csv -b /path/to/bundle.zip -k <KEYSPACE NAME> -t video_ratings_by_user -u <USERNAME> -p <PASSWORD>
```

#### Loading from an existing Cassandra table

To load data from an existing table in a Cassandra keyspace into Apollo there are two options to accomplish this.

##### Option 1 - Unload and Load in Separate Steps
The first option for loading data from an existing Cassandra cluster into Apollo requires that you unload the data from the Cassandra cluster into a local file and then load the data into Apollo.  The commands to accomplish this look like this:

```
./dsbulk unload -h <CASSANDRA CLUSTER IP> -k <KEYSPACE NAME> -t video_ratings_by_user -url /path/to/file/migrate.csv
./dsbulk load -url /path/to/file/migrate.csv -b /path/to/bundle.zip -k <KEYSPACE NAME> -t video_ratings_by_user -u <USERNAME> -p <PASSWORD>
```

##### Option 2 - Unload and Load by Chaining Steps
The second option for loading data from an existing Cassandra cluster into Apollo requires that you unload the data from the Cassandra cluster and pipe that into a command load the data into Apollo.  This has some advantages as it will run in a single command but it will only run single threaded as it uses stdin/stdout. The commands to accomplish this look like this:

```
./dsbulk unload -h <CASSANDRA CLUSTER IP> -k <KEYSPACE NAME> -t video_ratings_by_user -url /path/to/file/migrate.csv | ./dsbulk load -url /path/to/file/migrate.csv -b /path/to/bundle.zip -k <KEYSPACE NAME> -t video_ratings_by_user -u <USERNAME> -p <PASSWORD>
```

#### Validating the Results
After running any of these commands you should see a result printed to the screen similar to 
```
total | failed | rows/s | p50ms | p99ms | p999ms | batches
  101 |      0 |     94 | 63.92 | 70.25 |  70.25 |   10.10
Operation LOAD_20191113-185907-331567 completed successfully in 0 seconds.
Last processed positions can be found in positions.txt
```

If you would like to check to see that all your data has loaded correctly then you can use the count functionality of DS Bulk to verify that the data has been loaded using the command below:

```
./dsbulk count -b /path/to/bundle.zip -k <KEYSPACE NAME> -t video_ratings_by_user -u <USERNAME> -p 
```

If you were following along with this example you will get a number of `101` rows.



