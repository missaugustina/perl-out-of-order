perl-out-of-order
=================

Sample code for my YAPC::NA talk "Perl Out Of Order"

The application presented is a simple Mojo::Lite app that generates a report. This report is generated by combining data from 2 HTTP requests with a long running SQL query. The goal of this project is to show how to make small architectural improvements to web applications, including how to identify and troubleshoot specific bottlenecks.

## Setup Instructions
### Database
This project was initially set up using Postgres. You can also use a different Database Server.

#### Instructions for setup with Postgres
This assumes you already have Postgres installed and configured.

1. Create a new user called poo and set the password to "pooiscool": `sudo -u postgres createuser -D -A -P poo`
1. Create a new database called poo for the poo user you just created: `sudo -u postgres createdb -O poo poo`
1. Create a new file called .pgpass in your home directory, or append the following line to it: `localhost:5432:poo:poo:password`
1. You may need to edit connection permissions if there are any client connectivity issues: 
  1. Edit `/etc/postgresql/9.1/main/pg_hba.conf` Change "peer" to "md5" on the line for "local" 
  1. Restart PostgreSQL - `sudo /etc/init.d/postgresql restart`
1. Load the schema in the 'sql' directory: `psql -U poo -d poo -a -f 01_poo.sql`

You now have a database called "poo" with the schema, data, and some initial reports inserted. One thing to note, the images table is created as an empty table and the initial reports do not have real image data. Due to the increased size of the database, the images are not included in the schema. The images are located in the support folder and can be loaded into the database using a script in the same folder. To run it, use the following command: `perl load_images_into_db.pl shutterstock_images`

Please note that the images are licensed stock images provided courtesy of Shutterstock. The use of these images is solely limited to use with this sample application. The images may not be reused nor redistributed. If you would like to reuse or redistribute these images, feel free to visit shutterstock.com for licensing details.

The test data is provided from the samples on the PG Foundry website: http://pgfoundry.org/projects/dbsamples/ I modified the first names so they would have real names instead of encoded ones, just for demonstration purposes (I thought it might look nicer).

### Rabbitmq
I installed rabbitmq-server through apt-get. I also recommend enabling the RabbitMQ administration plugin that lets you manage RMQ through a web browser.

The application just uses the default guest/guest configuration. Make sure you add guest to the '/' vhost.

## Running the Applications
Run the main.pl files in the bin directory in each version of the application. See Mojolicious docs for the different ways to run Mojolicious apps. For the http services, run support/http_services.pl. Make sure you run this on a different port than the main.pl applications.

* original - the original version of the application with no improvements.
* async - the version with asyncronous HTTP requests added.
* workerqueue - the version with worker-queue support added. To run this, you'll also need to run the worker script, also located in the bin directory.
